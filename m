From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] tms380tr: Fix cascading if/else tab abuse
Date: Sat, 04 Feb 2012 12:52:56 -0800
Message-ID: <1328388776.7008.13.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cascading "if/else if"'s are ugly.

Signed-off-by: Joe Perches <joe@perches.com>
---
Found this beauty when looking at tab indentation use.
Might as well fix it as it's the worst in drivers/net/

git diff -w shows only the if( and else fixes.

 drivers/net/tokenring/tms380tr.c |  179 ++++++++++++++------------------------
 1 files changed, 67 insertions(+), 112 deletions(-)

diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index 65e9cf3..102f896 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -1525,10 +1525,8 @@ static void tms380tr_chk_outstanding_cmds(struct net_device *dev)
 	/* Check if adapter is opened, avoiding COMMAND_REJECT
 	 * interrupt by the adapter!
 	 */
-	if(tp->AdapterOpenFlag == 0)
-	{
-		if(tp->CMDqueue & OC_OPEN)
-		{
+	if (tp->AdapterOpenFlag == 0) {
+		if (tp->CMDqueue & OC_OPEN) {
 			/* Execute OPEN command	*/
 			tp->CMDqueue ^= OC_OPEN;
 
@@ -1536,21 +1534,17 @@ static void tms380tr_chk_outstanding_cmds(struct net_device *dev)
 			tp->scb.Parm[0] = LOWORD(Addr);
 			tp->scb.Parm[1] = HIWORD(Addr);
 			tp->scb.CMD = OPEN;
-		}
-		else
+		} else
 			/* No OPEN command queued, but adapter closed. Note:
 			 * We'll try to re-open the adapter in DriverPoll()
 			 */
 			return;		/* No adapter command issued */
-	}
-	else
-	{
+	} else {
 		/* Adapter is open; evaluate command queue: try to execute
 		 * outstanding commands (depending on priority!) CLOSE
 		 * command queued
 		 */
-		if(tp->CMDqueue & OC_CLOSE)
-		{
+		if (tp->CMDqueue & OC_CLOSE) {
 			tp->CMDqueue ^= OC_CLOSE;
 			tp->AdapterOpenFlag = 0;
 			tp->scb.Parm[0] = 0; /* Parm[0], Parm[1] are ignored */
@@ -1560,109 +1554,70 @@ static void tms380tr_chk_outstanding_cmds(struct net_device *dev)
 				tp->CMDqueue |= OC_OPEN; /* re-open adapter */
 			else
 				tp->CMDqueue = 0;	/* no more commands */
-		}
-		else
-		{
-			if(tp->CMDqueue & OC_RECEIVE)
-			{
-				tp->CMDqueue ^= OC_RECEIVE;
-				Addr = htonl(((char *)tp->RplHead - (char *)tp) + tp->dmabuffer);
-				tp->scb.Parm[0] = LOWORD(Addr);
-				tp->scb.Parm[1] = HIWORD(Addr);
-				tp->scb.CMD = RECEIVE;
-			}
-			else
-			{
-				if(tp->CMDqueue & OC_TRANSMIT_HALT)
-				{
-					/* NOTE: TRANSMIT.HALT must be checked 
-					 * before TRANSMIT.
-					 */
-					tp->CMDqueue ^= OC_TRANSMIT_HALT;
-					tp->scb.CMD = TRANSMIT_HALT;
-
-					/* Parm[0] and Parm[1] are ignored
-					 * but should be set to zero!
-					 */
-					tp->scb.Parm[0] = 0;
-					tp->scb.Parm[1] = 0;
-				}
-				else
-				{
-					if(tp->CMDqueue & OC_TRANSMIT)
-					{
-						/* NOTE: TRANSMIT must be 
-						 * checked after TRANSMIT.HALT
-						 */
-						if(tp->TransmitCommandActive)
-						{
-							if(!tp->TransmitHaltScheduled)
-							{
-								tp->TransmitHaltScheduled = 1;
-								tms380tr_exec_cmd(dev, OC_TRANSMIT_HALT) ;
-							}
-							tp->TransmitCommandActive = 0;
-							return;
-						}
-
-						tp->CMDqueue ^= OC_TRANSMIT;
-						tms380tr_cancel_tx_queue(tp);
-						Addr = htonl(((char *)tp->TplBusy - (char *)tp) + tp->dmabuffer);
-						tp->scb.Parm[0] = LOWORD(Addr);
-						tp->scb.Parm[1] = HIWORD(Addr);
-						tp->scb.CMD = TRANSMIT;
-						tp->TransmitCommandActive = 1;
-					}
-					else
-					{
-						if(tp->CMDqueue & OC_MODIFY_OPEN_PARMS)
-						{
-							tp->CMDqueue ^= OC_MODIFY_OPEN_PARMS;
-							tp->scb.Parm[0] = tp->ocpl.OPENOptions; /* new OPEN options*/
-							tp->scb.Parm[0] |= ENABLE_FULL_DUPLEX_SELECTION;
-							tp->scb.Parm[1] = 0; /* is ignored but should be zero */
-							tp->scb.CMD = MODIFY_OPEN_PARMS;
-						}
-						else
-						{
-							if(tp->CMDqueue & OC_SET_FUNCT_ADDR)
-							{
-								tp->CMDqueue ^= OC_SET_FUNCT_ADDR;
-								tp->scb.Parm[0] = LOWORD(tp->ocpl.FunctAddr);
-								tp->scb.Parm[1] = HIWORD(tp->ocpl.FunctAddr);
-								tp->scb.CMD = SET_FUNCT_ADDR;
-							}
-							else
-							{
-								if(tp->CMDqueue & OC_SET_GROUP_ADDR)
-								{
-									tp->CMDqueue ^= OC_SET_GROUP_ADDR;
-									tp->scb.Parm[0] = LOWORD(tp->ocpl.GroupAddr);
-									tp->scb.Parm[1] = HIWORD(tp->ocpl.GroupAddr);
-									tp->scb.CMD = SET_GROUP_ADDR;
-								}
-								else
-								{
-									if(tp->CMDqueue & OC_READ_ERROR_LOG)
-									{
-										tp->CMDqueue ^= OC_READ_ERROR_LOG;
-										Addr = htonl(((char *)&tp->errorlogtable - (char *)tp) + tp->dmabuffer);
-										tp->scb.Parm[0] = LOWORD(Addr);
-										tp->scb.Parm[1] = HIWORD(Addr);
-										tp->scb.CMD = READ_ERROR_LOG;
-									}
-									else
-									{
-										printk(KERN_WARNING "CheckForOutstandingCommand: unknown Command\n");
-										tp->CMDqueue = 0;
-										return;
-									}
-								}
-							}
-						}
-					}
+		} else if (tp->CMDqueue & OC_RECEIVE) {
+			tp->CMDqueue ^= OC_RECEIVE;
+			Addr = htonl(((char *)tp->RplHead - (char *)tp) + tp->dmabuffer);
+			tp->scb.Parm[0] = LOWORD(Addr);
+			tp->scb.Parm[1] = HIWORD(Addr);
+			tp->scb.CMD = RECEIVE;
+		} else if (tp->CMDqueue & OC_TRANSMIT_HALT) {
+			/* NOTE: TRANSMIT.HALT must be checked
+			 * before TRANSMIT.
+			 */
+			tp->CMDqueue ^= OC_TRANSMIT_HALT;
+			tp->scb.CMD = TRANSMIT_HALT;
+
+			/* Parm[0] and Parm[1] are ignored
+			 * but should be set to zero!
+			 */
+			tp->scb.Parm[0] = 0;
+			tp->scb.Parm[1] = 0;
+		} else if (tp->CMDqueue & OC_TRANSMIT) {
+			/* NOTE: TRANSMIT must be
+			 * checked after TRANSMIT.HALT
+			 */
+			if (tp->TransmitCommandActive) {
+				if (!tp->TransmitHaltScheduled) {
+					tp->TransmitHaltScheduled = 1;
+					tms380tr_exec_cmd(dev, OC_TRANSMIT_HALT);
 				}
+				tp->TransmitCommandActive = 0;
+				return;
 			}
+
+			tp->CMDqueue ^= OC_TRANSMIT;
+			tms380tr_cancel_tx_queue(tp);
+			Addr = htonl(((char *)tp->TplBusy - (char *)tp) + tp->dmabuffer);
+			tp->scb.Parm[0] = LOWORD(Addr);
+			tp->scb.Parm[1] = HIWORD(Addr);
+			tp->scb.CMD = TRANSMIT;
+			tp->TransmitCommandActive = 1;
+		} else if (tp->CMDqueue & OC_MODIFY_OPEN_PARMS) {
+			tp->CMDqueue ^= OC_MODIFY_OPEN_PARMS;
+			tp->scb.Parm[0] = tp->ocpl.OPENOptions; /* new OPEN options*/
+			tp->scb.Parm[0] |= ENABLE_FULL_DUPLEX_SELECTION;
+			tp->scb.Parm[1] = 0; /* is ignored but should be zero */
+			tp->scb.CMD = MODIFY_OPEN_PARMS;
+		} else if (tp->CMDqueue & OC_SET_FUNCT_ADDR) {
+			tp->CMDqueue ^= OC_SET_FUNCT_ADDR;
+			tp->scb.Parm[0] = LOWORD(tp->ocpl.FunctAddr);
+			tp->scb.Parm[1] = HIWORD(tp->ocpl.FunctAddr);
+			tp->scb.CMD = SET_FUNCT_ADDR;
+		} else if (tp->CMDqueue & OC_SET_GROUP_ADDR) {
+			tp->CMDqueue ^= OC_SET_GROUP_ADDR;
+			tp->scb.Parm[0] = LOWORD(tp->ocpl.GroupAddr);
+			tp->scb.Parm[1] = HIWORD(tp->ocpl.GroupAddr);
+			tp->scb.CMD = SET_GROUP_ADDR;
+		} else if (tp->CMDqueue & OC_READ_ERROR_LOG) {
+			tp->CMDqueue ^= OC_READ_ERROR_LOG;
+			Addr = htonl(((char *)&tp->errorlogtable - (char *)tp) + tp->dmabuffer);
+			tp->scb.Parm[0] = LOWORD(Addr);
+			tp->scb.Parm[1] = HIWORD(Addr);
+			tp->scb.CMD = READ_ERROR_LOG;
+		} else {
+			printk(KERN_WARNING "CheckForOutstandingCommand: unknown Command\n");
+			tp->CMDqueue = 0;
+			return;
 		}
 	}
 
