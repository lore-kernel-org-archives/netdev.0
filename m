From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Sun, 23 Mar 2014 16:43:52 +0200
Message-ID: <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20140320.160229.857536522237793124.davem@davemloft.net>
	<OFA209BE80.4610C3E5-ON87257CA1.00723468-87257CA1.0072346C@us.ibm.com>
	<CAF1J0HPE9L1Z4xst9ap_Z8nQ9k-N-UAbW7yre0S-wvQF5+NznA@mail.gmail.com>
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
	<CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:33089 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbaCWOnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2014 10:43:53 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so4396328pbb.28
        for <netdev@vger.kernel.org>; Sun, 23 Mar 2014 07:43:52 -0700 (PDT)
In-Reply-To: <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 23, 2014 at 11:27 AM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:

> I believe I've groked what's going on in vxlan_udp_encap_recv and
> vxlan_rcv. There are actually two unrelated problems:
>
> 1) When the vxlan is configured with IPv4 group it crashes when it
> starts to receive IPv6 IGMP packets encapsulated into IPv4 vxlan
> packets. This happens because when ipv6_rcv handles the inner packet,
> the skb->dst still refernces outer IPv4 info. The very old vxlan code
> had skb_dst_drop call in vxlan_udp_encap_recv, which was removed when
> vxlan was refactored to use iptunnel_pull_header (commit
> 7ce04758279514ca1d8ebfe322508a4a430fe2c8: "vxlan: Restructure vxlan
> receive"). The iptunnel_pull_header called skb_dst_drop until recent
> commit 10ddceb22bab11dab10ba645c7df2e4a8e7a5db5 ("ip_tunnel:multicast
> process cause panic due to skb->_skb_refdst NULL pointer").
> The simplest fix, I think, would be to restore call to skb_dst_drop in
> vxlan_udp_encap_recv.

Yep, following Mike's suggestion, adding the below call allows things to work,
where trying vxlan without OVS, e.g using

$ ip link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dev ethN

$ ifconfig vxlan42 192.168.42.54/24 up

over the net tree with 3.14-rc6 and beyond crashes instantly on node A
when node B is
taken up and starts sending, so commit 10ddceb22b indeed introduced a
regression.

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a7eb3f2..22d7484 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1150,6 +1150,8 @@ static int vxlan_udp_encap_recv(struct sock *sk,
struct sk_buff *skb)
        if (iptunnel_pull_header(skb, VXLAN_HLEN, htons(ETH_P_TEB)))
                goto drop;

+       skb_dst_drop(skb);
+
        port = inet_sk(sk)->inet_sport;

        vs = rcu_dereference_sk_user_data(sk);
