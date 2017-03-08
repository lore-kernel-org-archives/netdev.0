From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v4 net-next 4/6] drivers: net: xgene-v2: Add base driver
Date: Tue, 7 Mar 2017 17:22:26 -0800
Message-ID: <88abbf29-9762-b5d1-86db-291159978269@gmail.com>
References: <1488935325-13603-1-git-send-email-isubramanian@apm.com>
 <1488935325-13603-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
 netdev@vger.kernel.org, andrew@lunn.ch, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488935325-13603-5-git-send-email-isubramanian@apm.com>
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

On 03/07/2017 05:08 PM, Iyappan Subramanian wrote:
> This patch adds,
> 
>      - probe, remove, shutdown
>      - open, close and stats
>      - create and delete ring
>      - request and delete irq
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
> ---

> +	pdata->resources.phy_mode = phy_mode;
> +
> +	if (pdata->resources.phy_mode != PHY_INTERFACE_MODE_RGMII) {
> +		dev_err(dev, "Incorrect phy-connection-type specified\n");
> +		return -ENODEV;
> +	}

This does not take into account all other PHY_INTERFACE_MODE_RGMII
variants, is that really intentional here?

> +
> +	ret = platform_get_irq(pdev, 0);
> +	if (ret <= 0) {

0 can be a valid interrupt on some platforms AFAIR, so you may want to
just check < 0.

> +		dev_err(dev, "Unable to get ENET IRQ\n");
> +		ret = ret ? : -ENXIO;
> +		return ret;
> +	}
> +	pdata->resources.irq = ret;
> +

> +static int xge_request_irq(struct net_device *ndev)
> +{
> +	struct xge_pdata *pdata = netdev_priv(ndev);
> +	struct device *dev = &pdata->pdev->dev;
> +	int ret;
> +
> +	snprintf(pdata->irq_name, IRQ_ID_SIZE, "%s", ndev->name);
> +
> +	ret = devm_request_irq(dev, pdata->resources.irq, xge_irq,
> +			       0, pdata->irq_name, pdata);
> +	if (ret)
> +		netdev_err(ndev, "Failed to request irq %s\n", pdata->irq_name);

The preference for network driver is to manage the request_irq() in the
ndo_open() callback and free_irq() in the ndo_close() which kind of
defeats the purpose of using devm_* functions for that purpose.


> +static int xge_open(struct net_device *ndev)
> +{
> +	struct xge_pdata *pdata = netdev_priv(ndev);
> +	int ret;
> +
> +	ret = xge_create_desc_rings(ndev);
> +	if (ret)
> +		return ret;
> +
> +	napi_enable(&pdata->napi);
> +	ret = xge_request_irq(ndev);
> +	if (ret)
> +		return ret;
> +
> +	xge_intr_enable(pdata);
> +	xge_wr_csr(pdata, DMARXCTRL, 1);
> +	xge_mac_enable(pdata);
> +	netif_start_queue(ndev);
> +	netif_carrier_on(ndev);

Can't you use PHYLIB to get the link indication and not manage the link
state manually here? Setting netif_carrier_on() without checking the
actualy physical medium is just plain wrong/


> +static void xge_timeout(struct net_device *ndev)
> +{
> +	struct xge_pdata *pdata = netdev_priv(ndev);
> +
> +	rtnl_lock();
> +
> +	if (netif_running(ndev)) {

Reduce indention here.

> +		netif_carrier_off(ndev);
> +		netif_stop_queue(ndev);
> +		xge_intr_disable(pdata);
> +		napi_disable(&pdata->napi);
> +

> +static int xge_probe(struct platform_device *pdev)
> +{
> +	struct device *dev = &pdev->dev;
> +	struct net_device *ndev;
> +	struct xge_pdata *pdata;
> +	int ret;
> +
> +	ndev = alloc_etherdev(sizeof(struct xge_pdata));

sizeof(*pdata).
-- 
Florian
