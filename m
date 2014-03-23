From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Sun, 23 Mar 2014 21:41:13 +0200
Message-ID: <20140323194113.GA13633@redhat.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jasowang@redhat.com, xemul@parallels.com,
	wuzhy@linux.vnet.ibm.com, therbert@google.com, yamato@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Monam Agarwal <monamagarwal123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 24, 2014 at 12:02:32AM +0530, Monam Agarwal wrote:
> This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
> 
> The rcu_assign_pointer() ensures that the initialization of a structure       
> is carried out before storing a pointer to that structure. 
> And in the case of the NULL pointer, there is no structure to initialize. 
> So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)
> 
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>

Sounds right ... but doing this all over the place seems
fragile, and error prone. Can't we make this kind of
optimization automatic? See below:


> ---
>  drivers/net/tun.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 26f8635..ee328ba 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -452,7 +452,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
>  
>  		--tun->numqueues;
>  		if (clean) {
> -			rcu_assign_pointer(tfile->tun, NULL);
> +			RCU_INIT_POINTER(tfile->tun, NULL);
>  			sock_put(&tfile->sk);
>  		} else
>  			tun_disable_queue(tun, tfile);
> @@ -499,12 +499,12 @@ static void tun_detach_all(struct net_device *dev)
>  		tfile = rtnl_dereference(tun->tfiles[i]);
>  		BUG_ON(!tfile);
>  		wake_up_all(&tfile->wq.wait);
> -		rcu_assign_pointer(tfile->tun, NULL);
> +		RCU_INIT_POINTER(tfile->tun, NULL);
>  		--tun->numqueues;
>  	}
>  	list_for_each_entry(tfile, &tun->disabled, next) {
>  		wake_up_all(&tfile->wq.wait);
> -		rcu_assign_pointer(tfile->tun, NULL);
> +		RCU_INIT_POINTER(tfile->tun, NULL);
>  	}
>  	BUG_ON(tun->numqueues != 0);
>  
> @@ -2194,7 +2194,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
>  					    &tun_proto);
>  	if (!tfile)
>  		return -ENOMEM;
> -	rcu_assign_pointer(tfile->tun, NULL);
> +	RCU_INIT_POINTER(tfile->tun, NULL);
>  	tfile->net = get_net(current->nsproxy->net_ns);
>  	tfile->flags = 0;
>  	tfile->ifindex = 0;
> -- 
> 1.7.9.5

--->

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
In the case of the NULL pointer, there is no structure to initialize,
so we can safely drop smp_wmb in this case.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

--

Lightly tested.
v is evaluated twice here but that should be ok since this
only happens when v is a constant, so evaluating it should
have no side effects.
Paul, what do you think?

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 72bf3a0..d33c9ec 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -587,7 +587,8 @@ static inline void rcu_preempt_sleep_check(void)
  */
 #define rcu_assign_pointer(p, v) \
 	do { \
-		smp_wmb(); \
+		if (!__builtin_constant_p(v) || (v)) \
+			smp_wmb(); \
 		ACCESS_ONCE(p) = RCU_INITIALIZER(v); \
 	} while (0)
 
