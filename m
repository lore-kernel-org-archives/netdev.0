From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 13/13] s390/qeth: remove OSN-devices
Date: Wed, 11 Jan 2017 12:56:00 +0100
Message-ID: <20170111115600.4524-14-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CHPID type "OSN" is a device type which had been used by IBM product
"Communication Controller for Linux". This product has reached end of
service in March 2016. Thus OSN support can be removed from the qeth
driver.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  28 ----
 drivers/s390/net/qeth_core_main.c |  53 ++------
 drivers/s390/net/qeth_core_mpc.c  |   3 -
 drivers/s390/net/qeth_core_mpc.h  |  10 +-
 drivers/s390/net/qeth_core_sys.c  |  17 ---
 drivers/s390/net/qeth_l2_main.c   | 267 +++++++-------------------------------
 6 files changed, 56 insertions(+), 322 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index e7addea..a32c2aa 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -310,22 +310,10 @@ struct qeth_hdr_layer2 {
 	__u8 reserved2[16];
 } __attribute__ ((packed));
 
-struct qeth_hdr_osn {
-	__u8 id;
-	__u8 reserved;
-	__u16 seq_no;
-	__u16 reserved2;
-	__u16 control_flags;
-	__u16 pdu_length;
-	__u8 reserved3[18];
-	__u32 ccid;
-} __attribute__ ((packed));
-
 struct qeth_hdr {
 	union {
 		struct qeth_hdr_layer2 l2;
 		struct qeth_hdr_layer3 l3;
-		struct qeth_hdr_osn    osn;
 	} hdr;
 } __attribute__ ((packed));
 
@@ -372,7 +360,6 @@ enum qeth_header_ids {
 	QETH_HEADER_TYPE_LAYER3 = 0x01,
 	QETH_HEADER_TYPE_LAYER2 = 0x02,
 	QETH_HEADER_TYPE_TSO	= 0x03,
-	QETH_HEADER_TYPE_OSN    = 0x04,
 };
 /* flags for qeth_hdr.ext_flags */
 #define QETH_HDR_EXT_VLAN_FRAME       0x01
