From: Joe Eykholt <jre@nuovasystems.com>
Subject: [RFC PATCH] [BOND] Let non-IP L2 protocols receive on inactive slaves.
Date: Sat, 08 Mar 2008 14:55:47 -0800
Message-ID: <47D31973.7060905@nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:34771 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751883AbYCHWzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 17:55:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'd like to get some comments on a proposed patch to assist the
use of L2 protocols in the presence of bonding.

This is for when active/backup mode is used to bond IP, but
it is still appropriate to handle some L2 protocols (e.g.,
LLDP and FCoE) on the backup (inactive) links.

The existing Linux bonding hook drops (almost) all traffic
being received on the inactive slave interface except for
ARP replies used by bonding itself to test connectivity.

Once we are past the bonding hook, netif_receive_skb()
delivers the packet to all packet_type structures
that match the following criteria:
  1) The type field matches either ETH_P_ALL
     or the received packet's type AND
  2) the dev field is NULL or matches the (master)
     interface dev pointer.

The packet_type.dev field is usually NULL.
Almost all protocols in the kernel initialize the dev
field to NULL and don't touch it.  The only exceptions
are the bonding code itself and AF_PACKET during the bind
operation.

My proposal is to tweak the semantics so that when the
packet_type dev field is non-NULL and matches
the slave device, we deliver the frame to the packet_type
function even in the case where the bonding driver would've
dropped it.
This provides for any L2 protocol and user-level program
using AF_PACKET bound to the individual slave interface.
If AF_PACKET is not bound, it'll receive on all interfaces
still except passive slaves, and will receive from active
slaves as if the frame arrived on the master (the current
behavior).

It's important to note that this is a potential change
for user programs that bind to slave devices, since they
wouldn't have received traffic while the slave was bound in
the past.  I'm not sure how many such programs there might
be so I'm unsure how concerned to be about this.
This however is how I think it should work.

So, here is a patch that accomplishes this, just for
discussion purposes.

The way this works is a tiny bit tricky.  Instead of testing
ptype->dev == NULL, when checking for packet delivery,
I use a pointer 'wild_card' which is NULL in most cases and
test ptype->dev == wild_card.

This way the non-bonding case is unaffected.  In the bonding
case, if skb_bond_should_drop() returns non-zero,
the wild_card is set to dev, the original slave device,
so only exact matches to the slave will pass.
The packet_types with dev == NULL will not be matched.

If no packet_types match, the drop at the end of the
routine takes care of dropping the packet.

In the non-drop case we still set dev = dev->master and
skb->dev = dev.

I moved skb_bond() into netif_receive() because otherwise it'd
need two return values, orig_dev and the wild_card.

The performance impact of this change should be neglegible.
If bonding is off, the test is only slightly more expensive.
If no protocols are registered with non-NULL devs, which is
usually the case, the extra test in the ptype list is never
reached.  In the bonding case, it does mean that if heavy
traffic were arriving on the backup slave, more checks
would be done before dropping the traffic.  That would
be unusual.

This approach could be extended to remove some of the
special cases in 'skb_bond_should_drop()' by having the
bonding driver register packet_type matches for itself on
the inactive slave.

There are related issues with MAC addresses, but I think
there are good solutions to them, and I'd like to discuss
that separately.

Please let me know what you think.

    Thanks,
    Joe Eykholt


[PATCH] Allow bond to receive some packets on the passive side.

commit 4e4fd41cbdeab598febe9782de76e745fbe1b7dc
Author: Joe Eykholt <jre@nuovasystems.com>
Date:   Wed Mar 5 18:32:37 2008 -0800

    Allow bond to receive some packets on inactive slaves.

    This is for protocols which do not wish to be bonded
    or do not wish to have their packets dropped on the
    passive side of an active/passive bond.

    Only a few cases currently use the packet_type dev match
    to select one specific device.  All other packet_types
    have dev == NULL.  There are two such cases in the
    bonding code for ARP and LACP, and one for af_packet,
    where it may bond to a specific interface.

    In these cases, we change the semantic to mean that packets
    matching the type and device will still be received,
    even on inactive slaves of bonds.

diff --git a/net/core/dev.c b/net/core/dev.c
index fcdf03c..cc70055 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1816,21 +1816,6 @@ int netif_rx_ni(struct sk_buff *skb)

 EXPORT_SYMBOL(netif_rx_ni);

-static inline struct net_device *skb_bond(struct sk_buff *skb)
-{
-       struct net_device *dev = skb->dev;
-
-       if (dev->master) {
-               if (skb_bond_should_drop(skb)) {
-                       kfree_skb(skb);
-                       return NULL;
-               }
-               skb->dev = dev->master;
-       }
-
-       return dev;
-}
-

 static void net_tx_action(struct softirq_action *h)
 {
@@ -2022,6 +2007,8 @@ out:
 int netif_receive_skb(struct sk_buff *skb)
 {
        struct packet_type *ptype, *pt_prev;
+       struct net_device *dev;
+       struct net_device *wild_card;
        struct net_device *orig_dev;
        int ret = NET_RX_DROP;
        __be16 type;
@@ -2036,10 +2023,17 @@ int netif_receive_skb(struct sk_buff *skb)
        if (!skb->iif)
                skb->iif = skb->dev->ifindex;

-       orig_dev = skb_bond(skb);
-
-       if (!orig_dev)
-               return NET_RX_DROP;
+       wild_card = NULL;
+       dev = skb->dev;
+       orig_dev = dev;
+       if (dev->master) {
+               if (skb_bond_should_drop(skb)) {
+                       wild_card = dev;        /* deliver only exact match */
+               } else {
+                       dev = dev->master;
+                       skb->dev = dev;
+               }
+       }

        __get_cpu_var(netdev_rx_stat).total++;

@@ -2059,7 +2053,7 @@ int netif_receive_skb(struct sk_buff *skb)
 #endif

        list_for_each_entry_rcu(ptype, &ptype_all, list) {
-               if (!ptype->dev || ptype->dev == skb->dev) {
+               if (ptype->dev == wild_card || ptype->dev == skb->dev) {
                        if (pt_prev)
                                ret = deliver_skb(skb, pt_prev, orig_dev);
                        pt_prev = ptype;
@@ -2084,7 +2078,8 @@ ncls:
        list_for_each_entry_rcu(ptype,
                        &ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
                if (ptype->type == type &&
-                   (!ptype->dev || ptype->dev == skb->dev)) {
+                   (ptype->dev == wild_card || ptype->dev == skb->dev ||
+                    ptype->dev == orig_dev)) {
                        if (pt_prev)
                                ret = deliver_skb(skb, pt_prev, orig_dev);
                        pt_prev = ptype;




