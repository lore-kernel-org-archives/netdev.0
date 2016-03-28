From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/9] openvswitch: Fix checking for new expected connections.
Date: Mon, 28 Mar 2016 19:57:55 +0200
Message-ID: <1459187882-5357-3-git-send-email-pablo@netfilter.org>
References: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50837 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751785AbcC1R6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Mar 2016 13:58:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id EFD21E839A
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A8CB8DA38E
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 16578DA391
	for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 19:58:09 +0200 (CEST)
In-Reply-To: <1459187882-5357-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

OVS should call into CT NAT for packets of new expected connections only
when the conntrack state is persisted with the 'commit' option to the
OVS CT action.  The test for this condition is doubly wrong, as the CT
status field is ANDed with the bit number (IPS_EXPECTED_BIT) rather
than the mask (IPS_EXPECTED), and due to the wrong assumption that the
expected bit would apply only for the first (i.e., 'new') packet of a
connection, while in fact the expected bit remains on for the lifetime of
an expected connection.  The 'ctinfo' value IP_CT_RELATED derived from
the ct status can be used instead, as it is only ever applicable to
the 'new' packets of the expected connection.

Fixes: 05752523e565 ('openvswitch: Interface with NAT.')
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/openvswitch/conntrack.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index dc5eb29..47f7c62 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -664,11 +664,12 @@ static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
 
 	/* Determine NAT type.
 	 * Check if the NAT type can be deduced from the tracked connection.
-	 * Make sure expected traffic is NATted only when committing.
+	 * Make sure new expected connections (IP_CT_RELATED) are NATted only
+	 * when committing.
 	 */
 	if (info->nat & OVS_CT_NAT && ctinfo != IP_CT_NEW &&
 	    ct->status & IPS_NAT_MASK &&
-	    (!(ct->status & IPS_EXPECTED_BIT) || info->commit)) {
+	    (ctinfo != IP_CT_RELATED || info->commit)) {
 		/* NAT an established or related connection like before. */
 		if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY)
 			/* This is the REPLY direction for a connection
-- 
2.1.4
