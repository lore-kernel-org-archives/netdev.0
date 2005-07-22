From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Fri, 22 Jul 2005 02:26:34 +0200
Message-ID: <1121991994.5892.15.camel@notepaq>
References: <1121982131.5886.2.camel@notepaq>
	<20050721.152941.56567834.davem@davemloft.net>
	<1121989791.5892.8.camel@notepaq>
	<20050721.165207.35016196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-nUPGTUo4Dkz9NLCwrKK0"
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050721.165207.35016196.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--=-nUPGTUo4Dkz9NLCwrKK0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Dave,

> > The pkt_type zero is not a valid one. We only use 1-4 and 0xff. So this
> > can't be the problem. I assume that the cb is not copied from the driver
> > into the core at some point.
> 
> All clones and copies of SKBs copy of the ->cb[] for you.
> So perhaps something is spamming the ->cb[] between these
> two places.

I found the problem. The hci_usb is using the cb[] by itself and so
overwriting the pkt_type value. The attached patch works for me with the
hci_usb driver. However I haven't converted all other drivers and
checked them. This won't happen until I am back home, because I don't
have any of these devices with me around. However it looks like this
seems to work without any problems.

Regards

Marcel


--=-nUPGTUo4Dkz9NLCwrKK0
Content-Disposition: attachment; filename=patch
Content-Type: text/x-patch; name=patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff --git a/drivers/bluetooth/hci_usb.c b/drivers/bluetooth/hci_usb.c
--- a/drivers/bluetooth/hci_usb.c
+++ b/drivers/bluetooth/hci_usb.c
@@ -443,7 +443,7 @@ static int __tx_submit(struct hci_usb *h
 
 static inline int hci_usb_send_ctrl(struct hci_usb *husb, struct sk_buff *skb)
 {
-	struct _urb *_urb = __get_completed(husb, skb->pkt_type);
+	struct _urb *_urb = __get_completed(husb, bt_cb(skb)->pkt_type);
 	struct usb_ctrlrequest *dr;
 	struct urb *urb;
 
@@ -451,7 +451,7 @@ static inline int hci_usb_send_ctrl(stru
 		_urb = _urb_alloc(0, GFP_ATOMIC);
 		if (!_urb)
 			return -ENOMEM;
-		_urb->type = skb->pkt_type;
+		_urb->type = bt_cb(skb)->pkt_type;
 
 		dr = kmalloc(sizeof(*dr), GFP_ATOMIC);
 		if (!dr) {
@@ -479,7 +479,7 @@ static inline int hci_usb_send_ctrl(stru
 
 static inline int hci_usb_send_bulk(struct hci_usb *husb, struct sk_buff *skb)
 {
-	struct _urb *_urb = __get_completed(husb, skb->pkt_type);
+	struct _urb *_urb = __get_completed(husb, bt_cb(skb)->pkt_type);
 	struct urb *urb;
 	int pipe;
 
@@ -487,7 +487,7 @@ static inline int hci_usb_send_bulk(stru
 		_urb = _urb_alloc(0, GFP_ATOMIC);
 		if (!_urb)
 			return -ENOMEM;
-		_urb->type = skb->pkt_type;
+		_urb->type = bt_cb(skb)->pkt_type;
 	}
 
 	urb  = &_urb->urb;
@@ -505,14 +505,14 @@ static inline int hci_usb_send_bulk(stru
 #ifdef CONFIG_BT_HCIUSB_SCO
 static inline int hci_usb_send_isoc(struct hci_usb *husb, struct sk_buff *skb)
 {
-	struct _urb *_urb = __get_completed(husb, skb->pkt_type);
+	struct _urb *_urb = __get_completed(husb, bt_cb(skb)->pkt_type);
 	struct urb *urb;
 
 	if (!_urb) {
 		_urb = _urb_alloc(HCI_MAX_ISOC_FRAMES, GFP_ATOMIC);
 		if (!_urb)
 			return -ENOMEM;
-		_urb->type = skb->pkt_type;
+		_urb->type = bt_cb(skb)->pkt_type;
 	}
 
 	BT_DBG("%s skb %p len %d", husb->hdev->name, skb, skb->len);
@@ -601,11 +601,11 @@ static int hci_usb_send_frame(struct sk_
 	if (!test_bit(HCI_RUNNING, &hdev->flags))
 		return -EBUSY;
 
-	BT_DBG("%s type %d len %d", hdev->name, skb->pkt_type, skb->len);
+	BT_DBG("%s type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	husb = (struct hci_usb *) hdev->driver_data;
 
-	switch (skb->pkt_type) {
+	switch (bt_cb(skb)->pkt_type) {
 	case HCI_COMMAND_PKT:
 		hdev->stat.cmd_tx++;
 		break;
@@ -627,7 +627,7 @@ static int hci_usb_send_frame(struct sk_
 
 	read_lock(&husb->completion_lock);
 
-	skb_queue_tail(__transmit_q(husb, skb->pkt_type), skb);
+	skb_queue_tail(__transmit_q(husb, bt_cb(skb)->pkt_type), skb);
 	hci_usb_tx_wakeup(husb);
 
 	read_unlock(&husb->completion_lock);
@@ -682,7 +682,7 @@ static inline int __recv_frame(struct hc
 				return -ENOMEM;
 			}
 			skb->dev = (void *) husb->hdev;
-			skb->pkt_type = type;
+			bt_cb(skb)->pkt_type = type;
 	
 			__reassembly(husb, type) = skb;
 
@@ -702,6 +702,7 @@ static inline int __recv_frame(struct hc
 		if (!scb->expect) {
 			/* Complete frame */
 			__reassembly(husb, type) = NULL;
+			bt_cb(skb)->pkt_type = type;
 			hci_recv_frame(skb);
 		}
 
diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h
+++ b/include/net/bluetooth/bluetooth.h
@@ -131,7 +131,8 @@ struct sock *bt_accept_dequeue(struct so
 
 /* Skb helpers */
 struct bt_skb_cb {
-	int incoming;
+	__u8 pkt_type;
+	__u8 incoming;
 };
 #define bt_cb(skb) ((struct bt_skb_cb *)(skb->cb)) 
 
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -191,7 +191,7 @@ static void hci_init_req(struct hci_dev 
 
 	/* Special commands */
 	while ((skb = skb_dequeue(&hdev->driver_init))) {
-		skb->pkt_type = HCI_COMMAND_PKT;
+		bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 		skb->dev = (void *) hdev;
 		skb_queue_tail(&hdev->cmd_q, skb);
 		hci_sched_cmd(hdev);
@@ -995,7 +995,7 @@ static int hci_send_frame(struct sk_buff
 		return -ENODEV;
 	}
 
-	BT_DBG("%s type %d len %d", hdev->name, skb->pkt_type, skb->len);
+	BT_DBG("%s type %d len %d", hdev->name, bt_cb(skb)->pkt_type, skb->len);
 
 	if (atomic_read(&hdev->promisc)) {
 		/* Time stamp */
@@ -1034,7 +1034,7 @@ int hci_send_cmd(struct hci_dev *hdev, _
 
 	BT_DBG("skb len %d", skb->len);
 
-	skb->pkt_type = HCI_COMMAND_PKT;
+	bt_cb(skb)->pkt_type = HCI_COMMAND_PKT;
 	skb->dev = (void *) hdev;
 	skb_queue_tail(&hdev->cmd_q, skb);
 	hci_sched_cmd(hdev);
@@ -1081,7 +1081,7 @@ int hci_send_acl(struct hci_conn *conn, 
 	BT_DBG("%s conn %p flags 0x%x", hdev->name, conn, flags);
 
 	skb->dev = (void *) hdev;
-	skb->pkt_type = HCI_ACLDATA_PKT;
+	bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
 	hci_add_acl_hdr(skb, conn->handle, flags | ACL_START);
 
 	if (!(list = skb_shinfo(skb)->frag_list)) {
@@ -1103,7 +1103,7 @@ int hci_send_acl(struct hci_conn *conn, 
 			skb = list; list = list->next;
 			
 			skb->dev = (void *) hdev;
-			skb->pkt_type = HCI_ACLDATA_PKT;
+			bt_cb(skb)->pkt_type = HCI_ACLDATA_PKT;
 			hci_add_acl_hdr(skb, conn->handle, flags | ACL_CONT);
 
 			BT_DBG("%s frag %p len %d", hdev->name, skb, skb->len);
@@ -1139,7 +1139,7 @@ int hci_send_sco(struct hci_conn *conn, 
 	memcpy(skb->h.raw, &hdr, HCI_SCO_HDR_SIZE);
 
 	skb->dev = (void *) hdev;
-	skb->pkt_type = HCI_SCODATA_PKT;
+	bt_cb(skb)->pkt_type = HCI_SCODATA_PKT;
 	skb_queue_tail(&conn->data_q, skb);
 	hci_sched_tx(hdev);
 	return 0;
@@ -1369,7 +1369,7 @@ void hci_rx_task(unsigned long arg)
 
 		if (test_bit(HCI_INIT, &hdev->flags)) {
 			/* Don't process data packets in this states. */
-			switch (skb->pkt_type) {
+			switch (bt_cb(skb)->pkt_type) {
 			case HCI_ACLDATA_PKT:
 			case HCI_SCODATA_PKT:
 				kfree_skb(skb);
@@ -1378,7 +1378,7 @@ void hci_rx_task(unsigned long arg)
 		}
 
 		/* Process frame */
-		switch (skb->pkt_type) {
+		switch (bt_cb(skb)->pkt_type) {
 		case HCI_EVENT_PKT:
 			hci_event_packet(hdev, skb);
 			break;
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1086,7 +1086,7 @@ void hci_si_event(struct hci_dev *hdev, 
 	bt_cb(skb)->incoming = 1;
 	do_gettimeofday(&skb->stamp);
 
-	skb->pkt_type = HCI_EVENT_PKT;
+	bt_cb(skb)->pkt_type = HCI_EVENT_PKT;
 	skb->dev = (void *) hdev;
 	hci_send_to_sock(hdev, skb);
 	kfree_skb(skb);
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -110,11 +110,11 @@ void hci_send_to_sock(struct hci_dev *hd
 		/* Apply filter */
 		flt = &hci_pi(sk)->filter;
 
-		if (!test_bit((skb->pkt_type == HCI_VENDOR_PKT) ?
-				0 : (skb->pkt_type & HCI_FLT_TYPE_BITS), &flt->type_mask))
+		if (!test_bit((bt_cb(skb)->pkt_type == HCI_VENDOR_PKT) ?
+				0 : (bt_cb(skb)->pkt_type & HCI_FLT_TYPE_BITS), &flt->type_mask))
 			continue;
 
-		if (skb->pkt_type == HCI_EVENT_PKT) {
+		if (bt_cb(skb)->pkt_type == HCI_EVENT_PKT) {
 			register int evt = (*(__u8 *)skb->data & HCI_FLT_EVENT_BITS);
 
 			if (!hci_test_bit(evt, &flt->event_mask))
@@ -131,7 +131,7 @@ void hci_send_to_sock(struct hci_dev *hd
 			continue;
 
 		/* Put type byte before the data */
-		memcpy(skb_push(nskb, 1), &nskb->pkt_type, 1);
+		memcpy(skb_push(nskb, 1), &bt_cb(nskb)->pkt_type, 1);
 
 		if (sock_queue_rcv_skb(sk, nskb))
 			kfree_skb(nskb);
@@ -327,8 +327,10 @@ static inline void hci_sock_cmsg(struct 
 {
 	__u32 mask = hci_pi(sk)->cmsg_mask;
 
-	if (mask & HCI_CMSG_DIR)
-		put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(int), &bt_cb(skb)->incoming);
+	if (mask & HCI_CMSG_DIR) {
+		int incoming = bt_cb(skb)->incoming;
+		put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(incoming), &incoming);
+	}
 
 	if (mask & HCI_CMSG_TSTAMP)
 		put_cmsg(msg, SOL_HCI, HCI_CMSG_TSTAMP, sizeof(skb->stamp), &skb->stamp);
@@ -405,11 +407,11 @@ static int hci_sock_sendmsg(struct kiocb
 		goto drop;
 	}
 
-	skb->pkt_type = *((unsigned char *) skb->data);
+	bt_cb(skb)->pkt_type = *((unsigned char *) skb->data);
 	skb_pull(skb, 1);
 	skb->dev = (void *) hdev;
 
-	if (skb->pkt_type == HCI_COMMAND_PKT) {
+	if (bt_cb(skb)->pkt_type == HCI_COMMAND_PKT) {
 		u16 opcode = __le16_to_cpu(get_unaligned((u16 *)skb->data));
 		u16 ogf = hci_opcode_ogf(opcode);
 		u16 ocf = hci_opcode_ocf(opcode);

--=-nUPGTUo4Dkz9NLCwrKK0--
