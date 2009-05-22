From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 06/19] Added layer-1-hold feature
Date: Fri, 22 May 2009 23:04:48 +0200
Message-ID: <7b75bb78f88622935b1f8d0646513f8fd3f5ccd0.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758627AbZEVVGa@vger.kernel.org>
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas@eversberg.eu>

Add IMHOLD_L1 ioctl.
The feature will be disabled on closing.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/socket.c |   21 ++++++++++++++++++---
 drivers/isdn/mISDN/tei.c    |   43 +++++++++++++++++++++++++++++++------------
 include/linux/mISDNif.h     |    2 ++
 3 files changed, 51 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 508945d..530f689 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -292,7 +292,7 @@ static int
 data_sock_ioctl_bound(struct sock *sk, unsigned int cmd, void __user *p)
 {
 	struct mISDN_ctrl_req	cq;
-	int			err = -EINVAL, val;
+	int			err = -EINVAL, val[2];
 	struct mISDNchannel	*bchan, *next;
 
 	lock_sock(sk);
@@ -328,12 +328,27 @@ data_sock_ioctl_bound(struct sock *sk, unsigned int cmd, void __user *p)
 			err = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)p)) {
+		val[0] = cmd;
+		if (get_user(val[1], (int __user *)p)) {
 			err = -EFAULT;
 			break;
 		}
 		err = _pms(sk)->dev->teimgr->ctrl(_pms(sk)->dev->teimgr,
-		    CONTROL_CHANNEL, &val);
+		    CONTROL_CHANNEL, val);
+		break;
+	case IMHOLD_L1:
+		if (sk->sk_protocol != ISDN_P_LAPD_NT
+		 && sk->sk_protocol != ISDN_P_LAPD_TE) {
+			err = -EINVAL;
+			break;
+		}
+		val[0] = cmd;
+		if (get_user(val[1], (int __user *)p)) {
+			err = -EFAULT;
+			break;
+		}
+		err = _pms(sk)->dev->teimgr->ctrl(_pms(sk)->dev->teimgr,
+		    CONTROL_CHANNEL, val);
 		break;
 	default:
 		err = -EINVAL;
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index b452dea..c75af76 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -122,8 +122,11 @@ da_deactivate(struct FsmInst *fi, int event, void *arg)
 	}
 	read_unlock_irqrestore(&mgr->lock, flags);
 	/* All TEI are inactiv */
-	mISDN_FsmAddTimer(&mgr->datimer, DATIMER_VAL, EV_DATIMER, NULL, 1);
-	mISDN_FsmChangeState(fi, ST_L1_DEACT_PENDING);
+	if (!test_bit(OPTION_L1_HOLD, &mgr->options)) {
+		mISDN_FsmAddTimer(&mgr->datimer, DATIMER_VAL, EV_DATIMER,
+			NULL, 1);
+		mISDN_FsmChangeState(fi, ST_L1_DEACT_PENDING);
+	}
 }
 
 static void
@@ -132,9 +135,11 @@ da_ui(struct FsmInst *fi, int event, void *arg)
 	struct manager	*mgr = fi->userdata;
 
 	/* restart da timer */
-	mISDN_FsmDelTimer(&mgr->datimer, 2);
-	mISDN_FsmAddTimer(&mgr->datimer, DATIMER_VAL, EV_DATIMER, NULL, 2);
-
+	if (!test_bit(OPTION_L1_HOLD, &mgr->options)) {
+		mISDN_FsmDelTimer(&mgr->datimer, 2);
+		mISDN_FsmAddTimer(&mgr->datimer, DATIMER_VAL, EV_DATIMER,
+			NULL, 2);
+	}
 }
 
 static void
@@ -1103,6 +1108,7 @@ free_teimanager(struct manager *mgr)
 {
 	struct layer2	*l2, *nl2;
 
+	test_and_clear_bit(OPTION_L1_HOLD, &mgr->options);
 	if (test_bit(MGR_OPT_NETWORK, &mgr->options)) {
 		/* not locked lock is taken in release tei */
 		mgr->up = NULL;
@@ -1133,13 +1139,26 @@ static int
 ctrl_teimanager(struct manager *mgr, void *arg)
 {
 	/* currently we only have one option */
-	int	clean = *((int *)arg);
-
-	if (clean)
-		test_and_set_bit(OPTION_L2_CLEANUP, &mgr->options);
-	else
-		test_and_clear_bit(OPTION_L2_CLEANUP, &mgr->options);
-	return 0;
+	int	*val = (int *)arg;
+	int	ret = 0;
+
+	switch (val[0]) {
+	case IMCLEAR_L2:
+		if (val[1])
+			test_and_set_bit(OPTION_L2_CLEANUP, &mgr->options);
+		else
+			test_and_clear_bit(OPTION_L2_CLEANUP, &mgr->options);
+		break;
+	case IMHOLD_L1:
+		if (val[1])
+			test_and_set_bit(OPTION_L1_HOLD, &mgr->options);
+		else
+			test_and_clear_bit(OPTION_L1_HOLD, &mgr->options);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+	return ret;
 }
 
 /* This function does create a L2 for fixed TEI in NT Mode */
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index cf97459..0b28fd1 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -229,6 +229,7 @@
 #define OPTION_L2_PTP		2
 #define OPTION_L2_FIXEDTEI	3
 #define OPTION_L2_CLEANUP	4
+#define OPTION_L1_HOLD		5
 
 /* should be in sync with linux/kobject.h:KOBJ_NAME_LEN */
 #define MISDN_MAX_IDLEN		20
@@ -317,6 +318,7 @@ struct ph_info {
 #define IMCTRLREQ	_IOR('I', 69, int)
 #define IMCLEAR_L2	_IOR('I', 70, int)
 #define IMSETDEVNAME	_IOR('I', 71, struct mISDN_devrename)
+#define IMHOLD_L1	_IOR('I', 72, int)
 
 static inline int
 test_channelmap(u_int nr, u_char *map)
-- 
1.6.0.2
