From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Thu, 21 Jul 2005 23:42:11 +0200
Message-ID: <1121982131.5886.2.camel@notepaq>
References: <20050718.203145.105430424.davem@davemloft.net>
	<20050720132305.GA4077@rama> <1121970035.5904.6.camel@notepaq>
	<20050721.131250.55509013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4ma85xFQzzh1R6ayCaQi"
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050721.131250.55509013.davem@davemloft.net>
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


--=-4ma85xFQzzh1R6ayCaQi
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Dave,

> > However after a look trough the Bluetooth core it should be quite
> > easy too move the pkt_type into the control buffer. We already use
> > it for a direction bit. The nasty thing is that I have to modify all
> > the drivers. So when you finally decided to shrink the pkt_type, I
> > think that I can come up with a patch for it quiet quickly.
> 
> We are trimming SKB madly right now, so if you could work on
> the bluetooth patch so we can trim the pkt_type size ASAP
> that would be much appreciated.

unfortunatly it is not that straight forward as I thought. The attached
patch which modifies the Bluetooth core and the hci_usb driver is not
working on my machine.

Regards

Marcel


--=-4ma85xFQzzh1R6ayCaQi
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
@@ -405,11 +405,11 @@ static int hci_sock_sendmsg(struct kiocb
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

--=-4ma85xFQzzh1R6ayCaQi--
