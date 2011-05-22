From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/3] vlan: Always strip the vlan header in vlan_untag.
Date: Sun, 22 May 2011 12:40:24 -0700
Message-ID: <m14o4mjzh3.fsf_-_@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38843 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366Ab1EVTk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 15:40:28 -0400
In-Reply-To: <m1ei3qjzix.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 22 May 2011 12:39:18 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Calling vlan_dev_info() on a non-vlan device gives completely undefined
results, and is no longer needed now that we no longer support keeping
the vlan tag.

Simplify and correct the code by remove the check for VLAN_FLAG_REORDER_HDR.

Additionally rename vlan_check_reorder_header to just
vlan_reorder_header as there is no check involved now.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/8021q/vlan_core.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 41495dc..302d8e3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -89,17 +89,15 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 }
 EXPORT_SYMBOL(vlan_gro_frags);
 
-static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
+static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
 {
-	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_cow(skb, skb_headroom(skb)) < 0)
-			skb = NULL;
-		if (skb) {
-			/* Lifted from Gleb's VLAN code... */
-			memmove(skb->data - ETH_HLEN,
-				skb->data - VLAN_ETH_HLEN, 12);
-			skb->mac_header += VLAN_HLEN;
-		}
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		skb = NULL;
+	if (skb) {
+		/* Lifted from Gleb's VLAN code... */
+		memmove(skb->data - ETH_HLEN,
+			skb->data - VLAN_ETH_HLEN, 12);
+		skb->mac_header += VLAN_HLEN;
 	}
 	return skb;
 }
@@ -161,7 +159,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
 
-	skb = vlan_check_reorder_header(skb);
+	skb = vlan_reorder_header(skb);
 	if (unlikely(!skb))
 		goto err_free;
 
-- 
1.7.5.1.217.g4e3aa

