From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rocker: fix Wmaybe-uninitialized false-positive
Date: Tue, 28 Mar 2017 16:11:18 +0200
Message-ID: <20170328141126.1541994-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:50753 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752292AbdC1OM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:12:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc-7 reports a warning that earlier versions did not have:

drivers/net/ethernet/rocker/rocker_ofdpa.c: In function 'ofdpa_port_stp_update':
arch/x86/include/asm/string_32.h:79:22: error: '*((void *)&prev_ctrls+4)' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   *((short *)to + 2) = *((short *)from + 2);
   ~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/rocker/rocker_ofdpa.c:2218:7: note: '*((void *)&prev_ctrls+4)' was declared here

This is clearly a variation of the warning about 'prev_state' that
was shut up using uninitialized_var().

We can slightly simplify the code and get rid of the warning by unconditionally
saving the prev_state and prev_ctrls variables. The inlined memcpy is not
particularly expensive here, as it just has to read five bytes from one or
two cache lines.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 7cd76b6b5cb9..2ae852454780 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2216,18 +2216,15 @@ static int ofdpa_port_stp_update(struct ofdpa_port *ofdpa_port,
 {
 	bool want[OFDPA_CTRL_MAX] = { 0, };
 	bool prev_ctrls[OFDPA_CTRL_MAX];
-	u8 uninitialized_var(prev_state);
+	u8 prev_state;
 	int err;
 	int i;
 
-	if (switchdev_trans_ph_prepare(trans)) {
-		memcpy(prev_ctrls, ofdpa_port->ctrls, sizeof(prev_ctrls));
-		prev_state = ofdpa_port->stp_state;
-	}
-
-	if (ofdpa_port->stp_state == state)
+	prev_state = ofdpa_port->stp_state;
+	if (prev_state == state)
 		return 0;
 
+	memcpy(prev_ctrls, ofdpa_port->ctrls, sizeof(prev_ctrls));
 	ofdpa_port->stp_state = state;
 
 	switch (state) {
-- 
2.9.0
