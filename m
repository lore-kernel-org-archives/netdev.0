From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: stmmac: sti: Fix uninitialized pointer dereference if !OF
Date: Mon, 15 Dec 2014 12:25:51 +0100
Message-ID: <1418642751-23308-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If CONFIG_OF is not set:

drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c: In function =E2=80=98s=
ti_dwmac_parse_data=E2=80=99:
drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c:318: warning: =E2=80=98=
rs=E2=80=99 is used uninitialized in this function

of_property_read_string() will return -ENOSYS in this case, and rs will
be an uninitialized pointer.

While the fallback clock selection is already selected correctly in thi=
s
case, the string comparisons should be skipped too, else the system wil=
l
crash while dereferencing the uninitialized pointer.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/=
net/ethernet/stmicro/stmmac/dwmac-sti.c
index 0e137751e76e45b4..056b358b4a72441d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -309,16 +309,16 @@ static int sti_dwmac_parse_data(struct sti_dwmac =
*dwmac,
=20
 	if (IS_PHY_IF_MODE_GBIT(dwmac->interface)) {
 		const char *rs;
-		dwmac->tx_retime_src =3D TX_RETIME_SRC_CLKGEN;
=20
 		err =3D of_property_read_string(np, "st,tx-retime-src", &rs);
-		if (err < 0)
+		if (err < 0) {
 			dev_warn(dev, "Use internal clock source\n");
-
-		if (!strcasecmp(rs, "clk_125"))
+			dwmac->tx_retime_src =3D TX_RETIME_SRC_CLKGEN;
+		} else if (!strcasecmp(rs, "clk_125")) {
 			dwmac->tx_retime_src =3D TX_RETIME_SRC_CLK_125;
-		else if (!strcasecmp(rs, "txclk"))
+		} else if (!strcasecmp(rs, "txclk")) {
 			dwmac->tx_retime_src =3D TX_RETIME_SRC_TXCLK;
+		}
=20
 		dwmac->speed =3D SPEED_1000;
 	}
--=20
1.9.1
