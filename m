From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] rocker: Provide offload indication using nexthop flags
Date: Wed,  2 Aug 2017 09:56:02 +0200
Message-ID: <20170802075606.1090-3-jiri@resnulli.us>
References: <20170802075606.1090-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33938 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdHBH4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:56:13 -0400
Received: by mail-wr0-f195.google.com with SMTP id o33so3044592wrb.1
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:56:12 -0700 (PDT)
In-Reply-To: <20170802075606.1090-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We want to stop using the FIB info's flags to provide the offlaod
indication and instead do that on a per-nexthop basis.

Convert rocker to do just that. It only supports one nexthop per-route,
so conversion is simple.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 600e30e..da4e26b 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2761,7 +2761,7 @@ static int ofdpa_fib4_add(struct rocker *rocker,
 				  fen_info->tb_id, 0);
 	if (err)
 		return err;
-	fib_info_offload_inc(fen_info->fi);
+	fen_info->fi->fib_nh->nh_flags |= RTNH_F_OFFLOAD;
 	return 0;
 }
 
@@ -2776,7 +2776,7 @@ static int ofdpa_fib4_del(struct rocker *rocker,
 	ofdpa_port = ofdpa_port_dev_lower_find(fen_info->fi->fib_dev, rocker);
 	if (!ofdpa_port)
 		return 0;
-	fib_info_offload_dec(fen_info->fi);
+	fen_info->fi->fib_nh->nh_flags &= ~RTNH_F_OFFLOAD;
 	return ofdpa_port_fib_ipv4(ofdpa_port, htonl(fen_info->dst),
 				   fen_info->dst_len, fen_info->fi,
 				   fen_info->tb_id, OFDPA_OP_FLAG_REMOVE);
@@ -2803,7 +2803,7 @@ static void ofdpa_fib4_abort(struct rocker *rocker)
 						       rocker);
 		if (!ofdpa_port)
 			continue;
-		fib_info_offload_dec(flow_entry->fi);
+		flow_entry->fi->fib_nh->nh_flags &= ~RTNH_F_OFFLOAD;
 		ofdpa_flow_tbl_del(ofdpa_port, OFDPA_OP_FLAG_REMOVE,
 				   flow_entry);
 	}
-- 
2.9.3
