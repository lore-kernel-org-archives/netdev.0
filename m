From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 3/9] s390/qeth: add VNICC get/set timeout support
Date: Mon, 18 Sep 2017 21:18:16 +0200
Message-ID: <20170918191822.65142-4-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40030 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750897AbdIRTUE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:20:04 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJJx12091078
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:03 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2ea07ay0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:00 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:24 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

HiperSockets allow configuring so called VNIC Characteristics (VNICC)
that influence how the underlying hardware handles packets. For VNICCs,
additional commands for getting and setting timeouts are available.
Currently, the learning VNICC uses these commands.

* Learning VNICC: If learning is enabled on a qeth device, the device
  learns the source MAC addresses of outgoing packets and incoming
  packets to those learned MAC addresses are received.

For learning, the timeout specifies the idle period in seconds, after
which the underlying hardware removes a learned MAC address again.

This patch adds support for the IPA commands that are required to get
and set the current timeout values for the learning VNIC characteristic.
Also, it introduces the sysfs interface that allows users to configure
the timeout.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h     |   3 +
 drivers/s390/net/qeth_core_mpc.h |  11 ++++
 drivers/s390/net/qeth_l2.h       |   2 +
 drivers/s390/net/qeth_l2_main.c  | 135 +++++++++++++++++++++++++++++++++++++--
 drivers/s390/net/qeth_l2_sys.c   |  44 +++++++++++++
 5 files changed, 190 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 2236c0c9744a..e3d3609cd9e7 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -188,6 +188,9 @@ struct qeth_vnicc_info {
 	u32 cur_chars;
 	/* supported commands: bitmasks which VNICCs support respective cmd */
 	u32 set_char_sup;
+	u32 getset_timeout_sup;
+	/* timeout value for the learning characteristic */
+	u32 learning_timeout;
 	/* characteristics wanted/configured by user */
 	u32 wanted_chars;
 	/* has user explicitly enabled rx_bcast while online? */
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 7f67a81a2ae6..2f1f0da3d089 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -562,6 +562,8 @@ struct qeth_ipacmd_diagass {
 #define IPA_VNICC_QUERY_CMDS		0x00000001L
 #define IPA_VNICC_ENABLE		0x00000002L
 #define IPA_VNICC_DISABLE		0x00000004L
+#define IPA_VNICC_SET_TIMEOUT		0x00000008L
+#define IPA_VNICC_GET_TIMEOUT		0x00000010L
 
 /* VNICC flags */
 #define QETH_VNICC_FLOODING		0x80000000
@@ -575,6 +577,8 @@ struct qeth_ipacmd_diagass {
 /* VNICC default values */
 #define QETH_VNICC_ALL			0xff000000
 #define QETH_VNICC_DEFAULT		QETH_VNICC_RX_BCAST
+/* default VNICC timeout in seconds */
+#define QETH_VNICC_DEFAULT_TIMEOUT	600
 
 /* VNICC header */
 struct qeth_ipacmd_vnicc_hdr {
@@ -600,6 +604,12 @@ struct qeth_vnicc_set_char {
 	u32 vnic_char;
 };
 
+/* get/set timeout for VNIC characteristic */
+struct qeth_vnicc_getset_timeout {
+	u32 vnic_char;
+	u32 timeout;
+};
+
 /* complete VNICC IPA command message */
 struct qeth_ipacmd_vnicc {
 	struct qeth_ipacmd_vnicc_hdr hdr;
@@ -607,6 +617,7 @@ struct qeth_ipacmd_vnicc {
 	union {
 		struct qeth_vnicc_query_cmds query_cmds;
 		struct qeth_vnicc_set_char set_char;
+		struct qeth_vnicc_getset_timeout getset_timeout;
 	};
 };
 
diff --git a/drivers/s390/net/qeth_l2.h b/drivers/s390/net/qeth_l2.h
index 0619018c76f9..241df6b98ab4 100644
--- a/drivers/s390/net/qeth_l2.h
+++ b/drivers/s390/net/qeth_l2.h
@@ -16,6 +16,8 @@ void qeth_l2_setup_bridgeport_attrs(struct qeth_card *card);
 
 int qeth_l2_vnicc_set_state(struct qeth_card *card, u32 vnicc, bool state);
 int qeth_l2_vnicc_get_state(struct qeth_card *card, u32 vnicc, bool *state);
+int qeth_l2_vnicc_set_timeout(struct qeth_card *card, u32 timeout);
+int qeth_l2_vnicc_get_timeout(struct qeth_card *card, u32 *timeout);
 bool qeth_l2_vnicc_is_in_use(struct qeth_card *card);
 
 struct qeth_mac {
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 36a7fd7255e3..25a0f381bcd5 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -35,6 +35,8 @@ static void qeth_bridge_host_event(struct qeth_card *card,
 					struct qeth_ipa_cmd *cmd);
 static void qeth_l2_vnicc_set_defaults(struct qeth_card *card);
 static void qeth_l2_vnicc_init(struct qeth_card *card);
+static bool qeth_l2_vnicc_recover_timeout(struct qeth_card *card, u32 vnicc,
+					  u32 *timeout);
 
 static int qeth_l2_verify_dev(struct net_device *dev)
 {
@@ -2096,9 +2098,13 @@ struct _qeth_l2_vnicc_request_cbctl {
 	u32 sub_cmd;
 	struct {
 		u32 vnic_char;
+		u32 timeout;
 	} param;
 	struct {
-		u32 *sup_cmds;
+		union{
+			u32 *sup_cmds;
+			u32 *timeout;
+		};
 	} result;
 };
 
@@ -2122,6 +2128,9 @@ static int qeth_l2_vnicc_request_cb(struct qeth_card *card,
 	if (cbctl->sub_cmd == IPA_VNICC_QUERY_CMDS)
 		*cbctl->result.sup_cmds = rep->query_cmds.sup_cmds;
 
+	if (cbctl->sub_cmd == IPA_VNICC_GET_TIMEOUT)
+		*cbctl->result.timeout = rep->getset_timeout.timeout;
+
 	return 0;
 }
 
@@ -2162,6 +2171,13 @@ static int qeth_l2_vnicc_request(struct qeth_card *card,
 		req->sub_hdr.data_length += sizeof(req->set_char);
 		req->set_char.vnic_char = cbctl->param.vnic_char;
 		break;
+	case IPA_VNICC_SET_TIMEOUT:
+		req->getset_timeout.timeout = cbctl->param.timeout;
+		/* fallthrough */
+	case IPA_VNICC_GET_TIMEOUT:
+		req->sub_hdr.data_length += sizeof(req->getset_timeout);
+		req->getset_timeout.vnic_char = cbctl->param.vnic_char;
+		break;
 	default:
 		qeth_release_buffer(iob->channel, iob);
 		return -EOPNOTSUPP;
@@ -2215,6 +2231,24 @@ static int qeth_l2_vnicc_set_char(struct qeth_card *card, u32 vnic_char,
 	return qeth_l2_vnicc_request(card, &cbctl);
 }
 
+/* VNICC get/set timeout for characteristic request */
+static int qeth_l2_vnicc_getset_timeout(struct qeth_card *card, u32 vnicc,
+					u32 cmd, u32 *timeout)
+{
+	struct _qeth_l2_vnicc_request_cbctl cbctl;
+
+	/* prepare callback control */
+	cbctl.sub_cmd = cmd;
+	cbctl.param.vnic_char = vnicc;
+	if (cmd == IPA_VNICC_SET_TIMEOUT)
+		cbctl.param.timeout = *timeout;
+	if (cmd == IPA_VNICC_GET_TIMEOUT)
+		cbctl.result.timeout = timeout;
+
+	QETH_CARD_TEXT(card, 2, "vniccgst");
+	return qeth_l2_vnicc_request(card, &cbctl);
+}
+
 /* set current VNICC flag state; called from sysfs store function */
 int qeth_l2_vnicc_set_state(struct qeth_card *card, u32 vnicc, bool state)
 {
@@ -2258,8 +2292,14 @@ int qeth_l2_vnicc_set_state(struct qeth_card *card, u32 vnicc, bool state)
 	if (rc)
 		card->options.vnicc.wanted_chars =
 			card->options.vnicc.cur_chars;
-	else if (state && vnicc == QETH_VNICC_RX_BCAST)
-		card->options.vnicc.rx_bcast_enabled = true;
+	else {
+		/* successful online VNICC change; handle special cases */
+		if (state && vnicc == QETH_VNICC_RX_BCAST)
+			card->options.vnicc.rx_bcast_enabled = true;
+		if (!state && vnicc == QETH_VNICC_LEARNING)
+			qeth_l2_vnicc_recover_timeout(card, vnicc,
+					&card->options.vnicc.learning_timeout);
+	}
 
 	return rc;
 }
@@ -2287,6 +2327,70 @@ int qeth_l2_vnicc_get_state(struct qeth_card *card, u32 vnicc, bool *state)
 	return rc;
 }
 
+/* set VNICC timeout; called from sysfs store function. Currently, only learning
+ * supports timeout
+ */
+int qeth_l2_vnicc_set_timeout(struct qeth_card *card, u32 timeout)
+{
+	int rc = 0;
+
+	QETH_CARD_TEXT(card, 2, "vniccsto");
+
+	/* do not change anything if BridgePort is enabled */
+	if (qeth_bridgeport_is_in_use(card))
+		return -EBUSY;
+
+	/* check if characteristic and set_timeout are supported */
+	if (!(card->options.vnicc.sup_chars & QETH_VNICC_LEARNING) ||
+	    !(card->options.vnicc.getset_timeout_sup & QETH_VNICC_LEARNING))
+		return -EOPNOTSUPP;
+
+	/* do we need to do anything? */
+	if (card->options.vnicc.learning_timeout == timeout)
+		return rc;
+
+	/* if card is not ready, simply store the value internally and return */
+	if (!qeth_card_hw_is_reachable(card)) {
+		card->options.vnicc.learning_timeout = timeout;
+		return rc;
+	}
+
+	/* send timeout value to card; if successful, store value internally */
+	rc = qeth_l2_vnicc_getset_timeout(card, QETH_VNICC_LEARNING,
+					  IPA_VNICC_SET_TIMEOUT, &timeout);
+	if (!rc)
+		card->options.vnicc.learning_timeout = timeout;
+
+	return rc;
+}
+
+/* get current VNICC timeout; called from sysfs show function. Currently, only
+ * learning supports timeout
+ */
+int qeth_l2_vnicc_get_timeout(struct qeth_card *card, u32 *timeout)
+{
+	int rc = 0;
+
+	QETH_CARD_TEXT(card, 2, "vniccgto");
+
+	/* do not get anything if BridgePort is enabled */
+	if (qeth_bridgeport_is_in_use(card))
+		return -EBUSY;
+
+	/* check if characteristic and get_timeout are supported */
+	if (!(card->options.vnicc.sup_chars & QETH_VNICC_LEARNING) ||
+	    !(card->options.vnicc.getset_timeout_sup & QETH_VNICC_LEARNING))
+		return -EOPNOTSUPP;
+	/* if card is ready, get timeout. Otherwise, just return stored value */
+	*timeout = card->options.vnicc.learning_timeout;
+	if (qeth_card_hw_is_reachable(card))
+		rc = qeth_l2_vnicc_getset_timeout(card, QETH_VNICC_LEARNING,
+						  IPA_VNICC_GET_TIMEOUT,
+						  timeout);
+
+	return rc;
+}
+
 /* check if VNICC is currently enabled */
 bool qeth_l2_vnicc_is_in_use(struct qeth_card *card)
 {
@@ -2304,6 +2408,19 @@ bool qeth_l2_vnicc_is_in_use(struct qeth_card *card)
 	return true;
 }
 
+/* recover user timeout setting */
+static bool qeth_l2_vnicc_recover_timeout(struct qeth_card *card, u32 vnicc,
+					  u32 *timeout)
+{
+	if (card->options.vnicc.sup_chars & vnicc &&
+	    card->options.vnicc.getset_timeout_sup & vnicc &&
+	    !qeth_l2_vnicc_getset_timeout(card, vnicc, IPA_VNICC_SET_TIMEOUT,
+					  timeout))
+		return false;
+	*timeout = QETH_VNICC_DEFAULT_TIMEOUT;
+	return true;
+}
+
 /* recover user characteristic setting */
 static bool qeth_l2_vnicc_recover_char(struct qeth_card *card, u32 vnicc,
 				       bool enable)
@@ -2322,6 +2439,7 @@ static bool qeth_l2_vnicc_recover_char(struct qeth_card *card, u32 vnicc,
 /* (re-)initialize VNICC */
 static void qeth_l2_vnicc_init(struct qeth_card *card)
 {
+	u32 *timeout = &card->options.vnicc.learning_timeout;
 	unsigned int chars_len, i;
 	unsigned long chars_tmp;
 	u32 sup_cmds, vnicc;
@@ -2332,7 +2450,8 @@ static void qeth_l2_vnicc_init(struct qeth_card *card)
 	card->options.vnicc.rx_bcast_enabled = 0;
 	/* initial query and storage of VNIC characteristics */
 	if (qeth_l2_vnicc_query_chars(card)) {
-		if (card->options.vnicc.wanted_chars != QETH_VNICC_DEFAULT)
+		if (card->options.vnicc.wanted_chars != QETH_VNICC_DEFAULT ||
+		    *timeout != QETH_VNICC_DEFAULT_TIMEOUT)
 			dev_err(&card->gdev->dev, "Configuring the VNIC characteristics failed\n");
 		/* fail quietly if user didn't change the default config */
 		card->options.vnicc.sup_chars = 0;
@@ -2346,12 +2465,16 @@ static void qeth_l2_vnicc_init(struct qeth_card *card)
 	for_each_set_bit(i, &chars_tmp, chars_len) {
 		vnicc = BIT(i);
 		qeth_l2_vnicc_query_cmds(card, vnicc, &sup_cmds);
+		if (!(sup_cmds & IPA_VNICC_SET_TIMEOUT) ||
+		    !(sup_cmds & IPA_VNICC_GET_TIMEOUT))
+			card->options.vnicc.getset_timeout_sup &= ~vnicc;
 		if (!(sup_cmds & IPA_VNICC_ENABLE) ||
 		    !(sup_cmds & IPA_VNICC_DISABLE))
 			card->options.vnicc.set_char_sup &= ~vnicc;
 	}
 	/* enforce assumed default values and recover settings, if changed  */
-	error = false;
+	error = qeth_l2_vnicc_recover_timeout(card, QETH_VNICC_LEARNING,
+					      timeout);
 	chars_tmp = card->options.vnicc.wanted_chars ^ QETH_VNICC_DEFAULT;
 	chars_tmp |= QETH_VNICC_BRIDGE_INVISIBLE;
 	chars_len = sizeof(card->options.vnicc.wanted_chars) * BITS_PER_BYTE;
@@ -2370,8 +2493,10 @@ static void qeth_l2_vnicc_set_defaults(struct qeth_card *card)
 	/* characteristics values */
 	card->options.vnicc.sup_chars = QETH_VNICC_ALL;
 	card->options.vnicc.cur_chars = QETH_VNICC_DEFAULT;
+	card->options.vnicc.learning_timeout = QETH_VNICC_DEFAULT_TIMEOUT;
 	/* supported commands */
 	card->options.vnicc.set_char_sup = QETH_VNICC_ALL;
+	card->options.vnicc.getset_timeout_sup = QETH_VNICC_LEARNING;
 	/* settings wanted by users */
 	card->options.vnicc.wanted_chars = QETH_VNICC_DEFAULT;
 }
diff --git a/drivers/s390/net/qeth_l2_sys.c b/drivers/s390/net/qeth_l2_sys.c
index 01936f7dbe7e..4608daedb204 100644
--- a/drivers/s390/net/qeth_l2_sys.c
+++ b/drivers/s390/net/qeth_l2_sys.c
@@ -309,6 +309,47 @@ static u32 qeth_l2_vnicc_sysfs_attr_to_char(const char *attr_name)
 	return 0;
 }
 
+/* get current timeout setting */
+static ssize_t qeth_vnicc_timeout_show(struct device *dev,
+				       struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	u32 timeout;
+	int rc;
+
+	if (!card)
+		return -EINVAL;
+
+	rc = qeth_l2_vnicc_get_timeout(card, &timeout);
+	if (rc == -EBUSY)
+		return sprintf(buf, "n/a (BridgePort)\n");
+	if (rc == -EOPNOTSUPP)
+		return sprintf(buf, "n/a\n");
+	return rc ? rc : sprintf(buf, "%d\n", timeout);
+}
+
+/* change timeout setting */
+static ssize_t qeth_vnicc_timeout_store(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	u32 timeout;
+	int rc;
+
+	if (!card)
+		return -EINVAL;
+
+	rc = kstrtou32(buf, 10, &timeout);
+	if (rc)
+		return rc;
+
+	mutex_lock(&card->conf_mutex);
+	rc = qeth_l2_vnicc_set_timeout(card, timeout);
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
+}
+
 /* get current setting of characteristic */
 static ssize_t qeth_vnicc_char_show(struct device *dev,
 				    struct device_attribute *attr, char *buf)
@@ -359,6 +400,8 @@ static DEVICE_ATTR(flooding, 0644, qeth_vnicc_char_show, qeth_vnicc_char_store);
 static DEVICE_ATTR(mcast_flooding, 0644, qeth_vnicc_char_show,
 		   qeth_vnicc_char_store);
 static DEVICE_ATTR(learning, 0644, qeth_vnicc_char_show, qeth_vnicc_char_store);
+static DEVICE_ATTR(learning_timeout, 0644, qeth_vnicc_timeout_show,
+		   qeth_vnicc_timeout_store);
 static DEVICE_ATTR(takeover_setvmac, 0644, qeth_vnicc_char_show,
 		   qeth_vnicc_char_store);
 static DEVICE_ATTR(takeover_learning, 0644, qeth_vnicc_char_show,
@@ -371,6 +414,7 @@ static struct attribute *qeth_l2_vnicc_attrs[] = {
 	&dev_attr_flooding.attr,
 	&dev_attr_mcast_flooding.attr,
 	&dev_attr_learning.attr,
+	&dev_attr_learning_timeout.attr,
 	&dev_attr_takeover_setvmac.attr,
 	&dev_attr_takeover_learning.attr,
 	&dev_attr_bridge_invisible.attr,
-- 
2.13.5
