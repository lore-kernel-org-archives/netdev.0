From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: Regulator support for smsc911x
Date: Fri, 3 Feb 2012 08:44:08 +0100
Message-ID: <20120203074408.GD1990@pengutronix.de>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
 <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.marklund@stericsson.com, netdev@vger.kernel.org,
	Sascha Hauer <kernel@pengutronix.de>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43323 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab2BCHoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 02:44:13 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2012 at 01:17:23AM -0200, Fabio Estevam wrote:
> On Thu, Feb 2, 2012 at 11:02 PM, Fabio Estevam <festevam@gmail.com> wrote:
> > Robert,
> >
> > Since commit c7e963f6 (net/smsc911x: Add regulator support) I am no
> > longer able to use smsc911x driver due to the lack of regulators for
> > smsc on mx31_3ds board.
> >
> > Do you a board example that uses such regulator, so that I can look
> > for a reference?
> 
> Ok, I fixed it by enabling CONFIG_REGULATOR_DUMMY on
> imx_v6_v7_defconfig, but I am wondering if the patch below would be a
> more appropriate fix:
> 
> --- a/drivers/net/ethernet/smsc/Kconfig
> +++ b/drivers/net/ethernet/smsc/Kconfig
> @@ -102,6 +102,8 @@ config SMSC911X
>         select NET_CORE
>         select MII
>         select PHYLIB
> +       select REGULATOR
> +       select REGULATOR_DUMMY
>         ---help---
>           Say Y here if you want support for SMSC LAN911x and LAN921x families
>           of ethernet controllers.
> 
> Please advise if I should fix it in Kconfig or defconfig, so that I
> can submit a patch.

The problem with the dummy regulator is that it can hide real problems.
If you enable it every device will get a regulator when it requests one.
If for some reason for example the initialization order of your devices
changes and a device gets probed before the corresponding (real)
regulator is registered, then this device will continue with the dummy
regulator and probably won't work.

We could a) live with this problem and default enable the dummy
regulator. We could also b) apply (a fixed version of) the following
patch which simplifies registration of a dummy regulator. Still it's a
bit annoying to have to fix all users once someone adds regulator
support for a driver.

Sascha

8<------------------------------------------------

regulator: allow boards to bind to the dummy regulator

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/regulator/core.c          |   19 +++++++++++++++++++
 include/linux/regulator/machine.h |    8 ++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/regulator/core.c b/drivers/regulator/core.c
index d8e6a42..a7a38ba 100644
--- a/drivers/regulator/core.c
+++ b/drivers/regulator/core.c
@@ -1046,6 +1046,25 @@ static void unset_regulator_supplies(struct regulator_dev *rdev)
 	}
 }
 
+int regulator_add_dummy_supply(struct regulator_consumer_supply *supply,
+		int num_supplies)
+{
+	int i, ret;
+
+	for (i = 0; i < num_supplies; i++) {
+		ret = set_consumer_device_supply(dummy_regulator_rdev, NULL,
+				supply[i].dev_name, supply[i].supply);
+		if (ret)
+			goto err_out;
+	}
+
+	return 0;
+err_out:
+	/* FIXME: unset device supply */
+	return ret;
+}
+EXPORT_SYMBOL_GPL(regulator_add_dummy_supply);
+
 #define REG_STR_SIZE	64
 
 static struct regulator *create_regulator(struct regulator_dev *rdev,
diff --git a/include/linux/regulator/machine.h b/include/linux/regulator/machine.h
index ce3127a..89089cd 100644
--- a/include/linux/regulator/machine.h
+++ b/include/linux/regulator/machine.h
@@ -192,6 +192,8 @@ int regulator_suspend_finish(void);
 #ifdef CONFIG_REGULATOR
 void regulator_has_full_constraints(void);
 void regulator_use_dummy_regulator(void);
+int regulator_add_dummy_supply(struct regulator_consumer_supply *supply,
+		int num_supplies);
 #else
 static inline void regulator_has_full_constraints(void)
 {
@@ -200,6 +202,12 @@ static inline void regulator_has_full_constraints(void)
 static inline void regulator_use_dummy_regulator(void)
 {
 }
+
+static inline int regulator_add_dummy_supply(struct regulator_consumer_supply *supply,
+		int num_supplies)
+{
+	return 0;
+}
 #endif
 
 #endif
-- 
1.7.8.3

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
