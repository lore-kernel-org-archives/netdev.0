From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 06/11] dvb-frontends: reduce stack size in i2c access
Date: Wed, 14 Jun 2017 23:15:41 +0200
Message-ID: <20170614211556.2062728-7-arnd@arndb.de>
References: <20170614211556.2062728-1-arnd@arndb.de>
Cc: kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>, Abylay Ospan <aospan@netup.ru>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        linux-media@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614211556.2062728-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A typical code fragment was copied across many dvb-frontend
drivers and causes large stack frames when built with
-fsanitize-address-use-after-scope, e.g.

drivers/media/dvb-frontends/cxd2841er.c:3225:1: error: the frame size of 3992 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/cxd2841er.c:3404:1: error: the frame size of 3136 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv0367.c:3143:1: error: the frame size of 4016 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv090x.c:3430:1: error: the frame size of 5312 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv090x.c:4248:1: error: the frame size of 4872 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

By marking the register access functions as noinline_if_stackbloat,
we can completely avoid this problem.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/dvb-frontends/ascot2e.c       |  3 ++-
 drivers/media/dvb-frontends/cxd2841er.c     |  4 ++--
 drivers/media/dvb-frontends/drx39xyj/drxj.c | 14 +++++++-------
 drivers/media/dvb-frontends/helene.c        |  4 ++--
 drivers/media/dvb-frontends/horus3a.c       |  2 +-
 drivers/media/dvb-frontends/itd1000.c       |  2 +-
 drivers/media/dvb-frontends/mt312.c         |  2 +-
 drivers/media/dvb-frontends/si2165.c        | 14 +++++++-------
 drivers/media/dvb-frontends/stb0899_drv.c   |  2 +-
 drivers/media/dvb-frontends/stb6100.c       |  2 +-
 drivers/media/dvb-frontends/stv0367.c       |  2 +-
 drivers/media/dvb-frontends/stv090x.c       |  2 +-
 drivers/media/dvb-frontends/stv6110.c       |  2 +-
 drivers/media/dvb-frontends/stv6110x.c      |  2 +-
 drivers/media/dvb-frontends/tda8083.c       |  2 +-
 drivers/media/dvb-frontends/zl10039.c       |  2 +-
 16 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/media/dvb-frontends/ascot2e.c b/drivers/media/dvb-frontends/ascot2e.c
index 0ee0df53b91b..da1d1fc03c5e 100644
--- a/drivers/media/dvb-frontends/ascot2e.c
+++ b/drivers/media/dvb-frontends/ascot2e.c
@@ -153,7 +153,8 @@ static int ascot2e_write_regs(struct ascot2e_priv *priv,
 	return 0;
 }
 
-static int ascot2e_write_reg(struct ascot2e_priv *priv, u8 reg, u8 val)
+static noinline_if_stackbloat int ascot2e_write_reg(struct ascot2e_priv *priv,
+						u8 reg, u8 val)
 {
 	return ascot2e_write_regs(priv, reg, &val, 1);
 }
diff --git a/drivers/media/dvb-frontends/cxd2841er.c b/drivers/media/dvb-frontends/cxd2841er.c
index ce37dc2e89c7..6b851a948ce0 100644
--- a/drivers/media/dvb-frontends/cxd2841er.c
+++ b/drivers/media/dvb-frontends/cxd2841er.c
@@ -258,7 +258,7 @@ static int cxd2841er_write_regs(struct cxd2841er_priv *priv,
 	return 0;
 }
 
