From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 16/16] sfc: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:11:22 -0700
Message-ID: <87lhwcw9j9.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com> <871ty41dps.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59945 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbaCOBL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:11:28 -0400
In-Reply-To: <871ty41dps.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 17:56:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Processing any incoming packets with a with a napi budget of 0
is incorrect driver behavior.

This matters as netpoll will shortly call drivers with a budget of 0
to avoid receive packet processing happening in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/sfc/ef10.c  |    3 +++
 drivers/net/ethernet/sfc/farch.c |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index eb75675f6e32..651626e133f9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -1955,6 +1955,9 @@ static int efx_ef10_ev_process(struct efx_channel *channel, int quota)
 	int tx_descs = 0;
 	int spent = 0;
 
+	if (quota <= 0)
+		return spent;
+
 	read_ptr = channel->eventq_read_ptr;
 
 	for (;;) {
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index aa1b169f45ec..a08761360cdf 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -1248,6 +1248,9 @@ int efx_farch_ev_process(struct efx_channel *channel, int budget)
 	int tx_packets = 0;
 	int spent = 0;
 
+	if (budget <= 0)
+		return spent;
+
 	read_ptr = channel->eventq_read_ptr;
 
 	for (;;) {
-- 
1.7.5.4
