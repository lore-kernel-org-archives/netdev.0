From: roopa@cumulusnetworks.com
Subject: [PATCH iproute2] bridge: Add master device name to bridge fdb show
Date: Tue, 27 May 2014 22:40:11 -0700
Message-ID: <1401255611-30862-1-git-send-email-roopa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, wkok@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, shm@cumulusnetworks.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36263 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbaE1FkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 01:40:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

(This patch depends on net-next patch titled
"Add bridge ifindex to bridge fdb notify msgs")

This patch adds master dev name from NDA_MASTER netlink attribute
 to bridge fdb show output

current iproute2 tries to print 'master' in the output if NTF_MASTER
is present. But, kernel today does not set NTF_MASTER during dump
requests. Which means I have not seen iproute2 bridge cmd print 'master' atall.
This patch overrides the NTF_MASTER flag if NDA_MASTER attribute is present.

Example output:

before this patch:
# bridge fdb show
44:38:39:00:27:ba dev bond2.2003 permanent
44:38:39:00:27:bb dev bond4.2003 permanent
44:38:39:00:27:bc dev bond2.2004 permanent

After this patch:
# bridge fdb show
44:38:39:00:27:ba dev bond2.2003 master br-2003 permanent
44:38:39:00:27:bb dev bond4.2003 master br-2003 permanent
44:38:39:00:27:bc dev bond2.2004 master br-2004 permanent

For comparision with the above, below is the output for NTF_SELF today,
# bridge fdb show
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:00:01:cc dev eth0 self permanent

If change in output is a concern, 'master' can be put at the end of the fdb
output line or made optional with -d[etails] option.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c              |    5 ++++-
 include/linux/neighbour.h |    1 +
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 9b720e3..d1c3da6 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -146,7 +146,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 	if (r->ndm_flags & NTF_SELF)
 		fprintf(fp, "self ");
-	if (r->ndm_flags & NTF_MASTER)
+	if (tb[NDA_MASTER])
+		fprintf(fp, "master %s ",
+			ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
+	else if (r->ndm_flags & NTF_MASTER)
 		fprintf(fp, "master ");
 	if (r->ndm_flags & NTF_ROUTER)
 		fprintf(fp, "router ");
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index d3ef583..4a1d7e9 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -24,6 +24,7 @@ enum {
 	NDA_PORT,
 	NDA_VNI,
 	NDA_IFINDEX,
+	NDA_MASTER,
 	__NDA_MAX
 };
 
-- 
1.7.10.4
