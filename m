From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: llc: fix order of evaluation in llc_conn_ac_inc_vr_by_1
Date: Wed,  1 Jan 2014 23:04:25 +0100
Message-ID: <1388613865-25003-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655AbaAAWEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 17:04:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function llc_conn_ac_inc_vr_by_1() evaluates via macro
PDU_GET_NEXT_Vr() into ...

  llc_sk(sk)->vR = ++llc_sk(sk)->vR & 0xffffffffffffff7f

... but the order in which the side effects take place is
undefined because there is no intervening sequence point.

As llc_sk(sk)->vR is written in llc_sk(sk)->vR (assignment
left-hand side) and written in ++llc_sk(sk)->vR & 0xffffffffffffff7f
this might possibly yield undefined behavior.

The final value of llc_sk(sk)->vR is ambiguous, because,
depending on the order of expression evaluation, the
increment may occur before, after, or interleaved with
the assignment. In C, evaluating such an expression yields
undefined behavior.

Since we're doing the increment via PDU_GET_NEXT_Vr() macro
and the only place it is being used is from
llc_conn_ac_inc_vr_by_1(), in order to increment vR by 1
with a follow-up optimized modulo, rewrite the expression
into ((vR + 1) & CONST) in order to fix this.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 include/net/llc_pdu.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index 31e2de7..c0f0a13 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -142,7 +142,7 @@
 #define LLC_S_PF_IS_1(pdu)     ((pdu->ctrl_2 & LLC_S_PF_BIT_MASK) ? 1 : 0)
 
 #define PDU_SUPV_GET_Nr(pdu)   ((pdu->ctrl_2 & 0xFE) >> 1)
-#define PDU_GET_NEXT_Vr(sn)    (++sn & ~LLC_2_SEQ_NBR_MODULO)
+#define PDU_GET_NEXT_Vr(sn)    (((sn) + 1) & ~LLC_2_SEQ_NBR_MODULO)
 
 /* FRMR information field macros */
 
-- 
1.7.11.7
