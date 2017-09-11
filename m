From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum: Fix EEPROM access in case of SFP/SFP+
Date: Mon, 11 Sep 2017 09:42:26 +0200
Message-ID: <20170911074226.2020-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        flokli@flokli.de, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34557 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750937AbdIKHma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 03:42:30 -0400
Received: by mail-wm0-f67.google.com with SMTP id l19so6168299wmi.1
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 00:42:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The current code does not handle correctly the access to the upper page
in case of SFP/SFP+ EEPROM. In that case the offset should be local
and the I2C address should be changed.

Fixes: 2ea109039cd3 ("mlxsw: spectrum: Add support for access cable info via ethtool")
Reported-by: Florian Klink <flokli@flokli.de>
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
Dave, could you please queue this up to STABLE as well? Thanks!
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ed7cd6c..e080459 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2545,7 +2545,9 @@ static int mlxsw_sp_flash_device(struct net_device *dev,
 	return err;
 }
 
-#define MLXSW_SP_QSFP_I2C_ADDR 0x50
+#define MLXSW_SP_I2C_ADDR_LOW 0x50
+#define MLXSW_SP_I2C_ADDR_HIGH 0x51
+#define MLXSW_SP_EEPROM_PAGE_LENGTH 256
 
 static int mlxsw_sp_query_module_eeprom(struct mlxsw_sp_port *mlxsw_sp_port,
 					u16 offset, u16 size, void *data,
@@ -2554,12 +2556,25 @@ static int mlxsw_sp_query_module_eeprom(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char eeprom_tmp[MLXSW_SP_REG_MCIA_EEPROM_SIZE];
 	char mcia_pl[MLXSW_REG_MCIA_LEN];
+	u16 i2c_addr;
 	int status;
 	int err;
 
 	size = min_t(u16, size, MLXSW_SP_REG_MCIA_EEPROM_SIZE);
+
+	if (offset < MLXSW_SP_EEPROM_PAGE_LENGTH &&
+	    offset + size > MLXSW_SP_EEPROM_PAGE_LENGTH)
+		/* Cross pages read, read until offset 256 in low page */
+		size = MLXSW_SP_EEPROM_PAGE_LENGTH - offset;
+
+	i2c_addr = MLXSW_SP_I2C_ADDR_LOW;
+	if (offset >= MLXSW_SP_EEPROM_PAGE_LENGTH) {
+		i2c_addr = MLXSW_SP_I2C_ADDR_HIGH;
+		offset -= MLXSW_SP_EEPROM_PAGE_LENGTH;
+	}
+
 	mlxsw_reg_mcia_pack(mcia_pl, mlxsw_sp_port->mapping.module,
-			    0, 0, offset, size, MLXSW_SP_QSFP_I2C_ADDR);
+			    0, 0, offset, size, i2c_addr);
 
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mcia), mcia_pl);
 	if (err)
-- 
2.9.3
