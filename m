From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] ISDN: eicon: switch to use native bitmaps
Date: Tue,  4 Jul 2017 13:34:51 +0300
Message-ID: <20170704103451.52654-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:53232 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752040AbdGDKez (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Jul 2017 06:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two arrays are clearly bit maps, so, make that explicit by converting to
bitmap API and remove custom helpers.

Note sig_ind() uses out of boundary bit to (looks like) protect against
potential bitmap_empty() checks for the same bitmap.

This patch removes that since:
1) that didn't guarantee atomicity anyway;
2) the first operation inside the for-loop is set bit in the bitmap
   (which effectively makes it non-empty);
3) group_optimization() doesn't utilize possible emptiness of the bitmap
   in question.

Thus, if there is a protection needed it should be implemented properly.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/isdn/hardware/eicon/divacapi.h |  16 +--
 drivers/isdn/hardware/eicon/message.c  | 247 ++++++++-------------------------
 2 files changed, 58 insertions(+), 205 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divacapi.h b/drivers/isdn/hardware/eicon/divacapi.h
index a315a2914d70..c4868a0d82f4 100644
--- a/drivers/isdn/hardware/eicon/divacapi.h
+++ b/drivers/isdn/hardware/eicon/divacapi.h
@@ -26,15 +26,7 @@
 
 /*#define DEBUG */
 
-
-
-
-
-
-
-
-
-
+#include <linux/types.h>
 
 #define IMPLEMENT_DTMF 1
 #define IMPLEMENT_LINE_INTERCONNECT2 1
@@ -82,8 +74,6 @@
 #define CODEC_PERMANENT    0x02
 #define ADV_VOICE          0x03
 #define MAX_CIP_TYPES      5  /* kind of CIP types for group optimization */
-#define C_IND_MASK_DWORDS  ((MAX_APPL + 32) >> 5)
-
 
 #define FAX_CONNECT_INFO_BUFFER_SIZE  256
 #define NCPI_BUFFER_SIZE              256
@@ -265,8 +255,8 @@ struct _PLCI {
 	word          ncci_ring_list;
 	byte          inc_dis_ncci_table[MAX_CHANNELS_PER_PLCI];
 	t_std_internal_command internal_command_queue[MAX_INTERNAL_COMMAND_LEVELS];
-	dword         c_ind_mask_table[C_IND_MASK_DWORDS];
-	dword         group_optimization_mask_table[C_IND_MASK_DWORDS];
+	DECLARE_BITMAP(c_ind_mask_table, MAX_APPL);
+	DECLARE_BITMAP(group_optimization_mask_table, MAX_APPL);
 	byte          RBuffer[200];
 	dword         msg_in_queue[MSG_IN_QUEUE_SIZE/sizeof(dword)];
 	API_SAVE      saved_msg;
diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 3b11422b1cce..eadd1ed1e014 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -23,9 +23,7 @@
  *
  */
 
-
-
-
+#include <linux/bitmap.h>
 
 #include "platform.h"
 #include "di_defs.h"
@@ -35,19 +33,9 @@
 #include "mdm_msg.h"
 #include "divasync.h"
 
-
-
 #define FILE_ "MESSAGE.C"
 #define dprintf
 
-
-
-
-
-
-
-
-
 /*------------------------------------------------------------------*/
 /* This is options supported for all adapters that are server by    */
 /* XDI driver. Allo it is not necessary to ask it from every adapter*/
@@ -72,9 +60,6 @@ static dword diva_xdi_extended_features = 0;
 /*------------------------------------------------------------------*/
 
 static void group_optimization(DIVA_CAPI_ADAPTER *a, PLCI *plci);
-static void set_group_ind_mask(PLCI *plci);
-static void clear_group_ind_mask_bit(PLCI *plci, word b);
-static byte test_group_ind_mask_bit(PLCI *plci, word b);
 void AutomaticLaw(DIVA_CAPI_ADAPTER *);
 word CapiRelease(word);
 word CapiRegister(word);
@@ -1087,106 +1072,6 @@ static void plci_remove(PLCI *plci)
 }
 
 /*------------------------------------------------------------------*/
