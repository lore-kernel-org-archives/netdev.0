From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 22 Jan 2007 09:28:14 -0200
Message-ID: <20070122112814.GB3038@dmt>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056884.9175.66.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:56772 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbXAVLcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 06:32:17 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1169056884.9175.66.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 06:01:24PM +0000, Johannes Berg wrote:

> > 3) Could you enumerate your issues with the command dispatching?  Right
> > now, many of the commands are blocking, which is suboptimal.  This is an
> > artifact of the embedded history of the part.  We need to eventually fix
> > that and make the upper layers not expect to block stuff like auth/assoc
> > and scanning.  What other stuff are you thinking of?
> 
> Well, one thing is that the whole command processing goes through a
> single function for no real benefit. You're basically saying
> command(...,CMD_NUM,...) and in command() you do switch(cmd_num) and
> multiplex it to a lot of functions again. I suppose I'd rather it called
> the functions directly and those in turn called the little common code
> there is in the dispatch routine.

Three issues related to command dispatching as is performed in the
current code:

1) First problem is that there are certain commands which are sent      
in interrupt context, or in contexes which can't sleep (such as         
get_wireless_stats).                                                    

We need a mutex to synchronize command download to firmware, and certain
contexes, as mentioned above, can't sleep.

Thus the need for a thread (and the associated switch(cmd_num) and all
of its "unnecessary complexity") to handle command dispatching.

2) Another issue is that during the sleep period certain commands can't
be sent down to firmware and must remain in the command queue until the
awake window has been opened.

3) Having commands go through a unified queue allows the main thread to
know whether it can tell the HW to go back to sleep mode (in case there
are no commands pending), which is not possible (or suboptimal) if each
command is unaware of other commands being sent.

That said I'm not entirely sure that we want commands to be sent
directly to firmware, or an equivalent of that (have an "awake window
opened" waitqueue in which workqueue's handlers on behalf of commands
are triggered).

That sounds even more complex and suboptimal with reference to "ready to
go back to sleep state".

So IMHO the current way command dispatching works is optimal given the
driver support for sending commands from non-sleepable contexes and for
sending commands while the HW is in sleep mode.

Comments?

Follows a previous attempt at modifying command dispatching:

diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index de01d1b..2e21b10 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -94,9 +94,6 @@ #if defined(__KERNEL__)
 
 /* CmdCtrlNode */
 struct CmdCtrlNode {
-	/* CMD link list */
-	struct list_head list;
-
 	u32 Status;
 
 	/* CMD ID */
@@ -116,7 +113,9 @@ struct CmdCtrlNode {
 	/* wait queue */
 	u16 CmdWaitQWoken;
 	wait_queue_head_t cmdwait_q;
-} __attribute__ ((packed));
+
+	struct kref kref;
+};
 
 #endif
 
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 20b70f6..1c47239 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -144,6 +144,9 @@ static void if_usb_write_bulk_callback(s
 			netif_wake_queue(dev);
 	}
 
+	if (priv->adapter->PSState != PS_STATE_SLEEP)
+		if_usb_interrupt(priv, 0, TX_SUCCESS);
+
 	LEAVE();
 	return;
 }
diff --git a/drivers/net/wireless/libertas/if_usb.h b/drivers/net/wireless/libertas/if_usb.h
diff --git a/drivers/net/wireless/libertas/sbi.h b/drivers/net/wireless/libertas/sbi.h
diff --git a/drivers/net/wireless/libertas/wlan_cmd.c b/drivers/net/wireless/libertas/wlan_cmd.c
index dd4d0b2..d41e0f6 100644
--- a/drivers/net/wireless/libertas/wlan_cmd.c
+++ b/drivers/net/wireless/libertas/wlan_cmd.c
@@ -35,7 +35,8 @@ Change log:
 	      implementation through generic hostcmd API
 ********************************************************/
 
-#include	"include.h"
+#include "include.h"
+#include <linux/workqueue.h>
 
 /********************************************************
 		Local Variables
@@ -1184,60 +1185,6 @@ static int wlan_cmd_dft_access(wlan_priv
 	return WLAN_STATUS_SUCCESS;
 }
 
-/** 
- *  @brief This function queues the command to cmd list.
- *  
- *  @param Adapter	A pointer to wlan_adapter structure
- *  @param CmdNode   	A pointer to CmdCtrlNode structure
- *  @param addtail	specify if the cmd needs to be queued in the header or tail
- *  @return 	   	n/a
- */
-void QueueCmd(wlan_adapter * Adapter, struct CmdCtrlNode *CmdNode, u8 addtail)
-{
-	ulong flags;
-	struct HostCmd_DS_COMMAND *CmdPtr;
-
-	ENTER();
-
-	if (!CmdNode) {
-		PRINTM(INFO, "QUEUE_CMD: CmdNode is NULL\n");
-		goto done;
-	}
-
-	CmdPtr = (struct HostCmd_DS_COMMAND *)CmdNode->BufVirtualAddr;
-	if (!CmdPtr) {
-		PRINTM(INFO, "QUEUE_CMD: CmdPtr is NULL\n");
-		goto done;
-	}
-
-	/* Exit_PS command needs to be queued in the header always. */
-	if (CmdPtr->Command == HostCmd_CMD_802_11_PS_MODE) {
-		struct HostCmd_DS_802_11_PS_MODE *psm = &CmdPtr->params.psmode;
-		if (psm->Action == HostCmd_SubCmd_Exit_PS) {
-			if (Adapter->PSState != PS_STATE_FULL_POWER)
-				addtail = FALSE;
-		}
-	}
-
-	spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
-
-	if (addtail)
-		list_add_tail((struct list_head *)CmdNode,
-			      &Adapter->CmdPendingQ);
-	else
-		list_add((struct list_head *)CmdNode, &Adapter->CmdPendingQ);
-
-	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
-
-	PRINTM(INFO, "QUEUE_CMD: Inserted node=0x%x, cmd=0x%x in CmdPendingQ\n",
-	       (u32) CmdNode,
-	       ((struct HostCmd_DS_GEN *)CmdNode->BufVirtualAddr)->Command);
-
-      done:
-	LEAVE();
-	return;
-}
-
 /*
  * TODO: Fix the issue when DownloadCommandToStation is being called the
  * second time when the command timesout. All the CmdPtr->xxx are in little
@@ -1256,7 +1203,6 @@ void QueueCmd(wlan_adapter * Adapter, st
 static int DownloadCommandToStation(wlan_private * priv,
 				    struct CmdCtrlNode *CmdNode)
 {
-	ulong flags;
 	struct HostCmd_DS_COMMAND *CmdPtr;
 	wlan_adapter *Adapter = priv->adapter;
 	int ret = WLAN_STATUS_SUCCESS;
@@ -1269,25 +1215,24 @@ static int DownloadCommandToStation(wlan
 		PRINTM(INFO, "DNLD_CMD: Adapter = %#x, CmdNode = %#x\n",
 		       (int)Adapter, (int)CmdNode);
 		if (CmdNode)
-			CleanupAndInsertCmd(priv, CmdNode);
+			free_command(CmdNode);
 		ret = WLAN_STATUS_FAILURE;
 		goto done;
 	}
 
 	CmdPtr = (struct HostCmd_DS_COMMAND *)CmdNode->BufVirtualAddr;
 
+	Adapter->CurCmd = CmdNode;
+	Adapter->CurCmdRetCode = 0;
+
 	if (!CmdPtr || !CmdPtr->Size) {
 		PRINTM(INFO, "DNLD_CMD: CmdPtr is Null or Cmd Size is Zero, "
 		       "Not sending\n");
-		CleanupAndInsertCmd(priv, CmdNode);
+		free_command(CmdNode);
 		ret = WLAN_STATUS_FAILURE;
 		goto done;
 	}
 
-	spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
-	Adapter->CurCmd = CmdNode;
-	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
-	Adapter->CurCmdRetCode = 0;
 	PRINTM(INFO, "DNLD_CMD:: Before download, Size of Cmd = %d\n",
 	       CmdPtr->Size);
 
@@ -1302,10 +1247,7 @@ static int DownloadCommandToStation(wlan
 
 	if (ret != 0) {
 		PRINTM(INFO, "DNLD_CMD: Host to Card Failed\n");
-		CleanupAndInsertCmd(priv, Adapter->CurCmd);
-		spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
-		Adapter->CurCmd = NULL;
-		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
+		free_command(Adapter->CurCmd);
 		ret = WLAN_STATUS_FAILURE;
 		goto done;
 	}
@@ -1323,7 +1265,7 @@ static int DownloadCommandToStation(wlan
 
 	ret = WLAN_STATUS_SUCCESS;
 
-      done:
+done:
 	LEAVE();
 	return ret;
 }
@@ -1358,32 +1300,6 @@ static int wlan_cmd_mac_control(wlan_pri
 		Global Functions
 ********************************************************/
 
