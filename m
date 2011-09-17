From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: mac80211 regression (deadlock) with built-in ipw2200
Date: Sat, 17 Sep 2011 06:32:05 -0400
Message-ID: <CA+5PVA5eJXzLHO=S9kaBt4_OzuJxJxAOpmm7ABVSu7bm1VjmdQ@mail.gmail.com>
References: <877h57jwmh.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877h57jwmh.fsf@tac.ki.iif.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 17, 2011 at 6:23 AM, Ferenc Wagner <wferi@niif.hu> wrote:
> Hi,
>
> As pointed out by git-bisect, commit ecb44335 (mac80211: fix
> suspend/resume races with unregister hw) broke booting on my ThinkPad
> R50e. Looks like the rtnl_lock() around rdev->wiphy.registered =3D tr=
ue
> leads to a deadlock, possibly because ipw2200 is built-in in my
> config. =A0Testing with the additional debug patch
>
> --- a/net/wireless/core.c
> +++ b/net/wireless/core.c
> @@ -616,9 +616,8 @@ int wiphy_register(struct wiphy *wiphy)
> =A0 =A0 =A0 =A0if (res)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_rm_dev;
>
> - =A0 =A0 =A0 rtnl_lock();
> + =A0 =A0 =A0 WARN_ON(rtnl_is_locked());
> =A0 =A0 =A0 =A0rdev->wiphy.registered =3D true;
> - =A0 =A0 =A0 rtnl_unlock();
> =A0 =A0 =A0 =A0return 0;
>
> on top of c455ea4f (rc6+) leads to a working system with
>
> [ =A0 =A01.020738] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network D=
river, 1.2.2kmpr
> [ =A0 =A01.020812] ipw2200: Copyright(c) 2003-2006 Intel Corporation
> [ =A0 =A01.023406] ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 11
> [ =A0 =A01.025717] ipw2200 0000:02:02.0: PCI INT A -> Link[LNKF] -> G=
SI 11 (level, low
> ) -> IRQ 11
> [ =A0 =A01.028048] ipw2200: Detected Intel PRO/Wireless 2200BG Networ=
k Connection
> [ =A0 =A01.148058] ------------[ cut here ]------------
> [ =A0 =A01.150393] WARNING: at net/wireless/core.c:619 wiphy_register=
+0x4c1/0x58c()
> [ =A0 =A01.152781] Hardware name: 1834S5G
> [ =A0 =A01.155126] Pid: 1, comm: swapper Not tainted 3.1.0-rc6+ #86
> [ =A0 =A01.157520] Call Trace:
> [ =A0 =A01.159871] =A0[<c1028b98>] warn_slowpath_common+0x69/0x90
> [ =A0 =A01.162241] =A0[<c13ee7a8>] ? wiphy_register+0x4c1/0x58c
> [ =A0 =A01.164617] =A0[<c13ee7a8>] ? wiphy_register+0x4c1/0x58c
> [ =A0 =A01.166924] =A0[<c1028be1>] warn_slowpath_null+0x22/0x24
> [ =A0 =A01.169230] =A0[<c13ee7a8>] wiphy_register+0x4c1/0x58c
> [ =A0 =A01.171564] =A0[<c12daad0>] ? ipw_net_init+0x1e6/0x2d0
> [ =A0 =A01.173890] =A0[<c12da995>] ipw_net_init+0xab/0x2d0
> [ =A0 =A01.176173] =A0[<c1375032>] register_netdevice+0x70/0x271
> [ =A0 =A01.178446] =A0[<c137524e>] register_netdev+0x1b/0x28
> [ =A0 =A01.180688] =A0[<c142f5b8>] ipw_pci_probe+0x7c3/0x891
> [ =A0 =A01.182892] =A0[<c11a6f93>] local_pci_probe+0x40/0x9a
> [ =A0 =A01.185086] =A0[<c11a7c98>] pci_device_probe+0x56/0x71
> [ =A0 =A01.187259] =A0[<c128c902>] driver_probe_device+0x6c/0x177
> [ =A0 =A01.189453] =A0[<c11a6ed9>] ? pci_match_device+0x80/0x85
> [ =A0 =A01.191615] =A0[<c128ca79>] __driver_attach+0x6c/0x6e
> [ =A0 =A01.193794] =A0[<c128c257>] bus_for_each_dev+0x4a/0x68
> [ =A0 =A01.195936] =A0[<c128c7b4>] driver_attach+0x1e/0x20
> [ =A0 =A01.198043] =A0[<c128ca0d>] ? driver_probe_device+0x177/0x177
> [ =A0 =A01.200151] =A0[<c128bce5>] bus_add_driver+0x186/0x231
> [ =A0 =A01.202247] =A0[<c11a7b3c>] ? pci_dev_put+0x16/0x16
> [ =A0 =A01.204320] =A0[<c128cfac>] driver_register+0x6a/0x118
> [ =A0 =A01.206386] =A0[<c120665f>] ? misc_register+0xc2/0x133
> [ =A0 =A01.208425] =A0[<c15ee31e>] ? parse_early_options+0x25/0x25
> [ =A0 =A01.210423] =A0[<c11a7e66>] __pci_register_driver+0x33/0x8c
> [ =A0 =A01.212393] =A0[<c15ee31e>] ? parse_early_options+0x25/0x25
> [ =A0 =A01.214384] =A0[<c160e0e8>] ipw_init+0x30/0x75
> [ =A0 =A01.216356] =A0[<c15ee24c>] do_one_initcall+0x86/0x133
> [ =A0 =A01.218340] =A0[<c160e0b8>] ? tun_init+0x8b/0x8b
> [ =A0 =A01.220315] =A0[<c15ee31e>] ? parse_early_options+0x25/0x25
> [ =A0 =A01.222270] =A0[<c15ee393>] kernel_init+0x75/0x10c
> [ =A0 =A01.224214] =A0[<c14349b6>] kernel_thread_helper+0x6/0x10
> [ =A0 =A01.226124] ---[ end trace 4ef665623022622c ]---
> [ =A0 =A01.228121] ipw2200: Detected geography ZZR (14 802.11bg chann=
els, 0 802.11a channels)
>
> in dmesg. =A0It's a shoot in the dark, but register_netdev() issues
> rtnl_lock() before calling register_netdevice(), so wiphy_register()
> can't possibly acquire the rtnl mutex in the same call chain, or can
> it?

This is fixed here:

http://article.gmane.org/gmane.linux.kernel.wireless.general/77103

josh
