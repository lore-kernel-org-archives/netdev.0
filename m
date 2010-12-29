From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: BUG: while bridging Ethernet and wireless device:
Date: Wed, 29 Dec 2010 16:04:27 +0100
Message-ID: <1293635067.3546.16.camel@jlt3.sipsolutions.net>
References: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:55290 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753388Ab0L2PE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 10:04:29 -0500
In-Reply-To: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-12-16 at 14:11 +0200, Tomas Winkler wrote:
> Will be happy if someone can give me some more insight. (kernel 2.6.37-rc5)

Tomas looked into it a bit more and told me that it happens on IPv6
packets. To recap, he gets

kernel BUG at include/linux/skbuff.h:1178!
with
EIP: [<f83edd65>] br_multicast_rcv+0xc95/0xe1c [bridge]

Also remember that the packets are almost fully nonlinear, when they get
here they likely have almost no data in the skb header.

I then looked at br_multicast_ipv6_rcv(), and it looks fishy:

Up to:
	skb2 = skb_clone(skb, GFP_ATOMIC);

everything's fine, since ipv6_skip_exthdr() will use
skb_header_pointer(). At this point, offset is the result of
ipv6_skip_exthdr(). Remember that skb_clone() is not skb_copy().

Then, however, we do
	__skb_pull(skb2, offset);

At this point, however, I don't see anything that guarantees that all
"offset" bytes are part of the headroom -- and indeed I think this is
where it crashes.

If it didn't crash, because this many bytes were part of the header,
continuing further into the function, however, we could still crash:

        if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
                goto out;

now makes sure that we can read the ICMPv6 header. Later, however, we do

        case ICMPV6_MGM_REPORT:
            {
                struct mld_msg *mld = (struct mld_msg *)icmp6h;
                BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
                err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);

which seems just as unsafe since "mld_mca" need not be part of the
header of the SKB. Similarly in another branch of this.

Additionally, I'm not convinced that there even is guaranteed to be
enough space in the SKB at all for the entire "struct mld_msg".

And finally, the error path in this function is confusing. Below patch
should be fine since unlike IPv4 (where this was copied maybe?) this
code unconditionally clones the SKB.

johannes

---
 net/bridge/br_multicast.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- wireless-testing.orig/net/bridge/br_multicast.c	2010-12-29 15:45:03.000000000 +0100
+++ wireless-testing/net/bridge/br_multicast.c	2010-12-29 16:03:03.000000000 +0100
@@ -1430,7 +1430,7 @@ static int br_multicast_ipv6_rcv(struct
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
 {
-	struct sk_buff *skb2 = skb;
+	struct sk_buff *skb2;
 	struct ipv6hdr *ip6h;
 	struct icmp6hdr *icmp6h;
 	u8 nexthdr;
@@ -1535,9 +1535,7 @@ static int br_multicast_ipv6_rcv(struct
 	}
 
 out:
-	__skb_push(skb2, offset);
-	if (skb2 != skb)
-		kfree_skb(skb2);
+	kfree_skb(skb2);
 	return err;
 }
 #endif



