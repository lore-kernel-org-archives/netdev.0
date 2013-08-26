From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: reorder sctp_globals to reduce cacheline usage
Date: Mon, 26 Aug 2013 16:34:00 +0200
Message-ID: <1377527640-22447-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab3HZOeC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 10:34:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce cacheline usage from 2 to 1 cacheline for sctp_globals structure. By
reordering elements, we can close gaps and simply achieve the following:

Current situation:
  /* size: 80, cachelines: 2, members: 10 */
  /* sum members: 57, holes: 4, sum holes: 16 */
  /* padding: 7 */
  /* last cacheline: 16 bytes */

Afterwards:
  /* size: 64, cachelines: 1, members: 10 */
  /* padding: 7 */

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 422db6c..2174d8d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -113,29 +113,27 @@ struct sctp_hashbucket {
 
 /* The SCTP globals structure. */
 extern struct sctp_globals {
-	/* The following variables are implementation specific.	 */
-
-	/* Default initialization values to be applied to new associations. */
-	__u16 max_instreams;
-	__u16 max_outstreams;
-
 	/* This is a list of groups of functions for each address
 	 * family that we support.
 	 */
 	struct list_head address_families;
 
 	/* This is the hash of all endpoints. */
-	int ep_hashsize;
 	struct sctp_hashbucket *ep_hashtable;
-
 	/* This is the hash of all associations. */
-	int assoc_hashsize;
 	struct sctp_hashbucket *assoc_hashtable;
-
 	/* This is the sctp port control hash.	*/
-	int port_hashsize;
 	struct sctp_bind_hashbucket *port_hashtable;
 
+	/* Sizes of above hashtables. */
+	int ep_hashsize;
+	int assoc_hashsize;
+	int port_hashsize;
+
+	/* Default initialization values to be applied to new associations. */
+	__u16 max_instreams;
+	__u16 max_outstreams;
+
 	/* Flag to indicate whether computing and verifying checksum
 	 * is disabled. */
         bool checksum_disable;
-- 
1.7.11.7
