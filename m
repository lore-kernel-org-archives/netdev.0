From: David Herrmann <dh.herrmann@googlemail.com>
Subject: Re: [PATCH 2/2 v2] bluetooth: hci_core: fix NULL-pointer dereference
 at unregister
Date: Fri, 9 Mar 2012 15:04:11 +0100
Message-ID: <CANq1E4Rt0ctZ5cpXipJE--YmkR4OjKBXLBQkeTKWP3+Q-q37Yw@mail.gmail.com>
References: <1331228606.14217.5.camel@aeonflux>
	<1331297594-13332-1-git-send-email-jhovold@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: Johan Hovold <jhovold@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331297594-13332-1-git-send-email-jhovold@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johan

On Fri, Mar 9, 2012 at 1:53 PM, Johan Hovold <jhovold@gmail.com> wrote:
> Make sure hci_dev_open returns immediately if hci_dev_unregister has
> been called.
>
> This fixes a race between hci_dev_open and hci_dev_unregister which c=
an
> lead to a NULL-pointer dereference.
>
> Bug is 100% reproducible using hciattach and a disconnected serial po=
rt:
>
> 0. # hciattach -n /dev/ttyO1 any noflow
>
> 1. hci_dev_open called from hci_power_on grabs req lock
> 2. hci_init_req executes but device fails to initialise (times out
> =A0 eventually)
> 3. hci_dev_open is called from hci_sock_ioctl and sleeps on req lock
> 4. hci_uart_tty_close calls hci_dev_unregister and sleeps on req lock=
 in
> =A0 hci_dev_do_close
> 5. hci_dev_open (1) releases req lock
> 6. hci_dev_do_close grabs req lock and returns as device is not up
> 7. hci_dev_unregister sleeps in destroy_workqueue
> 8. hci_dev_open (3) grabs req lock, calls hci_init_req and eventually=
 sleeps