-/* Application Group function helpers                               */
-/*------------------------------------------------------------------*/
-
-static void set_group_ind_mask(PLCI *plci)
-{
-	word i;
-
-	for (i = 0; i < C_IND_MASK_DWORDS; i++)
-		plci->group_optimization_mask_table[i] = 0xffffffffL;
-}
-
-static void clear_group_ind_mask_bit(PLCI *plci, word b)
-{
-	plci->group_optimization_mask_table[b >> 5] &= ~(1L << (b & 0x1f));
-}
-
-static byte test_group_ind_mask_bit(PLCI *plci, word b)
-{
-	return ((plci->group_optimization_mask_table[b >> 5] & (1L << (b & 0x1f))) != 0);
-}
-
-/*------------------------------------------------------------------*/
-/* c_ind_mask operations for arbitrary MAX_APPL                     */
-/*------------------------------------------------------------------*/
-
-static void clear_c_ind_mask(PLCI *plci)
-{
-	word i;
-
-	for (i = 0; i < C_IND_MASK_DWORDS; i++)
-		plci->c_ind_mask_table[i] = 0;
-}
-
-static byte c_ind_mask_empty(PLCI *plci)
-{
-	word i;
-
-	i = 0;
-	while ((i < C_IND_MASK_DWORDS) && (plci->c_ind_mask_table[i] == 0))
-		i++;
-	return (i == C_IND_MASK_DWORDS);
-}
-
-static void set_c_ind_mask_bit(PLCI *plci, word b)
-{
-	plci->c_ind_mask_table[b >> 5] |= (1L << (b & 0x1f));
-}
-
-static void clear_c_ind_mask_bit(PLCI *plci, word b)
-{
-	plci->c_ind_mask_table[b >> 5] &= ~(1L << (b & 0x1f));
-}
-
-static byte test_c_ind_mask_bit(PLCI *plci, word b)
-{
-	return ((plci->c_ind_mask_table[b >> 5] & (1L << (b & 0x1f))) != 0);
-}
-
-static void dump_c_ind_mask(PLCI *plci)
-{
-	word i, j, k;
-	dword d;
-	char *p;
-	char buf[40];
-
-	for (i = 0; i < C_IND_MASK_DWORDS; i += 4)
-	{
-		p = buf + 36;
-		*p = '\0';
-		for (j = 0; j < 4; j++)
-		{
-			if (i + j < C_IND_MASK_DWORDS)
-			{
-				d = plci->c_ind_mask_table[i + j];
-				for (k = 0; k < 8; k++)
-				{
-					*(--p) = hex_asc_lo(d);
-					d >>= 4;
-				}
-			}
-			else if (i != 0)
-			{
-				for (k = 0; k < 8; k++)
-					*(--p) = ' ';
-			}
-			*(--p) = ' ';
-		}
-		dbug(1, dprintf("c_ind_mask =%s", (char *) p));
-	}
-}
-
-
-
-
-
-#define dump_plcis(a)
-
-
-
-/*------------------------------------------------------------------*/
 /* translation function for each message                            */
 /*------------------------------------------------------------------*/
 
@@ -1457,13 +1342,13 @@ static byte connect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 		return 1;
 	}
 	else if (plci->State == INC_CON_PENDING || plci->State == INC_CON_ALERT) {
-		clear_c_ind_mask_bit(plci, (word)(appl->Id - 1));
-		dump_c_ind_mask(plci);
+		__clear_bit(appl->Id - 1, plci->c_ind_mask_table);
+		dbug(1, dprintf("c_ind_mask =%*pb", MAX_APPL, plci->c_ind_mask_table));
 		Reject = GET_WORD(parms[0].info);
 		dbug(1, dprintf("Reject=0x%x", Reject));
 		if (Reject)
 		{
-			if (c_ind_mask_empty(plci))
+			if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL))
 			{
 				if ((Reject & 0xff00) == 0x3400)
 				{
@@ -1553,11 +1438,8 @@ static byte connect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 				sig_req(plci, CALL_RES, 0);
 			}
 
-			for (i = 0; i < max_appl; i++) {
-				if (test_c_ind_mask_bit(plci, i)) {
-					sendf(&application[i], _DISCONNECT_I, Id, 0, "w", _OTHER_APPL_CONNECTED);
-				}
-			}
+			for_each_set_bit(i, plci->c_ind_mask_table, max_appl)
+				sendf(&application[i], _DISCONNECT_I, Id, 0, "w", _OTHER_APPL_CONNECTED);
 		}
 	}
 	return 1;
