From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next] net: dsa: lan9303: Do not disable switch fabric port 0 at .probe
Date: Tue, 24 Oct 2017 17:14:10 +0200
Message-ID: <20171024151410.28494-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the LAN9303 work when lan9303_probe() is called twice.

For some unknown reason the LAN9303 switch fail to forward data when switch
fabric port 0 TX is disabled during probe. (Write of LAN9303_MAC_TX_CFG_0
in lan9303_disable_processing_port().)

In that situation the switch fabric seem to receive frames, because the ALR
is learning addresses. But no frames are transmitted on any of the ports.

In our system lan9303_probe() is called twice, first time
dsa_register_switch() return -EPROBE_DEFER. As an experiment, modified the
code to skip writing LAN9303_MAC_TX_CFG_0, port 0 during the first probe.
Then the switch works as expected.

Resolve the problem by not calling lan9303_disable_processing_port() on
port 0 during probe. Ports 1 and 2 are still disabled.

Although unsatisfying that the exact failure mechanism is not known,
the patch should not cause any harm.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 87f919f0e641..4c412bd52319 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -818,7 +818,7 @@ static int lan9303_disable_processing(struct lan9303 *chip)
 {
 	int p;
 
-	for (p = 0; p < LAN9303_NUM_PORTS; p++) {
+	for (p = 1; p < LAN9303_NUM_PORTS; p++) {
 		int ret = lan9303_disable_processing_port(chip, p);
 
 		if (ret)
-- 
2.11.0