-/** 
- *  @brief This function inserts command node to CmdFreeQ
- *  after cleans it.
- *  
- *  @param priv		A pointer to wlan_private structure
- *  @param pTempCmd	A pointer to CmdCtrlNode structure
- *  @return 		n/a
- */
-void CleanupAndInsertCmd(wlan_private * priv, struct CmdCtrlNode *pTempCmd)
-{
-	ulong flags;
-	wlan_adapter *Adapter = priv->adapter;
-
-	ENTER();
-
-	if (!pTempCmd)
-		goto done;
-
-	spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
-	CleanUpCmdCtrlNode(pTempCmd);
-	list_add_tail((struct list_head *)pTempCmd, &Adapter->CmdFreeQ);
-	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
-
-      done:
-	LEAVE();
-}
 
 /** 
  *  @brief This function sets radio control.
@@ -1432,6 +1348,9 @@ int SetMacPacketFilter(wlan_private * pr
 	return ret;
 }
 
+
+void destroy_command(struct kref *kref);
+
 /** 
  *  @brief This function prepare the command before send to firmware.
  *  
@@ -1467,7 +1386,7 @@ int PrepareAndSendCommand(wlan_private *
 		goto done;
 	}
 
-	CmdNode = GetFreeCmdCtrlNode(priv);
+	CmdNode = allocate_command(priv);
 
 	if (CmdNode == NULL) {
 		PRINTM(MSG, "PREP_CMD: No free CmdNode\n");
@@ -1485,13 +1404,6 @@ int PrepareAndSendCommand(wlan_private *
 	PRINTM(INFO, "PREP_CMD: Val of Cmd ptr =0x%x, command=0x%X\n",
 	       (u32) CmdPtr, cmd_no);
 
-	if (!CmdPtr) {
-		PRINTM(MSG, "PREP_CMD: BufVirtualAddr of CmdNode is NULL\n");
-		CleanupAndInsertCmd(priv, CmdNode);
-		ret = WLAN_STATUS_FAILURE;
-		goto done;
-	}
-
 	/* Set sequence number, command and INT option */
 	Adapter->SeqNum++;
 	CmdPtr->SeqNum = wlan_cpu_to_le16(Adapter->SeqNum);
@@ -1733,15 +1645,16 @@ #define ACTION_NUMLED_TLVTYPE_LEN_FIELDS
 	/* return error, since the command preparation failed */
 	if (ret != WLAN_STATUS_SUCCESS) {
 		PRINTM(INFO, "PREP_CMD: Command preparation failed\n");
-		CleanupAndInsertCmd(priv, CmdNode);
+		free_command(CmdNode);
 		ret = WLAN_STATUS_FAILURE;
 		goto done;
 	}
 
 	CmdNode->CmdWaitQWoken = FALSE;
 
-	QueueCmd(Adapter, CmdNode, TRUE);
-	wake_up_interruptible(&priv->MainThread.waitQ);
+	kref_get(&CmdNode->kref);
+
+	execute_command(priv, CmdNode, wait_option);
 
 	sbi_reenable_host_interrupt(priv, 0x00);
 
@@ -1751,6 +1664,8 @@ #define ACTION_NUMLED_TLVTYPE_LEN_FIELDS
 					 CmdNode->CmdWaitQWoken);
 	}
 
