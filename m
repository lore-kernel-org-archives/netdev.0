From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] vxlan nits
Date: Fri, 19 Oct 2012 07:46:48 -0400
Message-ID: <201210191148.q9JBkm0v018443@lab1.dls>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:47491 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920Ab2JSLty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 07:49:54 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 19 Oct 2012 05:49:51 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 69E993E4003D
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 05:49:21 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9JBnLqr257860
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 05:49:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9JBnKd7009772
	for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 05:49:21 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixes a couple problems with vxlan.

1) Improper check of NUD_PERMANENT makes permanent forwarding table
	entries timeout too.

2) Check for "0.0.0.0" as gaddr and allow to mean "no group". The
	iproute2 patch sends gaddr even if not specified, which
	fails the IN_MULTICAST() test. This patch allows static-only
	forwarding and dropping everything else.

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 607976c..3fac9f3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -816,7 +816,7 @@ static void vxlan_cleanup(unsigned long arg)
 				= container_of(p, struct vxlan_fdb, hlist);
 			unsigned long timeout;
 
-			if (f->state == NUD_PERMANENT)
+			if (f->state & NUD_PERMANENT)
 				continue;
 
 			timeout = f->used + vxlan->age_interval * HZ;
@@ -1047,7 +1047,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 
 	if (data[IFLA_VXLAN_GROUP]) {
 		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_GROUP]);
-		if (!IN_MULTICAST(ntohl(gaddr))) {
+		if (gaddr && !IN_MULTICAST(ntohl(gaddr))) {
 			pr_debug("group address is not IPv4 multicast\n");
 			return -EADDRNOTAVAIL;
 		}
