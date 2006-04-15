From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] wireless/airo: minimal WPA awareness
Date: Sat, 15 Apr 2006 12:26:18 -0400
Message-ID: <1145118379.2324.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	matthieu castet <castet.matthieu@free.fr>,
	Javier Achirica <achirica@telefonica.net>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:1154 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1030285AbWDOQaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 12:30:18 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

airo cards with firmware versions of 5.30.17 and higher support WPA.
This patch recognizes WPA-capable firmware versions and adds support for
retrieving the WPA and RSN information elements from the card's scan
results.  The JOB and FLAG fields are now independent, since there was
no space left in the FLAG field for FLAG_WPA_CAPABLE.

Signed-off-by: matthieu castet <castet.matthieu@free.fr>
Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/airo.c	2006-04-04 09:59:43.000000000 -0400
+++ b/drivers/net/wireless/airo.c	2006-04-15 12:16:21.000000000 -0400
@@ -47,6 +47,7 @@
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <asm/uaccess.h>
+#include <net/ieee80211.h>
 
 #include "airo.h"
 
@@ -467,6 +468,8 @@
 #define RID_ECHOTEST_RESULTS 0xFF71
 #define RID_BSSLISTFIRST 0xFF72
 #define RID_BSSLISTNEXT  0xFF73
+#define RID_WPA_BSSLISTFIRST 0xFF74
+#define RID_WPA_BSSLISTNEXT  0xFF75
 
 typedef struct {
 	u16 cmd;
@@ -739,6 +742,14 @@
 	u16 extSoftCap;
 } CapabilityRid;
 
+
+/* Only present on firmware >= 5.30.17 */
+typedef struct {
+  u16 unknown[4];
+  u8 fixed[12]; /* WLAN management frame */
+  u8 iep[624];
+} BSSListRidExtra;
+
 typedef struct {
   u16 len;
   u16 index; /* First is 0 and 0xffff means end of list */
@@ -767,6 +778,9 @@
   } fh;
   u16 dsChannel;
   u16 atimWindow;
