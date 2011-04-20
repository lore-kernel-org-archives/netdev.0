From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 5/9] sctp: bail from sctp_endpoint_lookup_assoc()
 if not bound
Date: Wed, 20 Apr 2011 15:29:23 +0800
Message-ID: <4DAE8B53.2080007@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61938 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1DTH3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:29:23 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

The sctp_endpoint_lookup_assoc() function uses a port hash
to lookup the association and then checks to see if any of
them are on the current endpoint.  However, if the current
endpoint is not bound, there can't be any associations on
it, thus we can bail early.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/endpointola.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index e10acc0..c8cc24e 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -325,6 +325,7 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	struct sctp_transport **transport)
 {
 	struct sctp_association *asoc = NULL;
+	struct sctp_association *tmp;
 	struct sctp_transport *t = NULL;
 	struct sctp_hashbucket *head;
 	struct sctp_ep_common *epb;
@@ -333,25 +334,32 @@ static struct sctp_association *__sctp_endpoint_lookup_assoc(
 	int rport;
 
 	*transport = NULL;
+
+	/* If the local port is not set, there can't be any associations
+	 * on this endpoint.
+	 */
+	if (!ep->base.bind_addr.port)
+		goto out;
+
 	rport = ntohs(paddr->v4.sin_port);
 
 	hash = sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
 	head = &sctp_assoc_hashtable[hash];
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, node, &head->chain) {
-		asoc = sctp_assoc(epb);
-		if (asoc->ep != ep || rport != asoc->peer.port)
-			goto next;
+		tmp = sctp_assoc(epb);
+		if (tmp->ep != ep || rport != tmp->peer.port)
+			continue;
 
-		t = sctp_assoc_lookup_paddr(asoc, paddr);
+		t = sctp_assoc_lookup_paddr(tmp, paddr);
 		if (t) {
+			asoc = tmp;
 			*transport = t;
 			break;
 		}
-next:
-		asoc = NULL;
 	}
 	read_unlock(&head->lock);
+out:
 	return asoc;
 }
 
-- 
1.6.5.2


