From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] ISDN-CAPI: Adjust 17 function calls together with
 variable assignments
Date: Sun, 25 Sep 2016 13:13:19 +0200
Message-ID: <10355972-1c9b-1103-edf3-efde78237cdd@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 12:21:37 +0200

The script "checkpatch.pl" can point out that assignments should usually
not be performed within condition checks.
Thus move the assignment for a variable to a separate statement
in four functions.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/capi/capidrv.c | 59 +++++++++++++++++++++++++++------------------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index bb945dd..bd614e3 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -426,7 +426,8 @@ static inline capidrv_ncci *find_ncci(capidrv_contr *card, u32 ncci)
 	capidrv_plci *plcip;
 	capidrv_ncci *p;
 
-	if ((plcip = find_plci_by_ncci(card, ncci)) == NULL)
+	plcip = find_plci_by_ncci(card, ncci);
+	if (!plcip)
 		return NULL;
 
 	for (p = plcip->ncci_list; p; p = p->next)
@@ -441,7 +442,8 @@ static inline capidrv_ncci *find_ncci_by_msgid(capidrv_contr *card,
 	capidrv_plci *plcip;
 	capidrv_ncci *p;
 
-	if ((plcip = find_plci_by_ncci(card, ncci)) == NULL)
+	plcip = find_plci_by_ncci(card, ncci);
+	if (!plcip)
 		return NULL;
 
 	for (p = plcip->ncci_list; p; p = p->next)
@@ -1072,7 +1074,8 @@ static void handle_incoming_call(capidrv_contr *card, _cmsg *cmsg)
 		return;
 	}
 	bchan = &card->bchans[chan];
-	if ((plcip = new_plci(card, chan)) == NULL) {
+	plcip = new_plci(card, chan);
+	if (!plcip) {
 		printk(KERN_ERR "capidrv-%d: incoming call: no memory, sorry.\n", card->contrnr);
 		return;
 	}
@@ -1207,7 +1210,8 @@ static void handle_plci(_cmsg *cmsg)
 			       capi_cmd2str(cmsg->Command, cmsg->Subcommand),
 			       cmsg->Reason, capi_info2str(cmsg->Reason), cmsg->adr.adrPLCI);
 		}
-		if (!(plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI))) {
+		plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI);
+		if (!plcip) {
 			capi_cmsg_answer(cmsg);
 			send_message(card, cmsg);
 			goto notfound;
@@ -1227,7 +1231,8 @@ static void handle_plci(_cmsg *cmsg)
 			       cmsg->Info, capi_info2str(cmsg->Info),
 			       cmsg->adr.adrPLCI);
 		}
-		if (!(plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI)))
+		plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI);
+		if (!plcip)
 			goto notfound;
 
 		card->bchans[plcip->chan].disconnecting = 1;
@@ -1255,7 +1260,8 @@ static void handle_plci(_cmsg *cmsg)
 			       cmsg->Info, capi_info2str(cmsg->Info),
 			       cmsg->adr.adrPLCI);
 		}
-		if (!(plcip = find_plci_by_msgid(card, cmsg->Messagenumber)))
+		plcip = find_plci_by_msgid(card, cmsg->Messagenumber);
+		if (!plcip)
 			goto notfound;
 
 		plcip->plci = cmsg->adr.adrPLCI;
@@ -1267,8 +1273,8 @@ static void handle_plci(_cmsg *cmsg)
 		break;
 
 	case CAPI_CONNECT_ACTIVE_IND:	/* plci */
-
-		if (!(plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI)))
+		plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI);
+		if (!plcip)
 			goto notfound;
 
 		if (card->bchans[plcip->chan].incoming) {
@@ -1305,8 +1311,8 @@ static void handle_plci(_cmsg *cmsg)
 		break;
 
 	case CAPI_INFO_IND:	/* Controller/plci */
-
-		if (!(plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI)))
+		plcip = find_plci_by_plci(card, cmsg->adr.adrPLCI);
+		if (!plcip)
 			goto notfound;
 
 		if (cmsg->InfoNumber == 0x4000) {
@@ -1385,7 +1391,8 @@ static void handle_ncci(_cmsg *cmsg)
 	switch (CAPICMD(cmsg->Command, cmsg->Subcommand)) {
 
 	case CAPI_CONNECT_B3_ACTIVE_IND:	/* ncci */
-		if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI)))
+		nccip = find_ncci(card, cmsg->adr.adrNCCI);
+		if (!nccip)
 			goto notfound;
 
 		capi_cmsg_answer(cmsg);