+
+  /* Only present on firmware >= 5.30.17 */
+  BSSListRidExtra extra;
 } BSSListRid;
 
 typedef struct {
@@ -1140,8 +1154,6 @@
 	char defindex; // Used with auto wep
 	struct proc_dir_entry *proc_entry;
         spinlock_t aux_lock;
-        unsigned long flags;
-#define FLAG_PROMISC	8	/* IFF_PROMISC 0x100 - include/linux/if.h */
 #define FLAG_RADIO_OFF	0	/* User disabling of MAC */
 #define FLAG_RADIO_DOWN	1	/* ifup/ifdown disabling of MAC */
 #define FLAG_RADIO_MASK 0x03
@@ -1151,6 +1163,7 @@
 #define FLAG_UPDATE_MULTI 5
 #define FLAG_UPDATE_UNI 6
 #define FLAG_802_11	7
+#define FLAG_PROMISC	8	/* IFF_PROMISC 0x100 - include/linux/if.h */
 #define FLAG_PENDING_XMIT 9
 #define FLAG_PENDING_XMIT11 10
 #define FLAG_MPI	11
@@ -1158,17 +1171,19 @@
 #define FLAG_COMMIT	13
 #define FLAG_RESET	14
 #define FLAG_FLASHING	15
-#define JOB_MASK	0x2ff0000
-#define JOB_DIE		16
-#define JOB_XMIT	17
-#define JOB_XMIT11	18
-#define JOB_STATS	19
-#define JOB_PROMISC	20
-#define JOB_MIC		21
-#define JOB_EVENT	22
-#define JOB_AUTOWEP	23
-#define JOB_WSTATS	24
-#define JOB_SCAN_RESULTS  25
+#define FLAG_WPA_CAPABLE	16
+	unsigned long flags;
+#define JOB_DIE	0
+#define JOB_XMIT	1
+#define JOB_XMIT11	2
+#define JOB_STATS	3
+#define JOB_PROMISC	4
+#define JOB_MIC	5
+#define JOB_EVENT	6
+#define JOB_AUTOWEP	7
+#define JOB_WSTATS	8
+#define JOB_SCAN_RESULTS  9
+	unsigned long jobs;
 	int (*bap_read)(struct airo_info*, u16 *pu16Dst, int bytelen,
 			int whichbap);
 	unsigned short *flash;
@@ -1208,6 +1223,11 @@
 #define	PCI_SHARED_LEN		2*MPI_MAX_FIDS*PKTSIZE+RIDSIZE
 	char			proc_name[IFNAMSIZ];
 
+	/* WPA-related stuff */
+	unsigned int bssListFirst;
+	unsigned int bssListNext;
+	unsigned int bssListRidLen;
+
 	struct list_head network_list;
 	struct list_head network_free_list;
 	BSSListElement *networks;
@@ -1264,7 +1284,7 @@
 {
 	MICRid mic_rid;
 
-	clear_bit(JOB_MIC, &ai->flags);
+	clear_bit(JOB_MIC, &ai->jobs);
 	PC4500_readrid(ai, RID_MIC, &mic_rid, sizeof(mic_rid), 0);
 	up(&ai->sem);
 
@@ -1705,24 +1725,24 @@
 static int readBSSListRid(struct airo_info *ai, int first,
 		      BSSListRid *list) {
 	int rc;
-			Cmd cmd;
-			Resp rsp;
+	Cmd cmd;
+	Resp rsp;
 
 	if (first == 1) {
-			if (ai->flags & FLAG_RADIO_MASK) return -ENETDOWN;
-			memset(&cmd, 0, sizeof(cmd));
-			cmd.cmd=CMD_LISTBSS;
-			if (down_interruptible(&ai->sem))
-				return -ERESTARTSYS;
-			issuecommand(ai, &cmd, &rsp);
-			up(&ai->sem);
-			/* Let the command take effect */
-			ai->task = current;
-			ssleep(3);
-			ai->task = NULL;
-		}
-	rc = PC4500_readrid(ai, first ? RID_BSSLISTFIRST : RID_BSSLISTNEXT,
-			    list, sizeof(*list), 1);
+		if (ai->flags & FLAG_RADIO_MASK) return -ENETDOWN;
+		memset(&cmd, 0, sizeof(cmd));
+		cmd.cmd=CMD_LISTBSS;
+		if (down_interruptible(&ai->sem))
+			return -ERESTARTSYS;
+		issuecommand(ai, &cmd, &rsp);
+		up(&ai->sem);
+		/* Let the command take effect */
+		ai->task = current;
+		ssleep(3);
+		ai->task = NULL;
+	}
+	rc = PC4500_readrid(ai, first ? ai->bssListFirst : ai->bssListNext,
+			    list, ai->bssListRidLen, 1);
 
 	list->len = le16_to_cpu(list->len);
 	list->index = le16_to_cpu(list->index);
@@ -2112,7 +2132,7 @@
 	int fid = priv->xmit.fid;
 	u32 *fids = priv->fids;
 
-	clear_bit(JOB_XMIT, &priv->flags);
+	clear_bit(JOB_XMIT, &priv->jobs);
 	clear_bit(FLAG_PENDING_XMIT, &priv->flags);
 	status = transmit_802_3_packet (priv, fids[fid], skb->data);
 	up(&priv->sem);
@@ -2162,7 +2182,7 @@
 	if (down_trylock(&priv->sem) != 0) {
 		set_bit(FLAG_PENDING_XMIT, &priv->flags);
 		netif_stop_queue(dev);
-		set_bit(JOB_XMIT, &priv->flags);
+		set_bit(JOB_XMIT, &priv->jobs);
 		wake_up_interruptible(&priv->thr_wait);
 	} else
 		airo_end_xmit(dev);
@@ -2177,7 +2197,7 @@
 	int fid = priv->xmit11.fid;
 	u32 *fids = priv->fids;
 
-	clear_bit(JOB_XMIT11, &priv->flags);
+	clear_bit(JOB_XMIT11, &priv->jobs);
 	clear_bit(FLAG_PENDING_XMIT11, &priv->flags);
 	status = transmit_802_11_packet (priv, fids[fid], skb->data);
 	up(&priv->sem);
@@ -2233,7 +2253,7 @@
 	if (down_trylock(&priv->sem) != 0) {
 		set_bit(FLAG_PENDING_XMIT11, &priv->flags);
 		netif_stop_queue(dev);
-		set_bit(JOB_XMIT11, &priv->flags);
+		set_bit(JOB_XMIT11, &priv->jobs);
 		wake_up_interruptible(&priv->thr_wait);
 	} else
 		airo_end_xmit11(dev);
@@ -2244,7 +2264,7 @@
 	StatsRid stats_rid;
 	u32 *vals = stats_rid.vals;
 
-	clear_bit(JOB_STATS, &ai->flags);
+	clear_bit(JOB_STATS, &ai->jobs);
 	if (ai->power.event) {
 		up(&ai->sem);
 		return;
@@ -2272,10 +2292,10 @@
 {
 	struct airo_info *local =  dev->priv;
 
-	if (!test_bit(JOB_STATS, &local->flags)) {
+	if (!test_bit(JOB_STATS, &local->jobs)) {
 		/* Get stats out of the card if available */
 		if (down_trylock(&local->sem) != 0) {
-			set_bit(JOB_STATS, &local->flags);
+			set_bit(JOB_STATS, &local->jobs);
 			wake_up_interruptible(&local->thr_wait);
 		} else
 			airo_read_stats(local);
@@ -2290,7 +2310,7 @@
 
 	memset(&cmd, 0, sizeof(cmd));
 	cmd.cmd=CMD_SETMODE;
-	clear_bit(JOB_PROMISC, &ai->flags);
+	clear_bit(JOB_PROMISC, &ai->jobs);
 	cmd.parm0=(ai->flags&IFF_PROMISC) ? PROMISC : NOPROMISC;
 	issuecommand(ai, &cmd, &rsp);
 	up(&ai->sem);
@@ -2302,7 +2322,7 @@
 	if ((dev->flags ^ ai->flags) & IFF_PROMISC) {
 		change_bit(FLAG_PROMISC, &ai->flags);
 		if (down_trylock(&ai->sem) != 0) {
-			set_bit(JOB_PROMISC, &ai->flags);
+			set_bit(JOB_PROMISC, &ai->jobs);
 			wake_up_interruptible(&ai->thr_wait);
 		} else
 			airo_set_promisc(ai);
@@ -2380,7 +2400,7 @@
 		}
 		clear_bit(FLAG_REGISTERED, &ai->flags);
 	}
-	set_bit(JOB_DIE, &ai->flags);
+	set_bit(JOB_DIE, &ai->jobs);
 	kill_proc(ai->thr_pid, SIGTERM, 1);
 	wait_for_completion(&ai->thr_exited);
 
@@ -2701,14 +2721,14 @@
 	return 0;
 }
 
-#define MAX_NETWORK_COUNT	64
+#define AIRO_MAX_NETWORK_COUNT	64
 static int airo_networks_allocate(struct airo_info *ai)
 {
 	if (ai->networks)
 		return 0;
 
 	ai->networks =
-	    kzalloc(MAX_NETWORK_COUNT * sizeof(BSSListElement),
+	    kzalloc(AIRO_MAX_NETWORK_COUNT * sizeof(BSSListElement),
 		    GFP_KERNEL);
 	if (!ai->networks) {
 		airo_print_warn(ai->dev->name, "Out of memory allocating beacons");
@@ -2732,11 +2752,33 @@
 
 	INIT_LIST_HEAD(&ai->network_free_list);
 	INIT_LIST_HEAD(&ai->network_list);
-	for (i = 0; i < MAX_NETWORK_COUNT; i++)
+	for (i = 0; i < AIRO_MAX_NETWORK_COUNT; i++)
 		list_add_tail(&ai->networks[i].list,
 			      &ai->network_free_list);
 }
 
+static int airo_test_wpa_capable(struct airo_info *ai)
+{
+	int status;
+	CapabilityRid cap_rid;
+	const char *name = ai->dev->name;
+
+	status = readCapabilityRid(ai, &cap_rid, 1);
+	if (status != SUCCESS) return 0;
+
+	/* Only firmware versions 5.30.17 or better can do WPA */
+	if ((cap_rid.softVer > 0x530)
+	  || ((cap_rid.softVer == 0x530) && (cap_rid.softSubVer >= 0x17))) {
+		airo_print_info(name, "WPA is supported.");
+		return 1;
+	}
+
+	/* No WPA support */
+	airo_print_info(name, "WPA unsupported (only firmware versions 5.30.17"
+		" and greater support WPA.  Detected %s)", cap_rid.prodVer);
+	return 0;
+}
+
 static struct net_device *_init_airo_card( unsigned short irq, int port,
 					   int is_pcmcia, struct pci_dev *pci,
 					   struct device *dmdev )
@@ -2759,6 +2801,7 @@
 	ai = dev->priv;
 	ai->wifidev = NULL;
 	ai->flags = 0;
+	ai->jobs = 0;
 	ai->dev = dev;
 	if (pci && (pci->device == 0x5000 || pci->device == 0xa504)) {
 		airo_print_dbg(dev->name, "Found an MPI350 card");
@@ -2838,6 +2881,18 @@
 		set_bit(FLAG_FLASHING, &ai->flags);
 	}
 
+	/* Test for WPA support */
+	if (airo_test_wpa_capable(ai)) {
+		set_bit(FLAG_WPA_CAPABLE, &ai->flags);
+		ai->bssListFirst = RID_WPA_BSSLISTFIRST;
+		ai->bssListNext = RID_WPA_BSSLISTNEXT;
+		ai->bssListRidLen = sizeof(BSSListRid);
+	} else {
+		ai->bssListFirst = RID_BSSLISTFIRST;
+		ai->bssListNext = RID_BSSLISTNEXT;
+		ai->bssListRidLen = sizeof(BSSListRid) - sizeof(BSSListRidExtra);
+	}
+
 	rc = register_netdev(dev);
 	if (rc) {
 		airo_print_err(dev->name, "Couldn't register_netdev");
@@ -2875,7 +2930,7 @@
 err_out_unlink:
 	del_airo_dev(dev);
 err_out_thr:
-	set_bit(JOB_DIE, &ai->flags);
+	set_bit(JOB_DIE, &ai->jobs);
 	kill_proc(ai->thr_pid, SIGTERM, 1);
 	wait_for_completion(&ai->thr_exited);
 err_out_free:
@@ -2933,7 +2988,7 @@
 	union iwreq_data wrqu;
 	StatusRid status_rid;
 
-	clear_bit(JOB_EVENT, &ai->flags);
+	clear_bit(JOB_EVENT, &ai->jobs);
 	PC4500_readrid(ai, RID_STATUS, &status_rid, sizeof(status_rid), 0);
 	up(&ai->sem);
 	wrqu.data.length = 0;
@@ -2947,7 +3002,7 @@
 
 static void airo_process_scan_results (struct airo_info *ai) {
 	union iwreq_data	wrqu;
-	BSSListRid BSSList;
+	BSSListRid bss;
 	int rc;
 	BSSListElement * loop_net;
 	BSSListElement * tmp_net;
@@ -2960,15 +3015,15 @@
 	}
 
 	/* Try to read the first entry of the scan result */
-	rc = PC4500_readrid(ai, RID_BSSLISTFIRST, &BSSList, sizeof(BSSList), 0);
-	if((rc) || (BSSList.index == 0xffff)) {
+	rc = PC4500_readrid(ai, ai->bssListFirst, &bss, ai->bssListRidLen, 0);
+	if((rc) || (bss.index == 0xffff)) {
 		/* No scan results */
 		goto out;
 	}
 
 	/* Read and parse all entries */
 	tmp_net = NULL;
-	while((!rc) && (BSSList.index != 0xffff)) {
+	while((!rc) && (bss.index != 0xffff)) {
 		/* Grab a network off the free list */
 		if (!list_empty(&ai->network_free_list)) {
 			tmp_net = list_entry(ai->network_free_list.next,
@@ -2977,19 +3032,19 @@
 		}
 
 		if (tmp_net != NULL) {
-			memcpy(tmp_net, &BSSList, sizeof(tmp_net->bss));
+			memcpy(tmp_net, &bss, sizeof(tmp_net->bss));
 			list_add_tail(&tmp_net->list, &ai->network_list);
 			tmp_net = NULL;
 		}
 
 		/* Read next entry */
-		rc = PC4500_readrid(ai, RID_BSSLISTNEXT,
-				    &BSSList, sizeof(BSSList), 0);
+		rc = PC4500_readrid(ai, ai->bssListNext,
+				    &bss, ai->bssListRidLen, 0);
 	}
 
 out:
 	ai->scan_timeout = 0;
-	clear_bit(JOB_SCAN_RESULTS, &ai->flags);
+	clear_bit(JOB_SCAN_RESULTS, &ai->jobs);
 	up(&ai->sem);
 
 	/* Send an empty event to user space.
@@ -3019,10 +3074,10 @@
 		/* make swsusp happy with our thread */
 		try_to_freeze();
 
-		if (test_bit(JOB_DIE, &ai->flags))
+		if (test_bit(JOB_DIE, &ai->jobs))
 			break;
 
-		if (ai->flags & JOB_MASK) {
+		if (ai->jobs) {
 			locked = down_interruptible(&ai->sem);
 		} else {
 			wait_queue_t wait;
@@ -3031,16 +3086,16 @@
 			add_wait_queue(&ai->thr_wait, &wait);
 			for (;;) {
 				set_current_state(TASK_INTERRUPTIBLE);
-				if (ai->flags & JOB_MASK)
+				if (ai->jobs)
 					break;
 				if (ai->expires || ai->scan_timeout) {
 					if (ai->scan_timeout &&
 							time_after_eq(jiffies,ai->scan_timeout)){
-						set_bit(JOB_SCAN_RESULTS,&ai->flags);
+						set_bit(JOB_SCAN_RESULTS, &ai->jobs);
 						break;
 					} else if (ai->expires &&
 							time_after_eq(jiffies,ai->expires)){
-						set_bit(JOB_AUTOWEP,&ai->flags);
+						set_bit(JOB_AUTOWEP, &ai->jobs);
 						break;
 					}
 					if (!signal_pending(current)) {
@@ -3069,7 +3124,7 @@
 		if (locked)
 			continue;
 
-		if (test_bit(JOB_DIE, &ai->flags)) {
+		if (test_bit(JOB_DIE, &ai->jobs)) {
 			up(&ai->sem);
 			break;
 		}
@@ -3079,23 +3134,23 @@
 			continue;
 		}
 
-		if (test_bit(JOB_XMIT, &ai->flags))
+		if (test_bit(JOB_XMIT, &ai->jobs))
 			airo_end_xmit(dev);
-		else if (test_bit(JOB_XMIT11, &ai->flags))
+		else if (test_bit(JOB_XMIT11, &ai->jobs))
 			airo_end_xmit11(dev);
-		else if (test_bit(JOB_STATS, &ai->flags))
+		else if (test_bit(JOB_STATS, &ai->jobs))
 			airo_read_stats(ai);
-		else if (test_bit(JOB_WSTATS, &ai->flags))
+		else if (test_bit(JOB_WSTATS, &ai->jobs))
 			airo_read_wireless_stats(ai);
-		else if (test_bit(JOB_PROMISC, &ai->flags))
+		else if (test_bit(JOB_PROMISC, &ai->jobs))
 			airo_set_promisc(ai);
-		else if (test_bit(JOB_MIC, &ai->flags))
+		else if (test_bit(JOB_MIC, &ai->jobs))
 			micinit(ai);
-		else if (test_bit(JOB_EVENT, &ai->flags))
+		else if (test_bit(JOB_EVENT, &ai->jobs))
 			airo_send_event(dev);
-		else if (test_bit(JOB_AUTOWEP, &ai->flags))
+		else if (test_bit(JOB_AUTOWEP, &ai->jobs))
 			timer_func(dev);
-		else if (test_bit(JOB_SCAN_RESULTS, &ai->flags))
+		else if (test_bit(JOB_SCAN_RESULTS, &ai->jobs))
 			airo_process_scan_results(ai);
 		else  /* Shouldn't get here, but we make sure to unlock */
 			up(&ai->sem);
@@ -3133,7 +3188,7 @@
 		if ( status & EV_MIC ) {
 			OUT4500( apriv, EVACK, EV_MIC );
 			if (test_bit(FLAG_MIC_CAPABLE, &apriv->flags)) {
-				set_bit(JOB_MIC, &apriv->flags);
+				set_bit(JOB_MIC, &apriv->jobs);
 				wake_up_interruptible(&apriv->thr_wait);
 			}
 		}
@@ -3187,7 +3242,7 @@
 				set_bit(FLAG_UPDATE_MULTI, &apriv->flags);
 
 				if (down_trylock(&apriv->sem) != 0) {
-					set_bit(JOB_EVENT, &apriv->flags);
+					set_bit(JOB_EVENT, &apriv->jobs);
 					wake_up_interruptible(&apriv->thr_wait);
 				} else
 					airo_send_event(dev);
@@ -5485,7 +5540,7 @@
 	up(&apriv->sem);
 
 /* Schedule check to see if the change worked */
-	clear_bit(JOB_AUTOWEP, &apriv->flags);
+	clear_bit(JOB_AUTOWEP, &apriv->jobs);
 	apriv->expires = RUN_AT(HZ*3);
 }
 
@@ -6876,7 +6931,7 @@
 	}
 	range->num_txpower = i;
 	range->txpower_capa = IW_TXPOW_MWATT;
-	range->we_version_source = 12;
+	range->we_version_source = 19;
 	range->we_version_compiled = WIRELESS_EXT;
 	range->retry_capa = IW_RETRY_LIMIT | IW_RETRY_LIFETIME;
 	range->retry_flags = IW_RETRY_LIMIT;
@@ -7152,6 +7207,7 @@
 	u16			capabilities;
 	char *			current_val;	/* For rates */
 	int			i;
+	char *		buf;
 
 	/* First entry *MUST* be the AP MAC address */
 	iwe.cmd = SIOCGIWAP;
@@ -7238,8 +7294,69 @@
 	if((current_val - current_ev) > IW_EV_LCP_LEN)
 		current_ev = current_val;
 
-	/* The other data in the scan result are not really
-	 * interesting, so for now drop it - Jean II */
+	/* Beacon interval */
+	buf = kmalloc(30, GFP_KERNEL);
+	if (buf) {
+		iwe.cmd = IWEVCUSTOM;
+		sprintf(buf, "bcn_int=%d", bss->beaconInterval);
+		iwe.u.data.length = strlen(buf);
+		current_ev = iwe_stream_add_point(current_ev, end_buf, &iwe, buf);
+		kfree(buf);
+	}
+
+	/* Put WPA/RSN Information Elements into the event stream */
+	if (test_bit(FLAG_WPA_CAPABLE, &ai->flags)) {
+		unsigned int num_null_ies = 0;
+		u16 length = sizeof (bss->extra.iep);
+		struct ieee80211_info_element *info_element =
+			(struct ieee80211_info_element *) &bss->extra.iep;
+
+		while ((length >= sizeof(*info_element)) && (num_null_ies < 2)) {
+			if (sizeof(*info_element) + info_element->len > length) {
+				/* Invalid element, don't continue parsing IE */
+				break;
+			}
+
+			switch (info_element->id) {
+			case MFIE_TYPE_SSID:
+				/* Two zero-length SSID elements
+				 * mean we're done parsing elements */
+				if (!info_element->len)
+					num_null_ies++;
+				break;
+
+			case MFIE_TYPE_GENERIC:
+				if (info_element->len >= 4 &&
+				    info_element->data[0] == 0x00 &&
+				    info_element->data[1] == 0x50 &&
+				    info_element->data[2] == 0xf2 &&
+				    info_element->data[3] == 0x01) {
+					iwe.cmd = IWEVGENIE;
+					iwe.u.data.length = min(info_element->len + 2,
+								  MAX_WPA_IE_LEN);
+					current_ev = iwe_stream_add_point(current_ev, end_buf,
+							&iwe, (char *) info_element);
+				}
+				break;
+
+			case MFIE_TYPE_RSN:
+				iwe.cmd = IWEVGENIE;
+				iwe.u.data.length = min(info_element->len + 2,
+							  MAX_WPA_IE_LEN);
+				current_ev = iwe_stream_add_point(current_ev, end_buf,
+						&iwe, (char *) info_element);
+				break;
+
+			default:
+				break;
+			}
+
+			length -= sizeof(*info_element) + info_element->len;
+			info_element =
+			    (struct ieee80211_info_element *)&info_element->
+			    data[info_element->len];
+		}
+	}
 	return current_ev;
 }
 
@@ -7521,7 +7638,7 @@
 	u32 *vals = stats_rid.vals;
 
 	/* Get stats out of the card */
-	clear_bit(JOB_WSTATS, &local->flags);
+	clear_bit(JOB_WSTATS, &local->jobs);
 	if (local->power.event) {
 		up(&local->sem);
 		return;
@@ -7565,10 +7682,10 @@
 {
 	struct airo_info *local =  dev->priv;
 
-	if (!test_bit(JOB_WSTATS, &local->flags)) {
+	if (!test_bit(JOB_WSTATS, &local->jobs)) {
 		/* Get stats out of the card if available */
 		if (down_trylock(&local->sem) != 0) {
-			set_bit(JOB_WSTATS, &local->flags);
+			set_bit(JOB_WSTATS, &local->jobs);
 			wake_up_interruptible(&local->thr_wait);
 		} else
 			airo_read_wireless_stats(local);


