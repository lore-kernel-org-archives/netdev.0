From: David Herrmann <dh.herrmann@googlemail.com>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
Date: Fri, 9 Mar 2012 14:44:30 +0100
Message-ID: <CANq1E4Sd45FtZN6NXs7TZ1k6VrFkbcAZug-1UQwW-XPB0e5Aag@mail.gmail.com>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
	<1331136120-27075-2-git-send-email-jhovold@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: Johan Hovold <jhovold@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54909 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab2CINod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 08:44:33 -0500
In-Reply-To: <1331136120-27075-2-git-send-email-jhovold@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johan

On Wed, Mar 7, 2012 at 5:01 PM, Johan Hovold <jhovold@gmail.com> wrote:
> Do not close protocol driver until device has been unregistered.
>
> This fixes a race between tty_close and hci_dev_open which can result=
 in
> a NULL-pointer dereference.
>
> The line discipline closes the protocol driver while we may still hav=
e
> hci_dev_open sleeping on the req_lock mutex resulting in a NULL-point=
er
> dereference when lock is acquired and hci_init_req called.
>
> Bug is 100% reproducible using hciattach and a disconnected serial po=
rt:
>
> 0. # hciattach -n ttyO1 any noflow
>
> 1. hci_dev_open called from hci_power_on grabs req lock
> 2. hci_init_req executes but device fails to initialise (times out
> =A0 eventually)
> 3. hci_dev_open is called from hci_sock_ioctl and sleeps on req lock
> 4. hci_uart_tty_close detaches protocol driver and cancels init req
> 5. hci_dev_open (1) releases req lock
> 6. hci_dev_open (3) grabs req lock, calls hci_init_req, which trigger=
s oops
> =A0 when request is prepared in hci_uart_send_frame
>
> [ =A0137.201263] Unable to handle kernel NULL pointer dereference at =
virtual address 00000028
> [ =A0137.209838] pgd =3D c0004000
> [ =A0137.212677] [00000028] *pgd=3D00000000
> [ =A0137.216430] Internal error: Oops: 17 [#1]
> [ =A0137.220642] Modules linked in:
> [ =A0137.223846] CPU: 0 =A0 =A0Tainted: G =A0 =A0 =A0 =A0W =A0 =A0 (3=
=2E3.0-rc6-dirty #406)
> [ =A0137.230529] PC is at __lock_acquire+0x5c/0x1ab0
> [ =A0137.235290] LR is at lock_acquire+0x9c/0x128
> [ =A0137.239776] pc : [<c0071490>] =A0 =A0lr : [<c00733f8>] =A0 =A0ps=
r: 20000093
> [ =A0137.239776] sp : cf869dd8 =A0ip : c0529554 =A0fp : c051c730
> [ =A0137.251800] r10: 00000000 =A0r9 : cf8673c0 =A0r8 : 00000080
> [ =A0137.257293] r7 : 00000028 =A0r6 : 00000002 =A0r5 : 00000000 =A0r=
4 : c053fd70
> [ =A0137.264129] r3 : 00000000 =A0r2 : 00000000 =A0r1 : 00000000 =A0r=
0 : 00000001
> [ =A0137.270965] Flags: nzCv =A0IRQs off =A0FIQs on =A0Mode SVC_32 =A0=
ISA ARM =A0Segment kernel
> [ =A0137.278717] Control: 10c5387d =A0Table: 8f0f4019 =A0DAC: 0000001=
5
> [ =A0137.284729] Process kworker/u:1 (pid: 7, stack limit =3D 0xcf868=
2e8)
> [ =A0137.291229] Stack: (0xcf869dd8 to 0xcf86a000)
> [ =A0137.295776] 9dc0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c0529554 0=
0000000
> [ =A0137.304351] 9de0: cf8673c0 cf868000 d03ea1ef cf868000 000001ef 0=
0000470 00000000 00000002
> [ =A0137.312927] 9e00: cf8673c0 00000001 c051c730 c00716ec 0000000c 0=
0000440 c0529554 00000001
> [ =A0137.321533] 9e20: c051c730 cf868000 d03ea1f3 00000000 c053b978 0=
0000000 00000028 cf868000
> [ =A0137.330078] 9e40: 00000000 00000000 00000002 00000000 00000000 c=
00733f8 00000002 00000080
> [ =A0137.338684] 9e60: 00000000 c02a1d50 00000000 00000001 60000013 c=
0969a1c 60000093 c053b96c
> [ =A0137.347259] 9e80: 00000002 00000018 20000013 c02a1d50 cf0ac000 0=
0000000 00000002 cf868000
> [ =A0137.355834] 9ea0: 00000089 c0374130 00000002 00000000 c02a1d50 c=
f0ac000 0000000c cf0fc540
> [ =A0137.364410] 9ec0: 00000018 c02a1d50 cf0fc540 00000000 cf0fc540 c=
0282238 c028220c cf178d80
> [ =A0137.372985] 9ee0: 127525d8 c02821cc 9a1fa451 c032727c 9a1fa451 1=
27525d8 cf0fc540 cf0ac4ec
> [ =A0137.381561] 9f00: cf0ac000 cf0fc540 cf0ac584 c03285f4 c0328580 c=
f0ac4ec cf85c740 c05510cc
> [ =A0137.390136] 9f20: ce825400 c004c914 00000002 00000000 c004c884 c=
e8254f5 cf869f48 00000000
> [ =A0137.398712] 9f40: c0328580 ce825415 c0a7f914 c061af64 00000000 c=
048cf3c cf8673c0 cf85c740
> [ =A0137.407287] 9f60: c05510cc c051a66c c05510ec c05510c4 cf85c750 c=
f868000 00000089 c004d6ac
> [ =A0137.415863] 9f80: 00000000 c0073d14 00000001 cf853ed8 cf85c740 c=
004d558 00000013 00000000
> [ =A0137.424438] 9fa0: 00000000 00000000 00000000 c00516b0 00000000 0=
0000000 cf85c740 00000000
> [ =A0137.433013] 9fc0: 00000001 dead4ead ffffffff ffffffff c0551674 0=
0000000 00000000 c0450aa4
> [ =A0137.441589] 9fe0: cf869fe0 cf869fe0 cf853ed8 c005162c c0013b30 c=
0013b30 00ffff00 00ffff00
> [ =A0137.450164] [<c0071490>] (__lock_acquire+0x5c/0x1ab0) from [<c00=
733f8>] (lock_acquire+0x9c/0x128)
> [ =A0137.459503] [<c00733f8>] (lock_acquire+0x9c/0x128) from [<c03741=
30>] (_raw_spin_lock_irqsave+0x44/0x58)
> [ =A0137.469360] [<c0374130>] (_raw_spin_lock_irqsave+0x44/0x58) from=
 [<c02a1d50>] (skb_queue_tail+0x18/0x48)
> [ =A0137.479339] [<c02a1d50>] (skb_queue_tail+0x18/0x48) from [<c0282=
238>] (h4_enqueue+0x2c/0x34)
> [ =A0137.488189] [<c0282238>] (h4_enqueue+0x2c/0x34) from [<c02821cc>=
] (hci_uart_send_frame+0x34/0x68)
> [ =A0137.497497] [<c02821cc>] (hci_uart_send_frame+0x34/0x68) from [<=
c032727c>] (hci_send_frame+0x50/0x88)
> [ =A0137.507171] [<c032727c>] (hci_send_frame+0x50/0x88) from [<c0328=
5f4>] (hci_cmd_work+0x74/0xd4)
> [ =A0137.516204] [<c03285f4>] (hci_cmd_work+0x74/0xd4) from [<c004c91=
4>] (process_one_work+0x1a0/0x4ec)
> [ =A0137.525604] [<c004c914>] (process_one_work+0x1a0/0x4ec) from [<c=
004d6ac>] (worker_thread+0x154/0x344)
> [ =A0137.535278] [<c004d6ac>] (worker_thread+0x154/0x344) from [<c005=
16b0>] (kthread+0x84/0x90)
> [ =A0137.543975] [<c00516b0>] (kthread+0x84/0x90) from [<c0013b30>] (=
kernel_thread_exit+0x0/0x8)
> [ =A0137.552734] Code: e59f4e5c e5941000 e3510000 0a000031 (e5971000)
> [ =A0137.559234] ---[ end trace 1b75b31a2719ed1e ]---
>
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Johan Hovold <jhovold@gmail.com>
> ---
> =A0drivers/bluetooth/hci_ldisc.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ld=
isc.c
> index 0711448..6946081 100644
> --- a/drivers/bluetooth/hci_ldisc.c
> +++ b/drivers/bluetooth/hci_ldisc.c
> @@ -310,11 +310,11 @@ static void hci_uart_tty_close(struct tty_struc=
t *tty)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_uart_close(hdev);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_and_clear_bit(HCI_UART_PROTO_=
SET, &hu->flags)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hdev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_un=
register_dev(hdev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_fr=
ee_dev(hdev);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0}

I can confirm this. hci_uart_set_proto() opens the proto before it
registers the hci device. Hence, we should also unregister the hci
device before closing the proto. I also looked whether this introduces
other race conditions but no proto-callback can be called here as they
are all protected by the tty-layer which synchronizes all
tty-callbacks. Therefore, I think this is the correct fix.

We can apply this to stable even without the "destruct"-fixes from me
as hu->proto->$cb$() doesn't care whether hdev is valid or not. I
don't think the destruct-fixes are important enough to send them to
stable.

Reviewed-by: David Herrmann <dh.herrmann@googlemail.com>

Regards
David

> --
> 1.7.8.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluet=
ooth" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
