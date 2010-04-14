From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v3] fasync: RCU and fine grained locking
Date: Wed, 14 Apr 2010 21:55:35 +0200
Message-ID: <1271274935.16881.1746.camel@edumazet-laptop>
References: <1271230961.16881.630.camel@edumazet-laptop>
	 <4BC57E7D.9060706@cn.fujitsu.com>
	 <1271257027.16881.1663.camel@edumazet-laptop>
	 <1271259264.16881.1703.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Lai Jiangshan <laijs@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271259264.16881.1703.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is V3 of the patch. This patch is a preliminary work to full RCU
conversion of sock_def_readable() & sock_def_write_space() functions,
called nearly for each packet...

I based it against David net-next-2.6 tree.

Thanks

[PATCH net-next-2.6 v3] fasync: RCU and fine grained locking

kill_fasync() uses a central rwlock, candidate for RCU conversion, to
avoid cache line ping pongs on SMP.

fasync_remove_entry() and fasync_add_entry() can disable IRQS on a short
section instead during whole list scan.

Use a spinlock per fasync_struct to synchronize kill_fasync_rcu() and
fasync_{remove|add}_entry(). This spinlock is IRQ safe, so sock_fasync()
doesnt need its own implementation and can use fasync_helper(), to
reduce code size and complexity.

We can remove __kill_fasync() direct use in net/socket.c, and rename it
to kill_fasync_rcu().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
---
v3: sock_fasync() can use generic fasync_helper(), this gives a nice
cleanup.

v2: As Lai Jiangshan noticed, we need a mutual exclusion between
fasync_{remove|add}_entry() and kill_fasync_rcu().

 fs/fcntl.c         |   66 ++++++++++++++++++++++++--------------
 include/linux/fs.h |   12 +++----
 net/socket.c       |   73 ++++++-------------------------------------
 3 files changed, 59 insertions(+), 92 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 452d02f..0a14074 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -614,9 +614,15 @@ int send_sigurg(struct fown_struct *fown)
 	return ret;
 }
 
-static DEFINE_RWLOCK(fasync_lock);
+static DEFINE_SPINLOCK(fasync_lock);
 static struct kmem_cache *fasync_cache __read_mostly;
 
+static void fasync_free_rcu(struct rcu_head *head)
+{
+	kmem_cache_free(fasync_cache,
+			container_of(head, struct fasync_struct, fa_rcu));
+}
+
 /*
  * Remove a fasync entry. If successfully removed, return
  * positive and clear the FASYNC flag. If no entry exists,
@@ -625,8 +631,6 @@ static struct kmem_cache *fasync_cache __read_mostly;
  * NOTE! It is very important that the FASYNC flag always
  * match the state "is the filp on a fasync list".
  *
- * We always take the 'filp->f_lock', in since fasync_lock
- * needs to be irq-safe.
  */
 static int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
 {
@@ -634,17 +638,22 @@ static int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
 	int result = 0;
 
 	spin_lock(&filp->f_lock);
-	write_lock_irq(&fasync_lock);
+	spin_lock(&fasync_lock);
 	for (fp = fapp; (fa = *fp) != NULL; fp = &fa->fa_next) {
 		if (fa->fa_file != filp)
 			continue;
+
+		spin_lock_irq(&fa->fa_lock);
+		fa->fa_file = NULL;
+		spin_unlock_irq(&fa->fa_lock);
+
 		*fp = fa->fa_next;
-		kmem_cache_free(fasync_cache, fa);
+		call_rcu(&fa->fa_rcu, fasync_free_rcu);
 		filp->f_flags &= ~FASYNC;
 		result = 1;
 		break;
 	}
-	write_unlock_irq(&fasync_lock);
+	spin_unlock(&fasync_lock);
 	spin_unlock(&filp->f_lock);
 	return result;
 }
@@ -666,25 +675,30 @@ static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fa
 		return -ENOMEM;
 
 	spin_lock(&filp->f_lock);
