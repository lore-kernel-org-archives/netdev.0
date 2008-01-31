From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH][XFRM]: Fix statistics.
Date: Thu, 31 Jan 2008 16:49:52 +0900
Message-ID: <12017657921885-git-send-email-nakam@linux-ipv6.org>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	nakam@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:38572 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1760321AbYAaHus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 02:50:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I found some XFRM statistics updates which should be applied.
This patch change user-public header defines introduced at
net-2.6.25 and I hope to make it to be applied to linux 2.6.25.


[PATCH][XFRM]: Fix statistics.

o Outbound sequence number overflow error status
  is counted as XfrmOutStateSeqError.
o Additionaly, it changes inbound sequence number replay
  error name from XfrmInSeqOutOfWindow to XfrmInStateSeqError
  to apply name scheme above.
o Inbound IPv4 UDP encapsuling type mismatch error is wrongly
  mapped to XfrmInStateInvalid then this patch fiex the error
  to XfrmInStateMismatch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

---
 Documentation/networking/xfrm_proc.txt |    8 ++++++--
 include/linux/snmp.h                   |    3 ++-
 net/xfrm/xfrm_input.c                  |    4 ++--
 net/xfrm/xfrm_output.c                 |    1 +
 net/xfrm/xfrm_proc.c                   |    3 ++-
 5 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/xfrm_proc.txt b/Documentation/networking/xfrm_proc.txt
index 53c1a58..d0d8baf 100644
--- a/Documentation/networking/xfrm_proc.txt
+++ b/Documentation/networking/xfrm_proc.txt
@@ -26,8 +26,9 @@ XfrmInStateProtoError:
 	e.g. SA key is wrong
 XfrmInStateModeError:
 	Transformation mode specific error
-XfrmInSeqOutOfWindow:
-	Sequence out of window
+XfrmInStateSeqError:
+	Sequence error
+	i.e. Sequence number is out of window
 XfrmInStateExpired:
 	State is expired
 XfrmInStateMismatch:
@@ -60,6 +61,9 @@ XfrmOutStateProtoError:
 	Transformation protocol specific error
 XfrmOutStateModeError:
 	Transformation mode specific error
+XfrmOutStateSeqError:
+	Sequence error
+	i.e. Sequence number overflow
 XfrmOutStateExpired:
 	State is expired
 XfrmOutPolBlock:
diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 86d3eff..5df62ef 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -227,7 +227,7 @@ enum
 	LINUX_MIB_XFRMINNOSTATES,		/* XfrmInNoStates */
 	LINUX_MIB_XFRMINSTATEPROTOERROR,	/* XfrmInStateProtoError */
 	LINUX_MIB_XFRMINSTATEMODEERROR,		/* XfrmInStateModeError */
-	LINUX_MIB_XFRMINSEQOUTOFWINDOW,		/* XfrmInSeqOutOfWindow */
+	LINUX_MIB_XFRMINSTATESEQERROR,		/* XfrmInStateSeqError */
 	LINUX_MIB_XFRMINSTATEEXPIRED,		/* XfrmInStateExpired */
 	LINUX_MIB_XFRMINSTATEMISMATCH,		/* XfrmInStateMismatch */
 	LINUX_MIB_XFRMINSTATEINVALID,		/* XfrmInStateInvalid */
@@ -241,6 +241,7 @@ enum
 	LINUX_MIB_XFRMOUTNOSTATES,		/* XfrmOutNoStates */
 	LINUX_MIB_XFRMOUTSTATEPROTOERROR,	/* XfrmOutStateProtoError */
 	LINUX_MIB_XFRMOUTSTATEMODEERROR,	/* XfrmOutStateModeError */
+	LINUX_MIB_XFRMOUTSTATESEQERROR,		/* XfrmOutStateSeqError */
 	LINUX_MIB_XFRMOUTSTATEEXPIRED,		/* XfrmOutStateExpired */
 	LINUX_MIB_XFRMOUTPOLBLOCK,		/* XfrmOutPolBlock */
 	LINUX_MIB_XFRMOUTPOLDEAD,		/* XfrmOutPolDead */
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 039e701..c32b50b 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -160,12 +160,12 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		}
 
 		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEINVALID);
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEMISMATCH);
 			goto drop_unlock;
 		}
 
 		if (x->props.replay_window && xfrm_replay_check(x, skb, seq)) {
-			XFRM_INC_STATS(LINUX_MIB_XFRMINSEQOUTOFWINDOW);
+			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATESEQERROR);
 			goto drop_unlock;
 		}
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index f4a1047..fc69036 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -64,6 +64,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
 			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
 			if (unlikely(x->replay.oseq == 0)) {
+				XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATESEQERROR);
 				x->replay.oseq--;
 				xfrm_audit_state_replay_overflow(x, skb);
 				err = -EOVERFLOW;
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 31d0354..2b0db13 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -22,7 +22,7 @@ static struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmInNoStates", LINUX_MIB_XFRMINNOSTATES),
 	SNMP_MIB_ITEM("XfrmInStateProtoError", LINUX_MIB_XFRMINSTATEPROTOERROR),
 	SNMP_MIB_ITEM("XfrmInStateModeError", LINUX_MIB_XFRMINSTATEMODEERROR),
-	SNMP_MIB_ITEM("XfrmInSeqOutOfWindow", LINUX_MIB_XFRMINSEQOUTOFWINDOW),
+	SNMP_MIB_ITEM("XfrmInStateSeqError", LINUX_MIB_XFRMINSTATESEQERROR),
 	SNMP_MIB_ITEM("XfrmInStateExpired", LINUX_MIB_XFRMINSTATEEXPIRED),
 	SNMP_MIB_ITEM("XfrmInStateMismatch", LINUX_MIB_XFRMINSTATEMISMATCH),
 	SNMP_MIB_ITEM("XfrmInStateInvalid", LINUX_MIB_XFRMINSTATEINVALID),
@@ -36,6 +36,7 @@ static struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmOutNoStates", LINUX_MIB_XFRMOUTNOSTATES),
 	SNMP_MIB_ITEM("XfrmOutStateProtoError", LINUX_MIB_XFRMOUTSTATEPROTOERROR),
 	SNMP_MIB_ITEM("XfrmOutStateModeError", LINUX_MIB_XFRMOUTSTATEMODEERROR),
+	SNMP_MIB_ITEM("XfrmOutStateSeqError", LINUX_MIB_XFRMOUTSTATESEQERROR),
 	SNMP_MIB_ITEM("XfrmOutStateExpired", LINUX_MIB_XFRMOUTSTATEEXPIRED),
 	SNMP_MIB_ITEM("XfrmOutPolBlock", LINUX_MIB_XFRMOUTPOLBLOCK),
 	SNMP_MIB_ITEM("XfrmOutPolDead", LINUX_MIB_XFRMOUTPOLDEAD),
-- 
1.4.4.2

