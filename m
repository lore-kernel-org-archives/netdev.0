From: tim.gardner@canonical.com
Subject: [PATCH v4.4-rc8 1/7] isdn: eicon: message: Silence frame size warning
Date: Fri,  8 Jan 2016 05:32:49 -0700
Message-ID: <1452256375-24223-2-git-send-email-tim.gardner@canonical.com>
References: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
To: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452256375-24223-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Gardner <tim.gardner@canonical.com>

drivers/isdn/hardware/eicon/message.c: In function 'sig_ind':
drivers/isdn/hardware/eicon/message.c:6115:1: warning: the frame size of 1200 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 5.3.1 20151219 (Ubuntu 5.3.1-4ubuntu1)

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/isdn/hardware/eicon/message.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index d7c2866..bee8067 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -4851,7 +4851,7 @@ static void sig_ind(PLCI *plci)
 	byte *esc_cr  = "";
 	byte *esc_profile = "";
 
-	byte facility[256];
+	byte *facility;
 	PLCI *tplci = NULL;
 	byte chi[] = "\x02\x18\x01";
 	byte voice_cai[]  = "\x06\x14\x00\x00\x00\x00\x08";
@@ -4886,6 +4886,12 @@ static void sig_ind(PLCI *plci)
 	dword d;
 	word w;
 
+	facility = kmalloc(256, GFP_KERNEL);
+	if (!facility) {
+		dbug(1, dprintf("mem alloc failure"));
+		return;
+	}
+
 	a = plci->adapter;
 	Id = ((word)plci->Id << 8) | a->Id;
 	PUT_WORD(&SS_Ind[4], 0x0000);
@@ -4894,7 +4900,7 @@ static void sig_ind(PLCI *plci)
 	{
 		plci->Sig.RNR = 2; /* discard */
 		dbug(1, dprintf("SIG discard while remove pending"));
-		return;
+		goto out;
 	}
 	if (plci->tel && plci->SuppState != CALL_HELD) Id |= EXT_CONTROLLER;
 	dbug(1, dprintf("SigInd-Id=%08lx,plci=%x,tel=%x,state=0x%x,channels=%d,Discflowcl=%d",
@@ -4902,7 +4908,7 @@ static void sig_ind(PLCI *plci)
 	if (plci->Sig.Ind == CALL_HOLD_ACK && plci->channels)
 	{
 		plci->Sig.RNR = 1;
-		return;
+		goto out;
 	}
 	if (plci->Sig.Ind == HANGUP && plci->channels)
 	{
@@ -4929,7 +4935,7 @@ static void sig_ind(PLCI *plci)
 			plci_remove(plci);
 			plci->State = IDLE;
 		}
-		return;
+		goto out;
 	}
 
 	/* do first parse the info with no OAD in, because OAD will be converted */
@@ -5481,7 +5487,7 @@ static void sig_ind(PLCI *plci)
 					{
 						sendf(plci->appl, _FACILITY_I, Id & 0xf, 0, "wS", 3, &pty_cai[2]);
 						plci_remove(plci);
-						return;
+						goto out;
 					}
 					else sendf(plci->appl, _FACILITY_I, Id, 0, "wS", 3, &pty_cai[2]);
 					pty_cai[0] = 0;
@@ -6112,6 +6118,8 @@ static void sig_ind(PLCI *plci)
 		break;
 
 	}
+out:
+	kfree(facility);
 }
 
 
-- 
1.9.1
