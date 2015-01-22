From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netxen: fix netxen_nic_poll() logic
Date: Thu, 22 Jan 2015 07:56:18 -0800
Message-ID: <1421942178.3471.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421901805.5286.37.camel@marge.simpson.net>
	 <1421906274.4832.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421907358.5286.42.camel@marge.simpson.net>
	 <1421909520.3471.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421915821.5286.71.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Mike Galbraith <umgwanakikbuti@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:46508 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbbAVP4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:56:20 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so2076638iec.8
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:56:20 -0800 (PST)
In-Reply-To: <1421915821.5286.71.camel@marge.simpson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

NAPI poll logic now enforces that a poller returns exactly the budget
when it wants to be called again.

If a driver limits TX completion, it has to return budget as well when
the limit is hit, not the number of received packets.

Reported-and-tested-by: Mike Galbraith <umgwanakikbuti@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: d75b1ade567f ("net: less interrupt masking in NAPI")
Cc: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 613037584d08..c531c8ae1be4 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2388,7 +2388,10 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 
 	work_done = netxen_process_rcv_ring(sds_ring, budget);
 
-	if ((work_done < budget) && tx_complete) {
+	if (!tx_complete)
+		work_done = budget;
+
+	if (work_done < budget) {
 		napi_complete(&sds_ring->napi);
 		if (test_bit(__NX_DEV_UP, &adapter->state))
 			netxen_nic_enable_int(sds_ring);