@@ -1440,10 +1447,10 @@ static void handle_ncci(_cmsg *cmsg)
 		break;
 
 	case CAPI_CONNECT_B3_CONF:	/* ncci */
-
-		if (!(nccip = find_ncci_by_msgid(card,
-						 cmsg->adr.adrNCCI,
-						 cmsg->Messagenumber)))
+		nccip = find_ncci_by_msgid(card,
+					   cmsg->adr.adrNCCI,
+					   cmsg->Messagenumber);
+		if (!nccip)
 			goto notfound;
 
 		nccip->ncci = cmsg->adr.adrNCCI;
@@ -1475,7 +1482,8 @@ static void handle_ncci(_cmsg *cmsg)
 			printk(KERN_WARNING "CAPI_DATA_B3_CONF: Info %x - %s\n",
 			       cmsg->Info, capi_info2str(cmsg->Info));
 		}
-		if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI)))
+		nccip = find_ncci(card, cmsg->adr.adrNCCI);
+		if (!nccip)
 			goto notfound;
 
 		len = capidrv_del_ack(nccip, cmsg->DataHandle);
@@ -1489,7 +1497,8 @@ static void handle_ncci(_cmsg *cmsg)
 		break;
 
 	case CAPI_DISCONNECT_B3_IND:	/* ncci */
-		if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI)))
+		nccip = find_ncci(card, cmsg->adr.adrNCCI);
+		if (!nccip)
 			goto notfound;
 
 		card->bchans[nccip->chan].disconnecting = 1;
@@ -1500,7 +1509,8 @@ static void handle_ncci(_cmsg *cmsg)
 		break;
 
 	case CAPI_DISCONNECT_B3_CONF:	/* ncci */
-		if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI)))
+		nccip = find_ncci(card, cmsg->adr.adrNCCI);
+		if (!nccip)
 			goto notfound;
 		if (cmsg->Info) {
 			printk(KERN_INFO "capidrv-%d: %s info 0x%x (%s) for ncci 0x%x\n",
@@ -1513,7 +1523,8 @@ static void handle_ncci(_cmsg *cmsg)
 		break;
 
 	case CAPI_RESET_B3_IND:	/* ncci */
-		if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI)))
+		nccip = find_ncci(card, cmsg->adr.adrNCCI);
+		if (!nccip)
 			goto notfound;
 		ncci_change_state(card, nccip, EV_NCCI_RESET_B3_IND);
 		capi_cmsg_answer(cmsg);
@@ -1561,7 +1572,8 @@ static void handle_data(_cmsg *cmsg, struct sk_buff *skb)
 		kfree_skb(skb);
 		return;
 	}
-	if (!(nccip = find_ncci(card, cmsg->adr.adrNCCI))) {
+	nccip = find_ncci(card, cmsg->adr.adrNCCI);
+	if (!nccip) {
 		printk(KERN_ERR "capidrv-%d: %s: ncci 0x%x not found\n",
 		       card->contrnr,
 		       capi_cmd2str(cmsg->Command, cmsg->Subcommand),
@@ -1868,7 +1880,8 @@ static int capidrv_command(isdn_ctrl *c, capidrv_contr *card)
 				      NULL,	/* Useruserdata */
 				      NULL	/* Facilitydataarray */
 			);
-		if ((plcip = new_plci(card, (c->arg % card->nbchan))) == NULL) {
+		plcip = new_plci(card, c->arg % card->nbchan);
+		if (!plcip) {
 			cmd.command = ISDN_STAT_DHUP;
 			cmd.driver = card->myid;
 			cmd.arg = (c->arg % card->nbchan);
@@ -2254,9 +2267,9 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 		printk(KERN_WARNING "capidrv: (%s) Could not reserve module\n", id);
 		return -1;
 	}
-	if (!(card = kzalloc(sizeof(capidrv_contr), GFP_ATOMIC))) {
+	card = kzalloc(sizeof(capidrv_contr), GFP_ATOMIC);
+	if (!card)
 		return -1;
-	}
 	card->owner = THIS_MODULE;
 	setup_timer(&card->listentimer, listentimerfunc, (unsigned long)card);
 	strcpy(card->name, id);
-- 
2.10.0
