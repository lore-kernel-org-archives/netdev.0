From: Mark Jackson <mpfj-list@mimc.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Sun, 14 Apr 2013 20:16:40 +0100
Message-ID: <516B0098.4040809@mimc.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/13 19:52, Mugunthan V N wrote:
> This patch series implements Dual EMAC mode implementation of CPSW
> which acts as two standalone EMAC by segregating the switch using VIDs
> and port VLAN
>
> Mugunthan V N (3):
>    driver: net: ethernet: davinci_cpdma: add support for directed packet
>      and source port detection
>    driver: net: ethernet: cpsw: make cpts as pointer
>    driver: net: ethernet: cpsw: dual emac interface implementation
>
>   Documentation/devicetree/bindings/net/cpsw.txt |    2 +
>   drivers/net/ethernet/ti/cpsw.c                 |  387 +++++++++++++++++++-----
>   drivers/net/ethernet/ti/davinci_cpdma.c        |   17 +-
>   drivers/net/ethernet/ti/davinci_cpdma.h        |    4 +-
>   drivers/net/ethernet/ti/davinci_emac.c         |    6 +-
>   include/linux/platform_data/cpsw.h             |    3 +
>   6 files changed, 338 insertions(+), 81 deletions(-)

I'm trying to get dual emac mode working, but I'm only having partial 
success.  We have a custom AM335x board with dual LAN8710 PYHs, but the 
basic design is based on the BeagleBone board.

I have the following in my .dts file:-

mac: ethernet@4a100000 {
	dual_emac = <1>;
	cpsw_emac0: slave@4a100200 {
		dual_emac_res_vlan = <1>;
	};
	cpsw_emac1: slave@4a100300 {
		dual_emac_res_vlan = <2>;
	};
};

When I boot my board (across nfs via eth1):-

(a) the kernel is loaded (via tftp under U-Boot)
(b) the kernel mounts the nfsroot
(c) my init scripts are run (e.g. dropbear)
(d) the shell prompt appears

So far so good, but when I then try any shell command (e.g. "ps") the 
nfs link just hangs.

Below is an extract from the boot messages:-

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.9.0-rc6-00186-g5b55d70-dirty 
(mpfj@mpfj-nanobone) (gcc version 4.7.2 (Buildroot 
2013.02-00154-g851ceaa) ) #19 Sun Apr 14 19:50:21 BST 2013
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), 
cr=10c53c7d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing 
instruction cache
[    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: 
Newflow AM335x NanoBone
[    0.000000] Memory policy: ECC disabled, Data cache writeback
[    0.000000] CPU: All CPU(s) started in SVC mode.
[    0.000000] AM335X ES1.0 (neon )
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on. 
Total pages: 64768
[    0.000000] Kernel command line: root=/dev/nfs 
nfsroot=10.1.0.111:/tftpboot/nanobone/rootfs rw 
ip=10.1.0.199:10.1.0.111:10.1.0.1:255.255.0.0::eth1:off console=ttyO0,115200
...
[    1.424977] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
[    1.431443] davinci_mdio 4a101000.mdio: detected phy mask fffffffc
[    1.440939] libphy: 4a101000.mdio: probed
[    1.445266] davinci_mdio 4a101000.mdio: phy[0]: device 
4a101000.mdio:00, driver SMSC LAN8710/LAN8720
[    1.454962] davinci_mdio 4a101000.mdio: phy[1]: device 
4a101000.mdio:01, driver SMSC LAN8710/LAN8720
[    1.465059] Random MACID = a2:3f:fb:2c:47:d9
[    1.472276] cpsw: Random MACID = ae:d5:c0:c0:27:03
[    1.480588] rtc-ds1307 0-0068: setting system clock to 2013-04-14 
19:59:52 UTC (1365969592)
[    1.491543] net eth1: initializing cpsw version 1.12 (0)
[    1.516965] net eth1: phy found : id is : 0x7c0f1
[    4.595479] libphy: 4a101000.mdio:01 - Link is Up - 100/Full
[    4.625872] IP-Config: Complete:
[    4.629307]      device=eth1, hwaddr=ae:d5:c0:c0:27:03, 
ipaddr=10.1.0.199, mask=255.255.0.0, gw=10.1.0.1
[    4.639365]      host=10.1.0.199, domain=, nis-domain=(none)
[    4.645359]      bootserver=10.1.0.111, rootserver=10.1.0.111, rootpath=
[    4.674219] VFS: Mounted root (nfs filesystem) on device 0:12.
[    4.682438] devtmpfs: mounted
[    4.686042] Freeing init memory: 196K
Starting logging: OK
Initializing random number generator... done.
Starting network...
ip: RTNETLINK answers: File exists
[    5.340677] net eth0: initializing cpsw version 1.12 (0)
[    5.366463] net eth0: phy found : id is : 0x7c0f1
ip: RTNETLINK answers: File exists
ip: RTNETLINK answers: File exists
ip: RTNETLINK answers: File exists
Starting dropbear sshd: OK

Welcome to Buildroot
nanobone login: root
Password:
# ps
[   18.845266] nfs: server 10.1.0.111 not responding, still trying

At this point, I can disconnect my network cable from eth1 and connect 
to eth0, and back again which shows the PYHs appear to be detecting the 
link up/down status of each port.

[  562.675229] libphy: 4a101000.mdio:01 - Link is Down
[  567.885586] libphy: 4a101000.mdio:00 - Link is Up - 100/Full
[  571.965156] libphy: 4a101000.mdio:00 - Link is Down
[  575.014943] nfs: server 10.1.0.111 not responding, still trying
[  576.635412] libphy: 4a101000.mdio:01 - Link is Up - 100/Full
[  579.426051] nfs: server 10.1.0.111 OK

Notice that at the end, the nfs link appears to come back "ok", but the 
"ps" command never completes.

Any ideas of what's going on ?

Cheers
Mark J.
