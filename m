From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Thu, 09 Apr 2015 02:07:41 -0700
Message-ID: <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428566941.6875.7.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Poehn <sebastian.poehn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36189 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933881AbbDIJHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 05:07:43 -0400
Received: by igblo3 with SMTP id lo3so61344149igb.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 02:07:42 -0700 (PDT)
In-Reply-To: <1428566941.6875.7.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-09 at 10:09 +0200, Sebastian Poehn wrote:
> We are running a couple of thousand machines with 3.8 and 3.12. On very few systems
> (something below 10) we encounter panics in xfrm code. The main characteristic seams
> to be the usage of TPROXY.
> 
> Attached patch is only a workaround, as problems may also happen in other code portions
> (actually on even fewer systems this happens).
> 
> For timewait sockets the memory region of sk_policy does not belong
> to us anymore. So there may be someone else using it and we may panic
> because of corrupted pointers.
> 
> xfrm_sk_policy_lookup+0x38/0x66
> xfrm_lookup+0x93/0x48f
> nf_nat_packet+0x92/0xa4 [nf_nat]
> _decode_session4+0xd9/0x294
> nf_xfrm_me_harder+0x50/0xc5 [nf_nat]
> nf_nat_ipv4_out+0xad/0xc4 [iptable_nat]
> nf_iterate+0x42/0x7d
> ip_finish_output2+0x2b1/0x2b1
> nf_hook_slow+0x22f/0x2c9
> ip_finish_output2+0x2b1/0x2b1
> ip_finish_output2+0x2b1/0x2b1
> __xfrm_route_forward+0x7a/0x97
> ip_finish_output2+0x2b1/0x2b1
> NF_HOOK_COND+0x3f/0x54
> ip_output+0x5a/0x5e
> __netif_receive_skb+0x4b2/0x514
> process_backlog+0xee/0x1c5
> net_rx_action+0xa7/0x1fe
> 
> Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
> ---
>  net/xfrm/xfrm_policy.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 9c6b1ab..e9a74fa 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2072,7 +2072,7 @@ restart:
>  	xdst = NULL;
>  	route = NULL;
>  
> -	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
> +	if (sk && sk->sk_state != TCP_TIME_WAIT && sk->sk_policy[XFRM_POLICY_OUT]) {
>  		num_pols = 1;
>  		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
>  		err = xfrm_expand_policies(fl, family, pols,
> @@ -2349,7 +2349,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
>  	}
>  
>  	pol = NULL;
> -	if (sk && sk->sk_policy[dir]) {
> +	if (sk && sk->sk_state != TCP_TIME_WAIT && sk->sk_policy[dir]) {
>  		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
>  		if (IS_ERR(pol)) {
>  			XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);

Hmm.. interesting.

TCP stack never sends packets attached to a socket in timewait state.

On IPv4, the ACK packets sent on behalf of TIME_WAIT follow this path :

tcp_v4_timewait_ack()
 tcp_v4_send_ack()
  ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk))

The per cpu socket used to attach these skb are not in TCP_TIME_WAIT
state.

TPROXY can handle a socket in TCP_TIME_WAIT state only in input path.

So I am a bit confused. Could you elaborate ?

In any case, you probably should use sk_fullsock() new helper, as I
presume you'll have a similar issue with TCP_NEW_SYN_RECV pseudo sockets
when I am done with tcp listener refactoring.

Thanks.