+	kref_put(&CmdNode->kref, &destroy_command);
+
 	if (Adapter->CurCmdRetCode) {
 		PRINTM(INFO, "PREP_CMD: Command failed with return code=%d\n",
 		       Adapter->CurCmdRetCode);
@@ -1764,175 +1679,67 @@ #define ACTION_NUMLED_TLVTYPE_LEN_FIELDS
 }
 
 /** 
- *  @brief This function allocates the command buffer and link
- *  it to command free queue.
- *  
- *  @param priv		A pointer to wlan_private structure
- *  @return 		WLAN_STATUS_SUCCESS or WLAN_STATUS_FAILURE
- */
-int AllocateCmdBuffer(wlan_private * priv)
-{
-	int ret = WLAN_STATUS_SUCCESS;
-	u32 ulBufSize;
-	u32 i;
-	struct CmdCtrlNode *TempCmdArray;
-	u8 *pTempVirtualAddr;
-	wlan_adapter *Adapter = priv->adapter;
-
-	ENTER();
-
-	/* Allocate and initialize CmdCtrlNode */
-	ulBufSize = sizeof(struct CmdCtrlNode) * MRVDRV_NUM_OF_CMD_BUFFER;
-
-	if (!(TempCmdArray = kmalloc(ulBufSize, GFP_KERNEL))) {
-		PRINTM(INFO,
-		       "ALLOC_CMD_BUF: Failed to allocate TempCmdArray\n");
-		ret = WLAN_STATUS_FAILURE;
-		goto done;
-	}
-
-	Adapter->CmdArray = TempCmdArray;
-	memset(Adapter->CmdArray, 0, ulBufSize);
-
-	/* Allocate and initialize command buffers */
-	ulBufSize = MRVDRV_SIZE_OF_CMD_BUFFER;
-	for (i = 0; i < MRVDRV_NUM_OF_CMD_BUFFER; i++) {
-		if (!(pTempVirtualAddr = kmalloc(ulBufSize, GFP_KERNEL))) {
-			PRINTM(INFO,
-			       "ALLOC_CMD_BUF: pTempVirtualAddr: out of memory\n");
-			ret = WLAN_STATUS_FAILURE;
-			goto done;
-		}
-
-		memset(pTempVirtualAddr, 0, ulBufSize);
-
-		/* Update command buffer virtual */
-		TempCmdArray[i].BufVirtualAddr = pTempVirtualAddr;
-	}
-
-	for (i = 0; i < MRVDRV_NUM_OF_CMD_BUFFER; i++) {
-		init_waitqueue_head(&TempCmdArray[i].cmdwait_q);
-		CleanupAndInsertCmd(priv, &TempCmdArray[i]);
-	}
-
-	ret = WLAN_STATUS_SUCCESS;
-      done:
-	LEAVE();
-	return ret;
-}
-
-/** 
- *  @brief This function frees the command buffer.
- *  
- *  @param priv		A pointer to wlan_private structure
- *  @return 		WLAN_STATUS_SUCCESS or WLAN_STATUS_FAILURE
- */
-int FreeCmdBuffer(wlan_private * priv)
-{
-	u32 ulBufSize;
-	unsigned int i;
-	struct CmdCtrlNode *TempCmdArray;
-	wlan_adapter *Adapter = priv->adapter;
-
-	ENTER();
-
-	/* need to check if cmd array is allocated or not */
-	if (Adapter->CmdArray == NULL) {
-		PRINTM(INFO, "FREE_CMD_BUF: CmdArray is Null\n");
-		goto done;
-	}
-
-	TempCmdArray = Adapter->CmdArray;
-
-	/* Release shared memory buffers */
-	ulBufSize = MRVDRV_SIZE_OF_CMD_BUFFER;
-	for (i = 0; i < MRVDRV_NUM_OF_CMD_BUFFER; i++) {
-		if (TempCmdArray[i].BufVirtualAddr) {
-			PRINTM(INFO, "Free all the array\n");
-			kfree(TempCmdArray[i].BufVirtualAddr);
-			TempCmdArray[i].BufVirtualAddr = NULL;
-		}
-	}
-
-	/* Release CmdCtrlNode */
-	if (Adapter->CmdArray) {
-		PRINTM(INFO, "Free CmdArray\n");
-		kfree(Adapter->CmdArray);
-		Adapter->CmdArray = NULL;
-	}
-
-      done:
-	LEAVE();
-	return WLAN_STATUS_SUCCESS;
-}
-
-/** 
- *  @brief This function gets a free command node if available in
- *  command free queue.
+ *  @brief This function allocates a command.
  *  
  *  @param priv		A pointer to wlan_private structure
  *  @return CmdCtrlNode A pointer to CmdCtrlNode structure or NULL
  */