-static int cxd2841er_write_reg(struct cxd2841er_priv *priv,
+static noinline_if_stackbloat int cxd2841er_write_reg(struct cxd2841er_priv *priv,
 			       u8 addr, u8 reg, u8 val)
 {
 	return cxd2841er_write_regs(priv, addr, reg, &val, 1);
@@ -306,7 +306,7 @@ static int cxd2841er_read_regs(struct cxd2841er_priv *priv,
 	return 0;
 }
 
-static int cxd2841er_read_reg(struct cxd2841er_priv *priv,
+static noinline_if_stackbloat int cxd2841er_read_reg(struct cxd2841er_priv *priv,
 			      u8 addr, u8 reg, u8 *val)
 {
 	return cxd2841er_read_regs(priv, addr, reg, val, 1);
diff --git a/drivers/media/dvb-frontends/drx39xyj/drxj.c b/drivers/media/dvb-frontends/drx39xyj/drxj.c
index 14040c915dbb..ec5b13ca630b 100644
--- a/drivers/media/dvb-frontends/drx39xyj/drxj.c
+++ b/drivers/media/dvb-frontends/drx39xyj/drxj.c
@@ -1516,7 +1516,7 @@ static int drxdap_fasi_read_block(struct i2c_device_addr *dev_addr,
 *
 ******************************/
 
-static int drxdap_fasi_read_reg16(struct i2c_device_addr *dev_addr,
+static noinline_if_stackbloat int drxdap_fasi_read_reg16(struct i2c_device_addr *dev_addr,
 					 u32 addr,
 					 u16 *data, u32 flags)
 {
@@ -1549,7 +1549,7 @@ static int drxdap_fasi_read_reg16(struct i2c_device_addr *dev_addr,
 *
 ******************************/
 
-static int drxdap_fasi_read_reg32(struct i2c_device_addr *dev_addr,
+static noinline_if_stackbloat int drxdap_fasi_read_reg32(struct i2c_device_addr *dev_addr,
 					 u32 addr,
 					 u32 *data, u32 flags)
 {
@@ -1722,7 +1722,7 @@ static int drxdap_fasi_write_block(struct i2c_device_addr *dev_addr,
 *
 ******************************/
 
-static int drxdap_fasi_write_reg16(struct i2c_device_addr *dev_addr,
+static noinline_if_stackbloat int drxdap_fasi_write_reg16(struct i2c_device_addr *dev_addr,
 					  u32 addr,
 					  u16 data, u32 flags)
 {
@@ -1795,7 +1795,7 @@ static int drxdap_fasi_read_modify_write_reg16(struct i2c_device_addr *dev_addr,
 *
 ******************************/
 
-static int drxdap_fasi_write_reg32(struct i2c_device_addr *dev_addr,
+static noinline_if_stackbloat int drxdap_fasi_write_reg32(struct i2c_device_addr *dev_addr,
 					  u32 addr,
 					  u32 data, u32 flags)
 {
@@ -2172,7 +2172,7 @@ int drxj_dap_atomic_read_write_block(struct i2c_device_addr *dev_addr,
 * \fn int drxj_dap_atomic_read_reg32()
 * \brief Atomic read of 32 bits words
 */
-static
+static noinline_if_stackbloat
 int drxj_dap_atomic_read_reg32(struct i2c_device_addr *dev_addr,
 				     u32 addr,
 				     u32 *data, u32 flags)
@@ -4192,7 +4192,7 @@ int drxj_dap_scu_atomic_read_write_block(struct i2c_device_addr *dev_addr, u32 a
 * \fn int DRXJ_DAP_AtomicReadReg16()
 * \brief Atomic read of 16 bits words
 */
-static
+static noinline_if_stackbloat
 int drxj_dap_scu_atomic_read_reg16(struct i2c_device_addr *dev_addr,
 					 u32 addr,
 					 u16 *data, u32 flags)
@@ -4220,7 +4220,7 @@ int drxj_dap_scu_atomic_read_reg16(struct i2c_device_addr *dev_addr,
 * \fn int drxj_dap_scu_atomic_write_reg16()
 * \brief Atomic read of 16 bits words
 */
-static
+static noinline_if_stackbloat
 int drxj_dap_scu_atomic_write_reg16(struct i2c_device_addr *dev_addr,
 					  u32 addr,
 					  u16 data, u32 flags)
diff --git a/drivers/media/dvb-frontends/helene.c b/drivers/media/dvb-frontends/helene.c
index 4bf5a551ba40..849a18a837d0 100644
--- a/drivers/media/dvb-frontends/helene.c
+++ b/drivers/media/dvb-frontends/helene.c
@@ -329,7 +329,7 @@ static int helene_write_regs(struct helene_priv *priv,
 	return 0;
 }
 
-static int helene_write_reg(struct helene_priv *priv, u8 reg, u8 val)
+static noinline_if_stackbloat int helene_write_reg(struct helene_priv *priv, u8 reg, u8 val)
 {
 	return helene_write_regs(priv, reg, &val, 1);
 }
@@ -374,7 +374,7 @@ static int helene_read_regs(struct helene_priv *priv,
 	return 0;
 }
 
-static int helene_read_reg(struct helene_priv *priv, u8 reg, u8 *val)
+static noinline_if_stackbloat int helene_read_reg(struct helene_priv *priv, u8 reg, u8 *val)
 {
 	return helene_read_regs(priv, reg, val, 1);
 }
diff --git a/drivers/media/dvb-frontends/horus3a.c b/drivers/media/dvb-frontends/horus3a.c
index 68d759c4c52e..f879af6c3188 100644
--- a/drivers/media/dvb-frontends/horus3a.c
+++ b/drivers/media/dvb-frontends/horus3a.c
@@ -87,7 +87,7 @@ static int horus3a_write_regs(struct horus3a_priv *priv,
 	return 0;
 }
 
-static int horus3a_write_reg(struct horus3a_priv *priv, u8 reg, u8 val)
+static noinline_if_stackbloat int horus3a_write_reg(struct horus3a_priv *priv, u8 reg, u8 val)
 {
 	return horus3a_write_regs(priv, reg, &val, 1);
 }
diff --git a/drivers/media/dvb-frontends/itd1000.c b/drivers/media/dvb-frontends/itd1000.c
index 5bb1e73a10b4..8bd6d04362cc 100644
--- a/drivers/media/dvb-frontends/itd1000.c
+++ b/drivers/media/dvb-frontends/itd1000.c
@@ -93,7 +93,7 @@ static int itd1000_read_reg(struct itd1000_state *state, u8 reg)
 	return val;
 }
 
-static inline int itd1000_write_reg(struct itd1000_state *state, u8 r, u8 v)
+static noinline_if_stackbloat int itd1000_write_reg(struct itd1000_state *state, u8 r, u8 v)
 {
 	int ret = itd1000_write_regs(state, r, &v, 1);
 	state->shadow[r] = v;
diff --git a/drivers/media/dvb-frontends/mt312.c b/drivers/media/dvb-frontends/mt312.c
index 961b9a2508e0..d7a701da598a 100644
--- a/drivers/media/dvb-frontends/mt312.c
+++ b/drivers/media/dvb-frontends/mt312.c
@@ -139,7 +139,7 @@ static inline int mt312_readreg(struct mt312_state *state,
 	return mt312_read(state, reg, val, 1);
 }
 
-static inline int mt312_writereg(struct mt312_state *state,
+static noinline_if_stackbloat int mt312_writereg(struct mt312_state *state,
 				 const enum mt312_reg_addr reg, const u8 val)
 {
 	return mt312_write(state, reg, &val, 1);
diff --git a/drivers/media/dvb-frontends/si2165.c b/drivers/media/dvb-frontends/si2165.c
index 528b82a5dd46..8b1ac134f9d8 100644
--- a/drivers/media/dvb-frontends/si2165.c
+++ b/drivers/media/dvb-frontends/si2165.c
@@ -140,7 +140,7 @@ static int si2165_read(struct si2165_state *state,
 	return 0;
 }
 
-static int si2165_readreg8(struct si2165_state *state,
+static noinline_if_stackbloat int si2165_readreg8(struct si2165_state *state,
 		       const u16 reg, u8 *val)
 {
 	unsigned int val_tmp;
@@ -150,7 +150,7 @@ static int si2165_readreg8(struct si2165_state *state,
 	return ret;
 }
 
-static int si2165_readreg16(struct si2165_state *state,
+static noinline_if_stackbloat int si2165_readreg16(struct si2165_state *state,
 		       const u16 reg, u16 *val)
 {
 	u8 buf[2];
@@ -161,26 +161,26 @@ static int si2165_readreg16(struct si2165_state *state,
 	return ret;
 }
 
-static int si2165_writereg8(struct si2165_state *state, const u16 reg, u8 val)
+static noinline_if_stackbloat int si2165_writereg8(struct si2165_state *state, const u16 reg, u8 val)
 {
 	return regmap_write(state->regmap, reg, val);
 }
 
-static int si2165_writereg16(struct si2165_state *state, const u16 reg, u16 val)
+static noinline_if_stackbloat int si2165_writereg16(struct si2165_state *state, const u16 reg, u16 val)
 {
 	u8 buf[2] = { val & 0xff, (val >> 8) & 0xff };
 
 	return si2165_write(state, reg, buf, 2);
 }
 
-static int si2165_writereg24(struct si2165_state *state, const u16 reg, u32 val)
+static noinline_if_stackbloat int si2165_writereg24(struct si2165_state *state, const u16 reg, u32 val)
 {
 	u8 buf[3] = { val & 0xff, (val >> 8) & 0xff, (val >> 16) & 0xff };
 
 	return si2165_write(state, reg, buf, 3);
 }
 
-static int si2165_writereg32(struct si2165_state *state, const u16 reg, u32 val)
+static noinline_if_stackbloat int si2165_writereg32(struct si2165_state *state, const u16 reg, u32 val)
 {
 	u8 buf[4] = {
 		val & 0xff,
@@ -191,7 +191,7 @@ static int si2165_writereg32(struct si2165_state *state, const u16 reg, u32 val)
 	return si2165_write(state, reg, buf, 4);
 }
 
-static int si2165_writereg_mask8(struct si2165_state *state, const u16 reg,
+static noinline_if_stackbloat int si2165_writereg_mask8(struct si2165_state *state, const u16 reg,
 				 u8 val, u8 mask)
 {
 	if (mask != 0xff) {
diff --git a/drivers/media/dvb-frontends/stb0899_drv.c b/drivers/media/dvb-frontends/stb0899_drv.c
index 02347598277a..9258085b8d35 100644
--- a/drivers/media/dvb-frontends/stb0899_drv.c
+++ b/drivers/media/dvb-frontends/stb0899_drv.c
@@ -537,7 +537,7 @@ int stb0899_write_regs(struct stb0899_state *state, unsigned int reg, u8 *data,
 	return 0;
 }
 
-int stb0899_write_reg(struct stb0899_state *state, unsigned int reg, u8 data)
+noinline_if_stackbloat int stb0899_write_reg(struct stb0899_state *state, unsigned int reg, u8 data)
 {
 	return stb0899_write_regs(state, reg, &data, 1);
 }
diff --git a/drivers/media/dvb-frontends/stb6100.c b/drivers/media/dvb-frontends/stb6100.c
index 17a955d0031b..675dffe1ef20 100644
--- a/drivers/media/dvb-frontends/stb6100.c
+++ b/drivers/media/dvb-frontends/stb6100.c
@@ -224,7 +224,7 @@ static int stb6100_write_reg_range(struct stb6100_state *state, u8 buf[], int st
 	return 0;
 }
 
-static int stb6100_write_reg(struct stb6100_state *state, u8 reg, u8 data)
+static noinline_if_stackbloat int stb6100_write_reg(struct stb6100_state *state, u8 reg, u8 data)
 {
 	if (unlikely(reg >= STB6100_NUMREGS)) {
 		dprintk(verbose, FE_ERROR, 1, "Invalid register offset 0x%x", reg);
diff --git a/drivers/media/dvb-frontends/stv0367.c b/drivers/media/dvb-frontends/stv0367.c
index fd49c436a36d..2316c0bb3e21 100644
--- a/drivers/media/dvb-frontends/stv0367.c
+++ b/drivers/media/dvb-frontends/stv0367.c
@@ -798,7 +798,7 @@ int stv0367_writeregs(struct stv0367_state *state, u16 reg, u8 *data, int len)
 	return (ret != 1) ? -EREMOTEIO : 0;
 }
 
-static int stv0367_writereg(struct stv0367_state *state, u16 reg, u8 data)
+static noinline_if_stackbloat int stv0367_writereg(struct stv0367_state *state, u16 reg, u8 data)
 {
 	return stv0367_writeregs(state, reg, &data, 1);
 }
diff --git a/drivers/media/dvb-frontends/stv090x.c b/drivers/media/dvb-frontends/stv090x.c
index 7ef469c0c866..8afecc2e3637 100644
--- a/drivers/media/dvb-frontends/stv090x.c
+++ b/drivers/media/dvb-frontends/stv090x.c
@@ -753,7 +753,7 @@ static int stv090x_write_regs(struct stv090x_state *state, unsigned int reg, u8
 	return 0;
 }
 
-static int stv090x_write_reg(struct stv090x_state *state, unsigned int reg, u8 data)
+static noinline_if_stackbloat int stv090x_write_reg(struct stv090x_state *state, unsigned int reg, u8 data)
 {
 	return stv090x_write_regs(state, reg, &data, 1);
 }
diff --git a/drivers/media/dvb-frontends/stv6110.c b/drivers/media/dvb-frontends/stv6110.c
index e4fd9c1b0560..ddef3a912615 100644
--- a/drivers/media/dvb-frontends/stv6110.c
+++ b/drivers/media/dvb-frontends/stv6110.c
@@ -137,7 +137,7 @@ static int stv6110_read_regs(struct dvb_frontend *fe, u8 regs[],
 	return 0;
 }
 
-static int stv6110_read_reg(struct dvb_frontend *fe, int start)
+static noinline_if_stackbloat int stv6110_read_reg(struct dvb_frontend *fe, int start)
 {
 	u8 buf[] = { 0 };
 	stv6110_read_regs(fe, buf, start, 1);
diff --git a/drivers/media/dvb-frontends/stv6110x.c b/drivers/media/dvb-frontends/stv6110x.c
index 66eba38f1014..80c7024971de 100644
--- a/drivers/media/dvb-frontends/stv6110x.c
+++ b/drivers/media/dvb-frontends/stv6110x.c
@@ -95,7 +95,7 @@ static int stv6110x_write_regs(struct stv6110x_state *stv6110x, int start, u8 da
 	return 0;
 }
 
-static int stv6110x_write_reg(struct stv6110x_state *stv6110x, u8 reg, u8 data)
+static noinline_if_stackbloat int stv6110x_write_reg(struct stv6110x_state *stv6110x, u8 reg, u8 data)
 {
 	return stv6110x_write_regs(stv6110x, reg, &data, 1);
 }
diff --git a/drivers/media/dvb-frontends/tda8083.c b/drivers/media/dvb-frontends/tda8083.c
index aa3200d3c352..646f22aab24e 100644
--- a/drivers/media/dvb-frontends/tda8083.c
+++ b/drivers/media/dvb-frontends/tda8083.c
@@ -88,7 +88,7 @@ static int tda8083_readregs (struct tda8083_state* state, u8 reg1, u8 *b, u8 len
 	return ret == 2 ? 0 : -1;
 }
 
-static inline u8 tda8083_readreg (struct tda8083_state* state, u8 reg)
+static noinline_if_stackbloat u8 tda8083_readreg (struct tda8083_state* state, u8 reg)
 {
 	u8 val;
 
diff --git a/drivers/media/dvb-frontends/zl10039.c b/drivers/media/dvb-frontends/zl10039.c
index 623355fc2666..0075725cb161 100644
--- a/drivers/media/dvb-frontends/zl10039.c
+++ b/drivers/media/dvb-frontends/zl10039.c
@@ -130,7 +130,7 @@ static inline int zl10039_readreg(struct zl10039_state *state,
 	return zl10039_read(state, reg, val, 1);
 }
 
-static inline int zl10039_writereg(struct zl10039_state *state,
+static noinline_if_stackbloat int zl10039_writereg(struct zl10039_state *state,
 				const enum zl10039_reg_addr reg,
 				const u8 val)
 {
-- 
2.9.0