-	write_lock_irq(&fasync_lock);
+	spin_lock(&fasync_lock);
 	for (fp = fapp; (fa = *fp) != NULL; fp = &fa->fa_next) {
 		if (fa->fa_file != filp)
 			continue;
+
+		spin_lock_irq(&fa->fa_lock);
 		fa->fa_fd = fd;
+		spin_unlock_irq(&fa->fa_lock);
+
 		kmem_cache_free(fasync_cache, new);
 		goto out;
 	}
 
+	spin_lock_init(&new->fa_lock);
 	new->magic = FASYNC_MAGIC;
 	new->fa_file = filp;
 	new->fa_fd = fd;
 	new->fa_next = *fapp;
-	*fapp = new;
+	rcu_assign_pointer(*fapp, new);
 	result = 1;
 	filp->f_flags |= FASYNC;
 
 out:
-	write_unlock_irq(&fasync_lock);
+	spin_unlock(&fasync_lock);
 	spin_unlock(&filp->f_lock);
 	return result;
 }
@@ -704,37 +718,41 @@ int fasync_helper(int fd, struct file * filp, int on, struct fasync_struct **fap
 
 EXPORT_SYMBOL(fasync_helper);
 
-void __kill_fasync(struct fasync_struct *fa, int sig, int band)
+/*
+ * rcu_read_lock() is held
+ */
+static void kill_fasync_rcu(struct fasync_struct *fa, int sig, int band)
 {
 	while (fa) {
-		struct fown_struct * fown;
+		struct fown_struct *fown;
 		if (fa->magic != FASYNC_MAGIC) {
 			printk(KERN_ERR "kill_fasync: bad magic number in "
 			       "fasync_struct!\n");
 			return;
 		}
-		fown = &fa->fa_file->f_owner;
-		/* Don't send SIGURG to processes which have not set a
-		   queued signum: SIGURG has its own default signalling
-		   mechanism. */
-		if (!(sig == SIGURG && fown->signum == 0))
-			send_sigio(fown, fa->fa_fd, band);
-		fa = fa->fa_next;
+		spin_lock(&fa->fa_lock);
+		if (fa->fa_file) {
+			fown = &fa->fa_file->f_owner;
+			/* Don't send SIGURG to processes which have not set a
+			   queued signum: SIGURG has its own default signalling
+			   mechanism. */
+			if (!(sig == SIGURG && fown->signum == 0))
+				send_sigio(fown, fa->fa_fd, band);
+		}
+		spin_unlock(&fa->fa_lock);
+		fa = rcu_dereference(fa->fa_next);
 	}
 }
 
-EXPORT_SYMBOL(__kill_fasync);
-
 void kill_fasync(struct fasync_struct **fp, int sig, int band)
 {
 	/* First a quick test without locking: usually
 	 * the list is empty.
 	 */
 	if (*fp) {
-		read_lock(&fasync_lock);
-		/* reread *fp after obtaining the lock */
-		__kill_fasync(*fp, sig, band);
-		read_unlock(&fasync_lock);
+		rcu_read_lock();
+		kill_fasync_rcu(rcu_dereference(*fp), sig, band);
+		rcu_read_unlock();
 	}
 }
 EXPORT_SYMBOL(kill_fasync);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 39d57bc..018d382 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1280,10 +1280,12 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
 
 
 struct fasync_struct {
-	int	magic;
-	int	fa_fd;
-	struct	fasync_struct	*fa_next; /* singly linked list */
-	struct	file 		*fa_file;
+	spinlock_t		fa_lock;
+	int			magic;
+	int			fa_fd;
+	struct fasync_struct	*fa_next; /* singly linked list */
+	struct file		*fa_file;
+	struct rcu_head		fa_rcu;
 };
 
 #define FASYNC_MAGIC 0x4601
@@ -1292,8 +1294,6 @@ struct fasync_struct {
 extern int fasync_helper(int, struct file *, int, struct fasync_struct **);
 /* can be called from interrupts */
 extern void kill_fasync(struct fasync_struct **, int, int);
-/* only for net: no internal synchronization */
-extern void __kill_fasync(struct fasync_struct *, int, int);
 
 extern int __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
 extern int f_setown(struct file *filp, unsigned long arg, int force);
diff --git a/net/socket.c b/net/socket.c
index 35bc198..9822081 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1067,78 +1067,27 @@ static int sock_close(struct inode *inode, struct file *filp)
  *	1. fasync_list is modified only under process context socket lock
  *	   i.e. under semaphore.
  *	2. fasync_list is used under read_lock(&sk->sk_callback_lock)
- *	   or under socket lock.
- *	3. fasync_list can be used from softirq context, so that
- *	   modification under socket lock have to be enhanced with
- *	   write_lock_bh(&sk->sk_callback_lock).
- *							--ANK (990710)
+ *	   or under socket lock
  */
 
 static int sock_fasync(int fd, struct file *filp, int on)
 {
-	struct fasync_struct *fa, *fna = NULL, **prev;
-	struct socket *sock;
-	struct sock *sk;
-
-	if (on) {
-		fna = kmalloc(sizeof(struct fasync_struct), GFP_KERNEL);
-		if (fna == NULL)
-			return -ENOMEM;
-	}
-
-	sock = filp->private_data;
+	struct socket *sock = filp->private_data;
+	struct sock *sk = sock->sk;
 
-	sk = sock->sk;
-	if (sk == NULL) {
-		kfree(fna);
+	if (sk == NULL)
 		return -EINVAL;
-	}
 
 	lock_sock(sk);
 
-	spin_lock(&filp->f_lock);
-	if (on)
-		filp->f_flags |= FASYNC;
-	else
-		filp->f_flags &= ~FASYNC;
-	spin_unlock(&filp->f_lock);
-
-	prev = &(sock->fasync_list);
+	fasync_helper(fd, filp, on, &sock->fasync_list);
 
-	for (fa = *prev; fa != NULL; prev = &fa->fa_next, fa = *prev)
-		if (fa->fa_file == filp)
-			break;
-
-	if (on) {
-		if (fa != NULL) {
-			write_lock_bh(&sk->sk_callback_lock);
-			fa->fa_fd = fd;
-			write_unlock_bh(&sk->sk_callback_lock);
-
-			kfree(fna);
-			goto out;
-		}
-		fna->fa_file = filp;
-		fna->fa_fd = fd;
-		fna->magic = FASYNC_MAGIC;
-		fna->fa_next = sock->fasync_list;
-		write_lock_bh(&sk->sk_callback_lock);
-		sock->fasync_list = fna;
+	if (!sock->fasync_list)
+		sock_reset_flag(sk, SOCK_FASYNC);
+	else
 		sock_set_flag(sk, SOCK_FASYNC);
-		write_unlock_bh(&sk->sk_callback_lock);
-	} else {
-		if (fa != NULL) {
-			write_lock_bh(&sk->sk_callback_lock);
-			*prev = fa->fa_next;
-			if (!sock->fasync_list)
-				sock_reset_flag(sk, SOCK_FASYNC);
-			write_unlock_bh(&sk->sk_callback_lock);
-			kfree(fa);
-		}
-	}
 
-out:
-	release_sock(sock->sk);
+	release_sock(sk);
 	return 0;
 }
 
@@ -1159,10 +1108,10 @@ int sock_wake_async(struct socket *sock, int how, int band)
 		/* fall through */
 	case SOCK_WAKE_IO:
 call_kill:
-		__kill_fasync(sock->fasync_list, SIGIO, band);
+		kill_fasync(&sock->fasync_list, SIGIO, band);
 		break;
 	case SOCK_WAKE_URG:
-		__kill_fasync(sock->fasync_list, SIGURG, band);
+		kill_fasync(&sock->fasync_list, SIGURG, band);
 	}
 	return 0;
 }
