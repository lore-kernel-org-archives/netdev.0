From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 04 Jun 2007 11:45:32 +0200
Message-ID: <E1Hv980-0006gQ-00@dorka.pomaz.szeredi.hu>
References: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753424AbXFDJpz@vger.kernel.org>
In-reply-to: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu> (message from Miklos
	Szeredi on Sat, 02 Jun 2007 23:50:55 +0200)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
> send()+close() on the peer, causing recv() to return zero, even though
> the sent data should be received.
> 
> This happens if the send() and the close() is performed between
> skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():
> 
> process A  skb_dequeue() returns NULL, there's no data in the socket queue
> process B  new data is inserted onto the queue by unix_stream_sendmsg()
> process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
> process A  sk->sk_shutdown is checked, unix_release_sock() returns zero

This is only part of the story.  It turns out, there are other races
involving the garbage collector, that can throw away perfectly good
packets with AF_UNIX sockets in them.

The problems arise when a socket goes from installed to in-flight or
vica versa during garbage collection.  Since gc is done with a
spinlock held, this only shows up on SMP.

The following patch fixes it for me, but it's possibly the wrong
approach.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22-rc2/net/unix/garbage.c
===================================================================
--- linux-2.6.22-rc2.orig/net/unix/garbage.c	2007-06-03 23:58:11.000000000 +0200
+++ linux-2.6.22-rc2/net/unix/garbage.c	2007-06-04 11:39:42.000000000 +0200
@@ -90,6 +90,7 @@
 static struct sock *gc_current = GC_HEAD; /* stack of objects to mark */
 
 atomic_t unix_tot_inflight = ATOMIC_INIT(0);
+DECLARE_RWSEM(unix_gc_sem);
 
 
 static struct sock *unix_get_socket(struct file *filp)
@@ -169,7 +170,7 @@ static void maybe_unmark_and_push(struct
 
 void unix_gc(void)
 {
-	static DEFINE_MUTEX(unix_gc_sem);
+	static DEFINE_MUTEX(unix_gc_local_lock);
 	int i;
 	struct sock *s;
 	struct sk_buff_head hitlist;
@@ -179,9 +180,22 @@ void unix_gc(void)
 	 *	Avoid a recursive GC.
 	 */
 
-	if (!mutex_trylock(&unix_gc_sem))
+	if (!mutex_trylock(&unix_gc_local_lock))
 		return;
 
+
+	/*
+	 * unix_gc_sem protects against sockets going from in-flight to
+	 * installed
+	 *
+	 * Can't sleep on this, because skb_recv_datagram could be
+	 * waiting for a packet that is to be sent by the thread which
+	 * invoked the gc
+	 */
+	if (!down_write_trylock(&unix_gc_sem)) {
+		mutex_unlock(&unix_gc_local_lock);
+		return;
+	}
 	spin_lock(&unix_table_lock);
 
 	forall_unix_sockets(i, s)
@@ -207,8 +221,6 @@ void unix_gc(void)
 
 	forall_unix_sockets(i, s)
 	{
-		int open_count = 0;
-
 		/*
 		 *	If all instances of the descriptor are not
 		 *	in flight we are in use.
@@ -218,10 +230,20 @@ void unix_gc(void)
 		 *	In this case (see unix_create1()) we set artificial
 		 *	negative inflight counter to close race window.
 		 *	It is trick of course and dirty one.
+		 *
+		 *	Get the inflight counter first, then the open
+		 *	counter.  This avoids problems if racing with
+		 *	sendmsg
+		 *
+		 *	If just created socket is not yet attached to
+		 *	a file descriptor, assume open_count of 1
 		 */
+		int inflight_count = atomic_read(&unix_sk(s)->inflight);
+		int open_count = 1;
+
 		if (s->sk_socket && s->sk_socket->file)
 			open_count = file_count(s->sk_socket->file);
-		if (open_count > atomic_read(&unix_sk(s)->inflight))
+		if (open_count > inflight_count)
 			maybe_unmark_and_push(s);
 	}
 
@@ -302,11 +324,12 @@ void unix_gc(void)
 		u->gc_tree = GC_ORPHAN;
 	}
 	spin_unlock(&unix_table_lock);
+	up_write(&unix_gc_sem);
 
 	/*
 	 *	Here we are. Hitlist is filled. Die.
 	 */
 
 	__skb_queue_purge(&hitlist);
-	mutex_unlock(&unix_gc_sem);
+	mutex_unlock(&unix_gc_local_lock);
 }
Index: linux-2.6.22-rc2/include/net/af_unix.h
===================================================================
--- linux-2.6.22-rc2.orig/include/net/af_unix.h	2007-04-26 05:08:32.000000000 +0200
+++ linux-2.6.22-rc2/include/net/af_unix.h	2007-06-04 09:13:56.000000000 +0200
@@ -14,6 +14,7 @@ extern void unix_gc(void);
 
 extern struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 extern spinlock_t unix_table_lock;
+extern struct rw_semaphore unix_gc_sem;
 
 extern atomic_t unix_tot_inflight;
 
Index: linux-2.6.22-rc2/net/unix/af_unix.c
===================================================================
--- linux-2.6.22-rc2.orig/net/unix/af_unix.c	2007-06-03 23:58:11.000000000 +0200
+++ linux-2.6.22-rc2/net/unix/af_unix.c	2007-06-04 11:04:15.000000000 +0200
@@ -1572,6 +1572,7 @@ static int unix_dgram_recvmsg(struct kio
 
 	msg->msg_namelen = 0;
 
+	down_read(&unix_gc_sem);
 	mutex_lock(&u->readlock);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
@@ -1629,6 +1630,7 @@ out_free:
 	skb_free_datagram(sk,skb);
 out_unlock:
 	mutex_unlock(&u->readlock);
+	up_read(&unix_gc_sem);
 out:
 	return err;
 }
@@ -1704,6 +1706,7 @@ static int unix_stream_recvmsg(struct ki
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
 	}
 
+	down_read(&unix_gc_sem);
 	mutex_lock(&u->readlock);
 
 	do
@@ -1732,6 +1735,7 @@ static int unix_stream_recvmsg(struct ki
 			if (!timeo)
 				break;
 			mutex_unlock(&u->readlock);
+			up_read(&unix_gc_sem);
 
 			timeo = unix_stream_data_wait(sk, timeo);
 
@@ -1739,6 +1743,7 @@ static int unix_stream_recvmsg(struct ki
 				err = sock_intr_errno(timeo);
 				goto out;
 			}
+			down_read(&unix_gc_sem);
 			mutex_lock(&u->readlock);
 			continue;
  unlock:
@@ -1810,6 +1815,7 @@ static int unix_stream_recvmsg(struct ki
 	} while (size);
 
 	mutex_unlock(&u->readlock);
+	up_read(&unix_gc_sem);
 	scm_recv(sock, msg, siocb->scm, flags);
 out:
 	return copied ? : err;
