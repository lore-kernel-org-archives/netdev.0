From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/4] cxgb4/cxgb4vf: read the correct bits of PL
 Who Am I register
Date: Mon, 3 Aug 2015 15:12:38 +0300
Message-ID: <55BF5AB6.2010001@cogentembedded.com>
References: <1438620538-11421-1-git-send-email-hariprasad@chelsio.com>
 <1438620538-11421-4-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34747 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbHCMMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 08:12:38 -0400
Received: by lbqc9 with SMTP id c9so51230798lbq.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 05:12:36 -0700 (PDT)
In-Reply-To: <1438620538-11421-4-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/3/2015 7:48 PM, Hariprasad Shenai wrote:

> Read the correct bits of PL Who Am I for the Source PF field which has
> changed in T6

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 36 ++++++++++++++++++++++++-
>   drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 10 +++++--
>   drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  4 +++
>   drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c  |  4 ++-
>   4 files changed, 50 insertions(+), 4 deletions(-)

> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index d582e17..159b2a7 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4551,6 +4551,33 @@ static void free_some_resources(struct adapter *adapter)
>   		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
>   #define SEGMENT_SIZE 128
>
> +static int get_chip_type(struct pci_dev *pdev, u32 pl_rev)
> +{
> +	int ver, chip;
> +	uint16_t device_id;
> +
> +	/* Retrieve adapter's device ID
> +	 */

    Why not just a single line comment?

> +	pci_read_config_word(pdev, PCI_DEVICE_ID, &device_id);
> +	ver = device_id >> 12;
> +	switch (ver) {
> +	case CHELSIO_T4:
> +		chip |= CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
> +		break;
> +	case CHELSIO_T5:
> +		chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
> +		break;
> +	case CHELSIO_T6:
> +		chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
> +		break;

    Hum, the above 2 cases seems identical, why duplicate the code?

[...]
> @@ -4586,7 +4615,12 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>   		goto out_unmap_bar0;
>
>   	/* We control everything through one PF */
> -	func = SOURCEPF_G(readl(regs + PL_WHOAMI_A));
> +	whoami = readl(regs + PL_WHOAMI_A);
> +	pl_rev = REV_G(readl(regs + PL_REV_A));
> +	chip = get_chip_type(pdev, pl_rev);
> +	func = (CHELSIO_CHIP_VERSION(chip) <= CHELSIO_T5
> +		? SOURCEPF_G(whoami)

    Please leave the operators on the line being broken, not on the 
continuation line. Also, outer parens not needed.

> +		: T6_SOURCEPF_G(whoami));
>   	if (func != ent->driver_data) {
>   		iounmap(regs);
>   		pci_disable_device(pdev);
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> index b193295..3cd6a23 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> @@ -3529,7 +3529,10 @@ int t4_slow_intr_handler(struct adapter *adapter)
>   void t4_intr_enable(struct adapter *adapter)
>   {
>   	u32 val = 0;
> -	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
> +	u32 whoami = t4_read_reg(adapter, PL_WHOAMI_A);
> +	u32 pf = (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5
> +		  ? SOURCEPF_G(whoami)
> +		  : T6_SOURCEPF_G(whoami));

    Likewise.

[...]
> @@ -3554,7 +3557,10 @@ void t4_intr_enable(struct adapter *adapter)
>    */
>   void t4_intr_disable(struct adapter *adapter)
>   {
> -	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
> +	u32 whoami = t4_read_reg(adapter, PL_WHOAMI_A);
> +	u32 pf = (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5
> +		  ? SOURCEPF_G(whoami)
> +		  : T6_SOURCEPF_G(whoami));

    Likewise.

[...]

MBR, Sergei
