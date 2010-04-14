From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] fasync: RCU locking
Date: Wed, 14 Apr 2010 08:41:19 -0700
Message-ID: <20100414154119.GB2516@linux.vnet.ibm.com>
References: <1271230961.16881.630.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:51965 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756158Ab0DNPlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 11:41:24 -0400
Content-Disposition: inline
In-Reply-To: <1271230961.16881.630.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 14, 2010 at 09:42:41AM +0200, Eric Dumazet wrote:
> Paul, could you please check this patch, I am not sure
> of the IRQ safety thing...
> 
> Is call_rcu() the right method to use in this case ?

It looks like all the read-side critical sections are protected by
rcu_read_lock(), so call_rcu() should be OK.  And it is OK to invoke
call_rcu() with irqs disabled.  (Just don't try it in an NMI handler.)

Or am I missing some code path that tries to use disabling of irqs
instead of using rcu_read_lock()?  That happens to work in the current
implementation, but...

							Thanx, Paul

> Thanks
> 
> [PATCH net-next-2.6] fasync: RCU locking
> 
> kill_fasync() uses a central rwlock, candidate for RCU conversion.
> 
> We can remove __kill_fasync() direct use in net, and rename it to
> kill_fasync_rcu()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  fs/fcntl.c         |   36 +++++++++++++++++++++---------------
>  include/linux/fs.h |   11 +++++------
>  net/socket.c       |    4 ++--
>  3 files changed, 28 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/fcntl.c b/fs/fcntl.c
> index 452d02f..33cb3ee 100644
> --- a/fs/fcntl.c
> +++ b/fs/fcntl.c
> @@ -614,9 +614,15 @@ int send_sigurg(struct fown_struct *fown)
>  	return ret;
>  }
> 
> -static DEFINE_RWLOCK(fasync_lock);
> +static DEFINE_SPINLOCK(fasync_lock);
>  static struct kmem_cache *fasync_cache __read_mostly;
> 
> +static void fasync_free_rcu(struct rcu_head *head)
> +{
> +	kmem_cache_free(fasync_cache,
> +			container_of(head, struct fasync_struct, fa_rcu));
> +}
> +
>  /*
>   * Remove a fasync entry. If successfully removed, return
>   * positive and clear the FASYNC flag. If no entry exists,
> @@ -634,17 +640,17 @@ static int fasync_remove_entry(struct file *filp, struct fasync_struct **fapp)
>  	int result = 0;
> 
>  	spin_lock(&filp->f_lock);
> -	write_lock_irq(&fasync_lock);
> +	spin_lock_irq(&fasync_lock);
>  	for (fp = fapp; (fa = *fp) != NULL; fp = &fa->fa_next) {
>  		if (fa->fa_file != filp)
>  			continue;
>  		*fp = fa->fa_next;
> -		kmem_cache_free(fasync_cache, fa);
> +		call_rcu(&fa->fa_rcu, fasync_free_rcu);
>  		filp->f_flags &= ~FASYNC;
>  		result = 1;
>  		break;
>  	}
> -	write_unlock_irq(&fasync_lock);
> +	spin_unlock_irq(&fasync_lock);
>  	spin_unlock(&filp->f_lock);
>  	return result;
>  }
> @@ -666,7 +672,7 @@ static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fa
>  		return -ENOMEM;
> 
>  	spin_lock(&filp->f_lock);
> -	write_lock_irq(&fasync_lock);
> +	spin_lock_irq(&fasync_lock);
>  	for (fp = fapp; (fa = *fp) != NULL; fp = &fa->fa_next) {
>  		if (fa->fa_file != filp)
>  			continue;
> @@ -679,12 +685,12 @@ static int fasync_add_entry(int fd, struct file *filp, struct fasync_struct **fa
>  	new->fa_file = filp;
>  	new->fa_fd = fd;
>  	new->fa_next = *fapp;
> -	*fapp = new;
> +	rcu_assign_pointer(*fapp, new);
>  	result = 1;
>  	filp->f_flags |= FASYNC;
> 
>  out:
> -	write_unlock_irq(&fasync_lock);
> +	spin_unlock_irq(&fasync_lock);
>  	spin_unlock(&filp->f_lock);
>  	return result;
>  }
> @@ -704,7 +710,10 @@ int fasync_helper(int fd, struct file * filp, int on, struct fasync_struct **fap
> 
>  EXPORT_SYMBOL(fasync_helper);
> 
> -void __kill_fasync(struct fasync_struct *fa, int sig, int band)
> +/*
> + * rcu_read_lock() is held
> + */
> +static void kill_fasync_rcu(struct fasync_struct *fa, int sig, int band)
>  {
>  	while (fa) {
>  		struct fown_struct * fown;
> @@ -719,22 +728,19 @@ void __kill_fasync(struct fasync_struct *fa, int sig, int band)
>  		   mechanism. */
>  		if (!(sig == SIGURG && fown->signum == 0))
>  			send_sigio(fown, fa->fa_fd, band);
> -		fa = fa->fa_next;
> +		fa = rcu_dereference(fa->fa_next);
>  	}
>  }
> 
> -EXPORT_SYMBOL(__kill_fasync);
> -
>  void kill_fasync(struct fasync_struct **fp, int sig, int band)
>  {
>  	/* First a quick test without locking: usually
>  	 * the list is empty.
>  	 */
>  	if (*fp) {
> -		read_lock(&fasync_lock);
> -		/* reread *fp after obtaining the lock */
> -		__kill_fasync(*fp, sig, band);
> -		read_unlock(&fasync_lock);
> +		rcu_read_lock();
> +		kill_fasync_rcu(rcu_dereference(*fp), sig, band);
> +		rcu_read_unlock();
>  	}
>  }
>  EXPORT_SYMBOL(kill_fasync);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 39d57bc..158b2cc 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1280,10 +1280,11 @@ static inline int lock_may_write(struct inode *inode, loff_t start,
> 
> 
>  struct fasync_struct {
> -	int	magic;
> -	int	fa_fd;
> -	struct	fasync_struct	*fa_next; /* singly linked list */
> -	struct	file 		*fa_file;
> +	int			magic;
> +	int			fa_fd;
> +	struct fasync_struct	*fa_next; /* singly linked list */
> +	struct file		*fa_file;
> +	struct rcu_head		fa_rcu;
>  };
> 
>  #define FASYNC_MAGIC 0x4601
> @@ -1292,8 +1293,6 @@ struct fasync_struct {
>  extern int fasync_helper(int, struct file *, int, struct fasync_struct **);
>  /* can be called from interrupts */
>  extern void kill_fasync(struct fasync_struct **, int, int);
> -/* only for net: no internal synchronization */
> -extern void __kill_fasync(struct fasync_struct *, int, int);
> 
>  extern int __f_setown(struct file *filp, struct pid *, enum pid_type, int force);
>  extern int f_setown(struct file *filp, unsigned long arg, int force);
> diff --git a/net/socket.c b/net/socket.c
> index 35bc198..846739c 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -1159,10 +1159,10 @@ int sock_wake_async(struct socket *sock, int how, int band)
>  		/* fall through */
>  	case SOCK_WAKE_IO:
>  call_kill:
> -		__kill_fasync(sock->fasync_list, SIGIO, band);
> +		kill_fasync(sock->fasync_list, SIGIO, band);
>  		break;
>  	case SOCK_WAKE_URG:
> -		__kill_fasync(sock->fasync_list, SIGURG, band);
> +		kill_fasync(sock->fasync_list, SIGURG, band);
>  	}
>  	return 0;
>  }
> 
> 
