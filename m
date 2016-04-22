From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net v2 2/3] drivers: net: cpsw: fix error messages when
 using phy-handle DT property
Date: Fri, 22 Apr 2016 16:03:34 +0300
Message-ID: <571A2126.2060708@ti.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
 <1461263172-10428-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
 devicetree@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
 Nicolas Chauvet <kwizart@gmail.com>, linux-kernel@vger.kernel.org,
 Andrew Goodbody <andrew.goodbody@cambrionix.com>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
 <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>, Rob Herring
 <robh+dt@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461263172-10428-1-git-send-email-drivshin.allworx@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 04/21/2016 09:26 PM, David Rivshin (Allworx) wrote:
> From: David Rivshin <drivshin@allworx.com>
> 
> The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
> and only one need be specified. However if phy-handle was specified, an
> error message would complain about the lack of phy_id or fixed-link.
> 
> Also, if phy-handle was specified and the subsequent of_phy_connect()
> failed, the error message still referenced slaved->data->phy_id, which
> would be empty. Instead, use the name of the device_node as a useful
> identifier.
> 
> Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
> Signed-off-by: David Rivshin <drivshin@allworx.com>
> Acked-by: Rob Herring <robh@kernel.org>
> Tested-by: Nicolas Chauvet <kwizart@gmail.com>
> ---
> If would like this for -stable it should apply cleanly as far back
> as 4.5. It failes on 4.4 due to some context differences, but can be
> applied with 'git am -C2'. Or, I can produce a separate patch against
> linux-4.4.y if preferred.
> 
> Changes since v1 [1]:
> - Rebased (no conflicts)
> - Added Tested-by from Nicolas Chauvet
> - Added Acked-by from Rob Herring for the binding change
> 
> [1] https://patchwork.ozlabs.org/patch/560324/
> 
>   Documentation/devicetree/bindings/net/cpsw.txt |  4 ++--
>   drivers/net/ethernet/ti/cpsw.c                 | 17 +++++++++++++----
>   2 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index 28a4781..3033c0f 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -46,16 +46,16 @@ Optional properties:
>   - dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
>   - mac-address		: See ethernet.txt file in the same directory
>   - phy_id		: Specifies slave phy id

May be the "phy_id" can be marked as deprecated? (while here)
The recommended property now is "phy-handle".

>   - phy-handle		: See ethernet.txt file in the same directory
>   
>   Slave sub-nodes:
>   - fixed-link		: See fixed-link.txt file in the same directory
> -			  Either the property phy_id, or the sub-node
> -			  fixed-link can be specified
> +
> +Note: Exactly one of phy_id, phy-handle, or fixed-link must be specified.
>   
>   Note: "ti,hwmods" field is used to fetch the base address and irq
>   resources from TI, omap hwmod data base during device registration.
>   Future plan is to migrate hwmod data base contents into device tree
>   blob so that, all the required data will be used from device tree dts
>   file.
>   
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index d69cb3f..3c81413 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1150,16 +1150,19 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>   	if (slave->data->phy_node)
>   		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
>   				 &cpsw_adjust_link, 0, slave->data->phy_if);
>   	else
>   		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
>   				 &cpsw_adjust_link, slave->data->phy_if);
>   	if (IS_ERR(slave->phy)) {
> -		dev_err(priv->dev, "phy %s not found on slave %d\n",
> -			slave->data->phy_id, slave->slave_num);
> +		dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
> +			slave->data->phy_node ?
> +				slave->data->phy_node->full_name :
> +				slave->data->phy_id,
> +			slave->slave_num);

Unfortunately,  there are some inconsistency between legacy and FDT API :(
of_phy_connect() will return valid phy_device or NULL, but phy_connect()
can return valid phy_device or ERR_PTR().



>   		slave->phy = NULL;
>   	} else {
>   		phy_attached_info(slave->phy);
>   
>   		phy_start(slave->phy);
>   
>   		/* Configure GMII_SEL register */
> @@ -2030,15 +2033,19 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   		/* This is no slave child node, continue */
>   		if (strcmp(slave_node->name, "slave"))
>   			continue;
>   
>   		slave_data->phy_node = of_parse_phandle(slave_node,
>   							"phy-handle", 0);
>   		parp = of_get_property(slave_node, "phy_id", &lenp);
> -		if (of_phy_is_fixed_link(slave_node)) {
> +		if (slave_data->phy_node) {
> +			dev_dbg(&pdev->dev,
> +				"slave[%d] using phy-handle=\"%s\"\n",
> +				i, slave_data->phy_node->full_name);
> +		} else if (of_phy_is_fixed_link(slave_node)) {
>   			struct device_node *phy_node;
>   			struct phy_device *phy_dev;
>   
>   			/* In the case of a fixed PHY, the DT node associated
>   			 * to the PHY is the Ethernet MAC DT node.
>   			 */
>   			ret = of_phy_register_fixed_link(slave_node);
> @@ -2067,15 +2074,17 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   			if (!mdio) {
>   				dev_err(&pdev->dev, "Missing mdio platform device\n");
>   				return -EINVAL;
>   			}
>   			snprintf(slave_data->phy_id, sizeof(slave_data->phy_id),
>   				 PHY_ID_FMT, mdio->name, phyid);
>   		} else {
> -			dev_err(&pdev->dev, "No slave[%d] phy_id or fixed-link property\n", i);
> +			dev_err(&pdev->dev,
> +				"No slave[%d] phy_id, phy-handle, or fixed-link property\n",
> +				i);
>   			goto no_phy_slave;
>   		}
>   		slave_data->phy_if = of_get_phy_mode(slave_node);
>   		if (slave_data->phy_if < 0) {
>   			dev_err(&pdev->dev, "Missing or malformed slave[%d] phy-mode property\n",
>   				i);
>   			return slave_data->phy_if;
> 


-- 
regards,
-grygorii
