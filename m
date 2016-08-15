From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 8/9] mlxsw: spectrum: Allow packets to be trapped from any PG
Date: Mon, 15 Aug 2016 16:37:52 +0200
Message-ID: <1471271873-4389-9-git-send-email-jiri@resnulli.us>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33671 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201AbcHOOiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 10:38:07 -0400
Received: by mail-wm0-f68.google.com with SMTP id o80so11487760wme.0
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 07:38:06 -0700 (PDT)
In-Reply-To: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When packets enter the device they are classified to a priority group
(PG) buffer based on their PCP value. After their egress port and
traffic class are determined they are moved to the switch's shared
buffer and await transmission, if:

(Ingress{Port}.Usage < Thres && Ingress{Port,PG}.Usage < Thres &&
 Egress{Port}.Usage < Thres && Egress{Port,TC}.Usage < Thres)
||
(Ingress{Port}.Usage < Min || Ingress{Port,PG} < Min ||
 Egress{Port}.Usage < Min || Egress{Port,TC}.Usage < Min)

Packets scheduled to transmission through CPU port (trapped to CPU) use
traffic class 7, which has a zero maximum and minimum quotas. However,
when such packets arrive from PG 0 they are admitted to the shared
buffer as PG 0 has a non-zero minimum quota.

Allow all packets to be trapped to the CPU - regardless of the PG they
were classified to - by assigning a 10KB minimum quota for CPU port and
TC7.

Fixes: 8e8dfe9fdf06 ("mlxsw: spectrum: Add IEEE 802.1Qaz ETS support")
Reported-by: Tamir Winetroub <tamirw@mellanox.com>
Tested-by: Tamir Winetroub <tamirw@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 074cdda..237418a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -330,7 +330,7 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_cpu_port_sb_cms[] = {
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
-	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(10000), 0, 0),
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
-- 
2.5.5
