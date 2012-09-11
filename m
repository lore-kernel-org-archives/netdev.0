From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 01/12] qlcnic: Refactoring - template based hardware interface
Date: Tue, 11 Sep 2012 08:01:06 +0200
Message-ID: <20120911060106.GB6842@electric-eye.fr.zoreil.com>
References: <1347326403-1705-1-git-send-email-sony.chacko@qlogic.com> <1347326403-1705-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59299 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637Ab2IKGSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 02:18:36 -0400
Content-Disposition: inline
In-Reply-To: <1347326403-1705-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sony Chacko <sony.chacko@qlogic.com> :
> Modify 82xx driver to support new adapter - Qlogic 83XX CNA
> Separate adapter specific hardware accesses routines
> Create template based hardware interface
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   67 ++++-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    4 +-
>  .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   32 ++-
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   55 +---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  125 ++++++--
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   36 +++
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    1 +
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  309 +++++++++-----------
>  8 files changed, 359 insertions(+), 270 deletions(-)
>  create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> index eaa1db9..a4ae965 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> @@ -439,6 +439,8 @@ struct qlcnic_fw_dump {
>  	struct	qlcnic_dump_template_hdr *tmpl_hdr;
>  };
>  
> +struct qlcnic_hardware_ops;
> +

qlcnic_hardware_ops is defined in this same file and it only uses
pointers to yet unknown types. You can define it here.

[...]
> @@ -552,8 +556,9 @@ struct qlcnic_recv_context {
>  /* HW context creation */
>  
>  #define QLCNIC_OS_CRB_RETRY_COUNT	4000
> -#define QLCNIC_CDRP_SIGNATURE_MAKE(pcifn, version) \
> -	(((pcifn) & 0xff) | (((version) & 0xff) << 8) | (0xcafe << 16))
> +#define QLCNIC_CDRP_SIGNATURE_MAKE(ahw)					\
> +	(((ahw->pci_func) & 0xff) | (((ahw->fw_hal_version) &		\
> +	0xff) << 8) | (0xcafe << 16))

It could be a proper function and it could belong to the (only) file where
it is actually used (once).

[...]
> +static inline void
> +qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
> +		loff_t offset, size_t size)

?

static inline void qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
				   loff_t offset, size_t size)

[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> index 9e9e78a..c81fcf8 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
[...]
> @@ -603,8 +608,7 @@ qlcnic_set_pauseparam(struct net_device *netdev,
>  		else
>  			qlcnic_gb_unset_rx_flowctl(val);
>  
> -		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port),
> -				val);
> +		QLCWR32(adapter, QLCNIC_NIU_GB_MAC_CONFIG_0(port), val);

This change does not fit the patch description.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
> index 28a6b28..0bee9f7 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
[...]

Most of the changes in this file does not fit the patch description.

You could as well make a separate patch dedicated to removing unused stuff.

5...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
> index b528e52..ee4cd43 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
[...]
> @@ -880,7 +889,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
>  	m = &crb_128M_2M_map[CRB_BLK(off)].sub_block[CRB_SUBBLK(off)];
>  
>  	if (m->valid && (m->start_128M <= off) && (m->end_128M > off)) {
> -		*addr = adapter->ahw->pci_base0 + m->start_2M +
> +		*addr = ahw->pci_base0 + m->start_2M +
>  			(off - m->start_128M);

		*addr = ahw->pci_base0 + m->start_2M + off - m->start_128M;

[...]
> @@ -1105,7 +1116,7 @@ correct:
>  	i = 0;
>  	writel(TA_CTL_ENABLE, (mem_crb + TEST_AGT_CTRL));
>  	writel((TA_CTL_START | TA_CTL_ENABLE),
> -			(mem_crb + TEST_AGT_CTRL));
> +	       (mem_crb + TEST_AGT_CTRL));

  	writel(TA_CTL_START | TA_CTL_ENABLE, mem_crb + TEST_AGT_CTRL);

The topic of the patch does not ask for a change here and these lines
don't even appear in the context diff of such changes. It could be
isolated in a separate patch (where you would probably be suggested to
remove the useless parenthesis in "(TA_CTL_START | TA_CTL_ENABLE)" as well).

[...]
> @@ -1786,3 +1800,54 @@ error:
>  	vfree(fw_dump->data);
>  	return -EINVAL;
>  }
> +
> +void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
> +{
> +	void __iomem *msix_base_addr;
> +	u32 func;
> +	u32 msix_base;
> +
> +	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
> +	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
> +	msix_base = readl(msix_base_addr);
> +	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
> +	adapter->ahw->pci_func = func;
> +}

It is not used in this patch. #2 adds a declaration for it in qlcnic.h, a
function pointer for it in qlcnic_hardware_ops, then uses it. #5 renames
it to qlcnic_82xx_get_func_no.

Reviewers won't complain if you keep the patchset at the smallest size
for a given set of changes, especially as the qlcnic_82xx_ prefix is
used a few lines below.

> +
> +void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
> +{
> +	u32 addr;
> +
> +	addr = QLCNIC_PCIX_PS_REG(PCIX_OCM_WINDOW_REG(ahw->pci_func));
> +	ahw->ocm_win_crb = qlcnic_get_ioaddr(ahw, addr);
> +}

Either it's hidden behind some clever macro or it isn't used at all in
the whole patchset.

> +
> +void qlcnic_82xx_read_crb(struct qlcnic_adapter *adapter, char *buf,
> +			   loff_t offset, size_t size)
> +{
> +	u32 data;
> +	u64 qmdata;
> +
> +	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
> +		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
> +		memcpy(buf, &qmdata, size);
> +	} else {
> +		data = QLCRD32(adapter, offset);
> +		memcpy(buf, &data, size);
> +	}
> +}

Nit: reduce the scope of data and qmdata.

[...]
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
> new file mode 100644
> index 0000000..7dab9e2
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
> @@ -0,0 +1,36 @@
> +#ifndef __QLCNIC_HW_H
> +#define __QLCNIC_HW_H
> +
> +#include "qlcnic.h"
> +
> +/* List of PCI device IDs */
> +#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
> +#define QLCNIC_P3P_BAR0_LENGTH		0x00200000UL
> +
> +#define QLCNIC_BAR_LENGTH(dev_id, bar)			\
> +do {							\
> +	if (dev_id == PCI_DEVICE_ID_QLOGIC_QLE824X)\
> +		*bar = QLCNIC_P3P_BAR0_LENGTH;		\
> +	else						\
> +		*bar = 0;				\
> +} while (0)

It is used only once in the whole patchset.

> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
> index 0bcda9c..350bf79 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
[...]
> @@ -343,9 +312,9 @@ static const struct net_device_ops qlcnic_netdev_failed_ops = {
>  };
>  
>  static struct qlcnic_nic_template qlcnic_ops = {
> -	.config_bridged_mode = qlcnic_config_bridged_mode,
> -	.config_led = qlcnic_config_led,
> -	.start_firmware = qlcnic_start_firmware
> +	.config_bridged_mode = qlcnic_82xx_config_bridged_mode,
> +	.config_led = qlcnic_82xx_config_led,
> +	.start_firmware = qlcnic_82xx_start_firmware
>  };

You should really consider aligning as:

static struct qlcnic_nic_template qlcnic_ops = {
	.config_bridged_mode	= qlcnic_82xx_config_bridged_mode,
	.config_led		= qlcnic_82xx_config_led,
	.start_firmware		= qlcnic_82xx_start_firmware
};


(off to work)

-- 
Ueimor