> 9. hci_dev_unregister finishes, while hci_dev_open is still running..=
=2E
>
> [ =A0 79.627136] INFO: trying to register non-static key.
> [ =A0 79.632354] the code is fine but needs lockdep annotation.
> [ =A0 79.638122] turning off the locking correctness validator.
> [ =A0 79.643920] [<c00188bc>] (unwind_backtrace+0x0/0xf8) from [<c007=
29c4>] (__lock_acquire+0x1590/0x1ab0)
> [ =A0 79.653594] [<c00729c4>] (__lock_acquire+0x1590/0x1ab0) from [<c=
00733f8>] (lock_acquire+0x9c/0x128)
> [ =A0 79.663085] [<c00733f8>] (lock_acquire+0x9c/0x128) from [<c0040a=
88>] (run_timer_softirq+0x150/0x3ac)
> [ =A0 79.672668] [<c0040a88>] (run_timer_softirq+0x150/0x3ac) from [<=
c003a3b8>] (__do_softirq+0xd4/0x22c)
> [ =A0 79.682281] [<c003a3b8>] (__do_softirq+0xd4/0x22c) from [<c003a9=
24>] (irq_exit+0x8c/0x94)
> [ =A0 79.690856] [<c003a924>] (irq_exit+0x8c/0x94) from [<c0013a50>] =
(handle_IRQ+0x34/0x84)
> [ =A0 79.699157] [<c0013a50>] (handle_IRQ+0x34/0x84) from [<c0008530>=
] (omap3_intc_handle_irq+0x48/0x4c)
> [ =A0 79.708648] [<c0008530>] (omap3_intc_handle_irq+0x48/0x4c) from =
[<c037499c>] (__irq_usr+0x3c/0x60)
> [ =A0 79.718048] Exception stack(0xcf281fb0 to 0xcf281ff8)
> [ =A0 79.723358] 1fa0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 0001e6a0 be8dab00 0001e698 00036698
> [ =A0 79.731933] 1fc0: 0002df98 0002df38 0000001f 00000000 b6f234d0 0=
0000000 00000004 00000000
> [ =A0 79.740509] 1fe0: 0001e6f8 be8d6aa0 be8dac50 0000aab8 80000010 f=
fffffff
> [ =A0 79.747497] Unable to handle kernel NULL pointer dereference at =
virtual address 00000000
> [ =A0 79.756011] pgd =3D cf3b4000
> [ =A0 79.758850] [00000000] *pgd=3D8f0c7831, *pte=3D00000000, *ppte=3D=
00000000
> [ =A0 79.765502] Internal error: Oops: 80000007 [#1]
> [ =A0 79.770294] Modules linked in:
> [ =A0 79.773529] CPU: 0 =A0 =A0Tainted: G =A0 =A0 =A0 =A0W =A0 =A0 (3=
=2E3.0-rc6-00002-gb5d5c87 #421)
> [ =A0 79.781066] PC is at 0x0
> [ =A0 79.783721] LR is at run_timer_softirq+0x16c/0x3ac
> [ =A0 79.788787] pc : [<00000000>] =A0 =A0lr : [<c0040aa4>] =A0 =A0ps=
r: 60000113
> [ =A0 79.788787] sp : cf281ee0 =A0ip : 00000000 =A0fp : cf280000
> [ =A0 79.800903] r10: 00000004 =A0r9 : 00000100 =A0r8 : b6f234d0
> [ =A0 79.806427] r7 : c0519c28 =A0r6 : cf093488 =A0r5 : c0561a00 =A0r=
4 : 00000000
> [ =A0 79.813323] r3 : 00000000 =A0r2 : c054eee0 =A0r1 : 00000001 =A0r=
0 : 00000000
> [ =A0 79.820190] Flags: nZCv =A0IRQs on =A0FIQs on =A0Mode SVC_32 =A0=
ISA ARM =A0Segment user
> [ =A0 79.827728] Control: 10c5387d =A0Table: 8f3b4019 =A0DAC: 0000001=
5
> [ =A0 79.833801] Process gpsd (pid: 1265, stack limit =3D 0xcf2802e8)
> [ =A0 79.839965] Stack: (0xcf281ee0 to 0xcf282000)
> [ =A0 79.844573] 1ee0: 00000002 00000000 c0040a24 00000000 00000002 c=
f281f08 00200200 00000000
> [ =A0 79.853210] 1f00: 00000000 cf281f18 cf281f08 00000000 00000000 0=
0000000 cf281f18 cf281f18
> [ =A0 79.861816] 1f20: 00000000 00000001 c056184c 00000000 00000001 b=
6f234d0 c0561848 00000004
> [ =A0 79.870452] 1f40: cf280000 c003a3b8 c051e79c 00000001 00000000 0=
0000100 3fa9e7b8 0000000a
> [ =A0 79.879089] 1f60: 00000025 cf280000 00000025 00000000 00000000 b=
6f234d0 00000000 00000004
> [ =A0 79.887756] 1f80: 00000000 c003a924 c053ad38 c0013a50 fa200000 c=
f281fb0 ffffffff c0008530
> [ =A0 79.896362] 1fa0: 0001e6a0 0000aab8 80000010 c037499c 0001e6a0 b=
e8dab00 0001e698 00036698
> [ =A0 79.904998] 1fc0: 0002df98 0002df38 0000001f 00000000 b6f234d0 0=
0000000 00000004 00000000
> [ =A0 79.913665] 1fe0: 0001e6f8 be8d6aa0 be8dac50 0000aab8 80000010 f=
fffffff 00fbf700 04ffff00
> [ =A0 79.922302] [<c0040aa4>] (run_timer_softirq+0x16c/0x3ac) from [<=
c003a3b8>] (__do_softirq+0xd4/0x22c)
> [ =A0 79.931945] [<c003a3b8>] (__do_softirq+0xd4/0x22c) from [<c003a9=
24>] (irq_exit+0x8c/0x94)
> [ =A0 79.940582] [<c003a924>] (irq_exit+0x8c/0x94) from [<c0013a50>] =
(handle_IRQ+0x34/0x84)
> [ =A0 79.948913] [<c0013a50>] (handle_IRQ+0x34/0x84) from [<c0008530>=
] (omap3_intc_handle_irq+0x48/0x4c)
> [ =A0 79.958404] [<c0008530>] (omap3_intc_handle_irq+0x48/0x4c) from =
[<c037499c>] (__irq_usr+0x3c/0x60)
> [ =A0 79.967773] Exception stack(0xcf281fb0 to 0xcf281ff8)
> [ =A0 79.973083] 1fa0: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 0001e6a0 be8dab00 0001e698 00036698
> [ =A0 79.981658] 1fc0: 0002df98 0002df38 0000001f 00000000 b6f234d0 0=
0000000 00000004 00000000
> [ =A0 79.990234] 1fe0: 0001e6f8 be8d6aa0 be8dac50 0000aab8 80000010 f=
fffffff
> [ =A0 79.997161] Code: bad PC value
> [ =A0 80.000396] ---[ end trace 6f6739840475f9ee ]---
> [ =A0 80.005279] Kernel panic - not syncing: Fatal exception in inter=
rupt
>
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Johan Hovold <jhovold@gmail.com>
> ---
>
> v2: use hdev->dev_flags for internal unregister flag
>
>
> =A0include/net/bluetooth/hci.h | =A0 =A02 ++
> =A0net/bluetooth/hci_core.c =A0 =A0| =A0 =A07 +++++++
> =A02 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.=
h
> index 00596e8..e8879b9 100644
> --- a/include/net/bluetooth/hci.h
> +++ b/include/net/bluetooth/hci.h
> @@ -93,6 +93,8 @@ enum {
> =A0* states from the controller.
> =A0*/
> =A0enum {
> + =A0 =A0 =A0 HCI_UNREGISTER,
> +
> =A0 =A0 =A0 =A0HCI_LE_SCAN,
> =A0};
>
> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> index d6448f0..22b6781 100644
> --- a/net/bluetooth/hci_core.c
> +++ b/net/bluetooth/hci_core.c
> @@ -525,6 +525,11 @@ int hci_dev_open(__u16 dev)
>
> =A0 =A0 =A0 =A0hci_req_lock(hdev);
>
> + =A0 =A0 =A0 if (test_bit(HCI_UNREGISTER, &hdev->dev_flags)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> + =A0 =A0 =A0 }
> +

Isn't it enough to check for HCI_RUNNING here? We obviously have a
race here as we take the device with hci_dev_get(), then sleep and
then we do not check whether the device is still alive. However,
drivers are required to reset HCI_RUNNING before calling
hci_unregister_dev() (which is bogus anyway, but its the way we
handled it in the past) therefore it should be enough for us to check
for HCI_RUNNING.

Regards
David

> =A0 =A0 =A0 =A0if (hdev->rfkill && rfkill_blocked(hdev->rfkill)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ERFKILL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> @@ -1577,6 +1582,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
>
> =A0 =A0 =A0 =A0BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bu=
s);
>
> + =A0 =A0 =A0 set_bit(HCI_UNREGISTER, &hdev->dev_flags);
> +
> =A0 =A0 =A0 =A0write_lock(&hci_dev_list_lock);
> =A0 =A0 =A0 =A0list_del(&hdev->list);
> =A0 =A0 =A0 =A0write_unlock(&hci_dev_list_lock);
> --
> 1.7.8.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluet=
ooth" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
