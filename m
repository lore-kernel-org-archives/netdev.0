From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: 3.12-rc7 regression - network panic from ipv6
Date: Wed, 30 Oct 2013 14:09:45 +0100
Message-ID: <20131030130945.GJ31491@secunet.com>
References: <alpine.SOC.1.00.1310292221550.19416@math.ut.ee>
 <20131029210758.GA18323@order.stressinduktion.org>
 <alpine.SOC.1.00.1310292338010.22172@math.ut.ee>
 <20131029.174258.1677867676998240250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mroos@linux.ee, hannes@stressinduktion.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131029.174258.1677867676998240250.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 29, 2013 at 05:42:58PM -0400, David Miller wrote:
> From: Meelis Roos <mroos@linux.ee>
> Date: Tue, 29 Oct 2013 23:38:28 +0200 (EET)
> 
> >> > Some bad news - in a system where 3.12-rc6 and earlier worked fine, 
> >> > 3.12-rc7 panics or hangs repeatedly with network traffic (torrent being 
> >> > good test). First there is BUG from ipv6 code, followed by panic.
> >> 
> >> Could you do a bisect on this? There seems to be one commit for this
> >> particular function _decode_session6:
> >> 
> >> commit bafd4bd4dcfa13145db7f951251eef3e10f8c278
> >> Author: Steffen Klassert <steffen.klassert@secunet.com>
> >> Date:   Mon Sep 9 10:38:38 2013 +0200
> >> 
> >>     xfrm: Decode sessions with output interface.
> >>     
> >>     The output interface matching does not work on forward
> >>     policy lookups, the output interface of the flowi is
> >>     always 0. Fix this by setting the output interface when
> >>     we decode the session.
> >> 
> >> Maybe try to just revert this change locally and try again?
> > 
> > Yes, just reverting this patch on top of rc7 gets rid of the problem for 
> > me.
> 
> Steffen please fix this or I'll have to revert.

I was a bit surprised that the skb has no dst_entry attached.
But in the reported case, ip6_frag_queue() removes the dst_entry
explicitly on all but the last received fragments. And unlike the
ipv4 case, it does not restore it before ip6_expire_frag_queue()
calls icmpv6_send().

I'm currently testing the patch below. Meelis, could you please
check if this patch fixes your problems?

Unfortunately I'm off without network access for the whole day
tomorrow. So in case the patch fixes the problems, I'd integrate it
into the final ipsec pull request for this release cycle on friday.


Subject: [PATCH] xfrm: Fix null pointer dereference when decoding sessions

On some codepaths the skb does not have a dst entry
when xfrm_decode_session() is called. So check for
a valid skb_dst() before dereferencing the device
interface index. We use 0 as the device index if
there is no valid skb_dst(), or at reverse decoding
we use skb_iif as device interface index.

Bug was introduced with git commit bafd4bd4dc
("xfrm: Decode sessions with output interface.").

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_policy.c |    6 +++++-
 net/ipv6/xfrm6_policy.c |    6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4764ee4..e1a6393 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -104,10 +104,14 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	const struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 	struct flowi4 *fl4 = &fl->u.ip4;
+	int oif = 0;
+
+	if (skb_dst(skb))
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
-	fl4->flowi4_oif = skb_dst(skb)->dev->ifindex;
+	fl4->flowi4_oif = reverse ? skb->skb_iif : oif;
 
 	if (!ip_is_fragment(iph)) {
 		switch (iph->protocol) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index dd503a3..5f8e128 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -135,10 +135,14 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	struct ipv6_opt_hdr *exthdr;
 	const unsigned char *nh = skb_network_header(skb);
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
+	int oif = 0;
+
+	if (skb_dst(skb))
+		oif = skb_dst(skb)->dev->ifindex;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
-	fl6->flowi6_oif = skb_dst(skb)->dev->ifindex;
+	fl6->flowi6_oif = reverse ? skb->skb_iif : oif;
 
 	fl6->daddr = reverse ? hdr->saddr : hdr->daddr;
 	fl6->saddr = reverse ? hdr->daddr : hdr->saddr;
-- 
1.7.9.5
