From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Tue, 16 Dec 2003 08:43:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312160843.58992.bdschuym@pandora.be>
References: <Pine.LNX.4.44.0312151304350.8670-200000@sorbus2.navaho> <20031215171732.4877acd1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Steve Hill <steve@navaho.co.uk>
In-Reply-To: <20031215171732.4877acd1.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 16 December 2003 02:17, David S. Miller wrote:
> There must be something in particular that the IPV4 fragmentation code
> is doing that makes these fragment reference drops get forgotten.  Hmmm...
>
> I just noticed that both bridge netfilter and IPV4 fragmentation make much
> use of the skb->cb[] control block, this may be the true source of the
> troubles.
>
> In fact, since bridge netfilter expects pointers to be there, I'm surprised
> this does not cause a crash.

It only expects a pointer in br_nf_forward_finish() for ARP traffic. I
checked and the ARP code doesn't use the control buffer.
For IP traffic, it uses the control buffer just before and just after
the call to the IP PRE_ROUTING hook.
OK, I just looked at the ip_fragment.c code and it uses the control buffer
too. You are truly amazing. I'll use skbuff.c::nf_bridge_info instead.

Steve, does this patch fix things? Of course, first remove your code from
ip_fragment.c. I haven't tested this patch yet, this will have to wait
until this evening.
Dave, I'll cook up a slightly different patch for you later, I think
nf_bridge->hh is now a bad name, I'll change it into nf_bridge->data.

thanks,
Bart

--- linux-2.6.0-test11-bk10/net/bridge/br_netfilter.c.old	2003-12-16 08:33:35.000000000 +0100
+++ linux-2.6.0-test11-bk10/net/bridge/br_netfilter.c	2003-12-16 08:34:12.000000000 +0100
@@ -38,11 +38,9 @@
 
 
 #define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
-				 (skb->cb))->daddr.ipv4)
+				 (skb->nf_bridge->hh))->daddr.ipv4)
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = (skb)->nh.iph->daddr)
 #define dnat_took_place(skb)	 (skb_origaddr(skb) != (skb)->nh.iph->daddr)
-#define clear_cb(skb)		 (memset(&skb_origaddr(skb), 0, \
-				 sizeof(struct bridge_skb_cb)))
 
 #define has_bridge_parent(device)	((device)->br_port != NULL)
 #define bridge_parent(device)		((device)->br_port->br->dev)
@@ -203,7 +201,6 @@ bridged_dnat:
 				 */
 				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
-				clear_cb(skb);
 				if (skb->protocol ==
 				    __constant_htons(ETH_P_8021Q)) {
 					skb_push(skb, VLAN_HLEN);
@@ -224,7 +221,6 @@ bridged_dnat:
 		dst_hold(skb->dst);
 	}
 
-	clear_cb(skb);
 	skb->dev = nf_bridge->physindev;
 	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
 		skb_push(skb, VLAN_HLEN);
