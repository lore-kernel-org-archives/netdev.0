From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 03/17] sfc: Distinguish critical and
 non-critical over-temperature conditions
Date: Thu, 02 Dec 2010 23:46:24 +0000
Message-ID: <1291333584.3259.26.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12966 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932260Ab0LBXq1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:27 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set both the 'maximum' and critical temperature limits for LM87
hardware monitors on Falcon boards.  Do not shut down a port until the
critical temperature is reached, but warn as soon as the 'maximum'
temperature is reached.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_boards.c |  109 ++++++++++++++++++++++++++++---=
-------
 1 files changed, 80 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_b=
oards.c
index cfc29d7..86180ee 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -30,17 +30,28 @@
 #define FALCON_BOARD_SFN4112F 0x52
=20
 /* Board temperature is about 15=C2=B0C above ambient when air flow is
- * limited. */
+ * limited.  The maximum acceptable ambient temperature varies
+ * depending on the PHY specifications but the critical temperature
+ * above which we should shut down to avoid damage is 80=C2=B0C. */
 #define FALCON_BOARD_TEMP_BIAS	15
+#define FALCON_BOARD_TEMP_CRIT	(80 + FALCON_BOARD_TEMP_BIAS)
=20
 /* SFC4000 datasheet says: 'The maximum permitted junction temperature
  * is 125=C2=B0C; the thermal design of the environment for the SFC400=
0
  * should aim to keep this well below 100=C2=B0C.' */
+#define FALCON_JUNC_TEMP_MIN	0
 #define FALCON_JUNC_TEMP_MAX	90
+#define FALCON_JUNC_TEMP_CRIT	125
=20
 /*********************************************************************=
********
  * Support for LM87 sensor chip used on several boards
  */
+#define LM87_REG_TEMP_HW_INT_LOCK	0x13
+#define LM87_REG_TEMP_HW_EXT_LOCK	0x14
+#define LM87_REG_TEMP_HW_INT		0x17
+#define LM87_REG_TEMP_HW_EXT		0x18
+#define LM87_REG_TEMP_EXT1		0x26
+#define LM87_REG_TEMP_INT		0x27
 #define LM87_REG_ALARMS1		0x41
 #define LM87_REG_ALARMS2		0x42
 #define LM87_IN_LIMITS(nr, _min, _max)			\
