From: Greg KH <gregkh@suse.de>
Subject: [268/289] [stable] [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan packets when vid not used.
Date: Tue, 07 Dec 2010 17:00:45 -0800
Message-ID: <20101208005748.239994657@clark.site>
References: <20101208005821.GA2922@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:33865 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932873Ab0LHBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 20:04:01 -0500
In-Reply-To: <20101208005821.GA2922@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.36-stable review patch.  If anyone has any objections, please let us know.

------------------

From: Jesse Gross <jesse@nicira.com>

[This patch applies only to 2.6.36 stable.  The problem was introduced
in that release and is already fixed by larger changes to the vlan
code in 2.6.37.]

Normally hardware accelerated vlan packets are quickly dropped if
there is no corresponding vlan device configured.  The one exception
is promiscuous mode, where we allow all of these packets through so
they can be picked up by tcpdump.  However, this behavior causes a
crash if we actually try to receive these packets.  This fixes that
crash by ignoring packets with vids not corresponding to a configured
device in the vlan hwaccel routines and then dropping them before they
get to consumers in the network stack.


Reported-by: Ben Greear <greearb@candelatech.com>
Tested-by: Nikola Ciprich <extmaillist@linuxbox.cz>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Acked-by: David Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/8021q/vlan_core.c |    3 +++
 net/core/dev.c        |   13 +++++++++++++
 2 files changed, 16 insertions(+)

--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -43,6 +43,9 @@ int vlan_hwaccel_do_receive(struct sk_bu
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
 
+	if (unlikely(!is_vlan_dev(dev)))
+		return 0;
+
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
 
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2891,6 +2891,19 @@ static int __netif_receive_skb(struct sk
 ncls:
 #endif
 
+	/* If we got this far with a hardware accelerated VLAN tag, it means
+	 * that we were put in promiscuous mode but nobody is interested in
+	 * this vid.  Drop the packet now to prevent it from getting propagated
+	 * to other parts of the stack that won't know how to deal with packets
+	 * tagged in this manner.
+	 */
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		if (pt_prev)
+			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		kfree_skb(skb);
+		goto out;
+	}
+
 	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {


