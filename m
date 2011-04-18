From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/42] isdn: eicon: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:20 -0700 (PDT)
Message-ID: <20110417.173320.179931067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51030
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753897Ab1DRAdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A2CFD24C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'best_id' is set but unused in
diva_mnt_add_xdi_adapter().  Just kill it off.

Similarly for the variable 'CIP' in connect_req(), 'Number' in
sig_ind(), 'Info' in dtmf_confirmation() mixer_command()
fax_connect_ack_command() fax_edata_ack_command()
rtp_connect_b3_res_command() and rtp_connect_b3_res_command(), and 'a'
in mixer_indication_coefs_set(),

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hardware/eicon/debug.c   |    3 +--
 drivers/isdn/hardware/eicon/message.c |   23 ++---------------------
 2 files changed, 3 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/debug.c b/drivers/isdn/hardware/eicon/debug.c
index 3626401..7a9894c 100644
--- a/drivers/isdn/hardware/eicon/debug.c
+++ b/drivers/isdn/hardware/eicon/debug.c
@@ -861,7 +861,7 @@ static int diva_get_idi_adapter_info (IDI_CALL request, dword* serial, dword* lo
 void diva_mnt_add_xdi_adapter (const DESCRIPTOR* d) {
   diva_os_spin_lock_magic_t old_irql, old_irql1;
   dword sec, usec, logical, serial, org_mask;
-  int id, best_id = 0, free_id = -1;
+  int id, free_id = -1;
   char tmp[128];
   diva_dbg_entry_head_t* pmsg = NULL;
   int len;
@@ -906,7 +906,6 @@ void diva_mnt_add_xdi_adapter (const DESCRIPTOR* d) {
         and slot is still free - reuse it
         */
       free_id = id;
-      best_id = 1;
       break;
     }
   }
diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 8c5c563..a339598 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -1198,7 +1198,6 @@ static byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
   word ch;
   word i;
   word Info;
-  word CIP;
   byte LinkLayer;
   API_PARSE * ai;
   API_PARSE * bp;
@@ -1340,7 +1339,6 @@ static byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
         add_s(plci,BC,&parms[6]);
         add_s(plci,LLC,&parms[7]);
         add_s(plci,HLC,&parms[8]);
-        CIP = GET_WORD(parms[0].info);
         if (a->Info_Mask[appl->Id-1] & 0x200)
         {
           /* early B3 connect (CIP mask bit 9) no release after a disc */
@@ -4830,7 +4828,6 @@ static void sig_ind(PLCI *plci)
   dword x_Id;
   dword Id;
   dword rId;
-  word Number = 0;
   word i;
   word cip;
   dword cip_mask;
@@ -5106,7 +5103,7 @@ static void sig_ind(PLCI *plci)
     }
   }
 
-  if(plci->appl) Number = plci->appl->Number++;
+  if(plci->appl) plci->appl->Number++;
 
   switch(plci->Sig.Ind) {
   /* Response to Get_Supported_Services request */
@@ -5894,7 +5891,6 @@ static void sig_ind(PLCI *plci)
     break;
 
   case TEL_CTRL:
-    Number = 0;
     ie = multi_fac_parms[0]; /* inspect the facility hook indications */
     if(plci->State==ADVANCED_VOICE_SIG && ie[0]){
       switch (ie[1]&0x91) {
@@ -10119,14 +10115,12 @@ static byte dtmf_request (dword Id, word Number, DIVA_CAPI_ADAPTER   *a, PLCI
 
 static void dtmf_confirmation (dword Id, PLCI   *plci)
 {
-  word Info;
   word i;
     byte result[4];
 
   dbug (1, dprintf ("[%06lx] %s,%d: dtmf_confirmation",
     UnMapId (Id), (char   *)(FILE_), __LINE__));
 
-  Info = GOOD;
   result[0] = 2;
   PUT_WORD (&result[1], DTMF_SUCCESS);
   if (plci->dtmf_send_requests != 0)
@@ -11520,13 +11514,12 @@ static word mixer_restore_config (dword Id, PLCI   *plci, byte Rc)
 static void mixer_command (dword Id, PLCI   *plci, byte Rc)
 {
   DIVA_CAPI_ADAPTER   *a;
-  word i, internal_command, Info;
+  word i, internal_command;
 
   dbug (1, dprintf ("[%06lx] %s,%d: mixer_command %02x %04x %04x",
     UnMapId (Id), (char   *)(FILE_), __LINE__, Rc, plci->internal_command,
     plci->li_cmd));
 
-  Info = GOOD;
   a = plci->adapter;
   internal_command = plci->internal_command;
   plci->internal_command = 0;
@@ -11550,7 +11543,6 @@ static void mixer_command (dword Id, PLCI   *plci, byte Rc)
         {
           dbug (1, dprintf ("[%06lx] %s,%d: Load mixer failed",
             UnMapId (Id), (char   *)(FILE_), __LINE__));
-          Info = _FACILITY_NOT_SUPPORTED;
           break;
         }
         if (plci->internal_command)
@@ -11592,7 +11584,6 @@ static void mixer_command (dword Id, PLCI   *plci, byte Rc)
             } while ((plci->li_plci_b_write_pos != plci->li_plci_b_req_pos)
               && !(plci->li_plci_b_queue[i] & LI_PLCI_B_LAST_FLAG));
           }
-          Info = _FACILITY_NOT_SUPPORTED;
           break;
         }
         if (plci->internal_command)
@@ -11610,7 +11601,6 @@ static void mixer_command (dword Id, PLCI   *plci, byte Rc)
         {
           dbug (1, dprintf ("[%06lx] %s,%d: Unload mixer failed",
             UnMapId (Id), (char   *)(FILE_), __LINE__));
-          Info = _FACILITY_NOT_SUPPORTED;
           break;
         }
         if (plci->internal_command)
@@ -12448,13 +12438,11 @@ static byte mixer_request (dword Id, word Number, DIVA_CAPI_ADAPTER   *a, PLCI
 static void mixer_indication_coefs_set (dword Id, PLCI   *plci)
 {
   dword d;
-  DIVA_CAPI_ADAPTER   *a;
     byte result[12];
 
   dbug (1, dprintf ("[%06lx] %s,%d: mixer_indication_coefs_set",
     UnMapId (Id), (char   *)(FILE_), __LINE__));
 
-  a = plci->adapter;
   if (plci->li_plci_b_read_pos != plci->li_plci_b_req_pos)
   {
     do
@@ -14111,13 +14099,11 @@ static void select_b_command (dword Id, PLCI   *plci, byte Rc)
 
 static void fax_connect_ack_command (dword Id, PLCI   *plci, byte Rc)
 {
-  word Info;
   word internal_command;
 
   dbug (1, dprintf ("[%06lx] %s,%d: fax_connect_ack_command %02x %04x",
     UnMapId (Id), (char   *)(FILE_), __LINE__, Rc, plci->internal_command));
 
-  Info = GOOD;
   internal_command = plci->internal_command;
   plci->internal_command = 0;
   switch (internal_command)
@@ -14160,13 +14146,11 @@ static void fax_connect_ack_command (dword Id, PLCI   *plci, byte Rc)
 
 static void fax_edata_ack_command (dword Id, PLCI   *plci, byte Rc)
 {
-  word Info;
   word internal_command;
 
   dbug (1, dprintf ("[%06lx] %s,%d: fax_edata_ack_command %02x %04x",
     UnMapId (Id), (char   *)(FILE_), __LINE__, Rc, plci->internal_command));
 
-  Info = GOOD;
   internal_command = plci->internal_command;
   plci->internal_command = 0;
   switch (internal_command)
@@ -14395,13 +14379,11 @@ static void rtp_connect_b3_req_command (dword Id, PLCI   *plci, byte Rc)
 
 static void rtp_connect_b3_res_command (dword Id, PLCI   *plci, byte Rc)
 {
-  word Info;
   word internal_command;
 
   dbug (1, dprintf ("[%06lx] %s,%d: rtp_connect_b3_res_command %02x %04x",
     UnMapId (Id), (char   *)(FILE_), __LINE__, Rc, plci->internal_command));
 
-  Info = GOOD;
   internal_command = plci->internal_command;
   plci->internal_command = 0;
   switch (internal_command)
@@ -14423,7 +14405,6 @@ static void rtp_connect_b3_res_command (dword Id, PLCI   *plci, byte Rc)
     {
       dbug (1, dprintf ("[%06lx] %s,%d: RTP setting connect resp info failed %02x",
         UnMapId (Id), (char   *)(FILE_), __LINE__, Rc));
-      Info = _WRONG_STATE;
       break;
     }
     if (plci_nl_busy (plci))
-- 
1.7.4.3

