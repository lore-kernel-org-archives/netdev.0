From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC v2 PATCH 1/2] SCTP: Add RCU synchronization around sctp_localaddr_list
Date: Wed, 12 Sep 2007 15:26:58 -0700
Message-ID: <20070912222658.GI9830@linux.vnet.ibm.com>
References: <11896263983281-git-send-email-vladislav.yasevich@hp.com> <11896263982464-git-send-email-vladislav.yasevich@hp.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:48559 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbXILW1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 18:27:03 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CMR0Nn003010
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 18:27:00 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CMR03j666722
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 18:27:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CMQxTa012659
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 18:27:00 -0400
Content-Disposition: inline
In-Reply-To: <11896263982464-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 12, 2007 at 03:46:37PM -0400, Vlad Yasevich wrote:
> sctp_localaddr_list is modified dynamically via NETDEV_UP
> and NETDEV_DOWN events, but there is not synchronization
> between writer (even handler) and readers.  As a result,
> the readers can access an entry that has been freed and
> crash the sytem.

Looks much better!!!  Typo in comment noted below.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> ---
>  include/net/sctp/sctp.h    |    1 +
>  include/net/sctp/structs.h |    6 +++++
>  net/sctp/bind_addr.c       |    2 +
>  net/sctp/ipv6.c            |   34 ++++++++++++++++++++++---------
>  net/sctp/protocol.c        |   46 ++++++++++++++++++++++++++++++-------------
>  net/sctp/socket.c          |   38 +++++++++++++++++++++++------------
>  6 files changed, 90 insertions(+), 37 deletions(-)
> 
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index d529045..c9cc00c 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -123,6 +123,7 @@
>   * sctp/protocol.c
>   */
>  extern struct sock *sctp_get_ctl_sock(void);
> +extern void sctp_local_addr_free(struct rcu_head *head);
>  extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
>  				     sctp_scope_t, gfp_t gfp,
>  				     int flags);
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index c0d5848..a89e361 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -207,6 +207,9 @@ extern struct sctp_globals {
>  	 * It is a list of sctp_sockaddr_entry.
>  	 */
>  	struct list_head local_addr_list;
> +
> +	/* Lock that protects the local_addr_list writers */
> +	spinlock_t addr_list_lock;
>  	
>  	/* Flag to indicate if addip is enabled. */
>  	int addip_enable;
> @@ -242,6 +245,7 @@ extern struct sctp_globals {
>  #define sctp_port_alloc_lock		(sctp_globals.port_alloc_lock)
>  #define sctp_port_hashtable		(sctp_globals.port_hashtable)
>  #define sctp_local_addr_list		(sctp_globals.local_addr_list)
> +#define sctp_local_addr_lock		(sctp_globals.addr_list_lock)
>  #define sctp_addip_enable		(sctp_globals.addip_enable)
>  #define sctp_prsctp_enable		(sctp_globals.prsctp_enable)
> 
> @@ -737,8 +741,10 @@ const union sctp_addr *sctp_source(const struct sctp_chunk *chunk);
>  /* This is a structure for holding either an IPv6 or an IPv4 address.  */
>  struct sctp_sockaddr_entry {
>  	struct list_head list;
> +	struct rcu_head	rcu;
>  	union sctp_addr a;
>  	__u8 use_as_src;
> +	__u8 valid;
>  };
> 
>  typedef struct sctp_chunk *(sctp_packet_phandler_t)(struct sctp_association *);
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index fdb287a..7fc369f 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -163,8 +163,10 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>  		addr->a.v4.sin_port = htons(bp->port);
> 
>  	addr->use_as_src = use_as_src;
> +	addr->valid = 1;
> 
>  	INIT_LIST_HEAD(&addr->list);
> +	INIT_RCU_HEAD(&addr->rcu);
>  	list_add_tail(&addr->list, &bp->address_list);
>  	SCTP_DBG_OBJCNT_INC(addr);
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index f8aa23d..54ff472 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -77,13 +77,18 @@
> 
>  #include <asm/uaccess.h>
> 
> -/* Event handler for inet6 address addition/deletion events.  */
> +/* Event handler for inet6 address addition/deletion events.
> + * This even is part of the atomic notifier call chain

s/even/event/

> + * and thus happens atomically and can NOT sleep.  As a result
> + * we can't and really don't need to add any locks to guard the
> + * RCU.
> + */
>  static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>  				void *ptr)
>  {
>  	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
> -	struct sctp_sockaddr_entry *addr;
> -	struct list_head *pos, *temp;
> +	struct sctp_sockaddr_entry *addr = NULL;
> +	struct sctp_sockaddr_entry *temp;
> 
>  	switch (ev) {
>  	case NETDEV_UP:
> @@ -94,19 +99,26 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>  			memcpy(&addr->a.v6.sin6_addr, &ifa->addr,
>  				 sizeof(struct in6_addr));
>  			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
> -			list_add_tail(&addr->list, &sctp_local_addr_list);
> +			addr->valid = 1;
> +			spin_lock_bh(&sctp_local_addr_lock);
> +			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
> +			spin_unlock_bh(&sctp_local_addr_lock);
>  		}
>  		break;
>  	case NETDEV_DOWN:
> -		list_for_each_safe(pos, temp, &sctp_local_addr_list) {
> -			addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> -			if (ipv6_addr_equal(&addr->a.v6.sin6_addr, &ifa->addr)) {
> -				list_del(pos);
> -				kfree(addr);
> +		spin_lock_bh(&sctp_local_addr_lock);
> +		list_for_each_entry_safe(addr, temp,
> +					&sctp_local_addr_list, list) {
> +			if (ipv6_addr_equal(&addr->a.v6.sin6_addr,
> +					     &ifa->addr)) {
> +				addr->valid = 0;
> +				list_del_rcu(&addr->list);
>  				break;
>  			}
>  		}
> -
> +		spin_unlock_bh(&sctp_local_addr_lock);
> +		if (addr && !addr->valid)
> +			call_rcu(&addr->rcu, sctp_local_addr_free);
>  		break;
>  	}
> 
> @@ -367,7 +379,9 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
>  			addr->a.v6.sin6_port = 0;
>  			addr->a.v6.sin6_addr = ifp->addr;
>  			addr->a.v6.sin6_scope_id = dev->ifindex;
> +			addr->valid = 1;
>  			INIT_LIST_HEAD(&addr->list);
> +			INIT_RCU_HEAD(&addr->rcu);
>  			list_add_tail(&addr->list, addrlist);
>  		}
>  	}
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index e98579b..4688559 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -153,6 +153,8 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
>  			addr->a.v4.sin_family = AF_INET;
>  			addr->a.v4.sin_port = 0;
>  			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
> +			addr->valid = 1;
> +			INIT_RCU_HEAD(&addr->rcu);
>  			list_add_tail(&addr->list, addrlist);
>  		}
>  	}
> @@ -192,16 +194,24 @@ static void sctp_free_local_addr_list(void)
>  	}
>  }
> 
> +void sctp_local_addr_free(struct rcu_head *head)
> +{
> +	struct sctp_sockaddr_entry *e = container_of(head,
> +				struct sctp_sockaddr_entry, rcu);
> +	kfree(e);
> +}
> +
>  /* Copy the local addresses which are valid for 'scope' into 'bp'.  */
>  int sctp_copy_local_addr_list(struct sctp_bind_addr *bp, sctp_scope_t scope,
>  			      gfp_t gfp, int copy_flags)
>  {
>  	struct sctp_sockaddr_entry *addr;
>  	int error = 0;
> -	struct list_head *pos, *temp;
> 
> -	list_for_each_safe(pos, temp, &sctp_local_addr_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(addr, &sctp_local_addr_list, list) {
> +		if (!addr->valid)
> +			continue;
>  		if (sctp_in_scope(&addr->a, scope)) {
>  			/* Now that the address is in scope, check to see if
>  			 * the address type is really supported by the local
> @@ -221,6 +231,7 @@ int sctp_copy_local_addr_list(struct sctp_bind_addr *bp, sctp_scope_t scope,
>  	}
> 
>  end_copy:
> +	rcu_read_unlock();
>  	return error;
>  }
> 
> @@ -605,8 +616,8 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>  			       void *ptr)
>  {
>  	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
> -	struct sctp_sockaddr_entry *addr;
> -	struct list_head *pos, *temp;
> +	struct sctp_sockaddr_entry *addr = NULL;
> +	struct sctp_sockaddr_entry *temp;
> 
>  	switch (ev) {
>  	case NETDEV_UP:
> @@ -615,19 +626,25 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
>  			addr->a.v4.sin_family = AF_INET;
>  			addr->a.v4.sin_port = 0;
>  			addr->a.v4.sin_addr.s_addr = ifa->ifa_local;
> -			list_add_tail(&addr->list, &sctp_local_addr_list);
> +			addr->valid = 1;
> +			spin_lock_bh(&sctp_local_addr_lock);
> +			list_add_tail_rcu(&addr->list, &sctp_local_addr_list);
> +			spin_unlock_bh(&sctp_local_addr_lock);
>  		}
>  		break;
>  	case NETDEV_DOWN:
> -		list_for_each_safe(pos, temp, &sctp_local_addr_list) {
> -			addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +		spin_lock_bh(&sctp_local_addr_lock);
> +		list_for_each_entry_safe(addr, temp,
> +					&sctp_local_addr_list, list) {
>  			if (addr->a.v4.sin_addr.s_addr == ifa->ifa_local) {
> -				list_del(pos);
> -				kfree(addr);
> +				addr->valid = 0;
> +				list_del_rcu(&addr->list);
>  				break;
>  			}
>  		}
> -
> +		spin_unlock_bh(&sctp_local_addr_lock);
> +		if (addr && !addr->valid)
> +			call_rcu(&addr->rcu, sctp_local_addr_free);
>  		break;
>  	}
> 
> @@ -1160,6 +1177,7 @@ SCTP_STATIC __init int sctp_init(void)
> 
>  	/* Initialize the local address list. */
>  	INIT_LIST_HEAD(&sctp_local_addr_list);
> +	spin_lock_init(&sctp_local_addr_lock);
>  	sctp_get_local_addr_list();
> 
>  	/* Register notifier for inet address additions/deletions. */
> @@ -1227,6 +1245,9 @@ SCTP_STATIC __exit void sctp_exit(void)
>  	sctp_v6_del_protocol();
>  	inet_del_protocol(&sctp_protocol, IPPROTO_SCTP);
> 
> +	/* Unregister notifier for inet address additions/deletions. */
> +	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
> +
>  	/* Free the local address list.  */
>  	sctp_free_local_addr_list();
> 
> @@ -1240,9 +1261,6 @@ SCTP_STATIC __exit void sctp_exit(void)
>  	inet_unregister_protosw(&sctp_stream_protosw);
>  	inet_unregister_protosw(&sctp_seqpacket_protosw);
> 
> -	/* Unregister notifier for inet address additions/deletions. */
> -	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
> -
>  	sctp_sysctl_unregister();
>  	list_del(&sctp_ipv4_specific.list);
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 3335460..a3acf78 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4057,9 +4057,9 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>  					       int __user *optlen)
>  {
>  	sctp_assoc_t id;
> +	struct list_head *pos;
>  	struct sctp_bind_addr *bp;
>  	struct sctp_association *asoc;
> -	struct list_head *pos, *temp;
>  	struct sctp_sockaddr_entry *addr;
>  	rwlock_t *addr_lock;
>  	int cnt = 0;
> @@ -4096,15 +4096,19 @@ static int sctp_getsockopt_local_addrs_num_old(struct sock *sk, int len,
>  		addr = list_entry(bp->address_list.next,
>  				  struct sctp_sockaddr_entry, list);
>  		if (sctp_is_any(&addr->a)) {
> -			list_for_each_safe(pos, temp, &sctp_local_addr_list) {
> -				addr = list_entry(pos,
> -						  struct sctp_sockaddr_entry,
> -						  list);
> +			rcu_read_lock();
> +			list_for_each_entry_rcu(addr,
> +						&sctp_local_addr_list, list) {
> +				if (!addr->valid)
> +					continue;
> +
>  				if ((PF_INET == sk->sk_family) &&
>  				    (AF_INET6 == addr->a.sa.sa_family))
>  					continue;
> +
>  				cnt++;
>  			}
> +			rcu_read_unlock();
>  		} else {
>  			cnt = 1;
>  		}
> @@ -4127,14 +4131,16 @@ static int sctp_copy_laddrs_old(struct sock *sk, __u16 port,
>  					int max_addrs, void *to,
>  					int *bytes_copied)
>  {
> -	struct list_head *pos, *next;
>  	struct sctp_sockaddr_entry *addr;
>  	union sctp_addr temp;
>  	int cnt = 0;
>  	int addrlen;
> 
> -	list_for_each_safe(pos, next, &sctp_local_addr_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(addr, &sctp_local_addr_list, list) {
> +		if (!addr->valid)
> +			continue;
> +
>  		if ((PF_INET == sk->sk_family) &&
>  		    (AF_INET6 == addr->a.sa.sa_family))
>  			continue;
> @@ -4149,6 +4155,7 @@ static int sctp_copy_laddrs_old(struct sock *sk, __u16 port,
>  		cnt ++;
>  		if (cnt >= max_addrs) break;
>  	}
> +	rcu_read_unlock();
> 
>  	return cnt;
>  }
> @@ -4156,14 +4163,16 @@ static int sctp_copy_laddrs_old(struct sock *sk, __u16 port,
>  static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
>  			    size_t space_left, int *bytes_copied)
>  {
> -	struct list_head *pos, *next;
>  	struct sctp_sockaddr_entry *addr;
>  	union sctp_addr temp;
>  	int cnt = 0;
>  	int addrlen;
> 
> -	list_for_each_safe(pos, next, &sctp_local_addr_list) {
> -		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(addr, &sctp_local_addr_list, list) {
> +		if (!addr->valid)
> +			continue;
> +
>  		if ((PF_INET == sk->sk_family) &&
>  		    (AF_INET6 == addr->a.sa.sa_family))
>  			continue;
> @@ -4171,8 +4180,10 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
>  		sctp_get_pf_specific(sk->sk_family)->addr_v4map(sctp_sk(sk),
>  								&temp);
>  		addrlen = sctp_get_af_specific(temp.sa.sa_family)->sockaddr_len;
> -		if (space_left < addrlen)
> -			return -ENOMEM;
> +		if (space_left < addrlen) {
> +			cnt =  -ENOMEM;
> +			break;
> +		}
>  		memcpy(to, &temp, addrlen);
> 
>  		to += addrlen;
> @@ -4180,6 +4191,7 @@ static int sctp_copy_laddrs(struct sock *sk, __u16 port, void *to,
>  		space_left -= addrlen;
>  		*bytes_copied += addrlen;
>  	}
> +	rcu_read_unlock();
> 
>  	return cnt;
>  }
> -- 
> 1.5.2.4
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
