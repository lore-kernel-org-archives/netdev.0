From: Peter Ujfalusi <peter.ujfalusi@ti.com>
Subject: Re: [PATCH v2 4/4] ARM: OMAP2+: omap_device: fix crash on omap_device
 removal
Date: Fri, 29 Jul 2016 08:15:16 +0300
Message-ID: <ca582e58-8c97-67cb-8f1c-778e4c7b448e@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
 <20160728175037.22053-5-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>, Tony Lindgren <tony@atomide.com>,
	Tero Kristo <t-kristo@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728175037.22053-5-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/16 20:50, Grygorii Strashko wrote:
> Below call chain causes system crash when OMAP device is
> removed by calling of_platform_depopulate()/device_del():

Should you swap 3 <-> 4 in the series?
Currently patch 3 will introduce the crash you are fixing in patch 4...

>=20
> device_del()
> - blocking_notifier_call_chain(&dev->bus->p->bus_notifier,
>  			     BUS_NOTIFY_DEL_DEVICE, dev);
>   - _omap_device_notifier_call()
>     - omap_device_delete()
>       - od->pdev->archdata.od =3D NULL;
> 	kfree(od->hwmods);
> 	kfree(od);
>   - bus_remove_device()
>     - device_release_driver()
>       - __device_release_driver()
> 	- pm_runtime_get_sync()
> 	   - _od_runtime_resume()
> 	     - omap_hwmod_enable() <- OOPS od's delted already
>=20
> Backtrace:
> Unable to handle kernel NULL pointer dereference at virtual address 0=
000000d
> pgd =3D eb100000
> [0000000d] *pgd=3Dad6e1831, *pte=3D00000000, *ppte=3D00000000
> Internal error: Oops: 17 [#1] PREEMPT SMP ARM
> CPU: 1 PID: 1273 Comm: modprobe Not tainted 4.4.15-rt19-00115-ge4d3cd=
3-dirty #68
> Hardware name: Generic DRA74X (Flattened Device Tree)
> task: eb1ee800 ti: ec962000 task.ti: ec962000
> PC is at omap_device_enable+0x10/0x90
> LR is at _od_runtime_resume+0x10/0x24
> [...]
> [<c00299dc>] (omap_device_enable) from [<c0029a6c>] (_od_runtime_resu=
me+0x10/0x24)
> [<c0029a6c>] (_od_runtime_resume) from [<c04ad404>] (__rpm_callback+0=
x20/0x34)
> [<c04ad404>] (__rpm_callback) from [<c04ad438>] (rpm_callback+0x20/0x=
80)
> [<c04ad438>] (rpm_callback) from [<c04aee28>] (rpm_resume+0x48c/0x964=
)
> [<c04aee28>] (rpm_resume) from [<c04af360>] (__pm_runtime_resume+0x60=
/0x88)
> [<c04af360>] (__pm_runtime_resume) from [<c04a4974>] (__device_releas=
e_driver+0x30/0x100)
> [<c04a4974>] (__device_release_driver) from [<c04a4a60>] (device_rele=
ase_driver+0x1c/0x28)
> [<c04a4a60>] (device_release_driver) from [<c04a38c0>] (bus_remove_de=
vice+0xec/0x144)
> [<c04a38c0>] (bus_remove_device) from [<c04a0764>] (device_del+0x10c/=
0x210)
> [<c04a0764>] (device_del) from [<c04a67b0>] (platform_device_del+0x18=
/0x84)
> [<c04a67b0>] (platform_device_del) from [<c04a6828>] (platform_device=
_unregister+0xc/0x20)
> [<c04a6828>] (platform_device_unregister) from [<c05adcfc>] (of_platf=
orm_device_destroy+0x8c/0x90)
> [<c05adcfc>] (of_platform_device_destroy) from [<c04a02f0>] (device_f=
or_each_child+0x4c/0x78)
> [<c04a02f0>] (device_for_each_child) from [<c05adc5c>] (of_platform_d=
epopulate+0x30/0x44)
> [<c05adc5c>] (of_platform_depopulate) from [<bf123920>] (cpsw_remove+=
0x68/0xf4 [ti_cpsw])
> [<bf123920>] (cpsw_remove [ti_cpsw]) from [<c04a68d8>] (platform_drv_=
remove+0x24/0x3c)
> [<c04a68d8>] (platform_drv_remove) from [<c04a49c8>] (__device_releas=
e_driver+0x84/0x100)
> [<c04a49c8>] (__device_release_driver) from [<c04a4b20>] (driver_deta=
ch+0xac/0xb0)
> [<c04a4b20>] (driver_detach) from [<c04a3be8>] (bus_remove_driver+0x6=
0/0xd4)
> [<c04a3be8>] (bus_remove_driver) from [<c00d9870>] (SyS_delete_module=
+0x184/0x20c)
> [<c00d9870>] (SyS_delete_module) from [<c0010540>] (ret_fast_syscall+=
0x0/0x1c)
> Code: e3500000 e92d4070 1590630c 01a06000 (e5d6300d)
>=20
> Hence, fix it by using BUS_NOTIFY_REMOVED_DEVICE event for OMAP devic=
e
> deletion which is sent when DD has finished processing of device
> deletion.
>=20
> Cc: Tony Lindgren <tony@atomide.com>
> Cc: Tero Kristo <t-kristo@ti.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  arch/arm/mach-omap2/omap_device.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/arch/arm/mach-omap2/omap_device.c b/arch/arm/mach-omap2/=
omap_device.c
> index f7ff3b9..208f115 100644
> --- a/arch/arm/mach-omap2/omap_device.c
> +++ b/arch/arm/mach-omap2/omap_device.c
> @@ -194,7 +194,7 @@ static int _omap_device_notifier_call(struct noti=
fier_block *nb,
>  	int err;
> =20
>  	switch (event) {
> -	case BUS_NOTIFY_DEL_DEVICE:
> +	case BUS_NOTIFY_REMOVED_DEVICE:
>  		if (pdev->archdata.od)
>  			omap_device_delete(pdev->archdata.od);
>  		break;
>=20


--=20
P=E9ter
