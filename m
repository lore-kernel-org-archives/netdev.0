From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: bcm_sf2: Fix ageing conditions and operation
Date: Sat,  5 Sep 2015 13:07:27 -0700
Message-ID: <1441483647-8278-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32878 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbbIEUKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 16:10:07 -0400
Received: by pacex6 with SMTP id ex6so56016438pac.0
        for <netdev@vger.kernel.org>; Sat, 05 Sep 2015 13:10:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comparison check between cur_hw_state and hw_state is currently
invalid because cur_hw_state is right shifted by G_MISTP_SHIFT, while
hw_state is not, so we end-up comparing bits 2:0 with bits 7:5, which is
going to cause an additional aging to occur. Fix this by not shifting
cur_hw_state while reading it, but instead, mask the value with the
appropriately shitfted bitmask.

The other problem with the fast-ageing process is that we did not set
the EN_AGE_DYNAMIC bit to request the ageing to occur for dynamically
learned MAC addresses. Finally, write back 0 to the FAST_AGE_CTRL
register to avoid leaving spurious bits sets from one operation to the
other.

Fixes: 12f460f23423 ("net: dsa: bcm_sf2: add HW bridging support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
David, this dates back to 4.1, could you queue this for -stable?

Thanks!

 drivers/net/dsa/bcm_sf2.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 289e20443d83..9d56515f4c4d 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -418,7 +418,7 @@ static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
 	core_writel(priv, port, CORE_FAST_AGE_PORT);
 
 	reg = core_readl(priv, CORE_FAST_AGE_CTRL);
-	reg |= EN_AGE_PORT | FAST_AGE_STR_DONE;
+	reg |= EN_AGE_PORT | EN_AGE_DYNAMIC | FAST_AGE_STR_DONE;
 	core_writel(priv, reg, CORE_FAST_AGE_CTRL);
 
 	do {
@@ -432,6 +432,8 @@ static int bcm_sf2_sw_fast_age_port(struct dsa_switch  *ds, int port)
 	if (!timeout)
 		return -ETIMEDOUT;
 
+	core_writel(priv, 0, CORE_FAST_AGE_CTRL);
+
 	return 0;
 }
 
@@ -507,7 +509,7 @@ static int bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
 	u32 reg;
 
 	reg = core_readl(priv, CORE_G_PCTL_PORT(port));
-	cur_hw_state = reg >> G_MISTP_STATE_SHIFT;
+	cur_hw_state = reg & (G_MISTP_STATE_MASK << G_MISTP_STATE_SHIFT);
 
 	switch (state) {
 	case BR_STATE_DISABLED:
@@ -531,10 +533,12 @@ static int bcm_sf2_sw_br_set_stp_state(struct dsa_switch *ds, int port,
 	}
 
 	/* Fast-age ARL entries if we are moving a port from Learning or
-	 * Forwarding state to Disabled, Blocking or Listening state
+	 * Forwarding (cur_hw_state) state to Disabled, Blocking or Listening
+	 * state (hw_state)
 	 */
 	if (cur_hw_state != hw_state) {
-		if (cur_hw_state & 4 && !(hw_state & 4)) {
+		if (cur_hw_state >= G_MISTP_LEARN_STATE &&
+		    hw_state <= G_MISTP_LISTEN_STATE) {
 			ret = bcm_sf2_sw_fast_age_port(ds, port);
 			if (ret) {
 				pr_err("%s: fast-ageing failed\n", __func__);
-- 
2.1.0
