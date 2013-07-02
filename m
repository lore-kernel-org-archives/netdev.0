From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH V2] brcmsmac: Fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Tue, 2 Jul 2013 22:53:13 +0200
Message-ID: <51D33DB9.6020508@broadcom.com>
References: <1372781198-15218-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"Hante Meuleman" <meuleman@broadcom.com>,
	brcm80211-dev-list@broadcom.com
To: "Larry Finger" <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3511 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932160Ab3GBVNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 17:13:12 -0400
In-Reply-To: <1372781198-15218-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 06:06 PM, Larry Finger wrote:
> The driver fails to check the results of DMA mapping in twp places, which results
> in the following warning:
>
> [   28.078515] ------------[ cut here ]------------
> [   28.078529] WARNING: at lib/dma-debug.c:937 check_unmap+0x47e/0x930()
> [   28.078533] bcma-pci-bridge 0000:0e:00.0: DMA-API: device driver failed to check map error[device address=0x00000000b5d60d6c] [size=1876 bytes] [mapped as
>   single]
> [   28.078536] Modules linked in: bnep bluetooth vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) ipv6 b43 brcmsmac rtl8192cu rtl8192c_common rtlwifi mac802
> 11 brcmutil cfg80211 snd_hda_codec_conexant rng_core snd_hda_intel kvm_amd snd_hda_codec ssb kvm mmc_core snd_pcm snd_seq snd_timer snd_seq_device snd k8temp
>   cordic joydev serio_raw hwmon sr_mod sg pcmcia pcmcia_core soundcore cdrom i2c_nforce2 i2c_core forcedeth bcma snd_page_alloc autofs4 ext4 jbd2 mbcache crc1
> 6 scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh_emc scsi_dh ata_generic pata_amd
> [   28.078602] CPU: 1 PID: 2570 Comm: NetworkManager Tainted: G           O 3.10.0-rc7-wl+ #42
> [   28.078605] Hardware name: Hewlett-Packard HP Pavilion dv2700 Notebook PC/30D6, BIOS F.27 11/27/2008
> [   28.078607]  0000000000000009 ffff8800bbb03ad8 ffffffff8144f898 ffff8800bbb03b18
> [   28.078612]  ffffffff8103e1eb 0000000000000002 ffff8800b719f480 ffff8800b7b9c010
> [   28.078617]  ffffffff824204c0 ffffffff81754d57 0000000000000754 ffff8800bbb03b78
> [   28.078622] Call Trace:
> [   28.078624]  <IRQ>  [<ffffffff8144f898>] dump_stack+0x19/0x1b
> [   28.078634]  [<ffffffff8103e1eb>] warn_slowpath_common+0x6b/0xa0
> [   28.078638]  [<ffffffff8103e2c1>] warn_slowpath_fmt+0x41/0x50
> [   28.078650]  [<ffffffff8122d7ae>] check_unmap+0x47e/0x930
> [   28.078655]  [<ffffffff8122de4c>] debug_dma_unmap_page+0x5c/0x70
> [   28.078679]  [<ffffffffa04a808c>] dma64_getnextrxp+0x10c/0x190 [brcmsmac]
> [   28.078691]  [<ffffffffa04a9042>] dma_rx+0x62/0x240 [brcmsmac]
> [   28.078707]  [<ffffffffa0479101>] brcms_c_dpc+0x211/0x9d0 [brcmsmac]
> [   28.078717]  [<ffffffffa046d927>] ? brcms_dpc+0x27/0xf0 [brcmsmac]
> [   28.078731]  [<ffffffffa046d947>] brcms_dpc+0x47/0xf0 [brcmsmac]
> [   28.078736]  [<ffffffff81047dcc>] tasklet_action+0x6c/0xf0
> --snip--
> [   28.078974]  [<ffffffff813891bd>] SyS_sendmsg+0xd/0x20
> [   28.078979]  [<ffffffff81455c24>] tracesys+0xdd/0xe2
> [   28.078982] ---[ end trace 6164d1a08148e9c8 ]---
> [   28.078984] Mapped at:
> [   28.078985]  [<ffffffff8122c8fd>] debug_dma_map_page+0x9d/0x150
> [   28.078989]  [<ffffffffa04a9322>] dma_rxfill+0x102/0x3d0 [brcmsmac]
> [   28.079001]  [<ffffffffa047a13d>] brcms_c_init+0x87d/0x1100 [brcmsmac]
> [   28.079010]  [<ffffffffa046d851>] brcms_init+0x21/0x30 [brcmsmac]
> [   28.079018]  [<ffffffffa04786e0>] brcms_c_up+0x150/0x430 [brcmsmac]
>
> As the patch adds a new failure mechanism to dma_rxfill(). When I changed the
> comment at the start of the routine to add that information, I also polished
> the wording.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>
> Cc: Brett Rudley <brudley@broadcom.com>
> Cc: Arend van Spriel <arend@broadcom.com>
> Cc: Franky (Zhenhui) Lin <frankyl@broadcom.com>
> Cc: Hante Meuleman <meuleman@broadcom.com>
> Cc: brcm80211-dev-list@broadcom.com
> ---
>
> V2 - fixed two patch errors.

Hi Larry,

Are you planning to do a V3, ie. address my review comments sent earlier 
today? I can resend them if needed.

Regards,
Arend

> ---
>   drivers/net/wireless/brcm80211/brcmsmac/dma.c | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> index 1860c57..6260571 100644
> --- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> +++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
> @@ -1015,9 +1015,10 @@ static bool dma64_txidle(struct dma_info *di)
>
>   /*
>    * post receive buffers
> - *  return false is refill failed completely and ring is empty this will stall
> - *  the rx dma and user might want to call rxfill again asap. This unlikely
> - *  happens on memory-rich NIC, but often on memory-constrained dongle
> + *  return false is refill failed completely or dma mapping failed. The ring
> + *  is empty, which will stall the rx dma and user might want to call rxfill
> + *  again asap. This is unlikely to happen on a memory-rich NIC, but often on
> + *  memory-constrained dongle
>    */
>   bool dma_rxfill(struct dma_pub *pub)
>   {
> @@ -1078,6 +1079,8 @@ bool dma_rxfill(struct dma_pub *pub)
>
>   		pa = dma_map_single(di->dmadev, p->data, di->rxbufsize,
>   				    DMA_FROM_DEVICE);
> +		if (dma_mapping_error(di->dmadev, pa))
> +			return false;
>
>   		/* save the free packet pointer */
>   		di->rxp[rxout] = p;
> @@ -1284,7 +1287,8 @@ static void dma_txenq(struct dma_info *di, struct sk_buff *p)
>
>   	/* get physical address of buffer start */
>   	pa = dma_map_single(di->dmadev, data, len, DMA_TO_DEVICE);
> -
> +	if (dma_mapping_error(di->dmadev, pa))
> +		return;
>   	/* With a DMA segment list, Descriptor table is filled
>   	 * using the segment list instead of looping over
>   	 * buffers in multi-chain DMA. Therefore, EOF for SGLIST
>
