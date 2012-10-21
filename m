From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/5] drivers/net/wireless/ti/wlcore/main.c: eliminate possible double power off
Date: Sun, 21 Oct 2012 12:52:04 +0200
Message-ID: <1350816727-1381-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1350816727-1381-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350816727-1381-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The function wl12xx_set_power_on is only called twice, once in
wl12xx_chip_wakeup and once in wl12xx_get_hw_info.  On the failure of the
call in wl12xx_chip_wakeup, the containing function just returns, but on
the failure of the call in wl12xx_get_hw_info, the containing function
calls wl1271_power_off.  This does not seem necessary, because if
wl12xx_set_power_on has set the power on and then fails, it has already
turned the power off.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f,free,a;
parameter list[n] ps;
type T;
expression e;
@@

f(ps,T a,...) {
  ... when any
      when != a = e
  if(...) { ... free(a); ... return ...; }
  ... when any
}

@@
identifier r.f,r.free;
expression x,a;
expression list[r.n] xs;
@@

* x = f(xs,a,...);
  if (...) { ... free(a); ... return ...; }
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
wl1271_power_off seems to be resistent to being called when the power is
not on, so this should not change the behavior.  Not tested.

 drivers/net/wireless/ti/wlcore/main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 25530c8..0eb739b 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -5116,7 +5116,7 @@ static int wl12xx_get_hw_info(struct wl1271 *wl)
 
 	ret = wl12xx_set_power_on(wl);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	ret = wlcore_read_reg(wl, REG_CHIP_ID_B, &wl->chip.id);
 	if (ret < 0)
