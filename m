From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] wan: wanxl: Remove typedefs from struct names
Date: Sun, 10 Aug 2014 13:06:47 +0530
Message-ID: <20140810073647.GA3684@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedefs for
port_t, card_status_t and card_t. Also, the names of the structs
are changed to drop the _t, to make the name look less typedef-like.

The following Coccinelle semantic patch detects two cases and a
similar one detects the case for card_t.

@tn1@
type td;
@@

typedef struct { ... } td;

@script:python tf@
td << tn1.td;
tdres;
@@

coccinelle.tdres = td;

@@
type tn1.td;
identifier tf.tdres;
@@

-typedef
 struct
+  tdres
   { ... }
-td
 ;

@@
type tn1.td;
identifier tf.tdres;
@@

-td
+ struct tdres

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: Krzysztof Halasa <khc@pm.waw.pl>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 drivers/net/wan/wanxl.c | 63 +++++++++++++++++++++++++------------------------
 1 file changed, 32 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index f76aa90..1287c3e 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -54,24 +54,24 @@ static const char* version = "wanXL serial card driver version: 0.48";
 #define MBX2_MEMSZ_MASK 0xFFFF0000 /* PUTS Memory Size Register mask */
 
 
-typedef struct {
+struct port {
 	struct net_device *dev;
-	struct card_t *card;
+	struct card *card;
 	spinlock_t lock;	/* for wanxl_xmit */
         int node;		/* physical port #0 - 3 */
 	unsigned int clock_type;
 	int tx_in, tx_out;
 	struct sk_buff *tx_skbs[TX_BUFFERS];
-}port_t;
+};
 
 
-typedef struct {
+struct card_status {
 	desc_t rx_descs[RX_QUEUE_LENGTH];
 	port_status_t port_status[4];
-}card_status_t;
+};
 
 
-typedef struct card_t {
+struct card {
 	int n_ports;		/* 1, 2 or 4 ports */
 	u8 irq;
 
@@ -79,20 +79,20 @@ typedef struct card_t {
 	struct pci_dev *pdev;	/* for pci_name(pdev) */
 	int rx_in;
 	struct sk_buff *rx_skbs[RX_QUEUE_LENGTH];
-	card_status_t *status;	/* shared between host and card */
+	struct card_status *status;	/* shared between host and card */
 	dma_addr_t status_address;
-	port_t ports[0];	/* 1 - 4 port_t structures follow */
-}card_t;
+	struct port ports[0];	/* 1 - 4 port structures follow */
+};
 
 
 
-static inline port_t* dev_to_port(struct net_device *dev)
+static inline struct port *dev_to_port(struct net_device *dev)
 {
-        return (port_t *)dev_to_hdlc(dev)->priv;
+	return (struct port *)dev_to_hdlc(dev)->priv;
 }
 
 
-static inline port_status_t* get_status(port_t *port)
+static inline port_status_t *get_status(struct port *port)
 {
 	return &port->card->status->port_status[port->node];
 }
@@ -115,7 +115,7 @@ static inline dma_addr_t pci_map_single_debug(struct pci_dev *pdev, void *ptr,
 
 
 /* Cable and/or personality module change interrupt service */
-static inline void wanxl_cable_intr(port_t *port)
+static inline void wanxl_cable_intr(struct port *port)
 {
 	u32 value = get_status(port)->cable;
 	int valid = 1;
@@ -160,7 +160,7 @@ static inline void wanxl_cable_intr(port_t *port)
 
 
 /* Transmit complete interrupt service */
-static inline void wanxl_tx_intr(port_t *port)
+static inline void wanxl_tx_intr(struct port *port)
 {
 	struct net_device *dev = port->dev;
 	while (1) {
@@ -193,7 +193,7 @@ static inline void wanxl_tx_intr(port_t *port)
 
 
 /* Receive complete interrupt service */
-static inline void wanxl_rx_intr(card_t *card)
+static inline void wanxl_rx_intr(struct card *card)
 {
 	desc_t *desc;
 	while (desc = &card->status->rx_descs[card->rx_in],
@@ -203,7 +203,7 @@ static inline void wanxl_rx_intr(card_t *card)
 				pci_name(card->pdev));
 		else {
 			struct sk_buff *skb = card->rx_skbs[card->rx_in];
-			port_t *port = &card->ports[desc->stat &
+			struct port *port = &card->ports[desc->stat &
 						    PACKET_PORT_MASK];
 			struct net_device *dev = port->dev;
 
@@ -245,7 +245,7 @@ static inline void wanxl_rx_intr(card_t *card)
 
 static irqreturn_t wanxl_intr(int irq, void* dev_id)
 {
-        card_t *card = dev_id;
+	struct card *card = dev_id;
         int i;
         u32 stat;
         int handled = 0;
@@ -272,7 +272,7 @@ static irqreturn_t wanxl_intr(int irq, void* dev_id)
 
 static netdev_tx_t wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-        port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 	desc_t *desc;
 
         spin_lock(&port->lock);
@@ -319,7 +319,7 @@ static netdev_tx_t wanxl_xmit(struct sk_buff *skb, struct net_device *dev)
 static int wanxl_attach(struct net_device *dev, unsigned short encoding,
 			unsigned short parity)
 {
-	port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 
 	if (encoding != ENCODING_NRZ &&
 	    encoding != ENCODING_NRZI)
@@ -343,7 +343,7 @@ static int wanxl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	const size_t size = sizeof(sync_serial_settings);
 	sync_serial_settings line;
-	port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 
 	if (cmd != SIOCWANDEV)
 		return hdlc_ioctl(dev, ifr, cmd);
@@ -393,7 +393,7 @@ static int wanxl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static int wanxl_open(struct net_device *dev)
 {
-	port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 	u8 __iomem *dbr = port->card->plx + PLX_DOORBELL_TO_CARD;
 	unsigned long timeout;
 	int i;
@@ -429,7 +429,7 @@ static int wanxl_open(struct net_device *dev)
 
 static int wanxl_close(struct net_device *dev)
 {
-	port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 	unsigned long timeout;
 	int i;
 
@@ -467,7 +467,7 @@ static int wanxl_close(struct net_device *dev)
 
 static struct net_device_stats *wanxl_get_stats(struct net_device *dev)
 {
-	port_t *port = dev_to_port(dev);
+	struct port *port = dev_to_port(dev);
 
 	dev->stats.rx_over_errors = get_status(port)->rx_overruns;
 	dev->stats.rx_frame_errors = get_status(port)->rx_frame_errors;
@@ -478,7 +478,7 @@ static struct net_device_stats *wanxl_get_stats(struct net_device *dev)
 
 
 
-static int wanxl_puts_command(card_t *card, u32 cmd)
+static int wanxl_puts_command(struct card *card, u32 cmd)
 {
 	unsigned long timeout = jiffies + 5 * HZ;
 
@@ -495,7 +495,7 @@ static int wanxl_puts_command(card_t *card, u32 cmd)
 
 
 
-static void wanxl_reset(card_t *card)
+static void wanxl_reset(struct card *card)
 {
 	u32 old_value = readl(card->plx + PLX_CONTROL) & ~PLX_CTL_RESET;
 
@@ -511,7 +511,7 @@ static void wanxl_reset(card_t *card)
 
 static void wanxl_pci_remove_one(struct pci_dev *pdev)
 {
-	card_t *card = pci_get_drvdata(pdev);
+	struct card *card = pci_get_drvdata(pdev);
 	int i;
 
 	for (i = 0; i < card->n_ports; i++) {
@@ -537,7 +537,7 @@ static void wanxl_pci_remove_one(struct pci_dev *pdev)
 		iounmap(card->plx);
 
 	if (card->status)
-		pci_free_consistent(pdev, sizeof(card_status_t),
+		pci_free_consistent(pdev, sizeof(struct card_status),
 				    card->status, card->status_address);
 
 	pci_release_regions(pdev);
@@ -560,7 +560,7 @@ static const struct net_device_ops wanxl_ops = {
 static int wanxl_pci_init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
-	card_t *card;
+	struct card *card;
 	u32 ramsize, stat;
 	unsigned long timeout;
 	u32 plx_phy;		/* PLX PCI base address */
@@ -601,7 +601,7 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 	default: ports = 4;
 	}
 
-	alloc_size = sizeof(card_t) + ports * sizeof(port_t);
+	alloc_size = sizeof(struct card) + ports * sizeof(struct port);
 	card = kzalloc(alloc_size, GFP_KERNEL);
 	if (card == NULL) {
 		pci_release_regions(pdev);
@@ -612,7 +612,8 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, card);
 	card->pdev = pdev;
 
-	card->status = pci_alloc_consistent(pdev, sizeof(card_status_t),
+	card->status = pci_alloc_consistent(pdev,
+					    sizeof(struct card_status),
 					    &card->status_address);
 	if (card->status == NULL) {
 		wanxl_pci_remove_one(pdev);
@@ -766,7 +767,7 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 
 	for (i = 0; i < ports; i++) {
 		hdlc_device *hdlc;
-		port_t *port = &card->ports[i];
+		struct port *port = &card->ports[i];
 		struct net_device *dev = alloc_hdlcdev(port);
 		if (!dev) {
 			pr_err("%s: unable to allocate memory\n",
-- 
1.9.1
