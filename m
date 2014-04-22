From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] net: ipv6: Unduplicate {raw,udp}v6_sendmsg code
Date: Tue, 22 Apr 2014 17:48:42 +0200
Message-ID: <20140422154842.GC1960@order.stressinduktion.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398179656-9313-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60041 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010AbaDVPsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:48:43 -0400
Content-Disposition: inline
In-Reply-To: <1398179656-9313-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Apr 23, 2014 at 12:14:14AM +0900, Lorenzo Colitti wrote:
> rawv6_sendmsg and udpv6_sendmsg have ~100 lines of almost
> identical code. Move this into a new ipv6_datagram_send_common
> helper function.
> 
> Tested: black-box tested using user-mode Linux.
> 
> - Basic UDP sends using sendto work.
> - Mark routing and oif routing using SO_BINDTODEVICE work.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  include/net/ipv6.h  |   7 +++
>  net/ipv6/datagram.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/raw.c      | 107 ++++--------------------------------------
>  net/ipv6/udp.c      | 117 ++++-----------------------------------------
>  4 files changed, 156 insertions(+), 208 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index d640925..f1a247a 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -785,6 +785,13 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
>  int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
>  int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
>  				 int addr_len);
> +int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
> +			     struct sockaddr_in6 *sin6, int addr_len,
> +			     struct flowi6 *fl6, struct dst_entry **dstp,
> +			     struct ipv6_txoptions **optp,
> +			     struct ipv6_txoptions *opt_space,
> +			     int *hlimit, int *tclass, int *dontfrag,
> +			     int *connected);
>  
>  int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
>  		    int *addr_len);
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index c3bf2d2..e6df861 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -915,6 +915,139 @@ exit_f:
>  }
>  EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
>  
> +int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
> +			     struct sockaddr_in6 *sin6, int addr_len,
> +			     struct flowi6 *fl6, struct dst_entry **dstp,
> +			     struct ipv6_txoptions **optp,
> +			     struct ipv6_txoptions *opt_space,
> +			     int *hlimit, int *tclass, int *dontfrag,
> +			     int *connected)
> +{
> +	struct ipv6_txoptions *opt = NULL;
> +	struct ip6_flowlabel *flowlabel = NULL;
> +	struct in6_addr *final_p, final;
> +	struct ipv6_pinfo *np = inet6_sk(sk);
> +	struct in6_addr *daddr;
> +	struct dst_entry *dst;
> +	int err;
> +
> +	*optp = NULL;
> +	*dstp = NULL;
> +	*hlimit = *tclass = *dontfrag = -1;

Do we need those? If we return != 0 from ip6_datagram_send_common we
know the in/out arguments may or maybe got an update an as such cannot
use them.

Caller can initialize dstp = NULL so we can pass dstp to dst_release in the
error path in the caller function (dst_release checks for argument != NULL).

Does that make sense? It looks to me like it could hide errors, but just IMHO.

> +
> +	if (sin6) {
> +		daddr = &sin6->sin6_addr;
> +
> +		if (np->sndflow) {
> +			fl6->flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
> +			if (fl6->flowlabel&IPV6_FLOWLABEL_MASK) {
> +				flowlabel = fl6_sock_lookup(sk, fl6->flowlabel);
> +				if (flowlabel == NULL)
> +					return -EINVAL;
> +			}
> +		}
> +
> +		/* Otherwise it will be difficult to maintain
> +		 * sk->sk_dst_cache.
> +		 */
> +		if (sk->sk_state == TCP_ESTABLISHED &&
> +		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
> +			daddr = &sk->sk_v6_daddr;
> +
> +		if (addr_len >= sizeof(struct sockaddr_in6) &&
> +		    sin6->sin6_scope_id &&
> +		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
> +			fl6->flowi6_oif = sin6->sin6_scope_id;
> +	} else {
> +		if (sk->sk_state != TCP_ESTABLISHED)
> +			return -EDESTADDRREQ;
> +
> +		daddr = &sk->sk_v6_daddr;
> +		fl6->flowlabel = np->flow_label;
> +		*connected = 1;
> +	}
> +
> +	if (!fl6->flowi6_oif)
> +		fl6->flowi6_oif = sk->sk_bound_dev_if;
> +
> +	if (!fl6->flowi6_oif)
> +		fl6->flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
> +
> +	fl6->flowi6_mark = sk->sk_mark;
> +
> +	if (msg->msg_controllen) {
> +		opt = opt_space;
> +		memset(opt, 0, sizeof(*opt));
> +		opt->tot_len = sizeof(*opt);
> +
> +		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, fl6, opt,
> +					    hlimit, tclass, dontfrag);
> +		if (err < 0) {
> +			fl6_sock_release(flowlabel);
> +			return err;
> +		}
> +		if ((fl6->flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
> +			flowlabel = fl6_sock_lookup(sk, fl6->flowlabel);
> +			if (flowlabel == NULL)
> +				return -EINVAL;
> +		}
> +		if (!(opt->opt_nflen|opt->opt_flen))
> +			opt = NULL;
> +		*connected = 0;
> +	}
> +	if (opt == NULL)
> +		opt = np->opt;
> +	if (flowlabel)
> +		opt = fl6_merge_options(opt_space, flowlabel, opt);
> +	opt = ipv6_fixup_options(opt_space, opt);
> +
> +	if (!ipv6_addr_any(daddr))
> +		fl6->daddr = *daddr;
> +	else
> +		fl6->daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */

Maybe a newline?

> +	if (ipv6_addr_any(&fl6->saddr) && !ipv6_addr_any(&np->saddr))
> +		fl6->saddr = np->saddr;
> +
> +	final_p = fl6_update_dst(fl6, opt, &final);
> +	if (final_p)
> +		*connected = 0;
> +
> +	if (!fl6->flowi6_oif && ipv6_addr_is_multicast(&fl6->daddr)) {
> +		fl6->flowi6_oif = np->mcast_oif;
> +		*connected = 0;
> +	} else if (!fl6->flowi6_oif)
> +		fl6->flowi6_oif = np->ucast_oif;
> +
> +	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
> +
> +	dst = ip6_sk_dst_lookup_flow(sk, fl6, final_p);
> +	if (IS_ERR(dst)) {
> +		fl6_sock_release(flowlabel);
> +		return PTR_ERR(dst);
> +	}
> +
> +	if (*hlimit < 0) {
> +		if (ipv6_addr_is_multicast(&fl6->daddr))
> +			*hlimit = np->mcast_hops;
> +		else
> +			*hlimit = np->hop_limit;
> +		if (*hlimit < 0)
> +			*hlimit = ip6_dst_hoplimit(dst);
> +	}
> +
> +	if (*tclass < 0)
> +		*tclass = np->tclass;
> +
> +	if (*dontfrag < 0)
> +		*dontfrag = np->dontfrag;
> +
> +	*dstp = dst;
> +	*optp = opt;

We would also need a fl6_sock_release here because we finished processing
it.

You could also release the flowlabel after fl6_merge_options and could remove
the fl6_sock_release after ip6_sk_dst_lookup_flow in the error handling.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(ip6_datagram_send_common);

The rest looks good to me and is a nice work!

Thanks,

  Hannes
