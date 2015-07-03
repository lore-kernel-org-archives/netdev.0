From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we have
 a TCP_TIMEWAIT sk
Date: Fri, 3 Jul 2015 14:54:47 -0700
Message-ID: <CALCkm3eCnC7fwtStGZj4xZDJeNegLT3vBHKNABvsEq7_H7aQfg@mail.gmail.com>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
 <20150701.141402.587634025761326092.davem@davemloft.net> <CANn89iK8SMLFNA6J0WB_qVTB+-C6qoX2o7-CxvwrLVua-cXzWg@mail.gmail.com>
 <CALCkm3fUmO0pmQEgrwjoNy5PjFk+mzYbUd1wmBsV7hVSHBngPA@mail.gmail.com>
 <CANn89iL4Pr1MQ_7uDcKEyT+D+193cQk9R304JsMAE0od4+ieEQ@mail.gmail.com>
 <CALCkm3f1nmi-st-siG0CRv32X7G5d6+JCsOWM01Rh3Qif3HtuQ@mail.gmail.com>
 <alpine.LFD.2.11.1507021135180.2615@ja.home.ssi.bg> <CALCkm3c8N0HE774TU96wjdC_wrkDOwAHEDaSOS+eVJD22zCXmg@mail.gmail.com>
 <CALCkm3eGTi6038Zq7N+XZsX3v5vbP0wY42ded0YUbBn0pjSE8Q@mail.gmail.com> <alpine.LFD.2.11.1507031131010.1649@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	"agartrell@fb.com" <agartrell@fb.com>,
	netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:32977 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108AbbGCVzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 17:55:08 -0400
Received: by qgef3 with SMTP id f3so1159735qge.0
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 14:55:07 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1507031131010.1649@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey

On Fri, Jul 3, 2015 at 1:32 AM, Julian Anastasov <ja@ssi.bg> wrote:

> To summarize:
>         - we should call skb_orphan as soon as possible after
>         deciding if packets goes to local or remote real server
>         but only for skb->sk set by early_demux, not for packets
>         sent by TCP

Yeah, agree

>         - if packets go to local server IPVS should not touch
>         skb->dst, skb->sk, etc (NF_ACCEPT case)

Yeah, the thing is that early demux could totally match for a socket
that existed before we created the service, and in that instance it
might make the most sense to retain the connection and simply
NF_ACCEPT.  The problem with that approach though is that is that the
behavior changes if early_demux is not enabled.  I believe that we
should just do the consistent thing and always drop the early_demux
result if bound for non-local, as you've said.

The interesting thing though is that, for the purposes of routing,
enabling early_demux does change the behavior.  I suspect that's a
bug, but it's far enough away from actual use cases that it's probably
fine (who is out there tearing down addresses and setting up routes in
their place?)

>         - for skb->sk set by early_demux, skb_orphan should happen before
>         skb_set_owner_w in ip_vs_prepare_tunneled_skb because
>         skb_set_owner_w will try to increase sk_wmem_alloc which is
>         wrong for early_demux phase

Yeah that's my thinking as well.

>         - reaching skb_set_owner_w code for skb->sk set by eraly_demux
>         looks wrong to me, it can happen on:
>                 - redirect (DNAT), if somehow we have socket too
>                 - IPVS redirect: if we forward both to local and remote
>                 real servers
>                 - not likely for forward, nobody forwards traffic
>                 destined to local IP to remote host


What do you think of the following:

commit f04c42f8041cc4ccc4cb2a30c1058136dd497a83
Author: Alex Gartrell <agartrell@fb.com>
Date:   Wed Jul 1 13:24:46 2015 -0700

    ipvs: orphan_skb in case of forwarding

    It is possible that we bind against a local socket in early_demux when we
    are actually going to want to forward it.  In this case, the socket serves
    no purpose and only serves to confuse things (particularly functions which
    implicitly expect sk_fullsock to be true, like ip_local_out).
    Additionally, skb_set_owner_w is totally broken for non full-socks.

    Signed-off-by: Alex Gartrell <agartrell@fb.com>

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf66a86..3efe719 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -527,6 +527,19 @@ static inline int
ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
        return ret;
 }

+/* In the event of a remote destination, it's possible that we would have
+ * matches against an old socket (particularly a TIME-WAIT socket). This
+ * causes havoc down the line (ip_local_out et. al. expect regular sockets
+ * and invalid memory accesses will happen) so simply drop the association
+ * in this case
+*/
+static inline void ip_vs_drop_early_demux_sk(struct sk_buff *skb) {
+       /* If dev is set, the packet came from the LOCAL_IN callback and
+        * not from a local TCP socket */
+       if (skb->dev)
+               skb_orphan(skb);
+}
+
 /* return NF_STOLEN (sent) or NF_ACCEPT if local=1 (not sent) */
 static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
                                         struct ip_vs_conn *cp, int local)
@@ -539,6 +552,7 @@ static inline int ip_vs_nat_send_or_cont(int pf,
struct sk_buff *skb,
        else
                ip_vs_update_conntrack(skb, cp, 1);
        if (!local) {
+               ip_vs_drop_early_demux_sk(skb);
                skb_forward_csum(skb);
                NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
                        NULL, skb_dst(skb)->dev, dst_output_sk);
@@ -557,6 +571,7 @@ static inline int ip_vs_send_or_cont(int pf,
struct sk_buff *skb,
        if (likely(!(cp->flags & IP_VS_CONN_F_NFCT)))
                ip_vs_notrack(skb);
        if (!local) {
+               ip_vs_drop_early_demux_sk(skb);
                skb_forward_csum(skb);
                NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
                        NULL, skb_dst(skb)->dev, dst_output_sk);
@@ -845,6 +860,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
        struct ipv6hdr *old_ipv6h = NULL;
 #endif

+       ip_vs_drop_early_demux_sk(skb);
+
        if (skb_headroom(skb) < max_headroom || skb_cloned(skb)) {
                new_skb = skb_realloc_headroom(skb, max_headroom);
                if (!new_skb)
