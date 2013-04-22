From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/5 v2] net/cpsw: don't rely only on netif_running() to
 check which device is active
Date: Mon, 22 Apr 2013 10:30:48 +0200
Message-ID: <20130422083048.GA8162@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
 <1366235536-15744-4-git-send-email-bigeasy@linutronix.de>
 <516FDE0A.70504@ti.com>
 <516FE2AD.2040403@linutronix.de>
 <51711E0B.4000306@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56576 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab3DVIat convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:30:49 -0400
Content-Disposition: inline
In-Reply-To: <51711E0B.4000306@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_running() reports false before the ->ndo_stop() callback is
called. That means if one executes "ifconfig down" and the system
receives an interrupt before the interrupt source has been disabled we
hang for always for two reasons:
- we never disable the interrupt source because devices claim to be
  already inactive (or non-present) and don't feel responsible.
- since the ISR always reports IRQ_HANDLED the line is never deactivate=
d
  because it looks like the ISR feels responsible.

This patch looks at both, netif_running() and IFF_UP to check if the
device is up. IFF_UP is set after ndo_open() completes and cleared afte=
r
ndo_close() completes and netif_running is set before ndo_open() is
called and cleared before ndo_close() completes. Using both will avoid
false positives during the bring down sequence.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
* Mugunthan V N | 2013-04-19 16:05:55 [+0530]:

>The same netif_running(). But why you are telling not to rely on this =
API?
>device state is updated immediately after successful ndo_open.

I tried to describe the reason for that in my patch description. Here=20
it is again: netif_running() reports false before ndo_close() has been
called. That means an interrupt between the flag change and interrupt
disabling in ndo_close() will currently lockup the box (IRQ_NONE would
at least allow the core to disable the interrupt line).

Initialyly I decided against using IFF_UP as well but using would work
without the private active field. So here we have=20

-v1=E2=80=A6v2: replacing private active field with IFF_UP + netif_runn=
ing()

How about this?

>Regards
>Mugunthan V N
 drivers/net/ethernet/ti/cpsw.c |   23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
index 3b22a36..2705725 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -511,19 +511,24 @@ static irqreturn_t cpsw_interrupt(int irq, void *=
dev_id)
 {
 	struct cpsw_priv *priv =3D dev_id;
=20
-	if (likely(netif_running(priv->ndev))) {
+	if (likely(netif_running(priv->ndev) || priv->ndev->flags & IFF_UP)) =
{
 		cpsw_intr_disable(priv);
 		cpsw_disable_irq(priv);
 		napi_schedule(&priv->napi);
-	} else {
-		priv =3D cpsw_get_slave_priv(priv, 1);
-		if (likely(priv) && likely(netif_running(priv->ndev))) {
-			cpsw_intr_disable(priv);
-			cpsw_disable_irq(priv);
-			napi_schedule(&priv->napi);
-		}
+		return IRQ_HANDLED;
+	}
+
+	priv =3D cpsw_get_slave_priv(priv, 1);
+	if (!priv)
+		return IRQ_NONE;
+
+	if (likely(netif_running(priv->ndev) || priv->ndev->flags & IFF_UP)) =
{
+		cpsw_intr_disable(priv);
+		cpsw_disable_irq(priv);
+		napi_schedule(&priv->napi);
+		return IRQ_HANDLED;
 	}
-	return IRQ_HANDLED;
+	return IRQ_NONE;
 }
=20
 static int cpsw_poll(struct napi_struct *napi, int budget)
--=20
1.7.10.4
