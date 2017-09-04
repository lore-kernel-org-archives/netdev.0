From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] net: mdio-mux: add mdio_mux parameter to
 mdio_mux_init()
Date: Mon, 4 Sep 2017 10:00:35 -0700
Message-ID: <db7325bd-aee0-a920-a60c-6ce113f833c0@gmail.com>
References: <20170904163014.955-1-clabbe.montjoie@gmail.com>
 <20170904163014.955-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, andrew@lunn.ch,
        rjui@broadcom.com, sbranden@broadcom.com, jonmason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170904163014.955-2-clabbe.montjoie@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/2017 09:30 AM, Corentin Labbe wrote:
> mdio_mux_init() use the parameter dev for two distinct thing:
> 1) Have a device for all devm_ functions
> 2) Get device_node from it
> 
> Since it is two distinct purpose, this patch add a parameter mdio_mux
> that is linked to task 2.
> 
> This will also permit to register an of_node mdio-mux that lacks a direct
> owning device.
> For example a mdio-mux which is a subnode of a real device.

This looks fine, I was going to suggest introducing a wrapper around
mdio_mux_init() which does something along the lines below, but
considering the number of users of mdio_mux_init() within the kernel
tree, it's reasonably easy to audit those, therefore:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

diff --git a/include/linux/mdio-mux.h b/include/linux/mdio-mux.h
index 61f5b21b31c7..0316186c91b5 100644
--- a/include/linux/mdio-mux.h
+++ b/include/linux/mdio-mux.h
@@ -12,11 +12,19 @@
 #include <linux/device.h>
 #include <linux/phy.h>

-int mdio_mux_init(struct device *dev,
-                 int (*switch_fn) (int cur, int desired, void *data),
-                 void **mux_handle,
-                 void *data,
-                 struct mii_bus *mux_bus);
+int mdio_mux_init_dn(struct device *dev, struct device_node *mux_node,
+                    int (*switch_fn)(int cur, int desired, void *data),
+                    void **mux_handle, void *data,
+                    struct mii_bus *mux_bus);
+
+static inline int mdio_mux_init(struct device *dev,
+                               int (*switch_fn)(int cur, int desired,
void *data),
+                               void **mux_handle, void *data,
+                               struct mii_bus *mux_bus)
+{
+       return mdio_mux_init_dn(dev, dev->of_node, switch_fn,
+                               mux_handle, data, mux_bus);
+}

> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/phy/mdio-mux-bcm-iproc.c | 2 +-
>  drivers/net/phy/mdio-mux-gpio.c      | 2 +-
>  drivers/net/phy/mdio-mux-mmioreg.c   | 3 ++-
>  drivers/net/phy/mdio-mux.c           | 7 ++++---
>  include/linux/mdio-mux.h             | 9 +++++++++
>  5 files changed, 17 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio-mux-bcm-iproc.c b/drivers/net/phy/mdio-mux-bcm-iproc.c
> index 0a5f62e0efcc..0831b7142df7 100644
> --- a/drivers/net/phy/mdio-mux-bcm-iproc.c
> +++ b/drivers/net/phy/mdio-mux-bcm-iproc.c
> @@ -199,7 +199,7 @@ static int mdio_mux_iproc_probe(struct platform_device *pdev)
>  
>  	platform_set_drvdata(pdev, md);
>  
> -	rc = mdio_mux_init(md->dev, mdio_mux_iproc_switch_fn,
> +	rc = mdio_mux_init(md->dev, md->dev->of_node, mdio_mux_iproc_switch_fn,
>  			   &md->mux_handle, md, md->mii_bus);
>  	if (rc) {
>  		dev_info(md->dev, "mdiomux initialization failed\n");
> diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> index 919949960a10..082ffef0dec4 100644
> --- a/drivers/net/phy/mdio-mux-gpio.c
> +++ b/drivers/net/phy/mdio-mux-gpio.c
> @@ -54,7 +54,7 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
>  	if (IS_ERR(s->gpios))
>  		return PTR_ERR(s->gpios);
>  
> -	r = mdio_mux_init(&pdev->dev,
> +	r = mdio_mux_init(&pdev->dev, pdev->dev.of_node,
>  			  mdio_mux_gpio_switch_fn, &s->mux_handle, s, NULL);
>  
>  	if (r != 0) {
> diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
> index c3825c7da038..2573ab012f16 100644
> --- a/drivers/net/phy/mdio-mux-mmioreg.c
> +++ b/drivers/net/phy/mdio-mux-mmioreg.c
> @@ -159,7 +159,8 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
>  		}
>  	}
>  
> -	ret = mdio_mux_init(&pdev->dev, mdio_mux_mmioreg_switch_fn,
> +	ret = mdio_mux_init(&pdev->dev, pdev->dev.of_node,
> +			    mdio_mux_mmioreg_switch_fn,
>  			    &s->mux_handle, s, NULL);
>  	if (ret) {
>  		dev_err(&pdev->dev, "failed to register mdio-mux bus %pOF\n",
> diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
> index 6f75e9f27fed..0a86f1e4c02f 100644
> --- a/drivers/net/phy/mdio-mux.c
> +++ b/drivers/net/phy/mdio-mux.c
> @@ -86,6 +86,7 @@ static int mdio_mux_write(struct mii_bus *bus, int phy_id,
>  static int parent_count;
>  
>  int mdio_mux_init(struct device *dev,
> +		  struct device_node *mux_node,
>  		  int (*switch_fn)(int cur, int desired, void *data),
>  		  void **mux_handle,
>  		  void *data,
> @@ -98,11 +99,11 @@ int mdio_mux_init(struct device *dev,
>  	struct mdio_mux_parent_bus *pb;
>  	struct mdio_mux_child_bus *cb;
>  
> -	if (!dev->of_node)
> +	if (!mux_node)
>  		return -ENODEV;
>  
>  	if (!mux_bus) {
> -		parent_bus_node = of_parse_phandle(dev->of_node,
> +		parent_bus_node = of_parse_phandle(mux_node,
>  						   "mdio-parent-bus", 0);
>  
>  		if (!parent_bus_node)
> @@ -132,7 +133,7 @@ int mdio_mux_init(struct device *dev,
>  	pb->mii_bus = parent_bus;
>  
>  	ret_val = -ENODEV;
> -	for_each_available_child_of_node(dev->of_node, child_bus_node) {
> +	for_each_available_child_of_node(mux_node, child_bus_node) {
>  		int v;
>  
>  		r = of_property_read_u32(child_bus_node, "reg", &v);
> diff --git a/include/linux/mdio-mux.h b/include/linux/mdio-mux.h
> index 61f5b21b31c7..a5d58f221939 100644
> --- a/include/linux/mdio-mux.h
> +++ b/include/linux/mdio-mux.h
> @@ -12,7 +12,16 @@
>  #include <linux/device.h>
>  #include <linux/phy.h>
>  
> +/* mdio_mux_init() - Initialize a MDIO mux
> + * @dev		The device owning the MDIO mux
> + * @mux_node	The device node of the MDIO mux
> + * @switch_fn	The function called for switching target MDIO child
> + * mux_handle	A pointer to a (void *) used internaly by mdio-mux
> + * @data	Private data used by switch_fn()
> + * @mux_bus	An optional parent bus (Other case are to use parent_bus property)
> + */
>  int mdio_mux_init(struct device *dev,
> +		  struct device_node *mux_node,
>  		  int (*switch_fn) (int cur, int desired, void *data),
>  		  void **mux_handle,
>  		  void *data,
> 

-- 
Florian
