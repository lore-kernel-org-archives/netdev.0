From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 4 Dec 2015 02:50:57 +0100
Message-ID: <20151204015057.GB28005@lunn.ch>
References: <561FF9E2.30102@opensource.altera.com>
 <56200687.9040903@gmail.com>
 <562005AD.8020903@opensource.altera.com>
 <56200BD7.8020505@gmail.com>
 <20151203204811.GB14427@amd>
 <5660B2EC.1050705@caviumnetworks.com>
 <5660CD87.5050603@opensource.altera.com>
 <20151204011050.GC26934@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Daney <ddaney@caviumnetworks.com>,
	Pavel Machek <pavel@denx.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151204011050.GC26934@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 02:10:50AM +0100, Andrew Lunn wrote:
> > > FWIW: My initial patch to address the failure worked with the original DTB.
> > 
> > Can I ask what patch are you referring to? I was sidetracked for a while
> > on this issue, but I still see it failing as of v4.4-rc3. I'll try to
> > get back to debugging this.
> 
> Hi Dinh
> 
> There are two different patches:
> 
> https://lkml.org/lkml/2015/10/16/669
> 
> and
> 
> https://www.mail-archive.com/netdev@vger.kernel.org/msg83183.html
> 
> Although the first one works, it keeps searching up and up and up, so
> you could in theory put the phy properties a lot higher than the MAC.
> 
> The second patch restricts where it looks for the phy properties to
> only the MAC. But it does not work. We would like to understand why it
> does not work.

Hi Dinh

Please could you run this patch and let us know what it outputs.

Thanks
	Andrew

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index cf6312fafea5..d7ddc0bb0e7f 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -26,6 +26,7 @@
 #include <linux/module.h>
 #include <linux/phy.h>
 #include <linux/micrel_phy.h>
+#include <linux/netdevice.h>
 #include <linux/of.h>
 #include <linux/clk.h>
 
@@ -339,9 +340,19 @@ static int ksz9021_config_init(struct phy_device *phydev)
 {
 	const struct device *dev = &phydev->dev;
 	const struct device_node *of_node = dev->of_node;
+	const struct device *dev_walker;
 
-	if (!of_node && dev->parent->of_node)
-		of_node = dev->parent->of_node;
+	dev_info(dev, "dev->parent: %s\n", dev_name(dev->parent));
+	dev_info(dev, "phydev->attached_dev->dev: %s\n", dev_name(&phydev->attached_dev->dev));
+
+	dev_walker = &phydev->dev;
+	do {
+		of_node = dev_walker->of_node;
+		dev_info(dev, "walking: %s %p\n",
+			 dev_name(dev_walker), of_node);
+		dev_walker = dev_walker->parent;
+
+	} while (!of_node && dev_walker);
 
 	if (of_node) {
 		ksz9021_load_values_from_of(phydev, of_node,
