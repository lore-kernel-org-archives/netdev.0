From: Xander Hover <lkml@hover.be>
Subject: Re: softirq oops from b44_poll
Date: Tue, 22 Nov 2011 14:43:33 +0100
Message-ID: <CAJfGthT1Fbez_oyfjepo8gdh4BFhpfUPAX45aeRe+8dMd=Ku=Q@mail.gmail.com>
References: <CAJfGthSxanFbL2vKCpOQbP9K5oNAxeaYt7OMdmdoCb4eLQ_Fww@mail.gmail.com>
	<1321917453.10276.3.camel@pjaxe>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321917453.10276.3.camel@pjaxe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested on 3.1.1 and 3.2_rc2+ now.
=46ix is working as expected.

Kind regards,

Xander Hover


On Tue, Nov 22, 2011 at 12:17 AM, Peter P Waskiewicz Jr
<peter.p.waskiewicz.jr@intel.com> wrote:
> On Mon, 2011-11-21 at 05:58 -0800, Xander Hover wrote:
>> Hi all,
>>
>> I noticed the small discussion about the b44_poll OOPS and
>> I also have a uni-processor PC with a broadcom network device (b44)
>> that causes similar kernel OOPSes.
>>
>> Here is a (reproducible) trace that still shows up in kernel 3.1.1:
>>
>> =A0------------[ cut here ]------------
>> =A0 =A0 WARNING: at kernel/softirq.c:159 local_bh_enable+0x32/0x79()
>> =A0 =A0 Hardware name: Dimension 2400
>> =A0 =A0 Modules linked in: snd_seq_midi snd_emu10k1_synth snd_emux_s=
ynth
>> snd_seq_virmidi snd_seq_midi_emul snd_seq_oss snd_seq_midi_event
>> snd_seq snd_pcm_oss snd_mixer_oss bnep rfcomm cryptd aes_i586
>> aes_generic ecb btusb bluetooth rfkill ppdev snd_emu10k1 snd_rawmidi
>> snd_ac97_codec ac97_bus snd_pcm snd_seq_device snd_timer
>> snd_page_alloc dcdbas snd_util_mem parport_pc snd_hwdep snd parport
>> emu10k1_gp rtc_cmos gameport i2c_i801
>> =A0 =A0 Pid: 0, comm: swapper Not tainted 3.1.1-gentoo #1
>> =A0 =A0 Call Trace:
>> =A0 =A0 =A0[<c1022970>] warn_slowpath_common+0x65/0x7a
>> =A0 =A0 =A0[<c102699e>] ? local_bh_enable+0x32/0x79
>> =A0 =A0 =A0[<c1022994>] warn_slowpath_null+0xf/0x13
>> =A0 =A0 =A0[<c102699e>] local_bh_enable+0x32/0x79
>> =A0 =A0 =A0[<c134bfd8>] destroy_conntrack+0x7c/0x9b
>> =A0 =A0 =A0[<c134890b>] nf_conntrack_destroy+0x1f/0x26
>> =A0 =A0 =A0[<c132e3a6>] skb_release_head_state+0x74/0x83
>> =A0 =A0 =A0[<c132e286>] __kfree_skb+0xb/0x6b
>> =A0 =A0 =A0[<c132e30a>] consume_skb+0x24/0x26
>> =A0 =A0 =A0[<c127c925>] b44_poll+0xaa/0x449
>> =A0 =A0 =A0[<c1333ca1>] net_rx_action+0x3f/0xea
>> =A0 =A0 =A0[<c1026a44>] __do_softirq+0x5f/0xd5
>> =A0 =A0 =A0[<c10269e5>] ? local_bh_enable+0x79/0x79
>> =A0 =A0 =A0<IRQ> =A0[<c1026c32>] ? irq_exit+0x34/0x8d
>> =A0 =A0 =A0[<c1003628>] ? do_IRQ+0x74/0x87
>> =A0 =A0 =A0[<c13f5329>] ? common_interrupt+0x29/0x30
>> =A0 =A0 =A0[<c1006e18>] ? default_idle+0x29/0x3e
>> =A0 =A0 =A0[<c10015a7>] ? cpu_idle+0x2f/0x5d
>> =A0 =A0 =A0[<c13e91c5>] ? rest_init+0x79/0x7b
>> =A0 =A0 =A0[<c15c66a9>] ? start_kernel+0x297/0x29c
>> =A0 =A0 =A0[<c15c60b0>] ? i386_start_kernel+0xb0/0xb7
>> =A0 =A0 ---[ end trace 583f33bb1aa207a9 ]---
>>
>>
>> However if I apply the following patch this error does not show up a=
nymore:
>>
>>
>> diff --git a/drivers/net/ethernet/broadcom/b44.c
>> b/drivers/net/ethernet/broadcom/b44.c
>> index 4cf835d..3fb66d0 100644
>> --- a/drivers/net/ethernet/broadcom/b44.c
>> +++ b/drivers/net/ethernet/broadcom/b44.c
>> @@ -608,7 +608,7 @@ static void b44_tx(struct b44 *bp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s=
kb->len,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0D=
MA_TO_DEVICE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->skb =3D NULL;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_irq(skb);
>
> I suspect the "right" way to fix this is to call dev_kfree_skb_any(sk=
b);
> instead, since that will handle the in-interrupt case if that's where
> we're stuck.
>
> Can you try this patch (compile-tested only) and see if fixes the iss=
ue
> you're seeing:
>
> commit e36ef2c1a2b6b517ed43254eb89768794a049b1c
> Author: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: =A0 Mon Nov 21 15:14:18 2011 -0800
>
> b44: Use dev_kfree_skb_any() in b44_tx()
>
> Reported issues when using dev_kfree_skb() on UP systems and
> systems with low numbers of cores. =A0dev_kfree_skb_any() will
> properly save IRQ state before freeing the skb, depending on
> how b44_tx() is invoked.
>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com=
>
> ---
>
> =A0drivers/net/ethernet/broadcom/b44.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
>
> diff --git a/drivers/net/ethernet/broadcom/b44.c
> b/drivers/net/ethernet/broadcom/b44.c
> index 4cf835d..6a7c39b 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -608,7 +608,7 @@ static void b44_tx(struct b44 *bp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->=
len,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 DMA_T=
O_DEVICE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->skb =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb_any(skb);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0bp->tx_cons =3D cons;
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
