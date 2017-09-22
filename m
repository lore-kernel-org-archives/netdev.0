From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v4 6/9] dvb-frontends: fix i2c access helpers for KASAN
Date: Fri, 22 Sep 2017 23:29:17 +0200
Message-ID: <20170922212930.620249-7-arnd@arndb.de>
References: <20170922212930.620249-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@resnulli.us>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Michal Marek <mmarek@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kees Cook <keescook@chromium.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-media@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, kasan-dev@googlegroups.com
To: Mauro Carvalho Chehab <mchehab@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922212930.620249-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A typical code fragment was copied across many dvb-frontend drivers and
causes large stack frames when built with with CONFIG_KASAN on gcc-5/6/7:

drivers/media/dvb-frontends/cxd2841er.c:3225:1: error: the frame size of 3992 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/cxd2841er.c:3404:1: error: the frame size of 3136 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv0367.c:3143:1: error: the frame size of 4016 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv090x.c:3430:1: error: the frame size of 5312 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]
drivers/media/dvb-frontends/stv090x.c:4248:1: error: the frame size of 4872 bytes is larger than 3072 bytes [-Werror=frame-larger-than=]

gcc-8 now solves this by consolidating the stack slots for the argument
variables, but on older compilers we can get the same behavior by taking
the pointer of a local variable rather than the inline function argument.

Cc: stable@vger.kernel.org
Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I'm undecided here whether there should be a comment pointing
to PR81715 for each file that the bogus local variable workaround
to prevent it from being cleaned up again. It's probably not
necessary since anything that causes actual problems would also
trigger a build warning.
---
 drivers/media/dvb-frontends/ascot2e.c     | 4 +++-
 drivers/media/dvb-frontends/cxd2841er.c   | 4 +++-
 drivers/media/dvb-frontends/helene.c      | 4 +++-
 drivers/media/dvb-frontends/horus3a.c     | 4 +++-
 drivers/media/dvb-frontends/itd1000.c     | 5 +++--
 drivers/media/dvb-frontends/mt312.c       | 4 +++-
 drivers/media/dvb-frontends/stb0899_drv.c | 3 ++-
 drivers/media/dvb-frontends/stb6100.c     | 6 ++++--
 drivers/media/dvb-frontends/stv0367.c     | 4 +++-
 drivers/media/dvb-frontends/stv090x.c     | 4 +++-
 drivers/media/dvb-frontends/stv6110x.c    | 4 +++-
 drivers/media/dvb-frontends/zl10039.c     | 4 +++-
 12 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/drivers/media/dvb-frontends/ascot2e.c b/drivers/media/dvb-frontends/ascot2e.c
