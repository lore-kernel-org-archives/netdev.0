From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [Bridge] RE: [VLAN] Re: [PATCH/RFC] Let {ip, arp}tables "see"
	bridged VLAN tagged{I,AR}P packets
Date: 08 Oct 2003 10:09:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065600565.2572.209.camel@cyan.cph.tpack.net>
References: <5B537508CDBED3118403009027745A210B8C1499@knant18.kna.flextronics.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Linux 802.1Q VLAN'" <vlan@wanfear.com>,
        Bart De Schuymer <bdschuym@pandora.be>, netdev@oss.sgi.com,
        bridge <bridge@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian Darnell <Christian.Darnell@se.flextronics.com>
In-Reply-To: <5B537508CDBED3118403009027745A210B8C1499@knant18.kna.flextronics.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-10-07 at 11:06, Christian Darnell wrote:

> Hi Ben and all others, 
> 
> Just to clarify for other who hasn't been a part of this discussion before. 
> 
> ---- 8< ----
> When trying to grab a packet with pcap when using VLAN the beginning of the
> packet is corrupt an the VLAN TCI bits are missing. This is only a problem
> when sniffing on incoming traffic not outgoing.
> 
> 00 60 08 50 00 60 08 50 26 2a 00 60 08 6a b4 53 xx xx xx xx 08 00 45 00
> ^^^^^^^^^^^                                     ^^^^^^^^^^^^
> Where does these bytes come from?               Bytes missing (VLAN header)?
> 
> The correct MAC addresses here are:
> 00 60 08 50 26 2a and 00 60 08 6a b4 53
> ---- 8< ----

This is because the VLAN code is mangling shared data.
You need to do something like this:


--- linux-2.4/net/8021q/vlan_dev.c.org	2003-02-25 15:23:09.000000000
+0100
+++ linux-2.4/net/8021q/vlan_dev.c	2003-10-07 16:01:29.000000000 +0200
@@ -75,7 +75,12 @@
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff
*skb)
 {
 	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
-		skb = skb_share_check(skb, GFP_ATOMIC);
+		if (skb_shared(skb) || skb_cloned(skb)) {
+			struct sk_buff *nskb;
+			nskb = skb_copy(skb, GFP_ATOMIC);
+			kfree_skb(skb);
+			skb = nskb;
+		}
 		if (skb) {
 			/* Lifted from Gleb's VLAN code... */
 			memmove(skb->data - ETH_HLEN,


Christian, could you try this out?


Regarding sharing, the following should be applied as well.
The VLAN code is handed shared sk_buff's, but doesn't handle them
as such.


--- linux-2.4/net/8021q/vlan.c.org	2003-02-25 15:23:09.000000000 +0100
+++ linux-2.4/net/8021q/vlan.c	2003-10-07 16:02:52.000000000 +0200
@@ -67,7 +67,7 @@
 	type: __constant_htons(ETH_P_8021Q),
 	dev:  NULL,
 	func: vlan_skb_recv, /* VLAN receive method */
-	data: (void *)(-1),  /* Set here '(void *)1' when this code can SHARE
SKBs */
+	data: NULL,          /* Set here '(void *)1' when this code can SHARE
SKBs */
 	next: NULL
 };
 

I guess this is a special case of "off-by-one" ;-)

-Tommy
