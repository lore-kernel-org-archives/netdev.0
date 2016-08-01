From: Quan Nguyen <qnguyen@apm.com>
Subject: Re: [PATCH net-next 08/10] drivers: net: xgene: Poll link status via
 GPIO
Date: Mon, 1 Aug 2016 12:39:35 +0700
Message-ID: <CAFopSPQfX6kQYqNieXhJ-zFH3DCGsckOdAW9DKDT7Xm16U7sOw@mail.gmail.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
 <1469838843-19943-9-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 patches <patches@apm.com>, linux@armlinux.org.uk, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1469838843-19943-9-git-send-email-isubramanian@apm.com>
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

On Sat, Jul 30, 2016 at 7:34 AM, Iyappan Subramanian
<isubramanian@apm.com> wrote:
> When 10GbE SFP+ module is not plugged in or cable is not connected,
> the link status register does not report the proper state due
> to floating signal. This patch checks the module present status via an
> GPIO to determine whether to ignore the link status register and report
> link down.
>
> Signed-off-by: Quan Nguyen <qnguyen@apm.com>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> Tested-by: Fushen Chen <fchen@apm.com>
> ---
>  drivers/net/ethernet/apm/xgene/Kconfig            |  1 +
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 15 +++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
>  drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  6 ++++++
>  4 files changed, 23 insertions(+)
>
> diff --git a/drivers/net/ethernet/apm/xgene/Kconfig b/drivers/net/ethernet/apm/xgene/Kconfig
> index 300e3b5..6c60a7d 100644
> --- a/drivers/net/ethernet/apm/xgene/Kconfig
> +++ b/drivers/net/ethernet/apm/xgene/Kconfig
> @@ -4,6 +4,7 @@ config NET_XGENE
>         depends on ARCH_XGENE || COMPILE_TEST
>         select PHYLIB
>         select MDIO_XGENE
> +       select GPIO_XGENE_SB

I think this should change to GPIOLIB as we dont expected to work with
only gpio-xgene-sb.c. Other gpio drivers should be used as well.

>         help
>           This is the Ethernet driver for the on-chip ethernet interface on the
>           APM X-Gene SoC.
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 383e7ad..bda386d 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -19,6 +19,7 @@
>   * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>   */
>
> +#include <linux/gpio.h>
>  #include "xgene_enet_main.h"
>  #include "xgene_enet_hw.h"
>  #include "xgene_enet_sgmac.h"
> @@ -1322,6 +1323,18 @@ static int xgene_enet_check_phy_handle(struct xgene_enet_pdata *pdata)
>         return 0;
>  }
>
> +static void xgene_enet_gpiod_get(struct xgene_enet_pdata *pdata)
> +{
> +       struct device *dev = &pdata->pdev->dev;
> +
> +       if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII)
> +               return;
> +
> +       pdata->sfp_rdy = gpiod_get(dev, "rxlos", GPIOD_IN);
> +       if (IS_ERR(pdata->sfp_rdy))
> +               pdata->sfp_rdy = gpiod_get(dev, "sfp", GPIOD_IN);
> +}
> +
>  static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>  {
>         struct platform_device *pdev;
> @@ -1411,6 +1424,8 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
>         if (ret)
>                 return ret;
>
> +       xgene_enet_gpiod_get(pdata);
> +
>         pdata->clk = devm_clk_get(&pdev->dev, NULL);
>         if (IS_ERR(pdata->clk)) {
>                 /* Firmware may have set up the clock already. */
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> index 53f4a16..b339fc1 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
> @@ -217,6 +217,7 @@ struct xgene_enet_pdata {
>         u8 tx_delay;
>         u8 rx_delay;
>         bool mdio_driver;
> +       struct gpio_desc *sfp_rdy;
>  };
>
>  struct xgene_indirect_ctl {
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
> index 4087dba..d672e71 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
> @@ -18,6 +18,8 @@
>   * along with this program.  If not, see <http://www.gnu.org/licenses/>.
>   */
>
> +#include <linux/of_gpio.h>
> +#include <linux/gpio.h>
>  #include "xgene_enet_main.h"
>  #include "xgene_enet_hw.h"
>  #include "xgene_enet_xgmac.h"
> @@ -399,10 +401,14 @@ static void xgene_enet_link_state(struct work_struct *work)
>  {
>         struct xgene_enet_pdata *pdata = container_of(to_delayed_work(work),
>                                          struct xgene_enet_pdata, link_work);
> +       struct gpio_desc *sfp_rdy = pdata->sfp_rdy;
>         struct net_device *ndev = pdata->ndev;
>         u32 link_status, poll_interval;
>
>         link_status = xgene_enet_link_status(pdata);
> +       if (link_status && !IS_ERR(sfp_rdy) && !gpiod_get_value(sfp_rdy))
> +               link_status = 0;
> +
>         if (link_status) {
>                 if (!netif_carrier_ok(ndev)) {
>                         netif_carrier_on(ndev);
> --
> 1.9.1
>
