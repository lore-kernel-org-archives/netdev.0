From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] sctp: fix memory leak of the ASCONF queue when free asoc
Date: Wed, 25 May 2011 15:48:02 +0800
Message-ID: <4DDCB432.7000903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56760 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755676Ab1EYHsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 03:48:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an ASCONF chunk is outstanding, then the following ASCONF
chunk will be queued for later transmission. But when we free
the asoc, we forget to free the ASCONF queue at the same time,
this will cause memory leak.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/associola.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 1a21c57..525f97c 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -64,6 +64,7 @@
 /* Forward declarations for internal functions. */
 static void sctp_assoc_bh_rcv(struct work_struct *work);
 static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc);
+static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc);
 
 /* Keep track of the new idr low so that we don't re-use association id
  * numbers too fast.  It is protected by they idr spin lock is in the
@@ -446,6 +447,9 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Free any cached ASCONF_ACK chunk. */
 	sctp_assoc_free_asconf_acks(asoc);
 
+	/* Free the ASCONF queue. */
+	sctp_assoc_free_asconf_queue(asoc);
+
 	/* Free any cached ASCONF chunk. */
 	if (asoc->addip_last_asconf)
 		sctp_chunk_free(asoc->addip_last_asconf);
@@ -1578,6 +1582,18 @@ retry:
 	return error;
 }
 
+/* Free the ASCONF queue */
+static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc)
+{
+	struct sctp_chunk *asconf;
+	struct sctp_chunk *tmp;
+
+	list_for_each_entry_safe(asconf, tmp, &asoc->addip_chunk_list, list) {
+		list_del_init(&asconf->list);
+		sctp_chunk_free(asconf);
+	}
+}
+
 /* Free asconf_ack cache */
 static void sctp_assoc_free_asconf_acks(struct sctp_association *asoc)
 {
-- 
1.6.5.2


