From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 2/4] rocker: set untagged VLAN when opening port
Date: Mon, 13 Apr 2015 15:47:55 +0900
Message-ID: <1428907677-27204-3-git-send-email-simon.horman@netronome.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33037 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbbDMGsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:48:25 -0400
Received: by pdbnk13 with SMTP id nk13so97272908pdb.0
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:48:24 -0700 (PDT)
In-Reply-To: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When joining a bridge rocker sets the untagged VLAN of a port
according to the ifindex of its bridge device.

And when leaving a bridge rocker sets the untagged VLAN of a port
according to the ifindex of the port's device.

So after joining and leaving a VLAN the untagged VLAN of a port will
be set according to the latter. However, prior to joining a VLAN it is
unset.

This patch sets the untagged VLAN of a port according to the ifindex
of the port's device when the port's device is opened. That is, the same
value that can be achieved by joining then leaving a VLAN. Which seems
logical and consistent.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 955cf0ae33a7..b88097b26587 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3853,9 +3853,13 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
+	err = rocker_port_set_untagged_vlan(rocker_port);
+	if (err)
+		goto err_set_vlan;
+
 	err = rocker_port_fwd_enable(rocker_port);
 	if (err)
-		goto err_fwd_enable;
+		goto err_set_vlan;
 
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
@@ -3863,7 +3867,7 @@ static int rocker_port_open(struct net_device *dev)
 	netif_start_queue(dev);
 	return 0;
 
-err_fwd_enable:
+err_set_vlan:
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
-- 
2.1.4
