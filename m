From: Phil Sutter <phil@nwl.cc>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 7 Aug 2013 17:59:18 +0200
Message-ID: <20130807155918.GA16263@orbit.nwl.cc>
References: <20130807155443.a0355d0429f3e0b4ccbed261@canb.auug.org.au>
 <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	wireless <linux-wireless@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60808 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757052Ab3HGP7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 11:59:45 -0400
Content-Disposition: inline
In-Reply-To: <CA+icZUW+uxCsvPYcY2RRvMxRVzaBLuH9u8M4ziQNWXv=nk4b2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 07, 2013 at 10:29:18AM +0200, Sedat Dilek wrote:
> On Wed, Aug 7, 2013 at 7:54 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > Hi all,
> >
> > Changes since 20130806:
> >
> > The ext4 tree lost its build failure.
> >
> > The mvebu tree gained a build failure so I used the version from
> > next-20130806.
> >
> > The akpm tree gained conflicts against the ext4 tree.
> >
> > ----------------------------------------------------------------------------
> >
> 
> [ CC some netdev and wireless folks ]
> 
> Yesterday, I discovered an issue with net-next.
> The patch in [1] fixed the problems in my network/wifi environment.
> Hannes confirmed that virtio_net are solved, too.
> Today's next-20130807 still needs it for affected people.
> 
> - Sedat -
> 
> [1] http://marc.info/?l=linux-netdev&m=137582524017840&w=2
> [2] http://marc.info/?l=linux-netdev&m=137583048219416&w=2
> [3] http://marc.info/?t=137579712800008&r=1&w=2

Could you please try the attached patch. It limits parsing the ethernet
header (by calling eth_type_trans()) to cases when the configured
protocol is ETH_P_ALL, so at least for 802.1X this should fix the
problem.

The idea behind this patch is that users setting the protocol to
something else probably do know better and so should be left alone.

Best wishes, Phil

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="af_packet_fixup.diff"

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bbe1ece..66bc79c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1932,8 +1932,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 
 	ph.raw = frame;
 
-	skb->protocol = proto;
-	skb->dev = dev;
 	skb->priority = po->sk.sk_priority;
 	skb->mark = po->sk.sk_mark;
 	sock_tx_timestamp(&po->sk, &skb_shinfo(skb)->tx_flags);
@@ -2002,13 +2000,18 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err))
 			return err;
 
-		if (dev->type == ARPHRD_ETHER)
-			skb->protocol = eth_type_trans(skb, dev);
-
 		data += dev->hard_header_len;
 		to_write -= dev->hard_header_len;
 	}
 
+	if (dev->type == ARPHRD_ETHER &&
+	    proto = htons(ETH_P_ALL)) {
+		skb->protocol = eth_type_trans(skb, dev);
+	} else {
+		skb->protocol = proto;
+		skb->dev = dev;
+	}
+
 	max_frame_len = dev->mtu + dev->hard_header_len;
 	if (skb->protocol == htons(ETH_P_8021Q))
 		max_frame_len += VLAN_HLEN;
@@ -2331,15 +2334,17 @@ static int packet_snd(struct socket *sock,
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
-	if (dev->type == ARPHRD_ETHER) {
+	if (dev->type == ARPHRD_ETHER &&
+	    proto == htons(ETH_P_ALL)) {
 		skb->protocol = eth_type_trans(skb, dev);
-		if (skb->protocol == htons(ETH_P_8021Q))
-			reserve += VLAN_HLEN;
 	} else {
 		skb->protocol = proto;
 		skb->dev = dev;
 	}
 
+	if (skb->protocol == htons(ETH_P_8021Q))
+		reserve += VLAN_HLEN;
+
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
 		err = -EMSGSIZE;
 		goto out_free;

--VS++wcV0S1rZb1Fb--