index 0ee0df53b91b..1219272ca3f0 100644
--- a/drivers/media/dvb-frontends/ascot2e.c
+++ b/drivers/media/dvb-frontends/ascot2e.c
@@ -155,7 +155,9 @@ static int ascot2e_write_regs(struct ascot2e_priv *priv,
 
 static int ascot2e_write_reg(struct ascot2e_priv *priv, u8 reg, u8 val)
 {
-	return ascot2e_write_regs(priv, reg, &val, 1);
+	u8 tmp = val;
+
+	return ascot2e_write_regs(priv, reg, &tmp, 1);
 }
 
 static int ascot2e_read_regs(struct ascot2e_priv *priv,
diff --git a/drivers/media/dvb-frontends/cxd2841er.c b/drivers/media/dvb-frontends/cxd2841er.c
index 48ee9bc00c06..b7574deff5c6 100644
--- a/drivers/media/dvb-frontends/cxd2841er.c
+++ b/drivers/media/dvb-frontends/cxd2841er.c
@@ -257,7 +257,9 @@ static int cxd2841er_write_regs(struct cxd2841er_priv *priv,
 static int cxd2841er_write_reg(struct cxd2841er_priv *priv,
 			       u8 addr, u8 reg, u8 val)
 {
-	return cxd2841er_write_regs(priv, addr, reg, &val, 1);
+	u8 tmp = val;
+
+	return cxd2841er_write_regs(priv, addr, reg, &tmp, 1);
 }
 
 static int cxd2841er_read_regs(struct cxd2841er_priv *priv,
diff --git a/drivers/media/dvb-frontends/helene.c b/drivers/media/dvb-frontends/helene.c
index 4bf5a551ba40..6e93f2d1575b 100644
--- a/drivers/media/dvb-frontends/helene.c
+++ b/drivers/media/dvb-frontends/helene.c
@@ -331,7 +331,9 @@ static int helene_write_regs(struct helene_priv *priv,
 
 static int helene_write_reg(struct helene_priv *priv, u8 reg, u8 val)
 {
-	return helene_write_regs(priv, reg, &val, 1);
+	u8 tmp = val;
+
+	return helene_write_regs(priv, reg, &tmp, 1);
 }
 
 static int helene_read_regs(struct helene_priv *priv,
diff --git a/drivers/media/dvb-frontends/horus3a.c b/drivers/media/dvb-frontends/horus3a.c
index 68d759c4c52e..fa9e2d373073 100644
--- a/drivers/media/dvb-frontends/horus3a.c
+++ b/drivers/media/dvb-frontends/horus3a.c
@@ -89,7 +89,9 @@ static int horus3a_write_regs(struct horus3a_priv *priv,
 
 static int horus3a_write_reg(struct horus3a_priv *priv, u8 reg, u8 val)
 {
-	return horus3a_write_regs(priv, reg, &val, 1);
+	u8 tmp = val;
+
+	return horus3a_write_regs(priv, reg, &tmp, 1);
 }
 
 static int horus3a_enter_power_save(struct horus3a_priv *priv)
diff --git a/drivers/media/dvb-frontends/itd1000.c b/drivers/media/dvb-frontends/itd1000.c
index 5bb1e73a10b4..1ac5177162f6 100644
--- a/drivers/media/dvb-frontends/itd1000.c
+++ b/drivers/media/dvb-frontends/itd1000.c
@@ -95,8 +95,9 @@ static int itd1000_read_reg(struct itd1000_state *state, u8 reg)
 
 static inline int itd1000_write_reg(struct itd1000_state *state, u8 r, u8 v)
 {
-	int ret = itd1000_write_regs(state, r, &v, 1);
-	state->shadow[r] = v;
+	u8 tmp = v;
+	int ret = itd1000_write_regs(state, r, &tmp, 1);
+	state->shadow[r] = tmp;
 	return ret;
 }
 
diff --git a/drivers/media/dvb-frontends/mt312.c b/drivers/media/dvb-frontends/mt312.c
index 961b9a2508e0..12c32c024252 100644
--- a/drivers/media/dvb-frontends/mt312.c
+++ b/drivers/media/dvb-frontends/mt312.c
@@ -142,7 +142,9 @@ static inline int mt312_readreg(struct mt312_state *state,
 static inline int mt312_writereg(struct mt312_state *state,
 				 const enum mt312_reg_addr reg, const u8 val)
 {
-	return mt312_write(state, reg, &val, 1);
+	u8 tmp = val;
+
+	return mt312_write(state, reg, &tmp, 1);
 }
 
 static inline u32 mt312_div(u32 a, u32 b)
diff --git a/drivers/media/dvb-frontends/stb0899_drv.c b/drivers/media/dvb-frontends/stb0899_drv.c
index 02347598277a..db5dde3215f0 100644
--- a/drivers/media/dvb-frontends/stb0899_drv.c
+++ b/drivers/media/dvb-frontends/stb0899_drv.c
@@ -539,7 +539,8 @@ int stb0899_write_regs(struct stb0899_state *state, unsigned int reg, u8 *data,
 
 int stb0899_write_reg(struct stb0899_state *state, unsigned int reg, u8 data)
 {
-	return stb0899_write_regs(state, reg, &data, 1);
+	u8 tmp = data;
+	return stb0899_write_regs(state, reg, &tmp, 1);
 }
 
 /*
diff --git a/drivers/media/dvb-frontends/stb6100.c b/drivers/media/dvb-frontends/stb6100.c
index 17a955d0031b..0167a3e1ecc5 100644
--- a/drivers/media/dvb-frontends/stb6100.c
+++ b/drivers/media/dvb-frontends/stb6100.c
@@ -226,12 +226,14 @@ static int stb6100_write_reg_range(struct stb6100_state *state, u8 buf[], int st
 
 static int stb6100_write_reg(struct stb6100_state *state, u8 reg, u8 data)
 {
+	u8 tmp = data;
+
 	if (unlikely(reg >= STB6100_NUMREGS)) {
 		dprintk(verbose, FE_ERROR, 1, "Invalid register offset 0x%x", reg);
 		return -EREMOTEIO;
 	}
-	data = (data & stb6100_template[reg].mask) | stb6100_template[reg].set;
-	return stb6100_write_reg_range(state, &data, reg, 1);
+	tmp = (tmp & stb6100_template[reg].mask) | stb6100_template[reg].set;
+	return stb6100_write_reg_range(state, &tmp, reg, 1);
 }
 
 
diff --git a/drivers/media/dvb-frontends/stv0367.c b/drivers/media/dvb-frontends/stv0367.c
index f3529df8211d..1964cb7d58b7 100644
--- a/drivers/media/dvb-frontends/stv0367.c
+++ b/drivers/media/dvb-frontends/stv0367.c
@@ -166,7 +166,9 @@ int stv0367_writeregs(struct stv0367_state *state, u16 reg, u8 *data, int len)
 
 static int stv0367_writereg(struct stv0367_state *state, u16 reg, u8 data)
 {
-	return stv0367_writeregs(state, reg, &data, 1);
+	u8 tmp = data;
+
+	return stv0367_writeregs(state, reg, &tmp, 1);
 }
 
 static u8 stv0367_readreg(struct stv0367_state *state, u16 reg)
diff --git a/drivers/media/dvb-frontends/stv090x.c b/drivers/media/dvb-frontends/stv090x.c
index 7ef469c0c866..85ec19305483 100644
--- a/drivers/media/dvb-frontends/stv090x.c
+++ b/drivers/media/dvb-frontends/stv090x.c
@@ -755,7 +755,9 @@ static int stv090x_write_regs(struct stv090x_state *state, unsigned int reg, u8
 
 static int stv090x_write_reg(struct stv090x_state *state, unsigned int reg, u8 data)
 {
-	return stv090x_write_regs(state, reg, &data, 1);
+	u8 tmp = data;
+
+	return stv090x_write_regs(state, reg, &tmp, 1);
 }
 
 static int stv090x_i2c_gate_ctrl(struct stv090x_state *state, int enable)
diff --git a/drivers/media/dvb-frontends/stv6110x.c b/drivers/media/dvb-frontends/stv6110x.c
index 66eba38f1014..f0fd9605aa77 100644
--- a/drivers/media/dvb-frontends/stv6110x.c
+++ b/drivers/media/dvb-frontends/stv6110x.c
@@ -97,7 +97,9 @@ static int stv6110x_write_regs(struct stv6110x_state *stv6110x, int start, u8 da
 
 static int stv6110x_write_reg(struct stv6110x_state *stv6110x, u8 reg, u8 data)
 {
-	return stv6110x_write_regs(stv6110x, reg, &data, 1);
+	u8 tmp = data;
+
+	return stv6110x_write_regs(stv6110x, reg, &tmp, 1);
 }
 
 static int stv6110x_init(struct dvb_frontend *fe)
diff --git a/drivers/media/dvb-frontends/zl10039.c b/drivers/media/dvb-frontends/zl10039.c
index 623355fc2666..4ec9a8fb8c12 100644
--- a/drivers/media/dvb-frontends/zl10039.c
+++ b/drivers/media/dvb-frontends/zl10039.c
@@ -134,7 +134,9 @@ static inline int zl10039_writereg(struct zl10039_state *state,
 				const enum zl10039_reg_addr reg,
 				const u8 val)
 {
-	return zl10039_write(state, reg, &val, 1);
+	const u8 tmp = val;
+
+	return zl10039_write(state, reg, &tmp, 1);
 }
 
 static int zl10039_init(struct dvb_frontend *fe)
-- 
2.9.0