@@ -627,7 +614,6 @@ struct qeth_seqno {
 	__u32 pdu_hdr;
 	__u32 pdu_hdr_ack;
 	__u16 ipa;
-	__u32 pkt_seqno;
 };
 
 struct qeth_reply {
@@ -703,11 +689,6 @@ enum qeth_threads {
 	QETH_RECOVER_THREAD = 1,
 };
 
-struct qeth_osn_info {
-	int (*assist_cb)(struct net_device *dev, void *data);
-	int (*data_cb)(struct sk_buff *skb);
-};
-
 enum qeth_discipline_id {
 	QETH_DISCIPLINE_LAYER3 = 0,
 	QETH_DISCIPLINE_LAYER2 = 1,
@@ -803,7 +784,6 @@ struct qeth_card {
 	struct qeth_qdio_info qdio;
 	struct qeth_perf_stats perf_stats;
 	int read_or_write_problem;
-	struct qeth_osn_info osn_info;
 	struct qeth_discipline *discipline;
 	atomic_t force_alloc_skb;
 	struct service_level qeth_service_level;
@@ -888,7 +868,6 @@ static inline int qeth_is_diagass_supported(struct qeth_card *card,
 extern struct qeth_discipline qeth_l2_discipline;
 extern struct qeth_discipline qeth_l3_discipline;
 extern const struct attribute_group *qeth_generic_attr_groups[];
-extern const struct attribute_group *qeth_osn_attr_groups[];
 extern struct workqueue_struct *qeth_wq;
 
 int qeth_card_hw_is_reachable(struct qeth_card *);
@@ -997,11 +976,4 @@ int qeth_set_features(struct net_device *, netdev_features_t);
 int qeth_recover_features(struct net_device *);
 netdev_features_t qeth_fix_features(struct net_device *, netdev_features_t);
 
-/* exports for OSN */
-int qeth_osn_assist(struct net_device *, void *, int);
-int qeth_osn_register(unsigned char *read_dev_no, struct net_device **,
-		int (*assist_cb)(struct net_device *, void *),
-		int (*data_cb)(struct sk_buff *));
-void qeth_osn_deregister(struct net_device *);
-
 #endif /* __QETH_CORE_H__ */
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 315d8a2..048a19a 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -120,8 +120,6 @@ static inline const char *qeth_get_cardname(struct qeth_card *card)
 			return " OSD Express";
 		case QETH_CARD_TYPE_IQD:
 			return " HiperSockets";
-		case QETH_CARD_TYPE_OSN:
-			return " OSN QDIO";
 		case QETH_CARD_TYPE_OSM:
 			return " OSM QDIO";
 		case QETH_CARD_TYPE_OSX:
@@ -174,8 +172,6 @@ const char *qeth_get_cardname_short(struct qeth_card *card)
 			}
 		case QETH_CARD_TYPE_IQD:
 			return "HiperSockets";
-		case QETH_CARD_TYPE_OSN:
-			return "OSN";
 		case QETH_CARD_TYPE_OSM:
 			return "OSM_1000";
 		case QETH_CARD_TYPE_OSX:
@@ -602,10 +598,7 @@ static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
 	if (IS_IPA(iob->data)) {
 		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
 		if (IS_IPA_REPLY(cmd)) {
-			if (cmd->hdr.command != IPA_CMD_SETCCID &&
-			    cmd->hdr.command != IPA_CMD_DELCCID &&
-			    cmd->hdr.command != IPA_CMD_MODCCID &&
-			    cmd->hdr.command != IPA_CMD_SET_DIAG_ASS)
+			if (cmd->hdr.command != IPA_CMD_SET_DIAG_ASS)
 				qeth_issue_ipa_msg(cmd,
 						cmd->hdr.return_code, card);
 			return cmd;
@@ -653,8 +646,6 @@ static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
 					return cmd;
 				else
 					return NULL;
-			case IPA_CMD_MODCCID:
-				return cmd;
 			case IPA_CMD_REGISTER_LOCAL_ADDR:
 				QETH_CARD_TEXT(card, 3, "irla");
 				break;
@@ -835,14 +826,6 @@ static void qeth_send_control_data_cb(struct qeth_channel *channel,
 	cmd = qeth_check_ipa_data(card, iob);
 	if ((cmd == NULL) && (card->state != CARD_STATE_DOWN))
 		goto out;
-	/*in case of OSN : check if cmd is set */
-	if (card->info.type == QETH_CARD_TYPE_OSN &&
-	    cmd &&
-	    cmd->hdr.command != IPA_CMD_STARTLAN &&
-	    card->osn_info.assist_cb != NULL) {
-		card->osn_info.assist_cb(card->dev, cmd);
-		goto out;
-	}
 
 	spin_lock_irqsave(&card->lock, flags);
 	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
@@ -1529,6 +1512,11 @@ static int qeth_determine_card_type(struct qeth_card *card)
 		    (CARD_RDEV(card)->id.dev_model ==
 				known_devices[i][QETH_DEV_MODEL_IND])) {
 			card->info.type = known_devices[i][QETH_DEV_MODEL_IND];
+			if (card->info.type == QETH_CARD_TYPE_OSN) {
+				dev_err(&card->gdev->dev,
+				       "OSN devices are not supported\n");
+				goto out;
+			}
 			card->qdio.no_out_queues =
 				known_devices[i][QETH_QUEUE_NO_IND];
 			card->qdio.no_in_queues = 1;
@@ -1539,6 +1527,7 @@ static int qeth_determine_card_type(struct qeth_card *card)
 		}
 		i++;
 	}
+out:
 	card->info.type = QETH_CARD_TYPE_UNKNOWN;
 	dev_err(&card->gdev->dev, "The adapter hardware is of an "
 		"unknown type\n");
@@ -1756,7 +1745,6 @@ static void qeth_init_func_level(struct qeth_card *card)
 		card->info.func_level =	QETH_IDX_FUNC_LEVEL_IQD;
 		break;
 	case QETH_CARD_TYPE_OSD:
-	case QETH_CARD_TYPE_OSN:
 		card->info.func_level = QETH_IDX_FUNC_LEVEL_OSD;
 		break;
 	default:
@@ -2255,7 +2243,6 @@ static inline int qeth_mtu_is_valid(struct qeth_card *card, int mtu)
 	case QETH_CARD_TYPE_IQD:
 		return ((mtu >= 576) &&
 			(mtu <= card->info.max_mtu));
-	case QETH_CARD_TYPE_OSN:
 	case QETH_CARD_TYPE_UNKNOWN:
 	default:
 		return 1;
@@ -2331,10 +2318,7 @@ static int qeth_ulp_enable(struct qeth_card *card)
 	*(QETH_ULP_ENABLE_LINKNUM(iob->data)) =
 		(__u8) card->info.portno;
 	if (card->options.layer2)
-		if (card->info.type == QETH_CARD_TYPE_OSN)
-			prot_type = QETH_PROT_OSN2;
-		else
-			prot_type = QETH_PROT_LAYER2;
+		prot_type = QETH_PROT_LAYER2;
 	else
 		prot_type = QETH_PROT_TCPIP;
 
@@ -2927,10 +2911,7 @@ int qeth_send_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
 	QETH_CARD_TEXT(card, 4, "sendipa");
 
 	if (card->options.layer2)
-		if (card->info.type == QETH_CARD_TYPE_OSN)
-			prot_type = QETH_PROT_OSN2;
-		else
-			prot_type = QETH_PROT_LAYER2;
+		prot_type = QETH_PROT_LAYER2;
 	else
 		prot_type = QETH_PROT_TCPIP;
 	qeth_prepare_ipa_cmd(card, iob, prot_type);
@@ -4427,7 +4408,6 @@ int qeth_mdio_read(struct net_device *dev, int phy_id, int regnum)
 	case MII_BMCR: /* Basic mode control register */
 		rc = BMCR_FULLDPLX;
 		if ((card->info.link_type != QETH_LINK_TYPE_GBIT_ETH) &&
-		    (card->info.link_type != QETH_LINK_TYPE_OSN) &&
 		    (card->info.link_type != QETH_LINK_TYPE_10GBIT_ETH))
 			rc |= BMCR_SPEED100;
 		break;
@@ -5218,10 +5198,6 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 		skb_len = (*hdr)->hdr.l3.length;
 		headroom = ETH_HLEN;
 		break;
-	case QETH_HEADER_TYPE_OSN:
-		skb_len = (*hdr)->hdr.osn.pdu_length;
-		headroom = sizeof(struct qeth_hdr);
-		break;
 	default:
 		break;
 	}
@@ -5230,7 +5206,6 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 		return NULL;
 
 	if (((skb_len >= card->options.rx_sg_cb) &&
-	     (!(card->info.type == QETH_CARD_TYPE_OSN)) &&
 	     (!atomic_read(&card->force_alloc_skb))) ||
 	    (card->options.cq == QETH_CQ_ENABLED)) {
 		use_rx_sg = 1;
@@ -5463,10 +5438,6 @@ static const struct device_type qeth_generic_devtype = {
 	.name = "qeth_generic",
 	.groups = qeth_generic_attr_groups,
 };
-static const struct device_type qeth_osn_devtype = {
-	.name = "qeth_osn",
-	.groups = qeth_osn_attr_groups,
-};
 
 #define DBF_NAME_LEN	20
 
@@ -5588,13 +5559,9 @@ static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 		goto err_card;
 	}
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		gdev->dev.type = &qeth_osn_devtype;
-	else
-		gdev->dev.type = &qeth_generic_devtype;
+	gdev->dev.type = &qeth_generic_devtype;
 
 	switch (card->info.type) {
-	case QETH_CARD_TYPE_OSN:
 	case QETH_CARD_TYPE_OSM:
 		rc = qeth_core_load_discipline(card, QETH_DISCIPLINE_LAYER2);
 		if (rc)
diff --git a/drivers/s390/net/qeth_core_mpc.c b/drivers/s390/net/qeth_core_mpc.c
index beb4bdc..f10e5c2 100644
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -238,9 +238,6 @@ static struct ipa_cmd_names qeth_ipa_cmd_names[] = {
 	{IPA_CMD_SETVLAN,	"setvlan"},
 	{IPA_CMD_DELVLAN,	"delvlan"},
 	{IPA_CMD_SETBRIDGEPORT_OSA,	"set_bridge_port(osa)"},
-	{IPA_CMD_SETCCID,	"setccid"},
-	{IPA_CMD_DELCCID,	"delccid"},
-	{IPA_CMD_MODCCID,	"modccid"},
 	{IPA_CMD_SETIP,		"setip"},
 	{IPA_CMD_QIPASSIST,	"qipassist"},
 	{IPA_CMD_SETASSPARMS,	"setassparms"},
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index bc69d0a..b1b43d4 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -40,8 +40,6 @@ extern unsigned char IPA_PDU_HEADER[];
 /*****************************************************************************/
 #define IPA_CMD_INITIATOR_HOST  0x00
 #define IPA_CMD_INITIATOR_OSA   0x01
-#define IPA_CMD_INITIATOR_HOST_REPLY  0x80
-#define IPA_CMD_INITIATOR_OSA_REPLY   0x81
 #define IPA_CMD_PRIM_VERSION_NO 0x01
 
 enum qeth_card_types {
@@ -59,7 +57,6 @@ enum qeth_link_types {
 	QETH_LINK_TYPE_FAST_ETH     = 0x01,
 	QETH_LINK_TYPE_HSTR         = 0x02,
 	QETH_LINK_TYPE_GBIT_ETH     = 0x03,
-	QETH_LINK_TYPE_OSN          = 0x04,
 	QETH_LINK_TYPE_10GBIT_ETH   = 0x10,
 	QETH_LINK_TYPE_LANE_ETH100  = 0x81,
 	QETH_LINK_TYPE_LANE_TR      = 0x82,
@@ -93,9 +90,6 @@ enum qeth_ipa_cmds {
 	IPA_CMD_SETVLAN			= 0x25,
 	IPA_CMD_DELVLAN			= 0x26,
 	IPA_CMD_SETBRIDGEPORT_OSA	= 0x2b,
-	IPA_CMD_SETCCID			= 0x41,
-	IPA_CMD_DELCCID			= 0x42,
-	IPA_CMD_MODCCID			= 0x43,
 	IPA_CMD_SETIP			= 0xb1,
 	IPA_CMD_QIPASSIST		= 0xb2,
 	IPA_CMD_SETASSPARMS		= 0xb3,
@@ -717,8 +711,7 @@ extern char *qeth_get_ipa_cmd_name(enum qeth_ipa_cmds cmd);
 #define QETH_ARP_DATA_SIZE 3968
 #define QETH_ARP_CMD_LEN (QETH_ARP_DATA_SIZE + 8)
 /* Helper functions */
-#define IS_IPA_REPLY(cmd) ((cmd->hdr.initiator == IPA_CMD_INITIATOR_HOST) || \
-			   (cmd->hdr.initiator == IPA_CMD_INITIATOR_OSA_REPLY))
+#define IS_IPA_REPLY(cmd) (cmd->hdr.initiator == IPA_CMD_INITIATOR_HOST)
 
 /*****************************************************************************/
 /* END OF   IP Assist related definitions                                    */
@@ -764,7 +757,6 @@ extern unsigned char ULP_ENABLE[];
 /* Layer 2 definitions */
 #define QETH_PROT_LAYER2 0x08
 #define QETH_PROT_TCPIP  0x03
-#define QETH_PROT_OSN2   0x0a
 #define QETH_ULP_ENABLE_PROT_TYPE(buffer) (buffer + 0x50)
 #define QETH_IPA_CMD_PROT_TYPE(buffer) (buffer + 0x19)
 
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 75b29fd2..aafd891 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -735,20 +735,3 @@ const struct attribute_group *qeth_generic_attr_groups[] = {
 	&qeth_device_blkt_group,
 	NULL,
 };
-
-static struct attribute *qeth_osn_device_attrs[] = {
-	&dev_attr_state.attr,
-	&dev_attr_chpid.attr,
-	&dev_attr_if_name.attr,
-	&dev_attr_card_type.attr,
-	&dev_attr_buffer_count.attr,
-	&dev_attr_recover.attr,
-	NULL,
-};
-static struct attribute_group qeth_osn_device_attr_group = {
-	.attrs = qeth_osn_device_attrs,
-};
-const struct attribute_group *qeth_osn_attr_groups[] = {
-	&qeth_osn_device_attr_group,
-	NULL,
-};
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index bea4833..525febf 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -47,9 +47,6 @@ static int qeth_l2_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!qeth_card_hw_is_reachable(card))
 		return -ENODEV;
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return -EPERM;
-
 	switch (cmd) {
 	case SIOC_QETH_ADP_SET_SNMP_CONTROL:
 		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
@@ -103,28 +100,6 @@ static int qeth_l2_verify_dev(struct net_device *dev)
 	return rc;
 }
 
-static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
-{
-	struct qeth_card *card;
-	struct net_device *ndev;
-	__u16 temp_dev_no;
-	unsigned long flags;
-	struct ccw_dev_id read_devid;
-
-	ndev = NULL;
-	memcpy(&temp_dev_no, read_dev_no, 2);
-	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
-	list_for_each_entry(card, &qeth_core_card_list.list, list) {
-		ccw_device_get_id(CARD_RDEV(card), &read_devid);
-		if (read_devid.devno == temp_dev_no) {
-			ndev = card->dev;
-			break;
-		}
-	}
-	read_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
-	return ndev;
-}
-
 static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 {
 	int rc;
@@ -290,8 +265,6 @@ static inline u32 qeth_l2_mac_hash(const u8 *addr)
 static inline int qeth_l2_get_cast_type(struct qeth_card *card,
 			struct sk_buff *skb)
 {
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return RTN_UNSPEC;
 	if (is_broadcast_ether_addr(skb->data))
 		return RTN_BROADCAST;
 	if (is_multicast_ether_addr(skb->data))
@@ -463,8 +436,7 @@ static void qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 	if (card->read.state == CH_STATE_UP &&
 	    card->write.state == CH_STATE_UP &&
 	    (card->state == CARD_STATE_UP)) {
-		if (recovery_mode &&
-		    card->info.type != QETH_CARD_TYPE_OSN) {
+		if (recovery_mode) {
 			qeth_l2_stop(card->dev);
 		} else {
 			rtnl_lock();
@@ -510,40 +482,25 @@ static int qeth_l2_process_inbound_buffer(struct qeth_card *card,
 			break;
 		}
 		skb->dev = card->dev;
-		switch (hdr->hdr.l2.id) {
-		case QETH_HEADER_TYPE_LAYER2:
-			skb->pkt_type = PACKET_HOST;
-			skb->protocol = eth_type_trans(skb, skb->dev);
-			if ((card->dev->features & NETIF_F_RXCSUM)
-			   && ((hdr->hdr.l2.flags[1] &
-				(QETH_HDR_EXT_CSUM_HDR_REQ |
-				   QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
-				(QETH_HDR_EXT_CSUM_HDR_REQ |
-				   QETH_HDR_EXT_CSUM_TRANSP_REQ)))
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			else
-				skb->ip_summed = CHECKSUM_NONE;
-			if (skb->protocol == htons(ETH_P_802_2))
-				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
-			len = skb->len;
-			napi_gro_receive(&card->napi, skb);
-			break;
-		case QETH_HEADER_TYPE_OSN:
-			if (card->info.type == QETH_CARD_TYPE_OSN) {
-				skb_push(skb, sizeof(struct qeth_hdr));
-				skb_copy_to_linear_data(skb, hdr,
-						sizeof(struct qeth_hdr));
-				len = skb->len;
-				card->osn_info.data_cb(skb);
-				break;
-			}
-			/* else unknown */
-		default:
+		if (hdr->hdr.l2.id != QETH_HEADER_TYPE_LAYER2) {
 			dev_kfree_skb_any(skb);
 			QETH_CARD_TEXT(card, 3, "inbunkno");
 			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
+		skb->pkt_type = PACKET_HOST;
+		skb->protocol = eth_type_trans(skb, skb->dev);
+		if ((card->dev->features & NETIF_F_RXCSUM)
+		   && ((hdr->hdr.l2.flags[1] &
+			(QETH_HDR_EXT_CSUM_HDR_REQ |
+			   QETH_HDR_EXT_CSUM_TRANSP_REQ)) ==
+			(QETH_HDR_EXT_CSUM_HDR_REQ |
+			   QETH_HDR_EXT_CSUM_TRANSP_REQ)))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+		len = skb->len;
+		napi_gro_receive(&card->napi, skb);
 		work_done++;
 		budget--;
 		card->stats.rx_packets++;
@@ -676,8 +633,7 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 		return -EOPNOTSUPP;
 	}
 
-	if (card->info.type == QETH_CARD_TYPE_OSN ||
-	    card->info.type == QETH_CARD_TYPE_OSM ||
+	if (card->info.type == QETH_CARD_TYPE_OSM ||
 	    card->info.type == QETH_CARD_TYPE_OSX) {
 		QETH_CARD_TEXT(card, 3, "setmcTYP");
 		return -EOPNOTSUPP;
@@ -767,9 +723,6 @@ static void qeth_l2_set_rx_mode(struct net_device *dev)
 	int i;
 	int rc;
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return;
-
 	QETH_CARD_TEXT(card, 3, "setmulti");
 	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
 	    (card->state != CARD_STATE_UP))
@@ -835,10 +788,6 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_drop;
 	}
 
-	if ((card->info.type == QETH_CARD_TYPE_OSN) &&
-	    (skb->protocol == htons(ETH_P_IPV6)))
-		goto tx_drop;
-
 	if (card->options.performance_stats) {
 		card->perf_stats.outbound_cnt++;
 		card->perf_stats.outbound_start_time = qeth_get_micros();
@@ -862,36 +811,30 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_drop;
 	}
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		hdr = (struct qeth_hdr *)skb->data;
-	else {
-		if (card->info.type == QETH_CARD_TYPE_IQD) {
-			new_skb = skb;
-			data_offset = ETH_HLEN;
-			hd_len = ETH_HLEN;
-			hdr = kmem_cache_alloc(qeth_core_header_cache,
-						GFP_ATOMIC);
-			if (!hdr)
-				goto tx_drop;
-			elements_needed++;
-			skb_reset_mac_header(new_skb);
-			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
-			hdr->hdr.l2.pkt_length = new_skb->len;
-			memcpy(((char *)hdr) + sizeof(struct qeth_hdr),
-				skb_mac_header(new_skb), ETH_HLEN);
-		} else {
-			/* create a clone with writeable headroom */
-			new_skb = skb_realloc_headroom(skb,
-						sizeof(struct qeth_hdr));
-			if (!new_skb)
-				goto tx_drop;
-			hdr = (struct qeth_hdr *)skb_push(new_skb,
-						sizeof(struct qeth_hdr));
-			skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
-			qeth_l2_fill_header(card, hdr, new_skb, cast_type);
-			if (new_skb->ip_summed == CHECKSUM_PARTIAL)
-				qeth_l2_hdr_csum(card, hdr, new_skb);
-		}
+	if (card->info.type == QETH_CARD_TYPE_IQD) {
+		new_skb = skb;
+		data_offset = ETH_HLEN;
+		hd_len = ETH_HLEN;
+		hdr = kmem_cache_alloc(qeth_core_header_cache, GFP_ATOMIC);
+		if (!hdr)
+			goto tx_drop;
+		elements_needed++;
+		skb_reset_mac_header(new_skb);
+		qeth_l2_fill_header(card, hdr, new_skb, cast_type);
+		hdr->hdr.l2.pkt_length = new_skb->len;
+		memcpy(((char *)hdr) + sizeof(struct qeth_hdr),
+		       skb_mac_header(new_skb), ETH_HLEN);
+	} else {
+		/* create a clone with writeable headroom */
+		new_skb = skb_realloc_headroom(skb, sizeof(struct qeth_hdr));
+		if (!new_skb)
+			goto tx_drop;
+		hdr = (struct qeth_hdr *)skb_push(new_skb,
+						  sizeof(struct qeth_hdr));
+		skb_set_mac_header(new_skb, sizeof(struct qeth_hdr));
+		qeth_l2_fill_header(card, hdr, new_skb, cast_type);
+		if (new_skb->ip_summed == CHECKSUM_PARTIAL)
+			qeth_l2_hdr_csum(card, hdr, new_skb);
 	}
 
 	elements = qeth_get_elements_no(card, new_skb, elements_needed);
@@ -963,8 +906,7 @@ static int __qeth_l2_open(struct net_device *dev)
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 
-	if ((card->info.type != QETH_CARD_TYPE_OSN) &&
-	     (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))) {
+	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED)) {
 		QETH_CARD_TEXT(card, 4, "nomacadr");
 		return -EPERM;
 	}
@@ -1045,13 +987,6 @@ static const struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_settings = qeth_core_ethtool_get_settings,
 };
 
-static const struct ethtool_ops qeth_l2_osn_ops = {
-	.get_strings = qeth_core_get_strings,
-	.get_ethtool_stats = qeth_core_get_ethtool_stats,
-	.get_sset_count = qeth_core_get_sset_count,
-	.get_drvinfo = qeth_core_get_drvinfo,
-};
-
 static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_open		= qeth_l2_open,
 	.ndo_stop		= qeth_l2_stop,
@@ -1076,11 +1011,6 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 		card->dev = alloc_netdev(0, "hsi%d", NET_NAME_UNKNOWN,
 					 ether_setup);
 		break;
-	case QETH_CARD_TYPE_OSN:
-		card->dev = alloc_netdev(0, "osn%d", NET_NAME_UNKNOWN,
-					 ether_setup);
-		card->dev->flags |= IFF_NOARP;
-		break;
 	default:
 		card->dev = alloc_etherdev(0);
 	}
@@ -1094,9 +1024,7 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	card->dev->min_mtu = 64;
 	card->dev->max_mtu = ETH_MAX_MTU;
 	card->dev->netdev_ops = &qeth_l2_netdev_ops;
-	card->dev->ethtool_ops =
-		(card->info.type != QETH_CARD_TYPE_OSN) ?
-		&qeth_l2_ethtool_ops : &qeth_l2_osn_ops;
+	card->dev->ethtool_ops = &qeth_l2_ethtool_ops;
 	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
 		card->dev->hw_features = NETIF_F_SG;
@@ -1158,8 +1086,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 		goto out_remove;
 	}
 
-	if (card->info.type != QETH_CARD_TYPE_OSN)
-		qeth_l2_send_setmac(card, &card->dev->dev_addr[0]);
+	qeth_l2_send_setmac(card, &card->dev->dev_addr[0]);
 
 	if (qeth_is_diagass_supported(card, QETH_DIAGS_CMD_TRAP)) {
 		if (card->info.hwtrap &&
@@ -1184,8 +1111,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 			goto out_remove;
 	}
 
-	if (card->info.type != QETH_CARD_TYPE_OSN &&
-	    card->info.type != QETH_CARD_TYPE_OSM)
+	if (card->info.type != QETH_CARD_TYPE_OSM)
 		qeth_l2_process_vlans(card);
 
 	netif_tx_disable(card->dev);
@@ -1204,8 +1130,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 
 	qeth_set_allowed_threads(card, 0xffffffff, 0);
 	if (recover_flag == CARD_STATE_RECOVER) {
-		if (recovery_mode &&
-		    card->info.type != QETH_CARD_TYPE_OSN) {
+		if (recovery_mode) {
 			__qeth_l2_open(card->dev);
 		} else {
 			rtnl_lock();
@@ -1421,108 +1346,6 @@ struct qeth_discipline qeth_l2_discipline = {
 };
 EXPORT_SYMBOL_GPL(qeth_l2_discipline);
 
-static int qeth_osn_send_control_data(struct qeth_card *card, int len,
-			   struct qeth_cmd_buffer *iob)
-{
-	unsigned long flags;
-	int rc = 0;
-
-	QETH_CARD_TEXT(card, 5, "osndctrd");
-
-	wait_event(card->wait_q,
-		   atomic_cmpxchg(&card->write.irq_pending, 0, 1) == 0);
-	qeth_prepare_control_data(card, len, iob);
-	QETH_CARD_TEXT(card, 6, "osnoirqp");
-	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
-	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
-			      (addr_t) iob, 0, 0);
-	spin_unlock_irqrestore(get_ccwdev_lock(card->write.ccwdev), flags);
-	if (rc) {
-		QETH_DBF_MESSAGE(2, "qeth_osn_send_control_data: "
-			   "ccw_device_start rc = %i\n", rc);
-		QETH_CARD_TEXT_(card, 2, " err%d", rc);
-		qeth_release_buffer(iob->channel, iob);
-		atomic_set(&card->write.irq_pending, 0);
-		wake_up(&card->wait_q);
-	}
-	return rc;
-}
-
-static int qeth_osn_send_ipa_cmd(struct qeth_card *card,
-			struct qeth_cmd_buffer *iob, int data_len)
-{
-	u16 s1, s2;
-
-	QETH_CARD_TEXT(card, 4, "osndipa");
-
-	qeth_prepare_ipa_cmd(card, iob, QETH_PROT_OSN2);
-	s1 = (u16)(IPA_PDU_HEADER_SIZE + data_len);
-	s2 = (u16)data_len;
-	memcpy(QETH_IPA_PDU_LEN_TOTAL(iob->data), &s1, 2);
-	memcpy(QETH_IPA_PDU_LEN_PDU1(iob->data), &s2, 2);
-	memcpy(QETH_IPA_PDU_LEN_PDU2(iob->data), &s2, 2);
-	memcpy(QETH_IPA_PDU_LEN_PDU3(iob->data), &s2, 2);
-	return qeth_osn_send_control_data(card, s1, iob);
-}
-
-int qeth_osn_assist(struct net_device *dev, void *data, int data_len)
-{
-	struct qeth_cmd_buffer *iob;
-	struct qeth_card *card;
-	int rc;
-
-	if (!dev)
-		return -ENODEV;
-	card = dev->ml_priv;
-	if (!card)
-		return -ENODEV;
-	QETH_CARD_TEXT(card, 2, "osnsdmc");
-	if (!qeth_card_hw_is_reachable(card))
-		return -ENODEV;
-	iob = qeth_wait_for_buffer(&card->write);
-	memcpy(iob->data+IPA_PDU_HEADER_SIZE, data, data_len);
-	rc = qeth_osn_send_ipa_cmd(card, iob, data_len);
-	return rc;
-}
-EXPORT_SYMBOL(qeth_osn_assist);
-
-int qeth_osn_register(unsigned char *read_dev_no, struct net_device **dev,
-		  int (*assist_cb)(struct net_device *, void *),
-		  int (*data_cb)(struct sk_buff *))
-{
-	struct qeth_card *card;
-
-	*dev = qeth_l2_netdev_by_devno(read_dev_no);
-	if (*dev == NULL)
-		return -ENODEV;
-	card = (*dev)->ml_priv;
-	if (!card)
-		return -ENODEV;
-	QETH_CARD_TEXT(card, 2, "osnreg");
-	if ((assist_cb == NULL) || (data_cb == NULL))
-		return -EINVAL;
-	card->osn_info.assist_cb = assist_cb;
-	card->osn_info.data_cb = data_cb;
-	return 0;
-}
-EXPORT_SYMBOL(qeth_osn_register);
-
-void qeth_osn_deregister(struct net_device *dev)
-{
-	struct qeth_card *card;
-
-	if (!dev)
-		return;
-	card = dev->ml_priv;
-	if (!card)
-		return;
-	QETH_CARD_TEXT(card, 2, "osndereg");
-	card->osn_info.assist_cb = NULL;
-	card->osn_info.data_cb = NULL;
-	return;
-}
-EXPORT_SYMBOL(qeth_osn_deregister);
-
 /* SETBRIDGEPORT support, async notifications */
 
 enum qeth_an_event_type {anev_reg_unreg, anev_abort, anev_reset};
-- 
2.8.4