@@ -57,6 +68,27 @@
=20
 #if defined(CONFIG_SENSORS_LM87) || defined(CONFIG_SENSORS_LM87_MODULE=
)
=20
+static int efx_poke_lm87(struct i2c_client *client, const u8 *reg_valu=
es)
+{
+	while (*reg_values) {
+		u8 reg =3D *reg_values++;
+		u8 value =3D *reg_values++;
+		int rc =3D i2c_smbus_write_byte_data(client, reg, value);
+		if (rc)
+			return rc;
+	}
+	return 0;
+}
+
+static const u8 falcon_lm87_common_regs[] =3D {
+	LM87_REG_TEMP_HW_INT_LOCK, FALCON_BOARD_TEMP_CRIT,
+	LM87_REG_TEMP_HW_INT, FALCON_BOARD_TEMP_CRIT,
+	LM87_TEMP_EXT1_LIMITS(FALCON_JUNC_TEMP_MIN, FALCON_JUNC_TEMP_MAX),
+	LM87_REG_TEMP_HW_EXT_LOCK, FALCON_JUNC_TEMP_CRIT,
+	LM87_REG_TEMP_HW_EXT, FALCON_JUNC_TEMP_CRIT,
+	0
+};
+
 static int efx_init_lm87(struct efx_nic *efx, struct i2c_board_info *i=
nfo,
 			 const u8 *reg_values)
 {
@@ -67,13 +99,12 @@ static int efx_init_lm87(struct efx_nic *efx, struc=
t i2c_board_info *info,
 	if (!client)
 		return -EIO;
=20
-	while (*reg_values) {
-		u8 reg =3D *reg_values++;
-		u8 value =3D *reg_values++;
-		rc =3D i2c_smbus_write_byte_data(client, reg, value);
-		if (rc)
-			goto err;
-	}
+	rc =3D efx_poke_lm87(client, reg_values);
+	if (rc)
+		goto err;
+	rc =3D efx_poke_lm87(client, falcon_lm87_common_regs);
+	if (rc)
+		goto err;
=20
 	board->hwmon_client =3D client;
 	return 0;
@@ -91,36 +122,56 @@ static void efx_fini_lm87(struct efx_nic *efx)
 static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 {
 	struct i2c_client *client =3D falcon_board(efx)->hwmon_client;
-	s32 alarms1, alarms2;
+	bool temp_crit, elec_fault, is_failure;
+	u16 alarms;
+	s32 reg;
=20
 	/* If link is up then do not monitor temperature */
 	if (EFX_WORKAROUND_7884(efx) && efx->link_state.up)
 		return 0;
=20
-	alarms1 =3D i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
-	alarms2 =3D i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
-	if (alarms1 < 0)
-		return alarms1;
-	if (alarms2 < 0)
-		return alarms2;
-	alarms1 &=3D mask;
-	alarms2 &=3D mask >> 8;
-	if (alarms1 || alarms2) {
+	reg =3D i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
+	if (reg < 0)
+		return reg;
+	alarms =3D reg;
+	reg =3D i2c_smbus_read_byte_data(client, LM87_REG_ALARMS2);
+	if (reg < 0)
+		return reg;
+	alarms |=3D reg << 8;
+	alarms &=3D mask;
+
+	temp_crit =3D false;
+	if (alarms & LM87_ALARM_TEMP_INT) {
+		reg =3D i2c_smbus_read_byte_data(client, LM87_REG_TEMP_INT);
+		if (reg < 0)
+			return reg;
+		if (reg > FALCON_BOARD_TEMP_CRIT)
+			temp_crit =3D true;
+	}
+	if (alarms & LM87_ALARM_TEMP_EXT1) {
+		reg =3D i2c_smbus_read_byte_data(client, LM87_REG_TEMP_EXT1);
+		if (reg < 0)
+			return reg;
+		if (reg > FALCON_JUNC_TEMP_CRIT)
+			temp_crit =3D true;
+	}
+	elec_fault =3D alarms & ~(LM87_ALARM_TEMP_INT | LM87_ALARM_TEMP_EXT1)=
;
+	is_failure =3D temp_crit || elec_fault;
+
+	if (alarms)
 		netif_err(efx, hw, efx->net_dev,
-			  "LM87 detected a hardware failure (status %02x:%02x)"
-			  "%s%s%s\n",
-			  alarms1, alarms2,
-			  (alarms1 & LM87_ALARM_TEMP_INT) ?
+			  "LM87 detected a hardware %s (status %02x:%02x)"
+			  "%s%s%s%s\n",
+			  is_failure ? "failure" : "problem",
+			  alarms & 0xff, alarms >> 8,
+			  (alarms & LM87_ALARM_TEMP_INT) ?
 			  "; board is overheating" : "",
-			  (alarms1 & LM87_ALARM_TEMP_EXT1) ?
+			  (alarms & LM87_ALARM_TEMP_EXT1) ?
 			  "; controller is overheating" : "",
-			  (alarms1 & ~(LM87_ALARM_TEMP_INT | LM87_ALARM_TEMP_EXT1)
-			   || alarms2) ?
-			  "; electrical fault" : "");
-		return -ERANGE;
-	}
+			  temp_crit ? "; reached critical temperature" : "",
+			  elec_fault ? "; electrical fault" : "");
=20
-	return 0;
+	return is_failure ? -ERANGE : 0;
 }
=20
 #else /* !CONFIG_SENSORS_LM87 */
--=20
1.7.3.2



--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

