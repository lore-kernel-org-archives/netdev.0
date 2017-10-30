From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: cris: Convert timers to use timer_setup()
Date: Mon, 30 Oct 2017 13:57:58 -0700
Message-ID: <20171030205758.GA21929@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        Paul Gortmaker <paul.gortmaker@windriver.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This patch depends on the tip/timers/core DEFINE_TIMER() cleanups, so
I intend to carry this in the timer tree. An Ack or Review would be
appreciated. Thanks!
---
 drivers/net/cris/eth_v10.c | 36 +++++++++++++++++-------------------
 1 file changed, 17 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 1fcc86fa4e05..7193dfafa577 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -164,9 +164,16 @@ static unsigned int network_rec_config_shadow = 0;
 
 static unsigned int network_tr_ctrl_shadow = 0;
 
+/* Timers */
+static void e100_check_speed(struct timer_list *unused);
+static void e100_clear_network_leds(struct timer_list *unused);
+static void e100_check_duplex(struct timer_list *unused);
+static DEFINE_TIMER(speed_timer, e100_check_speed);
+static DEFINE_TIMER(clear_led_timer, e100_clear_network_leds);
+static DEFINE_TIMER(duplex_timer, e100_check_duplex);
+static struct net_device *timer_dev;
+
 /* Network speed indication. */
-static DEFINE_TIMER(speed_timer, NULL);
-static DEFINE_TIMER(clear_led_timer, NULL);
 static int current_speed; /* Speed read from transceiver */
 static int current_speed_selection; /* Speed selected by user */
 static unsigned long led_next_time;
@@ -174,7 +181,6 @@ static int led_active;
 static int rx_queue_len;
 
 /* Duplex */
-static DEFINE_TIMER(duplex_timer, NULL);
 static int full_duplex;
 static enum duplex current_duplex;
 
@@ -199,9 +205,7 @@ static void update_rx_stats(struct net_device_stats *);
 static void update_tx_stats(struct net_device_stats *);
 static int e100_probe_transceiver(struct net_device* dev);
 
-static void e100_check_speed(unsigned long priv);
 static void e100_set_speed(struct net_device* dev, unsigned long speed);
-static void e100_check_duplex(unsigned long priv);
 static void e100_set_duplex(struct net_device* dev, enum duplex);
 static void e100_negotiate(struct net_device* dev);
 
@@ -213,7 +217,6 @@ static void e100_send_mdio_bit(unsigned char bit);
 static unsigned char e100_receive_mdio_bit(void);
 static void e100_reset_transceiver(struct net_device* net);
 
-static void e100_clear_network_leds(unsigned long dummy);
 static void e100_set_network_leds(int active);
 
 static const struct ethtool_ops e100_ethtool_ops;
@@ -380,17 +383,12 @@ etrax_ethernet_init(void)
 	current_speed = 10;
 	current_speed_selection = 0; /* Auto */
 	speed_timer.expires = jiffies + NET_LINK_UP_CHECK_INTERVAL;
-	speed_timer.data = (unsigned long)dev;
-	speed_timer.function = e100_check_speed;
-
-	clear_led_timer.function = e100_clear_network_leds;
-	clear_led_timer.data = (unsigned long)dev;
 
 	full_duplex = 0;
 	current_duplex = autoneg;
 	duplex_timer.expires = jiffies + NET_DUPLEX_CHECK_INTERVAL;
-        duplex_timer.data = (unsigned long)dev;
-	duplex_timer.function = e100_check_duplex;
+
+	timer_dev = dev;
 
         /* Initialize mii interface */
 	np->mii_if.phy_id_mask = 0x1f;
@@ -679,9 +677,9 @@ intel_check_speed(struct net_device* dev)
 }
 #endif
 static void
-e100_check_speed(unsigned long priv)
+e100_check_speed(struct timer_list *unused)
 {
-	struct net_device* dev = (struct net_device*)priv;
+	struct net_device *dev = timer_dev;
 	struct net_local *np = netdev_priv(dev);
 	static int led_initiated = 0;
 	unsigned long data;
@@ -798,9 +796,9 @@ e100_set_speed(struct net_device* dev, unsigned long speed)
 }
 
 static void
-e100_check_duplex(unsigned long priv)
+e100_check_duplex(struct timer_list *unused)
 {
-	struct net_device *dev = (struct net_device *)priv;
+	struct net_device *dev = timer_dev;
 	struct net_local *np = netdev_priv(dev);
 	int old_duplex;
 
@@ -1668,9 +1666,9 @@ e100_hardware_send_packet(struct net_local *np, char *buf, int length)
 }
 
 static void
-e100_clear_network_leds(unsigned long dummy)
+e100_clear_network_leds(struct timer_list *unused)
 {
-	struct net_device *dev = (struct net_device *)dummy;
+	struct net_device *dev = timer_dev;
 	struct net_local *np = netdev_priv(dev);
 
 	spin_lock(&np->led_lock);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
