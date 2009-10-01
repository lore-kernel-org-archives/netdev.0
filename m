From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: Fix delay handling
Date: Thu, 01 Oct 2009 11:47:34 +0200
Message-ID: <4AC47AB6.9000501@gmail.com>
References: <20090922224902.17ed6cc4@nehalam>	<20090923174141.1d350103@s6510>	<4AC3E3C5.1090108@gmail.com> <20090930172532.2c2d1d42@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48757 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005AbZJAJre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 05:47:34 -0400
In-Reply-To: <20090930172532.2c2d1d42@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After last pktgen changes, delay handling is wrong.

pktgen actually sends packets at full line speed.

Fix is to update pkt_dev->next_tx even if spin() returns early,
so that next spin() calls have a chance to see a positive delay.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 0bcecbf..1a0682e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2106,15 +2106,17 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
 	ktime_t start;
-	s32 remaining;
+	s64 remaining;
 	struct hrtimer_sleeper t;
 
 	hrtimer_init_on_stack(&t.timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	hrtimer_set_expires(&t.timer, spin_until);
 
 	remaining = ktime_to_us(hrtimer_expires_remaining(&t.timer));
-	if (remaining <= 0)
+	if (remaining <= 0) {
+		pkt_dev->next_tx = ktime_add_ns(spin_until, pkt_dev->delay);
 		return;
+	}
 
 	start = ktime_now();
 	if (remaining < 100)