@@ -1584,13 +1466,10 @@ static byte disconnect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 	{
 		if (plci->State == INC_CON_PENDING || plci->State == INC_CON_ALERT)
 		{
-			clear_c_ind_mask_bit(plci, (word)(appl->Id - 1));
+			__clear_bit(appl->Id - 1, plci->c_ind_mask_table);
 			plci->appl = appl;
-			for (i = 0; i < max_appl; i++)
-			{
-				if (test_c_ind_mask_bit(plci, i))
-					sendf(&application[i], _DISCONNECT_I, Id, 0, "w", 0);
-			}
+			for_each_set_bit(i, plci->c_ind_mask_table, max_appl)
+				sendf(&application[i], _DISCONNECT_I, Id, 0, "w", 0);
 			plci->State = OUTG_DIS_PENDING;
 		}
 		if (plci->Sig.Id && plci->appl)
@@ -1634,7 +1513,7 @@ static byte disconnect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 	{
 		/* clear ind mask bit, just in case of collsion of          */
 		/* DISCONNECT_IND and CONNECT_RES                           */
-		clear_c_ind_mask_bit(plci, (word)(appl->Id - 1));
+		__clear_bit(appl->Id - 1, plci->c_ind_mask_table);
 		ncci_free_receive_buffers(plci, 0);
 		if (plci_remove_check(plci))
 		{
@@ -1642,7 +1521,7 @@ static byte disconnect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 		}
 		if (plci->State == INC_DIS_PENDING
 		    || plci->State == SUSPENDING) {
-			if (c_ind_mask_empty(plci)) {
+			if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL)) {
 				if (plci->State != SUSPENDING) plci->State = IDLE;
 				dbug(1, dprintf("chs=%d", plci->channels));
 				if (!plci->channels) {
@@ -3351,13 +3230,11 @@ static byte select_b_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 				}
 				plci->State = INC_CON_CONNECTED_ALERT;
 				plci->appl = appl;
-				clear_c_ind_mask_bit(plci, (word)(appl->Id - 1));
-				dump_c_ind_mask(plci);
-				for (i = 0; i < max_appl; i++) /* disconnect the other appls */
-				{                         /* its quasi a connect        */
-					if (test_c_ind_mask_bit(plci, i))
-						sendf(&application[i], _DISCONNECT_I, Id, 0, "w", _OTHER_APPL_CONNECTED);
-				}
+				__clear_bit(appl->Id - 1, plci->c_ind_mask_table);
+				dbug(1, dprintf("c_ind_mask =%*pb", MAX_APPL, plci->c_ind_mask_table));
+				/* disconnect the other appls its quasi a connect */
+				for_each_set_bit(i, plci->c_ind_mask_table, max_appl)
+					sendf(&application[i], _DISCONNECT_I, Id, 0, "w", _OTHER_APPL_CONNECTED);
 			}
 
 			api_save_msg(msg, "s", &plci->saved_msg);
@@ -5692,19 +5569,17 @@ static void sig_ind(PLCI *plci)
 		cip = find_cip(a, parms[4], parms[6]);
 		cip_mask = 1L << cip;
 		dbug(1, dprintf("cip=%d,cip_mask=%lx", cip, cip_mask));
-		clear_c_ind_mask(plci);
+		bitmap_zero(plci->c_ind_mask_table, MAX_APPL);
 		if (!remove_started && !a->adapter_disabled)
 		{
-			set_c_ind_mask_bit(plci, MAX_APPL);
 			group_optimization(a, plci);
-			for (i = 0; i < max_appl; i++) {
+			for_each_set_bit(i, plci->group_optimization_mask_table, max_appl) {
 				if (application[i].Id
 				    && (a->CIP_Mask[i] & 1 || a->CIP_Mask[i] & cip_mask)
-				    && CPN_filter_ok(parms[0], a, i)
-				    && test_group_ind_mask_bit(plci, i)) {
+				    && CPN_filter_ok(parms[0], a, i)) {
 					dbug(1, dprintf("storedcip_mask[%d]=0x%lx", i, a->CIP_Mask[i]));
-					set_c_ind_mask_bit(plci, i);
-					dump_c_ind_mask(plci);
+					__set_bit(i, plci->c_ind_mask_table);
+					dbug(1, dprintf("c_ind_mask =%*pb", MAX_APPL, plci->c_ind_mask_table));
 					plci->State = INC_CON_PENDING;
 					plci->call_dir = (plci->call_dir & ~(CALL_DIR_OUT | CALL_DIR_ORIGINATE)) |
 						CALL_DIR_IN | CALL_DIR_ANSWER;
@@ -5750,10 +5625,9 @@ static void sig_ind(PLCI *plci)
 						      SendMultiIE(plci, Id, multi_pi_parms, PI, 0x210, true));
 				}
 			}
-			clear_c_ind_mask_bit(plci, MAX_APPL);
-			dump_c_ind_mask(plci);
+			dbug(1, dprintf("c_ind_mask =%*pb", MAX_APPL, plci->c_ind_mask_table));
 		}
-		if (c_ind_mask_empty(plci)) {
+		if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL)) {
 			sig_req(plci, HANGUP, 0);
 			send_req(plci);
 			plci->State = IDLE;
@@ -5994,13 +5868,13 @@ static void sig_ind(PLCI *plci)
 		break;
 
 	case RESUME:
-		clear_c_ind_mask_bit(plci, (word)(plci->appl->Id - 1));
+		__clear_bit(plci->appl->Id - 1, plci->c_ind_mask_table);
 		PUT_WORD(&resume_cau[4], GOOD);
 		sendf(plci->appl, _FACILITY_I, Id, 0, "ws", (word)3, resume_cau);
 		break;
 
 	case SUSPEND:
-		clear_c_ind_mask(plci);
+		bitmap_zero(plci->c_ind_mask_table, MAX_APPL);
 
 		if (plci->NL.Id && !plci->nl_remove_id) {
 			mixer_remove(plci);
@@ -6037,15 +5911,12 @@ static void sig_ind(PLCI *plci)
 
 		if (plci->State == INC_CON_PENDING || plci->State == INC_CON_ALERT)
 		{
-			for (i = 0; i < max_appl; i++)
-			{
-				if (test_c_ind_mask_bit(plci, i))
-					sendf(&application[i], _DISCONNECT_I, Id, 0, "w", 0);
-			}
+			for_each_set_bit(i, plci->c_ind_mask_table, max_appl)
+				sendf(&application[i], _DISCONNECT_I, Id, 0, "w", 0);
 		}
 		else
 		{
-			clear_c_ind_mask(plci);
+			bitmap_zero(plci->c_ind_mask_table, MAX_APPL);
 		}
 		if (!plci->appl)
 		{
@@ -6055,7 +5926,7 @@ static void sig_ind(PLCI *plci)
 				a->listen_active--;
 			}
 			plci->State = INC_DIS_PENDING;
-			if (c_ind_mask_empty(plci))
+			if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL))
 			{
 				plci->State = IDLE;
 				if (plci->NL.Id && !plci->nl_remove_id)
@@ -6341,14 +6212,10 @@ static void SendInfo(PLCI *plci, dword Id, byte **parms, byte iesent)
 			    || Info_Number == DSP
 			    || Info_Number == UUI)
 			{
-				for (j = 0; j < max_appl; j++)
-				{
-					if (test_c_ind_mask_bit(plci, j))
-					{
-						dbug(1, dprintf("Ovl_Ind"));
-						iesent = true;
-						sendf(&application[j], _INFO_I, Id, 0, "wS", Info_Number, Info_Element);
-					}
+				for_each_set_bit(j, plci->c_ind_mask_table, max_appl) {
+					dbug(1, dprintf("Ovl_Ind"));
+					iesent = true;
+					sendf(&application[j], _INFO_I, Id, 0, "wS", Info_Number, Info_Element);
 				}
 			}
 		}               /* all other signalling states */
@@ -6416,14 +6283,10 @@ static byte SendMultiIE(PLCI *plci, dword Id, byte **parms, byte ie_type,
 		}
 		else if (!plci->appl && Info_Number)
 		{                                        /* overlap receiving broadcast */
-			for (j = 0; j < max_appl; j++)
-			{
-				if (test_c_ind_mask_bit(plci, j))
-				{
-					iesent = true;
-					dbug(1, dprintf("Mlt_Ovl_Ind"));
-					sendf(&application[j] , _INFO_I, Id, 0, "wS", Info_Number, Info_Element);
-				}
+			for_each_set_bit(j, plci->c_ind_mask_table, max_appl) {
+				iesent = true;
+				dbug(1, dprintf("Mlt_Ovl_Ind"));
+				sendf(&application[j] , _INFO_I, Id, 0, "wS", Info_Number, Info_Element);
 			}
 		}                                        /* all other signalling states */
 		else if (Info_Number
@@ -7270,7 +7133,6 @@ static word get_plci(DIVA_CAPI_ADAPTER *a)
 	word i, j;
 	PLCI *plci;
 
-	dump_plcis(a);
 	for (i = 0; i < a->max_plci && a->plci[i].Id; i++);
 	if (i == a->max_plci) {
 		dbug(1, dprintf("get_plci: out of PLCIs"));
@@ -7321,8 +7183,8 @@ static word get_plci(DIVA_CAPI_ADAPTER *a)
 
 	plci->ncci_ring_list = 0;
 	for (j = 0; j < MAX_CHANNELS_PER_PLCI; j++) plci->inc_dis_ncci_table[j] = 0;
-	clear_c_ind_mask(plci);
-	set_group_ind_mask(plci);
+	bitmap_zero(plci->c_ind_mask_table, MAX_APPL);
+	bitmap_fill(plci->group_optimization_mask_table, MAX_APPL);
 	plci->fax_connect_info_length = 0;
 	plci->nsf_control_bits = 0;
 	plci->ncpi_state = 0x00;
@@ -9373,10 +9235,10 @@ word CapiRelease(word Id)
 					if (plci->State == INC_CON_PENDING
 					    || plci->State == INC_CON_ALERT)
 					{
-						if (test_c_ind_mask_bit(plci, (word)(Id - 1)))
+						if (test_bit(Id - 1, plci->c_ind_mask_table))
 						{
-							clear_c_ind_mask_bit(plci, (word)(Id - 1));
-							if (c_ind_mask_empty(plci))
+							__clear_bit(Id - 1, plci->c_ind_mask_table);
+							if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL))
 							{
 								sig_req(plci, HANGUP, 0);
 								send_req(plci);
@@ -9384,10 +9246,10 @@ word CapiRelease(word Id)
 							}
 						}
 					}
-					if (test_c_ind_mask_bit(plci, (word)(Id - 1)))
+					if (test_bit(Id - 1, plci->c_ind_mask_table))
 					{
-						clear_c_ind_mask_bit(plci, (word)(Id - 1));
-						if (c_ind_mask_empty(plci))
+						__clear_bit(Id - 1, plci->c_ind_mask_table);
+						if (bitmap_empty(plci->c_ind_mask_table, MAX_APPL))
 						{
 							if (!plci->appl)
 							{
@@ -9452,7 +9314,7 @@ word CapiRelease(word Id)
 static word plci_remove_check(PLCI *plci)
 {
 	if (!plci) return true;
-	if (!plci->NL.Id && c_ind_mask_empty(plci))
+	if (!plci->NL.Id && bitmap_empty(plci->c_ind_mask_table, MAX_APPL))
 	{
 		if (plci->Sig.Id == 0xff)
 			plci->Sig.Id = 0;
@@ -14735,7 +14597,8 @@ static void group_optimization(DIVA_CAPI_ADAPTER *a, PLCI *plci)
 	word appl_number_group_type[MAX_APPL];
 	PLCI *auxplci;
 
-	set_group_ind_mask(plci); /* all APPLs within this inc. call are allowed to dial in */
+	/* all APPLs within this inc. call are allowed to dial in */
+	bitmap_fill(plci->group_optimization_mask_table, MAX_APPL);
 
 	if (!a->group_optimization_enabled)
 	{
@@ -14771,13 +14634,12 @@ static void group_optimization(DIVA_CAPI_ADAPTER *a, PLCI *plci)
 				if (a->plci[k].Id)
 				{
 					auxplci = &a->plci[k];
-					if (auxplci->appl == &application[i]) /* application has a busy PLCI */
-					{
+					if (auxplci->appl == &application[i]) {
+						/* application has a busy PLCI */
 						busy = true;
 						dbug(1, dprintf("Appl 0x%x is busy", i + 1));
-					}
-					else if (test_c_ind_mask_bit(auxplci, i)) /* application has an incoming call pending */
-					{
+					} else if (test_bit(i, plci->c_ind_mask_table)) {
+						/* application has an incoming call pending */
 						busy = true;
 						dbug(1, dprintf("Appl 0x%x has inc. call pending", i + 1));
 					}
@@ -14826,7 +14688,8 @@ static void group_optimization(DIVA_CAPI_ADAPTER *a, PLCI *plci)
 					if (appl_number_group_type[i] == appl_number_group_type[j])
 					{
 						dbug(1, dprintf("Appl 0x%x is member of group 0x%x, no call", j + 1, appl_number_group_type[j]));
-						clear_group_ind_mask_bit(plci, j);           /* disable call on other group members */
+						/* disable call on other group members */
+						__clear_bit(j, plci->group_optimization_mask_table);
 						appl_number_group_type[j] = 0;       /* remove disabled group member from group list */
 					}
 				}
@@ -14834,7 +14697,7 @@ static void group_optimization(DIVA_CAPI_ADAPTER *a, PLCI *plci)
 		}
 		else                                                 /* application should not get a call */
 		{
-			clear_group_ind_mask_bit(plci, i);
+			__clear_bit(i, plci->group_optimization_mask_table);
 		}
 	}
 
-- 
2.11.0
