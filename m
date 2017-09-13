From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH v2 net] sctp: potential read out of bounds in
 sctp_ulpevent_type_enabled()
Date: Thu, 14 Sep 2017 02:00:54 +0300
Message-ID: <20170913230054.fmtidvfi2swvy2mm@mwanda>
References: <20170913.092522.934509429497822082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41018 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdIMXCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 19:02:25 -0400
Content-Disposition: inline
In-Reply-To: <20170913.092522.934509429497822082.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code causes a static checker warning because Smatch doesn't trust
anything that comes from skb->data.  I've reviewed this code and I do
think skb->data can be controlled by the user here.

The sctp_event_subscribe struct has 13 __u8 fields and we want to see
if ours is non-zero.  sn_type can be any value in the 0-USHRT_MAX range.
We're subtracting SCTP_SN_TYPE_BASE which is 1 << 15 so we could read
either before the start of the struct or after the end.

This is a very old bug and it's surprising that it would go undetected
for so long but my theory is that it just doesn't have a big impact so
it would be hard to notice.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2:  Use reverse-christmas-tree local variable ordering.

diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index 1060494ac230..b8c86ec1a8f5 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -153,8 +153,12 @@ __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event);
 static inline int sctp_ulpevent_type_enabled(__u16 sn_type,
 					     struct sctp_event_subscribe *mask)
 {
+	int offset = sn_type - SCTP_SN_TYPE_BASE;
 	char *amask = (char *) mask;
-	return amask[sn_type - SCTP_SN_TYPE_BASE];
+
+	if (offset >= sizeof(struct sctp_event_subscribe))
+		return 0;
+	return amask[offset];
 }
 
 /* Given an event subscription, is this event enabled? */
