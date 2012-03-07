From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH] stmmac: Allow stmmac to work with other PHY buses(v2).
Date: Wed, 07 Mar 2012 08:08:44 +0000
Message-ID: <4F57178C.7010407@st.com>
References: <1331012520-19574-1-git-send-email-peppe.cavallaro@st.com> <20120306.165703.277843706808689044.davem@davemloft.net>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090006050205030806090209"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:33138 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754022Ab2CGIRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:17:45 -0500
In-Reply-To: <20120306.165703.277843706808689044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090006050205030806090209
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue,  6 Mar 2012 06:42:00 +0100
>
>   
>> After commit "db8857b stmmac: use an unique MDIO bus name" and "90b9a54
>> stmmac: fix phy naming inconsistency" stmmac cant work with other MDIO
>> buses, because mdio_bus name is fixed in the dirver.
>>     
>
> This sounds inaccurate, you're making it sound like these commits
> introduced this limitation, as far as I can tell they did not.
>
>   
Thanks for your comments,

Commit comment is true to some extent, before "db8857b stmmac: use an
unique MDIO bus name" and "a77e929 mdio-gpio: use an unique MDIO bus
name" we managed to get stmmac use mdio bus by specifying same id in
platform data of both the drivers.
However after these commits this method was no more possible because
stmmac can connect to phys on stmmac-x mdio buses Only.

I think, originally the problem was in stmmac to some extent which
became worse after adding prefix mdio bus.
Here is the new patch removing the misleading comments.


> Before the MDIO bus name was just plain "%x" and the bus_id number
> was placed there.  Then it became the same thing, except with some
> (potentially fixed) prefix.
>
> Nothing about that change makes any difference whatsoever about
> what you're modifications are trying to allow.
>
> BTW, also, commit "90b9a54" is ambiguous.
>
>   
Actual commit was : 90b9a5454fd2e626aa1614fe9ece6b63a0dc37af

Thanks,
srini
> [davem@bql net]$ git show 90b9a54
> error: short SHA1 90b9a54 is ambiguous.
> error: short SHA1 90b9a54 is ambiguous.
> fatal: ambiguous argument '90b9a54': unknown revision or path not in the working tree.
>   


--------------090006050205030806090209
Content-Type: text/x-patch;
 name="0001-stmmac-Allow-stmmac-to-work-with-other-PHY-buses-v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-stmmac-Allow-stmmac-to-work-with-other-PHY-buses-v3.pat";
 filename*1="ch"

>From 1f10d82e8d2df8d5b86595954dcb4e3c2cab9011 Mon Sep 17 00:00:00 2001
From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Date: Thu, 1 Mar 2012 09:40:12 +0000
Subject: [PATCH 3.3.0-rc4] stmmac: Allow stmmac to work with other PHY buses(v3).

As stmmac mdio bus name prefix is hardcoded in the driver, this allows
only phys on stmmac mdio buses to connect, however stmmac should allow
phys on other mdio buses too.

This patch adds new variable phy_bus_name to plat_stmmacenet_data
struct to let the BSP decide which phy bus to be used by stmmac driver.
A typical use-case is to have generic MDIO buses like mdio-gpio on top
of stmmac.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 +++++++-
 include/linux/stmmac.h                            |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6ee593a..da891ef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -307,7 +307,13 @@ static int stmmac_init_phy(struct net_device *dev)
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x", priv->plat->bus_id);
+	if (priv->plat->phy_bus_name)
+		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+				priv->plat->phy_bus_name, priv->plat->bus_id);
+	else
+		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
+				priv->plat->bus_id);
+
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..172b5e1 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -39,6 +39,7 @@ struct stmmac_mdio_bus_data {
 };
 
 struct plat_stmmacenet_data {
+	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
-- 
1.6.3.3


--------------090006050205030806090209--
