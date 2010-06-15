From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Tue, 15 Jun 2010 16:53:27 +0800
Message-ID: <4C173F87.7000704@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain> <20100603034312.5305.61000.sendpatchset@localhost.localdomain> <1275568622.2870.89.camel@localhost> <4C085D45.6040001@redhat.com> <1275661552.2095.13.camel@achroite.uk.solarflarecom.com> <4C0F5D97.5030605@redhat.com> <20100609104950.GB2599@dhcp-lab-161.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	herbert.xu@redhat.com, nhorman@redhat.com, davem@davemloft.net
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab0FOIt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 04:49:27 -0400
In-Reply-To: <20100609104950.GB2599@dhcp-lab-161.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/10 18:49, Stanislaw Gruszka wrote:
> Hi Amerigo
>
> Sorry for being silent in this thread before.
>
> On Wed, Jun 09, 2010 at 05:23:35PM +0800, Cong Wang wrote:
>>>>> Is that flag test actually unsafe - and if so, how is testing num_lro
>>>>> any better?  Perhaps access to net_device::features should be wrapped
>>>>> with ACCESS_ONCE() to ensure that reads and writes are atomic.
>>>>>
>>>>
>>>> At least, I don't find there is any race with 'num_lro', thus
>>>> no lock is needed.
>>>
>>> In both cases there is a race condition but it is harmless so long as
>>> the read and the write are atomic.  There is a general assumption in
>>> networking code that this is the case for int and long.  Personally I
>>> would prefer to see this made explicit using ACCESS_ONCE(), but I don't
>>> see any specific problem in mlx4 (not that I'm familiar with this driver
>>> either).
>>
>> I read this email again.
>>
>> I think you misunderstood the race condition here. Even read and write
>> are atomic here, the race still exists. One can just set NETIF_F_LRO
>> asynchronously right before mlx4 check this flag in mlx4_en_process_rx_cq()
>> which doesn't take rtnl_lock.
>
> If so, it's better to stop device before modify LRO settings. I suggest
> something like that in mlx4_ethtool_op_set_flags:
>
> if (!!(data&  ETH_FLAG_LRO) != !!(dev->features&  NETIF_F_LRO)) {


What does this line mean? This is to ignore all other flags, right?

> 	/* Need to toggle LRO */
>
> 	if (netdev_running(dev)) {
>                 mutex_lock(&mdev->state_lock);
>                 mlx4_en_stop_port(dev);
>                 rc = mlx4_en_start_port(dev);
>                 if (rc)
>                         en_err(priv, "Failed to restart port\n");
> 	}
>
> 	dev->features ^= NETIF_F_LRO;
>
> 	if (netdev_running(dev))
>                 mutex_unlock(&mdev->state_lock);
> }
>

I don't think mdev->state_lock is used to protect dev->feature.
rtnl_lock is. I think switching to mlx4_ethtool_op_set_flags()
from the default one has already solved this.

Thanks!
