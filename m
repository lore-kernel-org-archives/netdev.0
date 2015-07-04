From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Sat, 4 Jul 2015 11:34:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507041100480.1484@ja.home.ssi.bg>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com> <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com> <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com> <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com> <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg> <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
 <CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com> <alpine.LFD.2.11.1507031131010.1649@ja.home.ssi.bg> <CALCkm3eCnC7fwtStGZj4xZDJeNegLT3vBHKNABvsEq7_H7aQfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46814 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751697AbbGENsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jul 2015 09:48:53 -0400
In-Reply-To: <CALCkm3eCnC7fwtStGZj4xZDJeNegLT3vBHKNABvsEq7_H7aQfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 3 Jul 2015, Alex Gartrell wrote:

> >         - if packets go to local server IPVS should not touch
> >         skb->dst, skb->sk, etc (NF_ACCEPT case)
> 
> Yeah, the thing is that early demux could totally match for a socket
> that existed before we created the service, and in that instance it
> might make the most sense to retain the connection and simply
> NF_ACCEPT.  The problem with that approach though is that is that the
> behavior changes if early_demux is not enabled.  I believe that we
> should just do the consistent thing and always drop the early_demux
> result if bound for non-local, as you've said.

	We must not forget that a local server listening
on 0.0.0.0:VPORT or VIP:VPORT can be reached if a real
server with some local IP is used as RIP. So, early demux
will really work for this case when local stack is one
of the real servers.

> The interesting thing though is that, for the purposes of routing,
> enabling early_demux does change the behavior.  I suspect that's a
> bug, but it's far enough away from actual use cases that it's probably
> fine (who is out there tearing down addresses and setting up routes in
> their place?)

	Looks like routing by definition can not divert skbs with
early-demux socket because input routing is not called.
Netfilter's DNAT may change daddr/dport before early-demux
and in this case socket should not be found (eg. if we
DNAT to other host). So, there is problem mostly for IPVS,
I don't remember for other cases. May be CLUSTERIP too,
I'm not sure. There is the problem that at LOCAL_IN
SNAT is valid operation, not sure how it affects
early-demux.

> What do you think of the following:
> 
> commit f04c42f8041cc4ccc4cb2a30c1058136dd497a83
> Author: Alex Gartrell <agartrell@fb.com>
> Date:   Wed Jul 1 13:24:46 2015 -0700
> 
>     ipvs: orphan_skb in case of forwarding

	skb_orphan or orphan skb

>     It is possible that we bind against a local socket in early_demux when we
>     are actually going to want to forward it.  In this case, the socket serves
>     no purpose and only serves to confuse things (particularly functions which
>     implicitly expect sk_fullsock to be true, like ip_local_out).
>     Additionally, skb_set_owner_w is totally broken for non full-socks.
> 
>     Signed-off-by: Alex Gartrell <agartrell@fb.com>
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index bf66a86..3efe719 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -527,6 +527,19 @@ static inline int
> ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
>         return ret;
>  }
> 
> +/* In the event of a remote destination, it's possible that we would have
> + * matches against an old socket (particularly a TIME-WAIT socket). This
> + * causes havoc down the line (ip_local_out et. al. expect regular sockets
> + * and invalid memory accesses will happen) so simply drop the association
> + * in this case
> +*/
> +static inline void ip_vs_drop_early_demux_sk(struct sk_buff *skb) {

	Move '{' on next line and below comment should be closed
on next line. But I guess you will run later
scripts/checkpatch.pl --strict /tmp/file.patch

> +       /* If dev is set, the packet came from the LOCAL_IN callback and
> +        * not from a local TCP socket */
> +       if (skb->dev)
> +               skb_orphan(skb);
> +}
> +
>  /* return NF_STOLEN (sent) or NF_ACCEPT if local=1 (not sent) */
>  static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
>                                          struct ip_vs_conn *cp, int local)
> @@ -539,6 +552,7 @@ static inline int ip_vs_nat_send_or_cont(int pf,
> struct sk_buff *skb,
>         else
>                 ip_vs_update_conntrack(skb, cp, 1);
>         if (!local) {
> +               ip_vs_drop_early_demux_sk(skb);
>                 skb_forward_csum(skb);
>                 NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
>                         NULL, skb_dst(skb)->dev, dst_output_sk);

	For the local=true case in ip_vs_nat_send_or_cont may be
we should call skb_orphan when cp->dport != cp->vport or
cp->daddr != cp->vaddr. This is a case where we DNAT to
local real server but on different addr/port. If early
demux finds socket, it is some socket shadowed after adding
the virtual service. So, may be we have to add such checks
near the NF_ACCEPT code.

	Can this work?

	else {
		/* Drop early-demux socket on DNAT */
		if (cp->vport != cp->dport ||
		    !ip_vs_addr_equal(cp->af, cp->vaddr, &cp->caddr))
			ip_vs_drop_early_demux_sk(skb);
		ret = NF_ACCEPT;
	}

	Otherwise, the other changes look good to me.

Regards

--
Julian Anastasov <ja@ssi.bg>
