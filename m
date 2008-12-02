From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not respected
Date: Tue, 02 Dec 2008 07:04:48 +0100
Message-ID: <4934D000.5000304@cosmosbay.com>
References: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com> <491154C8.3040401@cosmosbay.com> <492D107B.1060303@cosmosbay.com> <1227719692.13189.7.camel@HP1> <1228173819.15505.15.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753087AbYLBGFP@vger.kernel.org>
In-Reply-To: <1228173819.15505.15.camel@HP1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan a =C3=A9crit :
> On Wed, 2008-11-26 at 09:14 -0800, Michael Chan wrote:
>> On Wed, 2008-11-26 at 01:01 -0800, Eric Dumazet wrote:
>>> Eric Dumazet a =C3=A9crit :
>>>> Michael Chan a =C3=A9crit :
>>>>> I believe this may be the patch that broke it:
>>>>>
>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=3Dce6fce4295ba727b36fdc73040e444bd1aae64cd=20
>>>>>
>>>>>
>>>>> I don't remember all the details, but the Broadcom 5708 chip is
>>>>> affected because it does not support MSI per-vector masking.
>>>>>
>>>>> One way to get around is to disable MSI with bnx2 parameter
>>>>> disable_msi=3D1.
>>>>>
>>>> I tried this MSI disabling and yes, it now works.
>>>>
>>>> 16:      42726        128        105        106         89        =
=20
>>>> 89        145        152   IO-APIC-fasteoi   uhci_hcd:usb1, eth0, =
eth1
>>>>
>>> I believe the bnx2 driver doesnt work at all if !disable_msi (defau=
lt setting)
>>>
>>> Doing a "echo 0 >/sys/devices/system/cpu/cpu1/online" just freeze n=
etwork
>>>
>>> No messages logged
>>>
>>> If loaded with disable_msi=3D1, the cpu unplug works as expected.
>>>
>>> Thats a pretty serious issue.
>>>
>> Yes, that's the same issue and it is serious.  If MSI is being deliv=
ered
>> to CPU 1 and you then take CPU 1 offline, the MSI will not be delive=
red
>> to another CPU.
>>
>> I think I can detect this problem in bnx2_timer() and try to recover=
=2E
>> I'll post a patch when I have something ready.  Thanks.
>=20
> [PATCH] bnx2: Add workaround to handle missed MSI.
>=20
> The bnx2 chips do not support per MSI vector masking.  On 5706/5708, =
new MSI
> address/data are stored only when the MSI enable bit is toggled.  As =
a result,
> SMP affinity no longer works in the latest kernel.  A more serious pr=
oblem is
> that the driver will no longer receive interrupts when the MSI receiv=
ing CPU
> goes offline.
>=20
> The workaround in this patch only addresses the problem of CPU going =
offline.
> When that happens, the driver's timer function will detect that it is=
 making
> no forward progress on pending interrupt events and will recover from=
 it.
>=20
> Eric Dumazet reported the problem.
>=20
> We also found that if an interrupt is internally asserted while MSI a=
nd INTA
> are disabled, the chip will end up in the same state after MSI is re-=
enabled.
> The same workaround is needed for this problem.=20
>=20
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |   35 ++++++++++++++++++++++++++++++++---
>  drivers/net/bnx2.h |    6 ++++++
>  2 files changed, 38 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 182f241..0e2218d 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -3147,6 +3147,28 @@ bnx2_has_work(struct bnx2_napi *bnapi)
>  	return 0;
>  }
> =20
> +static void
> +bnx2_chk_missed_msi(struct bnx2 *bp)
> +{
> +	struct bnx2_napi *bnapi =3D &bp->bnx2_napi[0];
> +	u32 msi_ctrl;
> +
> +	if (bnx2_has_work(bnapi)) {
> +		msi_ctrl =3D REG_RD(bp, BNX2_PCICFG_MSI_CONTROL);
> +		if (!(msi_ctrl & BNX2_PCICFG_MSI_CONTROL_ENABLE))
> +			return;
> +
> +		if (bnapi->last_status_idx =3D=3D bp->idle_chk_status_idx) {
> +			REG_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl &
> +			       ~BNX2_PCICFG_MSI_CONTROL_ENABLE);
> +			REG_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl);
> +			bnx2_msi(bp->irq_tbl[0].vector, bnapi);
> +		}
> +	}
> +
> +	bp->idle_chk_status_idx =3D bnapi->last_status_idx;
> +}
> +
>  static void bnx2_poll_link(struct bnx2 *bp, struct bnx2_napi *bnapi)
>  {
>  	struct status_block *sblk =3D bnapi->status_blk.msi;
> @@ -3221,14 +3243,15 @@ static int bnx2_poll(struct napi_struct *napi=
, int budget)
> =20
>  		work_done =3D bnx2_poll_work(bp, bnapi, work_done, budget);
> =20
> -		if (unlikely(work_done >=3D budget))
> -			break;
> -
>  		/* bnapi->last_status_idx is used below to tell the hw how
>  		 * much work has been processed, so we must read it before
>  		 * checking for more work.
>  		 */
>  		bnapi->last_status_idx =3D sblk->status_idx;
> +
> +		if (unlikely(work_done >=3D budget))
> +			break;
> +
>  		rmb();
>  		if (likely(!bnx2_has_work(bnapi))) {
>  			netif_rx_complete(bp->dev, napi);
> @@ -4581,6 +4604,8 @@ bnx2_init_chip(struct bnx2 *bp)
>  	for (i =3D 0; i < BNX2_MAX_MSIX_VEC; i++)
>  		bp->bnx2_napi[i].last_status_idx =3D 0;
> =20
> +	bp->idle_chk_status_idx =3D 0xffff;
> +
>  	bp->rx_mode =3D BNX2_EMAC_RX_MODE_SORT_MODE;
> =20
>  	/* Set up how to generate a link change interrupt. */
> @@ -5729,6 +5754,10 @@ bnx2_timer(unsigned long data)
>  	if (atomic_read(&bp->intr_sem) !=3D 0)
>  		goto bnx2_restart_timer;
> =20
> +	if ((bp->flags & (BNX2_FLAG_USING_MSI | BNX2_FLAG_ONE_SHOT_MSI)) =3D=
=3D
> +	     BNX2_FLAG_USING_MSI)
> +		bnx2_chk_missed_msi(bp);
> +
>  	bnx2_send_heart_beat(bp);
> =20
>  	bp->stats_blk->stat_FwRxDrop =3D
> diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
> index 0763108..2f43c45 100644
> --- a/drivers/net/bnx2.h
> +++ b/drivers/net/bnx2.h
> @@ -378,6 +378,9 @@ struct l2_fhdr {
>   *  pci_config_l definition
>   *  offset: 0000
>   */
> +#define BNX2_PCICFG_MSI_CONTROL				0x00000058
> +#define BNX2_PCICFG_MSI_CONTROL_ENABLE			 (1L<<16)
> +
>  #define BNX2_PCICFG_MISC_CONFIG				0x00000068
>  #define BNX2_PCICFG_MISC_CONFIG_TARGET_BYTE_SWAP	 (1L<<2)
>  #define BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP	 (1L<<3)
> @@ -6882,6 +6885,9 @@ struct bnx2 {
> =20
>  	u8			num_tx_rings;
>  	u8			num_rx_rings;
> +
> +	u32			idle_chk_status_idx;
> +
>  };
> =20
>  #define REG_RD(bp, offset)					\

Thanks a lot Michael

I tested your patch on my machine.

I confirm CPU unplug/hotplug works now (If correcting a bug in oprofile=
 first)
NIC doesnt freeze anymore

Eric
