From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netconsole: Initialize after all core networking drivers
Date: Thu, 17 Dec 2015 17:08:14 -0800
Message-ID: <1450400894.8474.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151217235239.GA1444048@devbig337.prn1.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shm@cumulusnetworks.com,
	izumi.taku@jp.fujitsu.com, linville@tuxdriver.com,
	dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151217235239.GA1444048@devbig337.prn1.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-17 at 15:52 -0800, Calvin Owens wrote:
> With built-in netconsole and IXGBE, configuring netconsole via the kernel
> cmdline results in the following panic at boot:
> 
>     netpoll: netconsole: device eth0 not up yet, forcing it
>     usb 2-1: new high-speed USB device number 2 using ehci-pci
>     ixgbe 0000:03:00.0: registered PHC device on eth0
>     BUG: unable to handle kernel NULL pointer dereference at 0000000000000810
>     <snip>
>     Call Trace:
>      [<ffffffff81578661>] ? vxlan_get_rx_port+0x41/0xa0
>      [<ffffffff81586828>] ixgbe_open+0x4e8/0x540
>      [<ffffffff8168045c>] __dev_open+0xac/0x120
>      [<ffffffff81680506>] dev_open+0x36/0x70
>      [<ffffffff8169abec>] netpoll_setup+0x23c/0x300
>      [<ffffffff8169a66a>] ? netpoll_parse_options+0x19a/0x200
>      [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>      [<ffffffff81d79882>] init_netconsole+0xda/0x262
>      [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>      [<ffffffff810003a8>] do_one_initcall+0x88/0x1b0
>      [<ffffffff81d31144>] kernel_init_freeable+0x14a/0x1e3
>      [<ffffffff81d308f1>] ? do_early_param+0x8c/0x8c
>      [<ffffffff81778610>] ? rest_init+0x80/0x80
>      [<ffffffff8177861e>] kernel_init+0xe/0xe0
>      [<ffffffff8177dc5f>] ret_from_fork+0x3f/0x70
>      [<ffffffff81778610>] ? rest_init+0x80/0x80
> 
> This happens because IXGBE assumes that vxlan has already been initialized.
> The cleanest way to fix this is to just initialize netconsole after all the
> other core networking stuff has completed.
> 
> Signed-off-by: Calvin Owens <calvinowens@fb.com>
> ---
>  drivers/net/Makefile | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 900b0c5..31557d0 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -15,7 +15,6 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
>  obj-$(CONFIG_MII) += mii.o
>  obj-$(CONFIG_MDIO) += mdio.o
>  obj-$(CONFIG_NET) += Space.o loopback.o
> -obj-$(CONFIG_NETCONSOLE) += netconsole.o
>  obj-$(CONFIG_PHYLIB) += phy/
>  obj-$(CONFIG_RIONET) += rionet.o
>  obj-$(CONFIG_NET_TEAM) += team/
> @@ -26,6 +25,7 @@ obj-$(CONFIG_VXLAN) += vxlan.o
>  obj-$(CONFIG_GENEVE) += geneve.o
>  obj-$(CONFIG_NLMON) += nlmon.o
>  obj-$(CONFIG_NET_VRF) += vrf.o
> +obj-$(CONFIG_NETCONSOLE) += netconsole.o
>  
>  #
>  # Networking Drivers


Looks odd to rely on link order, but we might already rely on this...

Have you considered using device_initcall() instead of late_initcall()
in vxlan ?

In any case, a comment would really be good to avoid future mistakes.
