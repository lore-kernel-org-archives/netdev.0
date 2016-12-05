From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 0/5] cpsw: add per channel shaper configuration
Date: Mon, 5 Dec 2016 14:33:40 -0600
Message-ID: <4640ce88-75b0-8508-05f0-849e8fd4927f@ti.com>
References: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480431651-6081-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ivan,

On 11/29/2016 09:00 AM, Ivan Khoronzhuk wrote:
> This series is intended to allow user to set rate for per channel
> shapers at cpdma level. This patchset doesn't have impact on performance.
> The rate can be set with:
> 
> echo 100 > /sys/class/net/ethX/queues/tx-0/tx_maxrate
> 
> Tested on am572xx
> Based on net-next/master
> 
> Ivan Khoronzhuk (5):
>   net: ethernet: ti: davinci_cpdma: add weight function for channels
>   net: ethernet: ti: davinci_cpdma: add set rate for a channel
>   net: ethernet: ti: cpsw: add .ndo to set per-queue rate
>   net: ethernet: ti: cpsw: optimize end of poll cycle
>   net: ethernet: ti: cpsw: split tx budget according between channels
> 
>  drivers/net/ethernet/ti/cpsw.c          | 264 +++++++++++++++----
>  drivers/net/ethernet/ti/davinci_cpdma.c | 453 ++++++++++++++++++++++++++++----
>  drivers/net/ethernet/ti/davinci_cpdma.h |   6 +
>  3 files changed, 624 insertions(+), 99 deletions(-)
> 


I've just tried net-next on BBB and got below back-trace:
INIT: Entering runlevel: 5
Configuring network interfaces... [   15.018356] net eth0: initializing cpsw version 1.12 (0)
[   15.120153] SMSC LAN8710/LAN8720 4a101000.mdio:00: attached PHY driver [SMSC LAN8710/LAN8720] (mii_bus:phy_addr=4a101000.mdio:00, irq=-1)
[   15.138578] Division by zero in kernel.
[   15.142667] CPU: 0 PID: 755 Comm: ifconfig Not tainted 4.9.0-rc7-01617-g6ea3f00 #5
[   15.150277] Hardware name: Generic AM33XX (Flattened Device Tree)
[   15.156399] Backtrace: 
[   15.158898] [<c010bbf8>] (dump_backtrace) from [<c010beb4>] (show_stack+0x18/0x1c)
[   15.166508]  r7:00000000 r6:600f0013 r5:00000000 r4:c0d395d0
[   15.172200] [<c010be9c>] (show_stack) from [<c03ce6cc>] (dump_stack+0x8c/0xa0)
[   15.179460] [<c03ce640>] (dump_stack) from [<c010bd60>] (__div0+0x1c/0x20)
[   15.186368]  r7:00000000 r6:ddf1c010 r5:00000001 r4:00000001
[   15.192068] [<c010bd44>] (__div0) from [<c03cd17c>] (Ldiv0+0x8/0x14)
[   15.198503] [<bf07ba38>] (cpsw_split_budget [ti_cpsw]) from [<bf07ee8c>] (cpsw_ndo_open+0x4b8/0x5e4 [ti_cpsw])
[   15.208554]  r10:ddf1c010 r9:00000000 r8:00000000 r7:ddf1c010 r6:dcc88000 r5:dcc88500
[   15.216418]  r4:ddf1c0b0
[   15.218985] [<bf07e9d4>] (cpsw_ndo_open [ti_cpsw]) from [<c0731c68>] (__dev_open+0xb0/0x114)
[   15.227466]  r10:00000000 r9:00000000 r8:00000000 r7:dcc88030 r6:bf080364 r5:00000000
[   15.235330]  r4:dcc88000
[   15.237880] [<c0731bb8>] (__dev_open) from [<c0731f24>] (__dev_change_flags+0x9c/0x14c)
[   15.245923]  r7:00001002 r6:00000001 r5:00001043 r4:dcc88000
[   15.251613] [<c0731e88>] (__dev_change_flags) from [<c0731ff4>] (dev_change_flags+0x20/0x50)
[   15.260093]  r9:00000000 r8:00000000 r7:dcbabf0c r6:00001002 r5:dcc8813c r4:dcc88000
[   15.267886] [<c0731fd4>] (dev_change_flags) from [<c07a3168>] (devinet_ioctl+0x6d4/0x794)
[   15.276105]  r9:00000000 r8:bee8cc64 r7:dcbabf0c r6:00000000 r5:dc921e80 r4:00000000
[   15.283891] [<c07a2a94>] (devinet_ioctl) from [<c07a54bc>] (inet_ioctl+0x19c/0x1c8)
[   15.291587]  r10:00000000 r9:dc920000 r8:bee8cc64 r7:c0d64bc0 r6:bee8cc64 r5:dd2728e0
[   15.299450]  r4:00008914
[   15.302002] [<c07a5320>] (inet_ioctl) from [<c07112dc>] (sock_ioctl+0x14c/0x300)
[   15.309443] [<c0711190>] (sock_ioctl) from [<c0241868>] (do_vfs_ioctl+0xa8/0x98c)
[   15.316962]  r7:00000003 r6:ddf0a780 r5:dd2728e0 r4:bee8cc64
[   15.322653] [<c02417c0>] (do_vfs_ioctl) from [<c0242188>] (SyS_ioctl+0x3c/0x64)
[   15.330000]  r10:00000000 r9:dc920000 r8:bee8cc64 r7:00008914 r6:ddf0a780 r5:00000003
[   15.337864]  r4:ddf0a780
[   15.340416] [<c024214c>] (SyS_ioctl) from [<c0107d60>] (ret_fast_syscall+0x0/0x3c)
[   15.348024]  r9:dc920000 r8:c0107f24 r7:00000036 r6:bee8cf4d r5:bee8ce4c r4:000949f0
[   15.361174] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
udhcpc (v1.23.1) started


-- 
regards,
-grygorii
