From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 12/13] nfp: mark port state as stale if update failed
Date: Mon, 22 May 2017 10:59:33 -0700
Message-ID: <20170522175934.27447-13-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34382 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760925AbdEVSBS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:18 -0400
Received: by mail-pf0-f171.google.com with SMTP id 9so89335708pfj.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:18 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If reading new state of the port failed, mark the port back as CHANGED.
This way next user state request will trigger refresh, which will
hopefully succeed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 12cbf21df3b9..dd1118c7e1a4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -528,6 +528,7 @@ nfp_net_eth_port_update(struct nfp_cpp *cpp, struct nfp_port *port,
 
 	eth_port = nfp_net_find_port(eth_table, port->eth_id);
 	if (!eth_port) {
+		set_bit(NFP_PORT_CHANGED, &port->flags);
 		nfp_warn(cpp, "Warning: port #%d not present after reconfig\n",
 			 port->eth_id);
 		return -EIO;
@@ -563,6 +564,9 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 
 	eth_table = nfp_eth_read_ports(pf->cpp);
 	if (!eth_table) {
+		list_for_each_entry(port, &pf->ports, port_list)
+			if (__nfp_port_get_eth_port(port))
+				set_bit(NFP_PORT_CHANGED, &port->flags);
 		rtnl_unlock();
 		nfp_err(pf->cpp, "Error refreshing port config!\n");
 		goto out;
@@ -611,6 +615,7 @@ int nfp_net_refresh_eth_port(struct nfp_port *port)
 
 	eth_table = nfp_eth_read_ports(cpp);
 	if (!eth_table) {
+		set_bit(NFP_PORT_CHANGED, &port->flags);
 		nfp_err(cpp, "Error refreshing port state table!\n");
 		return -EIO;
 	}
-- 
2.11.0
