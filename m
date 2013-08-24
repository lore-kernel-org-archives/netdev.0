From: Julian Anastasov <ja@ssi.bg>
Subject: Re: sendto() bug?
Date: Sat, 24 Aug 2013 11:35:44 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308241105220.1641@ja.ssi.bg>
References: <alpine.DEB.2.02.1308231257140.10771@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Chris Clark <chris.clark@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46797 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753900Ab3HXIc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Aug 2013 04:32:58 -0400
In-Reply-To: <alpine.DEB.2.02.1308231257140.10771@optio.utah.ind.alcatel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 23 Aug 2013, Chris Clark wrote:

> In the same vein as 2ad5b9e4, I'm soliciting feedback on something
> similar for raw_sendmsg():
> 
> =================================================================
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index dd44e0a..454d9c1 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -571,7 +571,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>         flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
>                            RT_SCOPE_UNIVERSE,
>                            inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
> -                          inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
> +                          inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP
> +                           | ((msg->msg_namelen
> +                               && (tos & RTO_ONLINK)) ? FLOWI_FLAG_KNOWN_NH : 0),
>                            daddr, saddr, 0, 0);
> 
>         if (!inet->hdrincl) {
> =================================================================
> 
> The thought here is to apply the FLOWI_FLAG_KNOWN_NH flag when:
>  (a) The dest_addr is given explicitly (msg->msg_namelen), and
>  (b) The socket is in MSG_DONTROUTE mode (tos & RTO_ONLINK).

	IMHO, FLOWI_FLAG_KNOWN_NH should be set only
for the inet->hdrincl case, otherwise it is set from
routing result: ip_push_pending_frames -> ip_finish_skb ->
__ip_make_skb -> ip_copy_addrs.

	The both cases for hdrincl (usin->sin_addr.s_addr
and inet->inet_daddr) can provide different address, so
it should work also for connected sockets.

	And it should not depend on MSG_DONTROUTE because
daddr for routing and daddr in header can be two
different IPs in local subnet, the user should not
be restricted to use MSG_DONTROUTE just to send
correct ARP request.

	So, something like
(inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0) ?

Regards

--
Julian Anastasov <ja@ssi.bg>
