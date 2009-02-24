From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/06: nfnetlink_log: fix per-rule qthreshold override
Date: Tue, 24 Feb 2009 15:52:46 +0100 (MET)
Message-ID: <20090224145246.9789.79896.sendpatchset@x2.localnet>
References: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709AbZBXOwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 09:52:49 -0500
In-Reply-To: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 5ca431f9ae8db8c6edb9c64bebe6d6521077afd6
Author: Eric Leblond <eric@inl.fr>
Date:   Wed Feb 18 15:29:23 2009 +0100

    netfilter: nfnetlink_log: fix per-rule qthreshold override
    
    In NFLOG the per-rule qthreshold should overrides per-instance only
    it is set. With current code, the per-rule qthreshold is 1 if not set
    and it overrides the per-instance qthreshold.
    
    This patch modifies the default xt_NFLOG threshold from 1 to
    0. Thus a value of 0 means there is no per-rule setting and the instance
    parameter has to apply.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_NFLOG.h b/include/linux/netfilter/xt_NFLOG.h
index cdcd0ed..4b36aeb 100644
--- a/include/linux/netfilter/xt_NFLOG.h
+++ b/include/linux/netfilter/xt_NFLOG.h
@@ -2,7 +2,7 @@
 #define _XT_NFLOG_TARGET
 
 #define XT_NFLOG_DEFAULT_GROUP		0x1
-#define XT_NFLOG_DEFAULT_THRESHOLD	1
+#define XT_NFLOG_DEFAULT_THRESHOLD	0
 
 #define XT_NFLOG_MASK			0x0
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index fa49dc7..580b837 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -590,8 +590,10 @@ nfulnl_log_packet(u_int8_t pf,
 
 	qthreshold = inst->qthreshold;
 	/* per-rule qthreshold overrides per-instance */
-	if (qthreshold > li->u.ulog.qthreshold)
-		qthreshold = li->u.ulog.qthreshold;
+	if (li->u.ulog.qthreshold)
+		if (qthreshold > li->u.ulog.qthreshold)
+			qthreshold = li->u.ulog.qthreshold;
+
 
 	switch (inst->copy_mode) {
 	case NFULNL_COPY_META:
