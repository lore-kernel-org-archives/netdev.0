From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH] net: mvmdio: fix wait_event_timeout() being called with a 1 jiffy timeout.
Date: Tue,  3 Dec 2013 14:16:00 +0100
Message-ID: <1386076560-1886-1-git-send-email-nschichan@freebox.fr>
References: <20131203122346.GD29282@titan.lakedaemon.net>
Cc: Florian Fainelli <florian@openwrt.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Leigh Brown <leigh@solinno.co.uk>,
	Nicolas Schichan <nschichan@freebox.fr>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131203122346.GD29282@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a timer interrupt kicks right after the wait_event_timeout() call,
we may endup a reporting timeout before the timeout really occured.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 drivers/net/ethernet/marvell/mvmdio.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 7354960..2814bbc 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -76,9 +76,19 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 {
 	struct orion_mdio_dev *dev = bus->priv;
 	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
-	unsigned long end = jiffies + timeout;
+	unsigned long end;
 	int timedout = 0;
 
+	/*
+	 * make sure that we wait at least more than one
+	 * jiffy. wait_event_timeout() with a timeout parameter of 1
+	 * jiffy may return before the SMI access is done if a timer
+	 * interrupt kicks immediately after.
+	 */
+	if (timeout < 2)
+		timeout = 2;
+	end = jiffies + timeout;
+
 	while (1) {
 	        if (orion_mdio_smi_is_done(dev))
 			return 0;
-- 
1.8.1.2
