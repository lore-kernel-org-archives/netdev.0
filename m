From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH 3/3] driver: net: ethernet: cpsw: dual emac interface
 implementation
Date: Sun, 14 Apr 2013 20:20:15 +0100
Message-ID: <516B016F.3020308@mimc.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <1360612340-9266-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360612340-9266-4-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/13 19:52, Mugunthan V N wrote:
> The CPSW switch can act as Dual EMAC by segregating the switch ports
> using VLAN and port VLAN as per the TRM description in
> 14.3.2.10.2 Dual Mac Mode
>
> Following CPSW components will be common for both the interfaces.
> * Interrupt source is common for both eth interfaces
> * Interrupt pacing is common for both interfaces
> * Hardware statistics is common for all the ports
> * CPDMA is common for both eth interface
> * CPTS is common for both the interface and it should not be enabled on
>    both the interface as timestamping information doesn't contain port
>    information.
>
> Constrains
> * Reserved VID of One port should not be used in other interface which will
>    enable switching functionality
> * Same VID must not be used in both the interface which will enable switching
>    functionality
>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>   Documentation/devicetree/bindings/net/cpsw.txt |    2 +
>   drivers/net/ethernet/ti/cpsw.c                 |  335 ++++++++++++++++++++----
>   include/linux/platform_data/cpsw.h             |    3 +
>   3 files changed, 288 insertions(+), 52 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index 6ddd028..ecfdf75 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
> @@ -24,6 +24,8 @@ Required properties:
>   Optional properties:
>   - ti,hwmods		: Must be "cpgmac0"
>   - no_bd_ram		: Must be 0 or 1
> +- dual_emac		: Specifies Switch to act as Dual EMAC
> +- dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
>
>   Note: "ti,hwmods" field is used to fetch the base address and irq
>   resources from TI, omap hwmod data base during device registration.
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 4b964bb..4ceed6e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c

<snip>

> @@ -1237,6 +1372,18 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   		if (mac_addr)
>   			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
>
> +		if (data->dual_emac) {
> +			if (of_property_read_u32(node, "dual_emac_res_vlan",
> +						 &prop)) {

Shouldn't this be:-

	if (of_property_read_u32(slave_node, "dual_emac_res_vlan",
                                  ^^^^^^^^^^

... so we pick each VLAN id from the individual slaves ?

Regards
Mark J.
