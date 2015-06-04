From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 1/2] sctp: rcu-ify addr_waitq
Date: Thu, 4 Jun 2015 10:27:10 -0400
Message-ID: <20150604142710.GD24585@hmsreliant.think-freely.org>
References: <20150602134851.GA15847@hmsreliant.think-freely.org>
 <660872d4d795833eca5f7e517c7e1dabbc1df02b.1433350421.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45125 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbbFDO1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 10:27:25 -0400
Content-Disposition: inline
In-Reply-To: <660872d4d795833eca5f7e517c7e1dabbc1df02b.1433350421.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 01:54:01PM -0300, mleitner@redhat.com wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> That's needed for the next patch, so we break the lock inversion between
> netns_sctp->addr_wq_lock and socket lock on
> sctp_addr_wq_timeout_handler(). With this, we can traverse addr_waitq
> without taking addr_wq_lock, taking it just for the write operations.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> 
> Notes:
>     v1->v2:
>      As asked by Neil, this now reuses addr_wq_lock. And for that, also
>      rcu-ifyies addr_waitq.
> 
>  include/net/netns/sctp.h |  2 +-
>  net/sctp/protocol.c      | 81 +++++++++++++++++++++++++++++-------------------
>  2 files changed, 50 insertions(+), 33 deletions(-)
> 
> diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
> index 3573a81815ad9e0efb6ceb721eb066d3726419f0..9e53412c4ed829e8e45777a6d95406d490dbaa75 100644
> --- a/include/net/netns/sctp.h
> +++ b/include/net/netns/sctp.h
> @@ -28,7 +28,7 @@ struct netns_sctp {
>  	 * It is a list of sctp_sockaddr_entry.
>  	 */
>  	struct list_head local_addr_list;
> -	struct list_head addr_waitq;
> +	struct list_head __rcu addr_waitq;
>  	struct timer_list addr_wq_timer;
>  	struct list_head auto_asconf_splist;
>  	spinlock_t addr_wq_lock;
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index 53b7acde9aa37bf3d4029c459421564d5270f4c0..a5089883b28195f3aef69ef35b5397322a01126f 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -593,15 +593,46 @@ static void sctp_v4_ecn_capable(struct sock *sk)
>  	INET_ECN_xmit(sk);
>  }
>  
> +static void sctp_free_addr_wq(struct net *net)
> +{
> +	struct sctp_sockaddr_entry *addrw;
> +
> +	spin_lock_bh(&net->sctp.addr_wq_lock);
> +	del_timer(&net->sctp.addr_wq_timer);
> +	list_for_each_entry_rcu(addrw, &net->sctp.addr_waitq, list) {
> +		list_del_rcu(&addrw->list);
> +		kfree_rcu(addrw, rcu);
> +	}
> +	spin_unlock_bh(&net->sctp.addr_wq_lock);
> +}
> +
> +/* As there is no refcnt on sctp_sockaddr_entry, we must check inside
> + * the lock if it wasn't removed from addr_waitq already, otherwise we
> + * could double-free it.
> + */
> +static void sctp_free_addr_wq_entry(struct net *net,
> +				    struct sctp_sockaddr_entry *addrw)
> +{
> +	struct sctp_sockaddr_entry *temp;
> +
> +	spin_lock_bh(&net->sctp.addr_wq_lock);
> +	list_for_each_entry_rcu(temp, &net->sctp.addr_waitq, list) {
> +		if (temp == addrw) {
> +			list_del_rcu(&addrw->list);
> +			kfree_rcu(addrw, rcu);
> +		}
> +	}
> +	spin_unlock_bh(&net->sctp.addr_wq_lock);
> +}
> +
>  static void sctp_addr_wq_timeout_handler(unsigned long arg)
>  {
>  	struct net *net = (struct net *)arg;
> -	struct sctp_sockaddr_entry *addrw, *temp;
> +	struct sctp_sockaddr_entry *addrw;
>  	struct sctp_sock *sp;
>  
> -	spin_lock_bh(&net->sctp.addr_wq_lock);
> -
> -	list_for_each_entry_safe(addrw, temp, &net->sctp.addr_waitq, list) {
> +	rcu_read_lock_bh();
> +	list_for_each_entry_rcu(addrw, &net->sctp.addr_waitq, list) {
>  		pr_debug("%s: the first ent in wq:%p is addr:%pISc for cmd:%d at "
>  			 "entry:%p\n", __func__, &net->sctp.addr_waitq, &addrw->a.sa,
>  			 addrw->state, addrw);
> @@ -627,7 +658,9 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
>  
>  				timeo_val = jiffies;
>  				timeo_val += msecs_to_jiffies(SCTP_ADDRESS_TICK_DELAY);
> +				spin_lock_bh(&net->sctp.addr_wq_lock);
>  				mod_timer(&net->sctp.addr_wq_timer, timeo_val);
> +				spin_unlock_bh(&net->sctp.addr_wq_lock);
Do we actually need to lock the addr_wq_lock here?  mod_timer has its own
internal locking.

>  				break;
>  			}
>  		}
> @@ -647,35 +680,20 @@ static void sctp_addr_wq_timeout_handler(unsigned long arg)
>  #if IS_ENABLED(CONFIG_IPV6)
>  free_next:
>  #endif
> -		list_del(&addrw->list);
> -		kfree(addrw);
> -	}
> -	spin_unlock_bh(&net->sctp.addr_wq_lock);
> -}
> -
> -static void sctp_free_addr_wq(struct net *net)
> -{
> -	struct sctp_sockaddr_entry *addrw;
> -	struct sctp_sockaddr_entry *temp;
> -
> -	spin_lock_bh(&net->sctp.addr_wq_lock);
> -	del_timer(&net->sctp.addr_wq_timer);
> -	list_for_each_entry_safe(addrw, temp, &net->sctp.addr_waitq, list) {
> -		list_del(&addrw->list);
> -		kfree(addrw);
> +		sctp_free_addr_wq_entry(net, addrw);
>  	}
> -	spin_unlock_bh(&net->sctp.addr_wq_lock);
> +	rcu_read_unlock_bh();
>  }
>  
>  /* lookup the entry for the same address in the addr_waitq
> - * sctp_addr_wq MUST be locked
> + * rcu read MUST be locked
>   */
>  static struct sctp_sockaddr_entry *sctp_addr_wq_lookup(struct net *net,
>  					struct sctp_sockaddr_entry *addr)
>  {
>  	struct sctp_sockaddr_entry *addrw;
>  
> -	list_for_each_entry(addrw, &net->sctp.addr_waitq, list) {
> +	list_for_each_entry_rcu(addrw, &net->sctp.addr_waitq, list) {
>  		if (addrw->a.sa.sa_family != addr->a.sa.sa_family)
>  			continue;
>  		if (addrw->a.sa.sa_family == AF_INET) {
> @@ -702,7 +720,7 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
>  	 * new address after a couple of addition and deletion of that address
>  	 */
>  
> -	spin_lock_bh(&net->sctp.addr_wq_lock);
> +	rcu_read_lock_bh();
>  	/* Offsets existing events in addr_wq */
>  	addrw = sctp_addr_wq_lookup(net, addr);
>  	if (addrw) {
> @@ -710,22 +728,21 @@ void sctp_addr_wq_mgmt(struct net *net, struct sctp_sockaddr_entry *addr, int cm
>  			pr_debug("%s: offsets existing entry for %d, addr:%pISc "
>  				 "in wq:%p\n", __func__, addrw->state, &addrw->a.sa,
>  				 &net->sctp.addr_waitq);
> -
> -			list_del(&addrw->list);
> -			kfree(addrw);
> +			sctp_free_addr_wq_entry(net, addrw);
>  		}
> -		spin_unlock_bh(&net->sctp.addr_wq_lock);
> +		rcu_read_unlock_bh();
>  		return;
>  	}
> +	rcu_read_unlock_bh();
>  
>  	/* OK, we have to add the new address to the wait queue */
>  	addrw = kmemdup(addr, sizeof(struct sctp_sockaddr_entry), GFP_ATOMIC);
> -	if (addrw == NULL) {
> -		spin_unlock_bh(&net->sctp.addr_wq_lock);
> +	if (!addrw)
>  		return;
> -	}
>  	addrw->state = cmd;
> -	list_add_tail(&addrw->list, &net->sctp.addr_waitq);
> +
> +	spin_lock_bh(&net->sctp.addr_wq_lock);
> +	list_add_tail_rcu(&addrw->list, &net->sctp.addr_waitq);
>  
>  	pr_debug("%s: add new entry for cmd:%d, addr:%pISc in wq:%p\n",
>  		 __func__, addrw->state, &addrw->a.sa, &net->sctp.addr_waitq);

Other than the comment above, and the break you need to insert, I think this
looks good, thanks for taking the extra time on it!
Best
Neil

> -- 
> 2.4.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
