From: David Miller <davem@davemloft.net>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Fri, 15 Nov 2013 17:44:26 -0500 (EST)
Message-ID: <20131115.174426.1448825246187940374.davem@davemloft.net>
References: <20131115183422.GA9417@pomac.netswarm.net>
	<CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pomac@vapor.com, linux-kernel@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org, alex.aring@gmail.com
To: bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 15 Nov 2013 15:29:53 -0700

> [+cc David, Eric, Alex, netdev]
> 
> Alex reported a similar issue at
> http://marc.info/?l=linux-netdev&m=138355719901790&w=4

Fixed by:

commit 84502b5ef9849a9694673b15c31bd3ac693010ae
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Wed Oct 30 11:16:28 2013 +0100

    xfrm: Fix null pointer dereference when decoding sessions
    
    On some codepaths the skb does not have a dst entry
    when xfrm_decode_session() is called. So check for
    a valid skb_dst() before dereferencing the device
    interface index. We use 0 as the device index if
    there is no valid skb_dst(), or at reverse decoding
    we use skb_iif as device interface index.
    
    Bug was introduced with git commit bafd4bd4dc
    ("xfrm: Decode sessions with output interface.").
    
    Reported-by: Meelis Roos <mroos@linux.ee>
    Tested-by: Meelis Roos <mroos@linux.ee>
    Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

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
