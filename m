From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sit tunnel slow since added GSO/TSO support
Date: Sat, 14 Dec 2013 17:23:49 -0800
Message-ID: <1387070629.19078.195.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52AB322B.7030802@redhat.com>
		 <1386952124.19078.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386975268.19078.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52ACCCB3.7010401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:49683 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab3LOBXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 20:23:51 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so4072480pbc.13
        for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 17:23:51 -0800 (PST)
In-Reply-To: <52ACCCB3.7010401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-12-14 at 22:25 +0100, Michal Schmidt wrote:
> On 12/13/2013 11:54 PM, Eric Dumazet wrote:
> > I tried the same setup than before and got good behavior on current
> > net-next kernel
> >
> > modprobe sit
> > ip link set sit0 up
> > ip -6 addr add dev sit0 2002:af6:1153::/64
> > ip -6 ro add 2002:a00::/24 via fe80:: dev sit0
> 
> Eric,
> in my test I do not use sit0. I create a new tunnel interface:
> ip tun add sittun mode sit remote $REMOTE_IPV4 local $LOCAL_IPV4 \
>    dev $IFACE
> 
> Looking at "ip tun show" I see that sit0 has the nopmtudisc option by 
> default, while sittun does not.
> 
> As I wrote in my original message, using nopmtudisc when creating my 
> tunnel interface works around the problem.
> 
> So I think nopmtudisc is the key difference in our setups.

Oh right.

Iguess the following should help ?

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba3359a..a710fdec42d3 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -924,7 +924,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		if (tunnel->parms.iph.daddr && skb_dst(skb))
 			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
-		if (skb->len > mtu) {
+		if (skb->len > mtu && !skb_is_gso(skb)) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
