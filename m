From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3-rc snmp6 panic
Date: Wed, 14 Mar 2012 23:56:15 -0700
Message-ID: <1331794575.2543.17.camel@edumazet-laptop>
References: <20120315052506.GA5974@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:58032 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472Ab2COG4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 02:56:18 -0400
Received: by dadp12 with SMTP id p12so4355107dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 23:56:18 -0700 (PDT)
In-Reply-To: <20120315052506.GA5974@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 mars 2012 =C3=A0 01:25 -0400, Dave Jones a =C3=A9crit :
> I've been seeing an occasional panic when I shut down my router
> since I put 3.3 on there. It happens about once a week, always during
> shutdown.  It wedges before I can get a good capture of the trace.
> This is the best I've captured so far.. https://twitpic.com/8wh5l5
> (apologies in advance for blurriness)
>=20
> From comparing the Code: line, and the objdump output, the code it's
> choking on in mld_sendpack seems to be a skb_dst macro in the NF_HOOK=
=2E.
>=20
>=20
>         err =3D NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, s=
kb->dev,
>     2dd9:       4c 8b 43 20             mov    0x20(%rbx),%r8
>     2ddd:       e9 00 00 00 00          jmpq   2de2 <mld_sendpack+0x1=
b2>
> static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
> {
>         /* If refdst was not refcounted, check we still are in a=20
>          * rcu_read_lock section
>          */
>         WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
>     2de2:       48 8b 43 58             mov    0x58(%rbx),%rax
>     2de6:       a8 01                   test   $0x1,%al
>     2de8:       0f 85 d2 01 00 00       jne    2fc0 <mld_sendpack+0x3=
90>
>                 !rcu_read_lock_held() &&
>                 !rcu_read_lock_bh_held());
>         return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMAS=
K);
>     2dee:       48 83 e0 fe             and    $0xfffffffffffffffe,%r=
ax
>     2df2:       48 89 df                mov    %rbx,%rdi
>     2df5:       ff 50 58                callq  *0x58(%rax)           =
<-----  BOOM
>=20
>=20
> This machine is running an snmpd, for my mrtg setup, so the teardown =
of that
> service is probably what's triggering it. But I can start/stop it in =
a loop
> as much as I want without it happening, so maybe the kernel needs to =
accumulate
> some state from it for a while first ?
>=20
> Anyone have any ideas what's happening here ?
>=20

Hmm, please try :

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c2e3ab..22b7664 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1077,7 +1077,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_devi=
ce *dev,
 	struct net *net =3D dev_net(dev);
=20
 	if (unlikely(!idev))
-		return NULL;
+		return ERR_PTR(-ENODEV);
=20
 	rt =3D ip6_dst_alloc(&net->ipv6.ip6_dst_ops, dev, 0);
 	if (unlikely(!rt)) {