-struct CmdCtrlNode *GetFreeCmdCtrlNode(wlan_private * priv)
+struct CmdCtrlNode *allocate_command(wlan_private * priv)
 {
 	struct CmdCtrlNode *TempNode;
-	wlan_adapter *Adapter = priv->adapter;
-	ulong flags;
 
 	ENTER();
 
-	if (!Adapter)
+	TempNode = kmalloc(sizeof(struct CmdCtrlNode), GFP_ATOMIC);
+
+	if (!TempNode)
 		return NULL;
 
-	spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
+	TempNode->BufVirtualAddr = kmalloc(MRVDRV_SIZE_OF_CMD_BUFFER,
+					   GFP_ATOMIC);
 
-	if (!list_empty(&Adapter->CmdFreeQ)) {
-		TempNode = (struct CmdCtrlNode *)Adapter->CmdFreeQ.next;
-		list_del((struct list_head *)TempNode);
-	} else {
-		PRINTM(INFO, "GET_CMD_NODE: CmdCtrlNode is not available\n");
-		TempNode = NULL;
+	if (!TempNode->BufVirtualAddr) {
+		kfree(TempNode);
+		return NULL;
 	}
 
-	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
-
-	if (TempNode) {
-		PRINTM(INFO, "GET_CMD_NODE: CmdCtrlNode available\n");
-		PRINTM(INFO, "GET_CMD_NODE: CmdCtrlNode Address = %p\n",
-		       TempNode);
-		CleanUpCmdCtrlNode(TempNode);
-	}
+	kref_init(&TempNode->kref);
+	init_waitqueue_head(&TempNode->cmdwait_q);
 
 	LEAVE();
 	return TempNode;
 }
 
+void destroy_command(struct kref *kref)
+{
+	struct CmdCtrlNode *cmd = container_of(kref, struct CmdCtrlNode, kref);
+	kfree(cmd->BufVirtualAddr);
+	kfree(cmd);
+}
+
 /** 
- *  @brief This function cleans command node.
+ *  @brief This function frees command node.
  *  
  *  @param pTempNode	A pointer to CmdCtrlNode structure
  *  @return 		n/a
  */
-void CleanUpCmdCtrlNode(struct CmdCtrlNode *pTempNode)
+void free_command(struct CmdCtrlNode *cmd)
 {
 	ENTER();
 
-	if (!pTempNode)
+	if (!cmd)
 		return;
-	pTempNode->CmdWaitQWoken = TRUE;
-	wake_up_interruptible(&pTempNode->cmdwait_q);
-	pTempNode->Status = 0;
-	pTempNode->cmd_oid = (u32) 0;
-	pTempNode->wait_option = 0;
-	pTempNode->pdata_buf = NULL;
 
-	if (pTempNode->BufVirtualAddr != NULL)
-		memset(pTempNode->BufVirtualAddr, 0, MRVDRV_SIZE_OF_CMD_BUFFER);
+	cmd->CmdWaitQWoken = TRUE;
+	wake_up_interruptible(&cmd->cmdwait_q);
+
+	kref_put(&cmd->kref, &destroy_command);
 
 	LEAVE();
 	return;
 }
 
+
 /** 
  *  @brief This function initializes the command node.
  *  
@@ -1959,6 +1766,99 @@ void SetCmdCtrlNode(wlan_private * priv,
 	LEAVE();
 }
 
+void wait_on_full_power(wlan_adapter *adapter)
+{
+	wait_queue_t wait;
+	init_waitqueue_entry(&wait, current);
+
+	do {
+		adapter->NeedToWakeup = TRUE;
+		add_wait_queue(&adapter->full_power_waitq, &wait);
+		spin_unlock(&adapter->psstate_lock);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		spin_lock(&adapter->psstate_lock);
+	} while (adapter->PSState != PS_STATE_FULL_POWER);
+
+	remove_wait_queue(&adapter->full_power_waitq, &wait);
+	set_current_state(TASK_RUNNING);
+}
+
+void wait_on_awake(wlan_adapter *adapter)
+{
+	wait_queue_t wait;
+	init_waitqueue_entry(&wait, current);
+
+	do {
+		adapter->NeedToWakeup = TRUE;
+		add_wait_queue(&adapter->ds_awake_q, &wait);
+		spin_unlock(&adapter->psstate_lock);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		spin_lock(&adapter->psstate_lock);
+	} while ((adapter->PSState == PS_STATE_SLEEP) ||
+		 (adapter->PSState == PS_STATE_PRE_SLEEP));
+
+	remove_wait_queue(&adapter->ds_awake_q, &wait);
+	set_current_state(TASK_RUNNING);
+}
+
+int scheduled_cmds = 0;
+
+struct priv_and_cmd {
+	struct work_struct *w;
+	struct CmdCtrlNode *cmd;
+	wlan_private *priv;
+};
+
+static void run_scheduled_command (void *data)
+{
+	struct priv_and_cmd *cbdata = (struct priv_and_cmd *)data;
+	struct HostCmd_DS_COMMAND *CmdPtr = cbdata->cmd->BufVirtualAddr;
+
+	printk(KERN_ERR "run scheduled command (0x%x) nr:%d\n", CmdPtr->Command,
+			scheduled_cmds);
+
+	scheduled_cmds--;
+
+	execute_command(cbdata->priv, cbdata->cmd, 1);	
+
+	kfree (cbdata->w);
+	kfree (cbdata);
+}
+
+static int schedule_command(wlan_private *priv, struct CmdCtrlNode *cmdnode)
+{
+	struct priv_and_cmd *cbdata;
+	struct work_struct *work;
+	struct HostCmd_DS_COMMAND *CmdPtr = cmdnode->BufVirtualAddr;
+
+	printk(KERN_ERR "scheduled command (0x%x) nr:%d\n", CmdPtr->Command,
+			scheduled_cmds);
+
+	cbdata = kmalloc(sizeof(struct priv_and_cmd), GFP_ATOMIC);
+	if (!cbdata)
+		return -1;
+
+	work = kmalloc(sizeof(struct work_struct), GFP_ATOMIC);
+	if (!work) { 
+		kfree(cbdata);
+		return -1;
+	}
+
+	cbdata->cmd = cmdnode;
+	cbdata->priv = priv;
+	cbdata->w = work;
+
+	INIT_WORK(work, run_scheduled_command, cbdata);
+
+	schedule_work(work);
+
+	scheduled_cmds++;
+
+	return 0;
+}
+
 /** 
  *  @brief This function executes next command in command
  *  pending queue. It will put fimware back to PS mode
@@ -1967,12 +1867,10 @@ void SetCmdCtrlNode(wlan_private * priv,
  *  @param priv     A pointer to wlan_private structure
  *  @return 	   WLAN_STATUS_SUCCESS or WLAN_STATUS_FAILURE
  */
-int ExecuteNextCommand(wlan_private * priv)
+int execute_command(wlan_private * priv, struct CmdCtrlNode *cmdnode, int can_sleep)
 {
 	wlan_adapter *Adapter = priv->adapter;
-	struct CmdCtrlNode *CmdNode = NULL;
 	struct HostCmd_DS_COMMAND *CmdPtr;
-	ulong flags;
 	int ret = WLAN_STATUS_SUCCESS;
 
 	ENTER();
@@ -1983,141 +1881,116 @@ int ExecuteNextCommand(wlan_private * pr
 		goto done;
 	}
 
-	spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
-
-	if (Adapter->CurCmd) {
-		PRINTM(MSG, "EXEC_NEXT_CMD: there is command in processing!\n");
-		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
-		ret = WLAN_STATUS_FAILURE;
+	CmdPtr = (struct HostCmd_DS_COMMAND *)cmdnode->BufVirtualAddr;
+	if (!can_sleep && CmdPtr->Command != wlan_cpu_to_le16(HostCmd_CMD_802_11_PS_MODE)) {
+		schedule_command(priv, cmdnode);
+		ret = WLAN_STATUS_SUCCESS;
 		goto done;
 	}
 
-	if (!list_empty(&Adapter->CmdPendingQ)) {
-		CmdNode = (struct CmdCtrlNode *)
-		    Adapter->CmdPendingQ.next;
-	}
-
-	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
+	spin_lock(&Adapter->psstate_lock);
 
-	if (CmdNode) {
-		PRINTM(INFO,
-		       "EXEC_NEXT_CMD: Got next command from CmdPendingQ\n");
-		CmdPtr = (struct HostCmd_DS_COMMAND *)CmdNode->BufVirtualAddr;
+	if ((Adapter->PSState == PS_STATE_SLEEP) ||
+	    (Adapter->PSState == PS_STATE_PRE_SLEEP)) {
+		if (CmdPtr->Command == wlan_cpu_to_le16(HostCmd_CMD_802_11_PS_MODE))
+			wait_on_awake(Adapter);
+		else
+			wait_on_full_power(Adapter);
+	}
 
+	if (Adapter->PSState == PS_STATE_AWAKE) {
+		struct HostCmd_DS_802_11_PS_MODE *psm;
+		/*
+		 * 1. Non-PS command: 
+		 * Queue it. set NeedToWakeup to TRUE if current state 
+		 * is SLEEP, otherwise call PSWakeup to send Exit_PS.
+		 * 2. PS command but not Exit_PS: 
+		 * Ignore it.
+		 * 3. PS command Exit_PS:
+		 * Set NeedToWakeup to TRUE if current state is SLEEP, 
+		 * otherwise send this command down to firmware
+		 * immediately.
+		 */
 		if (Is_Command_Allowed_In_PS(CmdPtr->Command)) {
-			if ((Adapter->PSState == PS_STATE_SLEEP)
-			    || (Adapter->PSState == PS_STATE_PRE_SLEEP)
-			    ) {
-				PRINTM(INFO,
-				       "EXEC_NEXT_CMD: Cannot send cmd 0x%x in PSState %d\n",
-				       CmdPtr->Command, Adapter->PSState);
-				ret = WLAN_STATUS_FAILURE;
-				goto done;
-			}
 			PRINTM(INFO, "EXEC_NEXT_CMD: OK to send command "
-			       "0x%x in PSState %d\n",
-			       CmdPtr->Command, Adapter->PSState);
-		} else if (Adapter->PSState != PS_STATE_FULL_POWER) {
+				      "0x%x in PSState %d\n",
+				      CmdPtr->Command, Adapter->PSState);
+			goto execute_cmd;
+		}	
+
+		if (CmdPtr->Command ==
+		    wlan_cpu_to_le16(HostCmd_CMD_802_11_PS_MODE)) {
 			/*
-			 * 1. Non-PS command: 
-			 * Queue it. set NeedToWakeup to TRUE if current state 
-			 * is SLEEP, otherwise call PSWakeup to send Exit_PS.
-			 * 2. PS command but not Exit_PS: 
-			 * Ignore it.
-			 * 3. PS command Exit_PS:
-			 * Set NeedToWakeup to TRUE if current state is SLEEP, 
-			 * otherwise send this command down to firmware
-			 * immediately.
+			 * PS command. Ignore it if it is not Exit_PS.
+			 * otherwise send it down immediately.
 			 */
-			if (CmdPtr->Command !=
-			    wlan_cpu_to_le16(HostCmd_CMD_802_11_PS_MODE)) {
-				/*  Prepare to send Exit PS,
-				 *  this non PS command will be sent later */
-				if ((Adapter->PSState == PS_STATE_SLEEP)
-				    || (Adapter->PSState == PS_STATE_PRE_SLEEP)
-				    ) {
-					/* w/ new scheme, it will not reach here.
-					   since it is blocked in main_thread. */
-					Adapter->NeedToWakeup = TRUE;
-				} else
-					PSWakeup(priv, 0);
+			psm = &CmdPtr->params.psmode;
 
+			if (psm->Action !=
+			    wlan_cpu_to_le16(HostCmd_SubCmd_Exit_PS)) {
+				PRINTM(INFO,
+				       "EXEC_NEXT_CMD: Ignore ExitPS cmd"
+					"in sleep\n");
 				ret = WLAN_STATUS_SUCCESS;
 				goto done;
-			} else {
-				/*
-				 * PS command. Ignore it if it is not Exit_PS. 
-				 * otherwise send it down immediately.
-				 */
-				struct HostCmd_DS_802_11_PS_MODE *psm =
-				    &CmdPtr->params.psmode;
-
-				PRINTM(INFO,
-				       "EXEC_NEXT_CMD: PS cmd- Action=0x%x\n",
-				       psm->Action);
-				if (psm->Action !=
-				    wlan_cpu_to_le16(HostCmd_SubCmd_Exit_PS)) {
-					PRINTM(INFO,
-					       "EXEC_NEXT_CMD: Ignore Enter PS cmd\n");
-					list_del((struct list_head *)CmdNode);
-					CleanupAndInsertCmd(priv, CmdNode);
-
-					ret = WLAN_STATUS_SUCCESS;
-					goto done;
-				}
-
-				if ((Adapter->PSState == PS_STATE_SLEEP)
-				    || (Adapter->PSState == PS_STATE_PRE_SLEEP)
-				    ) {
-					PRINTM(INFO,
-					       "EXEC_NEXT_CMD: Ignore ExitPS cmd in sleep\n");
-					list_del((struct list_head *)CmdNode);
-					CleanupAndInsertCmd(priv, CmdNode);
-					Adapter->NeedToWakeup = TRUE;
-
-					ret = WLAN_STATUS_SUCCESS;
-					goto done;
-				}
-
-				PRINTM(INFO,
-				       "EXEC_NEXT_CMD: Sending Exit_PS down...\n");
-			}
-		}
-		list_del((struct list_head *)CmdNode);
-		PRINTM(INFO, "EXEC_NEXT_CMD: Sending 0x%04X Command\n",
-		       CmdPtr->Command);
-		DownloadCommandToStation(priv, CmdNode);
-	} else {
-		/*
-		 * check if in power save mode, if yes, put the device back
-		 * to PS mode
-		 */
-		if ((Adapter->PSMode != Wlan802_11PowerModeCAM) &&
-		    (Adapter->PSState == PS_STATE_FULL_POWER) &&
-		    (Adapter->MediaConnectStatus == WlanMediaStateConnected)) {
-			if (Adapter->SecInfo.WPAEnabled
-			    || Adapter->SecInfo.WPA2Enabled) {
-				if (Adapter->IsGTK_SET) {
-					PRINTM(INFO,
-					       "EXEC_NEXT_CMD: WPA enabled and GTK_SET"
-					       " go back to PS_SLEEP");
-					PSSleep(priv, 0);
-				}
-			} else {
-				PRINTM(INFO,
-				       "EXEC_NEXT_CMD: Command PendQ is empty,"
-				       " go back to PS_SLEEP");
-				PSSleep(priv, 0);
 			}
+	//		PRINTM(INFO,
+	//		       "EXEC_NEXT_CMD: Sending Exit_PS down...\n");
+			printk(KERN_ERR "Sending Exit_PS down\n");
+			Adapter->NeedToWakeup = TRUE;
+			goto execute_cmd;
 		}
+
+		spin_unlock(&Adapter->psstate_lock);
+		PSWakeup(priv, 1);
+		spin_lock(&Adapter->psstate_lock);
+		wait_on_full_power(Adapter);
 	}
 
+execute_cmd:
+	spin_unlock(&Adapter->psstate_lock);
+//	down(&Adapter->command_sem);
+	DownloadCommandToStation(priv, cmdnode);
+
 	ret = WLAN_STATUS_SUCCESS;
-      done:
+done:
 	LEAVE();
 	return ret;
 }
 
+/* XXX: execute at timer */
+void put_back_to_ps(unsigned long data)
+{
+#if 0
+	wlan_private *priv = (wlan_private *)data;
+	wlan_adapter *Adapter = priv->adapter;
+	printk(KERN_ERR "putting back to ps mode!\n");
+	/*
+	 * check if in power save mode, if yes, put the device back
+	 * to PS mode
+	 */
+	if ((Adapter->PSMode != Wlan802_11PowerModeCAM) &&
+	    (Adapter->PSState == PS_STATE_FULL_POWER) &&
+	    (Adapter->MediaConnectStatus == WlanMediaStateConnected)) {
+		if (Adapter->SecInfo.WPAEnabled
+		    || Adapter->SecInfo.WPA2Enabled) {
+			if (Adapter->IsGTK_SET) {
+				PRINTM(INFO,
+				       "EXEC_NEXT_CMD: WPA enabled and GTK_SET"
+				       " go back to PS_SLEEP");
+				PSSleep(priv, 0);
+			}
+		} else {
+			PRINTM(INFO,
+			       "EXEC_NEXT_CMD: Command PendQ is empty,"
+			       " go back to PS_SLEEP");
+			PSSleep(priv, 0);
+			}
+		}
+	mod_timer(&Adapter->reenter_ps_timer, jiffies + (2*HZ));
+#endif
+}
+
 #if WIRELESS_EXT > 14
 /** 
  *  @brief This function sends customized event to application.
diff --git a/drivers/net/wireless/libertas/wlan_cmdresp.c b/drivers/net/wireless/libertas/wlan_cmdresp.c
index be08627..d65083b 100644
--- a/drivers/net/wireless/libertas/wlan_cmdresp.c
+++ b/drivers/net/wireless/libertas/wlan_cmdresp.c
@@ -779,9 +779,50 @@ static int wlan_ret_get_log(wlan_private
 	return WLAN_STATUS_SUCCESS;
 }
 
-/********************************************************
-		Global Functions
-********************************************************/
+#if 0
+struct cmdresp_wq {
+	struct work_struct *work;
+	struct sk_buff *skb;
+	unsigned int len;
+	wlan_private *priv;
+};
+
+static void do_process_rx_command (void *data)
+{
+	struct cmdresp_wq *cmdresp_wq = (struct cmdresp_wq*)data;
+
+	wlan_process_rx_command(cmdresp_wq->priv, cmdresp_wq->skb, cmdresp_wq->len);
+
+	kfree_skb(cmdresp_wq->skb);
+	kfree(cmdresp_wq->work);
+	kfree(cmdresp_wq);
+}
+
+void process_cmd_response(wlan_private *priv, struct sk_buff *skb, unsigned int len)
+{
+	struct cmdresp_wq *cmdresp_wq;
+	struct work_struct *work;
+
+	work = kzalloc(sizeof(struct work_struct), GFP_ATOMIC);
+	if (!work) 
+		return;
+
+	cmdresp_wq = kzalloc(sizeof(struct cmdresp_wq), GFP_ATOMIC);
+	if (!cmdresp_wq) {
+		kfree(work);
+		return;
+	}
+
+	cmdresp_wq->skb = skb;
+	cmdresp_wq->len = len;
+	cmdresp_wq->work = work; 
+	cmdresp_wq->priv = priv;
+
+	INIT_WORK(work, do_process_rx_command, cmdresp_wq);
+
+	schedule_work(work);
+}
+#endif
 
 /** 
  *  @brief This function handles the command response
@@ -806,26 +847,26 @@ int wlan_process_rx_command(wlan_private
 	del_timer(&Adapter->command_timer);
 
 	if (!Adapter->CurCmd) {
-		PRINTM(INFO, "CMD_RESP: NULL CurCmd=%p\n", Adapter->CurCmd);
-		ret = WLAN_STATUS_FAILURE;
-		goto done;
+		PRINTM(INFO, "CMD_RESP: NULL CurCmd\n");
+
+		return WLAN_STATUS_FAILURE;
 	}
+		
 	resp = (struct HostCmd_DS_COMMAND *)(Adapter->CurCmd->BufVirtualAddr);
 
-	HEXDUMP("CMD_RESP:", Adapter->CurCmd->BufVirtualAddr,
-		priv->wlan_dev.upld_len);
-
+       HEXDUMP("CMD_RESP:", Adapter->CurCmd->BufVirtualAddr,
+               priv->wlan_dev.upld_len);
 	RespCmd = wlan_le16_to_cpu(resp->Command);
 
 	Result = wlan_le16_to_cpu(resp->Result);
 
+
 	PRINTM(INFO, "CMD_RESP: %x Result: %d Length: %d\n", RespCmd,
 	       Result, priv->wlan_dev.upld_len);
 
 	if (!(RespCmd & 0x8000)) {
 		PRINTM(INFO, "Invalid response to command!");
-		Adapter->CurCmdRetCode = WLAN_STATUS_FAILURE;
-		CleanupAndInsertCmd(priv, Adapter->CurCmd);
+		free_command(Adapter->CurCmd);
 		spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
 		Adapter->CurCmd = NULL;
 		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
@@ -837,9 +878,15 @@ int wlan_process_rx_command(wlan_private
 	/* Store the response code to CurCmdRetCode. */
 	Adapter->CurCmdRetCode = wlan_le16_to_cpu(resp->Result);
 
+
+	printk(KERN_ERR "wlan_process_rx_command0\n");
+
+
 	if (RespCmd == HostCmd_RET_802_11_PS_MODE) {
 		struct HostCmd_DS_802_11_PS_MODE *psmode;
 
+		printk(KERN_ERR "HostCmd_RET_802_11_PS_MODE!\n");
+
 		psmode = &resp->params.psmode;
 		PRINTM(INFO,
 		       "CMD_RESP: PS_MODE cmd reply result=%#x action=0x%X\n",
@@ -878,15 +925,19 @@ int wlan_process_rx_command(wlan_private
 				PSWakeup(priv, 0);
 			}
 		} else if (psmode->Action == HostCmd_SubCmd_Exit_PS) {
+			spin_lock(&Adapter->psstate_lock);
 			Adapter->NeedToWakeup = FALSE;
 			Adapter->PSState = PS_STATE_FULL_POWER;
+			printk(KERN_ERR "FULL POWER!!\n");
+			wake_up_interruptible_all(&Adapter->full_power_waitq);
+			spin_unlock(&Adapter->psstate_lock);
 			PRINTM(INFO, "CMD_RESP: Exit_PS command response\n");
 		} else {
 			PRINTM(INFO, "CMD_RESP: PS- Action=0x%X\n",
 			       psmode->Action);
 		}
 
-		CleanupAndInsertCmd(priv, Adapter->CurCmd);
+		free_command(Adapter->CurCmd);
 		spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
 		Adapter->CurCmd = NULL;
 		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
@@ -895,13 +946,19 @@ int wlan_process_rx_command(wlan_private
 		goto done;
 	}
 
-	if (Adapter->CurCmd->CmdFlags & CMD_F_HOSTCMD) {
-		/* Copy the response back to response buffer */
-		memcpy(Adapter->CurCmd->pdata_buf, resp, resp->Size);
+	printk(KERN_ERR "wlan_process_rx_command1\n");
 
+	if (Adapter->CurCmd && (Adapter->CurCmd->CmdFlags & CMD_F_HOSTCMD)) {
+		/* Copy the response back to response buffer */
+		printk(KERN_ERR "copying to pdata_buf=%x\n", Adapter->CurCmd->pdata_buf);
+		if (Adapter->CurCmd->pdata_buf)
+			memcpy(Adapter->CurCmd->pdata_buf, resp, resp->Size);
 		Adapter->CurCmd->CmdFlags &= ~CMD_F_HOSTCMD;
 	}
 
+	printk(KERN_ERR "wlan_process_rx_command2\n");
+
+
 	/* If the command is not successful, cleanup and return failure */
 	if ((Result != HostCmd_RESULT_OK || !(RespCmd & 0x8000))) {
 		PRINTM(INFO, "CMD_RESP: command reply %#x result=%#x\n",
@@ -918,14 +975,19 @@ int wlan_process_rx_command(wlan_private
 
 		}
 
-		CleanupAndInsertCmd(priv, Adapter->CurCmd);
+		free_command(Adapter->CurCmd);
 		spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
 		Adapter->CurCmd = NULL;
 		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
 
+		up(&Adapter->command_sem);
 		return WLAN_STATUS_FAILURE;
 	}
 
+
+	printk(KERN_ERR "wlan_process_rx_command3\n");
+
+
 	switch (RespCmd) {
 	case HostCmd_RET_MAC_REG_ACCESS:
 	case HostCmd_RET_BBP_REG_ACCESS:
@@ -1095,13 +1157,14 @@ int wlan_process_rx_command(wlan_private
 
 	if (Adapter->CurCmd) {
 		/* Clean up and Put current command back to CmdFreeQ */
-		CleanupAndInsertCmd(priv, Adapter->CurCmd);
+		free_command(Adapter->CurCmd);
 		spin_lock_irqsave(&Adapter->QueueSpinLock, flags);
 		Adapter->CurCmd = NULL;
 		spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
 	}
 
-      done:
+done:
+	up(&Adapter->command_sem);
 	LEAVE();
 	return ret;
 }
@@ -1180,6 +1243,7 @@ int wlan_process_event(wlan_private * pr
 		}
 
 		Adapter->PSState = PS_STATE_AWAKE;
+		wake_up_interruptible_all(&priv->adapter->ds_awake_q);
 
 		if (Adapter->NeedToWakeup == TRUE) {
 			/*
@@ -1189,7 +1253,7 @@ int wlan_process_event(wlan_private * pr
 			 * in PSWakeup()
 			 */
 			PRINTM(INFO, "Waking up...\n");
-			PSWakeup(priv, 0);
+			PSWakeup(priv, 1);
 		}
 		break;
 
diff --git a/drivers/net/wireless/libertas/wlan_decl.h b/drivers/net/wireless/libertas/wlan_decl.h
index 534f44f..fb150e6 100644
--- a/drivers/net/wireless/libertas/wlan_decl.h
+++ b/drivers/net/wireless/libertas/wlan_decl.h
@@ -42,9 +42,11 @@ void SendTxFeedback(wlan_private * priv)
 u8 CheckLastPacketIndication(wlan_private * priv);
 
 void Wep_encrypt(wlan_private * priv, u8 * Buf, u32 Len);
-int FreeCmdBuffer(wlan_private * priv);
-void CleanUpCmdCtrlNode(struct CmdCtrlNode *pTempNode);
-struct CmdCtrlNode *GetFreeCmdCtrlNode(wlan_private * priv);
+struct CmdCtrlNode *allocate_command(wlan_private * priv);
+void free_command(struct CmdCtrlNode *);
+void destroy_command(struct kref *kref);
+int execute_command(wlan_private *, struct CmdCtrlNode *, int);
+
 
 void SetCmdCtrlNode(wlan_private * priv,
 		    struct CmdCtrlNode *pTempNode,
@@ -55,11 +57,7 @@ int PrepareAndSendCommand(wlan_private *
 			  u16 cmd_action,
 			  u16 wait_option, u32 cmd_oid, void *pdata_buf);
 
-void QueueCmd(wlan_adapter * Adapter, struct CmdCtrlNode *CmdNode, u8 addtail);
-
 int SetDeepSleep(wlan_private * priv, u8 bDeepSleep);
-int AllocateCmdBuffer(wlan_private * priv);
-int ExecuteNextCommand(wlan_private * priv);
 int wlan_process_event(wlan_private * priv);
 void wlan_interrupt(struct net_device *);
 int SetRadioControl(wlan_private * priv);
@@ -68,6 +66,7 @@ u8 data_rate_to_index(u32 rate);
 void HexDump(char *prompt, u8 * data, int len);
 void get_version(wlan_adapter * adapter, char *version, int maxlen);
 void wlan_read_write_rfreg(wlan_private * priv);
+void put_back_to_ps(unsigned long data);
 
 /** The proc fs interface */
 void wlan_proc_entry(wlan_private * priv, struct net_device *dev);
@@ -75,6 +74,7 @@ void wlan_proc_remove(wlan_private * pri
 void wlan_debug_entry(wlan_private * priv, struct net_device *dev);
 void wlan_debug_remove(wlan_private * priv);
 int wlan_process_rx_command(wlan_private * priv);
+void process_cmd_response(wlan_private *priv, struct sk_buff *skb, unsigned int len);
 int wlan_process_tx(wlan_private * priv, struct sk_buff *skb);
 void CleanupAndInsertCmd(wlan_private * priv, struct CmdCtrlNode *pTempCmd);
 void command_timer_fn(unsigned long data);
@@ -97,8 +97,6 @@ void PSWakeup(wlan_private * priv, int w
 
 #define SDIO_HEADER_LEN		4
 
-void wlan_send_rxskbQ(wlan_private * priv);
-
 extern CHANNEL_FREQ_POWER *find_cfp_by_band_and_channel(wlan_adapter * adapter,
 							u8 band, u16 channel);
 
diff --git a/drivers/net/wireless/libertas/wlan_dev.h b/drivers/net/wireless/libertas/wlan_dev.h
index fbc19cd..fd8b38d 100644
--- a/drivers/net/wireless/libertas/wlan_dev.h
+++ b/drivers/net/wireless/libertas/wlan_dev.h
@@ -133,16 +133,10 @@ typedef struct _wlan_dev {
 	void *card;
 	/** IO port */
 	u32 ioport;
-	/** Upload received */
-	u32 upld_rcv;
-	/** Upload type */
-	u32 upld_typ;
-	/** Upload length */
 	u32 upld_len;
+	u8 upld_buf[WLAN_UPLD_SIZE];
 	/** netdev pointer */
 	struct net_device *netdev;
-	/* Upload buffer */
-	u8 upld_buf[WLAN_UPLD_SIZE];
 	/* Download sent: 
 	   bit0 1/0=data_sent/data_tx_done, 
 	   bit1 1/0=cmd_sent/cmd_tx_done, 
@@ -220,6 +214,7 @@ #endif				/* REASSOCIATION */
 	/** Event Queues */
 	wait_queue_head_t ds_awake_q;
 
+
 	u8 HisRegCpy;
 
 	/** current ssid/bssid related parameters*/
@@ -251,6 +246,8 @@ #ifdef REASSOCIATION
 	struct semaphore ReassocSem;
 #endif				/* REASSOCIATION */
 
+	struct semaphore command_sem;
+
 	u8 ATIMEnabled;
 
 	/** MAC address information */
@@ -306,8 +303,14 @@ #endif				/* REASSOCIATION */
 	u16 PSMode;		/* Wlan802_11PowerModeCAM=disable
 				   Wlan802_11PowerModeMAX_PSP=enable */
 	u16 MultipleDtim;
+	spinlock_t psstate_lock;
 	u32 PSState;
 	u8 NeedToWakeup;
+	/* Exit power save mode (transition to full power) event */
+	wait_queue_head_t full_power_waitq;
+	struct timer_list reenter_ps_timer;
+
+
 
 	struct PS_CMD_ConfirmSleep PSConfirmSleep;
 	u16 LocalListenInterval;
diff --git a/drivers/net/wireless/libertas/wlan_fw.c b/drivers/net/wireless/libertas/wlan_fw.c
index df90bbc..866730b 100644
--- a/drivers/net/wireless/libertas/wlan_fw.c
+++ b/drivers/net/wireless/libertas/wlan_fw.c
@@ -161,8 +161,7 @@ static int wlan_allocate_adapter(wlan_pr
 
 	spin_lock_init(&Adapter->QueueSpinLock);
 
-	/* Allocate the command buffers */
-	AllocateCmdBuffer(priv);
+	spin_lock_init(&Adapter->psstate_lock);
 
 	memset(&Adapter->PSConfirmSleep, 0, sizeof(struct PS_CMD_ConfirmSleep));
 	Adapter->PSConfirmSleep.SeqNum = wlan_cpu_to_le16(++Adapter->SeqNum);
@@ -227,6 +226,7 @@ static void wlan_init_adapter(wlan_priva
 #ifdef REASSOCIATION
 	init_MUTEX(&Adapter->ReassocSem);
 #endif
+	init_MUTEX(&Adapter->command_sem);
 
 	Adapter->Prescan = CMD_ENABLED;
 
@@ -307,6 +307,9 @@ int wlan_init_fw(wlan_private * priv)
 	setup_timer(&Adapter->command_timer, command_timer_fn,
 			(unsigned long)priv);
 
+	setup_timer(&Adapter->reenter_ps_timer, put_back_to_ps,
+			(unsigned long)priv);
+
 #ifdef REASSOCIATION
         /* Initialize the timer for the reassociation */
 	setup_timer(&Adapter->reassoc_timer, reassoc_timer_fn,
@@ -345,9 +348,6 @@ void wlan_free_adapter(wlan_private * pr
 		return;
 	}
 
-	PRINTM(INFO, "Free Command buffer\n");
-	FreeCmdBuffer(priv);
-
 	PRINTM(INFO, "Free CommandTimer\n");
 	del_timer(&Adapter->command_timer);
 #ifdef REASSOCIATION
@@ -399,7 +399,7 @@ void command_timer_fn(unsigned long data
 	spin_unlock_irqrestore(&Adapter->QueueSpinLock, flags);
 
 	PRINTM(INFO, "Re-sending same command as it timeout...!\n");
-	QueueCmd(Adapter, pTempNode, FALSE);
+	execute_command(priv, pTempNode, 0);
 
 	wake_up_interruptible(&priv->MainThread.waitQ);
 
diff --git a/drivers/net/wireless/libertas/wlan_fw.h b/drivers/net/wireless/libertas/wlan_fw.h
index fe11c7e..bd6a3d8 100644
--- a/drivers/net/wireless/libertas/wlan_fw.h
+++ b/drivers/net/wireless/libertas/wlan_fw.h
@@ -43,6 +43,5 @@ #define FIRMWARE_TRANSFER_BLOCK_SIZE    
 int wlan_init_fw(wlan_private * priv);
 int wlan_disable_host_int(wlan_private * priv, u8 reg);
 int wlan_enable_host_int(wlan_private * priv, u8 mask);
-int wlan_free_cmd_buffers(wlan_private * priv);
 
 #endif				/* _WLAN_FW_H_ */
diff --git a/drivers/net/wireless/libertas/wlan_main.c b/drivers/net/wireless/libertas/wlan_main.c
index 1b1e167..a67cf67 100644
--- a/drivers/net/wireless/libertas/wlan_main.c
+++ b/drivers/net/wireless/libertas/wlan_main.c
@@ -744,11 +744,6 @@ static int wlan_service_main_thread(void
 			continue;
 		}
 
-		/* Execute the next command */
-		if (!priv->wlan_dev.dnld_sent && !Adapter->CurCmd) {
-			ExecuteNextCommand(priv);
-		}
-
 	}
 
 	wlan_deactivate_thread(thread);
@@ -823,6 +818,8 @@ #define NETIF_F_DYNALLOC 16
 
 	init_waitqueue_head(&priv->adapter->ds_awake_q);
 
+	init_waitqueue_head(&priv->adapter->full_power_waitq);
+
 #ifdef ENABLE_PM
 	if (!(wlan_pm_dev = pm_register(PM_UNKNOWN_DEV, 0, wlan_pm_callback)))
 		PRINTM(MSG, "Failed to register PM callback\n");
diff --git a/drivers/net/wireless/libertas/wlan_wext.c b/drivers/net/wireless/libertas/wlan_wext.c
index 63dda4b..fc058b2 100644
--- a/drivers/net/wireless/libertas/wlan_wext.c
+++ b/drivers/net/wireless/libertas/wlan_wext.c
@@ -1849,6 +1849,8 @@ static int wlan_set_power(struct net_dev
 
 	if (vwrq->disabled) {
 		Adapter->PSMode = Wlan802_11PowerModeCAM;
+
+		del_timer(&Adapter->reenter_ps_timer);
 		if (Adapter->PSState != PS_STATE_FULL_POWER) {
 			PSWakeup(priv, HostCmd_OPTION_WAITFORRSP);
 		}
@@ -1873,6 +1875,7 @@ static int wlan_set_power(struct net_dev
 
 	if (Adapter->MediaConnectStatus == WlanMediaStateConnected) {
 		PSSleep(priv, HostCmd_OPTION_WAITFORRSP);
+		mod_timer(&Adapter->reenter_ps_timer, jiffies + (2*HZ));
 	}
 
 	LEAVE();
@@ -2508,7 +2511,6 @@ static int wlan_hostcmd_ioctl(struct net
 	struct CmdCtrlNode *pCmdNode;
 	struct HostCmd_DS_GEN *gencmd, *pCmdPtr;
 	wlan_private *priv = dev->priv;
-	wlan_adapter *Adapter = priv->adapter;
 	u16 wait_option = 0;
 
 	ENTER();
@@ -2516,8 +2518,8 @@ static int wlan_hostcmd_ioctl(struct net
 	/*
 	 * Get a free command control node 
 	 */
-	if (!(pCmdNode = GetFreeCmdCtrlNode(priv))) {
-		PRINTM(INFO, "Failed GetFreeCmdCtrlNode\n");
+	if (!(pCmdNode = allocate_command(priv))) {
+		PRINTM(INFO, "Failed allocate_command\n");
 		return -ENOMEM;
 	}
 
@@ -2556,8 +2558,7 @@ static int wlan_hostcmd_ioctl(struct net
 	       req->ifr_data, pCmdPtr);
 
 	pCmdNode->CmdWaitQWoken = FALSE;
-	QueueCmd(Adapter, pCmdNode, TRUE);
-	wake_up_interruptible(&priv->MainThread.waitQ);
+	execute_command(priv, pCmdNode, 1);
 
 	if (wait_option & HostCmd_OPTION_WAITFORRSP) {
 		/* Sleep until response is generated by FW */
