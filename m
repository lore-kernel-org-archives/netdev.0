From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 4/4] net/l2tp: add support for L2TP over IPv6 UDP encap
Date: Wed, 18 Apr 2012 16:36:57 +0100
Message-ID: <4F8EDF99.2040401@katalix.com>
References: <20120418134438.GA5162@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53304 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752930Ab2DRPhN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 11:37:13 -0400
In-Reply-To: <20120418134438.GA5162@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/12 14:44, Benjamin LaHaise wrote:
> Now that encap_rcv() works on IPv6 UDP sockets, wire L2TP up to IPv6.
> Support has been tested with and without hardware offloading.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

...

> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index f6732b6..8cd5f4b 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -53,6 +53,9 @@
>  #include <net/inet_common.h>
>  #include <net/xfrm.h>
>  #include <net/protocol.h>
> +#include <net/inet6_connection_sock.h>
> +#include <net/inet_ecn.h>
> +#include <net/ip6_route.h>
>  
>  #include <asm/byteorder.h>
>  #include <linux/atomic.h>
> @@ -446,21 +449,43 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
>  {
>  	struct udphdr *uh = udp_hdr(skb);
>  	u16 ulen = ntohs(uh->len);
> -	struct inet_sock *inet;
>  	__wsum psum;
>  
> -	if (sk->sk_no_check || skb_csum_unnecessary(skb) || !uh->check)
> -		return 0;
> -
> -	inet = inet_sk(sk);
> -	psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr, ulen,
> -				  IPPROTO_UDP, 0);
> -
> -	if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
> -	    !csum_fold(csum_add(psum, skb->csum)))
> +	if (sk->sk_no_check || skb_csum_unnecessary(skb))
>  		return 0;
>  
> -	skb->csum = psum;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	if (sk->sk_family == PF_INET6) {
> +		if (!uh->check) {
> +			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
> +			return 1;
> +		}
> +		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
> +		    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +				     &ipv6_hdr(skb)->daddr, ulen,
> +				     IPPROTO_UDP, skb->csum)) {
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			return 0;
> +		}
> +		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +							 &ipv6_hdr(skb)->daddr,
> +							 skb->len, IPPROTO_UDP,
> +							 0));
> +	} else
> +#endif
> +	{
> +		struct inet_sock *inet;
> +		if (!uh->check)
> +			return 0;
> +		inet = inet_sk(sk);
> +		psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr,
> +					  ulen, IPPROTO_UDP, 0);
> +
> +		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
> +		    !csum_fold(csum_add(psum, skb->csum)))
> +			return 0;
> +		skb->csum = psum;
> +	}
>  
>  	return __skb_checksum_complete(skb);
>  }

I'm seeing UDP checksum errors with a loopback test. Regular
(non-loopback) sessions and loopback ipv4 sessions are fine. I retested
your previous patch and verified that it has the same problem. Although
loopback is a weird config, does it indicate a possible problem? Here is
the debug trace:

[  223.260340] lo: hw csum failure
[  223.260718] Pid: 1146, comm: pppd Not tainted 3.4.0-rc2+ #5
[  223.261373] Call Trace:
[  223.261840]  [<c1247b55>] netdev_rx_csum_fault+0x29/0x30
[  223.262467]  [<c12430ac>] __skb_checksum_complete_head+0x42/0x57
[  223.263159]  [<d8a41230>] l2tp_udp_encap_recv+0x13a/0x413 [l2tp_core]
[  223.263892]  [<d8a78c46>] ? pppol2tp_recv+0x11e/0x11e [l2tp_ppp]
[  223.265741]  [<c12cb69f>] ? rcu_read_unlock+0x4d/0x4f
[  223.266902]  [<c12c0028>] ? addrconf_notify+0x5c4/0x7e2
[  223.268066]  [<c12cd2d6>] udpv6_queue_rcv_skb+0x4a/0x256
[  223.269176]  [<c12cd9c6>] __udp6_lib_rcv+0x2c8/0x400
[  223.269733]  [<c12cdb10>] udpv6_rcv+0x12/0x16
[  223.270222]  [<c12bb1d3>] ip6_input_finish+0x1be/0x346
[  223.270793]  [<c12bb015>] ? T.1206+0x4d/0x4d
[  223.271270]  [<c12bb393>] T.1207+0x38/0x3f
[  223.271729]  [<c12bafa1>] ? rcu_read_unlock+0x4f/0x4f
[  223.272334]  [<c12bb79e>] ip6_input+0x17/0x19
[  223.272824]  [<c12bb015>] ? T.1206+0x4d/0x4d
[  223.273302]  [<c12bafc5>] ip6_rcv_finish+0x24/0x27
[  223.276246]  [<c12bb393>] T.1207+0x38/0x3f
[  223.276727]  [<c12bb726>] ipv6_rcv+0x38c/0x3ed
[  223.277242]  [<c12bafa1>] ? rcu_read_unlock+0x4f/0x4f
[  223.277833]  [<c124b97b>] __netif_receive_skb+0x46c/0x4a7
[  223.278459]  [<c124ba54>] process_backlog+0x9e/0x16e
[  223.279068]  [<c124c26d>] net_rx_action+0x9d/0x1af
[  223.279701]  [<c102cadd>] __do_softirq+0xb1/0x17f
[  223.280281]  [<c102ca2c>] ? irq_enter+0x5d/0x5d
[  223.280807]  <IRQ>  [<c122112d>] ? ppp_channel_push+0x62/0x93
[  223.281489]  [<c102c9a0>] ? _local_bh_enable_ip+0x8e/0xa6
[  223.282406]  [<c102c9c0>] ? local_bh_enable_ip+0x8/0xa
[  223.283026]  [<c12fe2d6>] ? _raw_spin_unlock_bh+0x25/0x28
[  223.283655]  [<c122112d>] ? ppp_channel_push+0x62/0x93
[  223.284308]  [<c1221200>] ? ppp_write+0xa2/0xac
[  223.284855]  [<c122115e>] ? ppp_channel_push+0x93/0x93
[  223.285451]  [<c10e0412>] ? vfs_write+0x80/0xde
[  223.286059]  [<c10e0d2a>] ? fget_light+0x2b/0x8f
[  223.286593]  [<c10e0507>] ? sys_write+0x3b/0x60
[  223.287121]  [<c130431f>] ? sysenter_do_call+0x12/0x38


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
