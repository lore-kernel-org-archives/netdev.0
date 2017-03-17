From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: ip_auto_config() prevents network device to be registered
Date: Fri, 17 Mar 2017 14:18:08 -0300
Message-ID: <1b5986dc-64a5-62a5-d4ca-6540ceb4e0fe@osg.samsung.com>
References: <b7ad0acb-1cad-3a45-0b0f-57d576ff1a36@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Sjoerd Simons <sjoerd.simons@collabora.co.uk>,
        Kevin Hilman <khilman@baylibre.com>,
        Shuah Khan <shuahkh@osg.samsung.com>,
        LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b7ad0acb-1cad-3a45-0b0f-57d576ff1a36@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 01/31/2017 02:49 PM, Javier Martinez Canillas wrote:
> 
> The kernelci folks pointed out that a Samsung Exynos based board was failing
> to boot when trying to mount the rootfs via NFS, due a networking issue [0].
> 
> I looked at the issue and it turned out to be a race between ip_auto_config()
> and register_netdev() when using the ip=dhcp param in the kernel command line.
> 
> The problem is that ip_auto_config() calls wait_for_devices() [1] and returns
> as soon as it finds a network device registered. Then ic_open_devs() [2] is
> called then to bring the network devs up and wait for their carrier signals.
> 
> But ic_open_devs() grabs the rtnl_mutex lock [3] when doing this, which is the
> same lock that register_netdev() [4] grabs before registering a network device.
> 
> And so if a network dev is found and wait_for_devices() returns, ic_open_devs()
> will be called and no new network dev could be registered in the meantime.
> 
> So since ic_open_devs() waits up to CONF_CARRIER_TIMEOUT (120 secs) with this
> lock held, if the network dev that's supposed to get its IP over DHCP isn't the
> first to be registered, the boot test job may timeout and be considered a fail.
> 
> A workaround is to use ip=:::::eth0:dhcp instead ip=dhcp, so wait_for_devices()
> waits for this specific device. Another workaround is to increase the timeout
> for the job to be much bigger than CONF_CARRIER_TIMEOUT so ip_auto_config() can
> retry and the network devices can be registered between tries.
> 
> But I wonder if someone can suggest a proper way to fix this. Grabbing a mutex
> that prevents network devs to be registered for 120 secs doesn't sound correct.
> 
> Thanks a lot for your help and please let me know if I misunderstood something.
> 
> [0]: https://storage.kernelci.org/mainline/v4.9/arm-exynos_defconfig/lab-collabora/boot-exynos5422-odroidxu3_rootfs:nfs.html
> [1]: http://lxr.free-electrons.com/source/net/ipv4/ipconfig.c#L1368
> [2]: http://lxr.free-electrons.com/source/net/ipv4/ipconfig.c#L202
> [3]: http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L68
> [4]: http://lxr.free-electrons.com/source/net/core/dev.c#L7326
> 
> 

Any comments on this?

We are still seeing this problem with today's -next (20170310):

https://storage.kernelci.org/next/next-20170310/arm-exynos_defconfig/lab-collabora/boot-exynos5422-odroidxu3.html

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
