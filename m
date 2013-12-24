From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Tue, 24 Dec 2013 17:38:35 +0200
Message-ID: <52B9AA7B.8090401@mellanox.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com> <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com> <52B6E568.4030400@mellanox.com> <20131223162957.GA6810@lintop.rgmadvisors.com> <20131223165934.GB6810@lintop.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, <tomk@rgmadvisors.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:41744 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750987Ab3LXPiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 10:38:46 -0500
In-Reply-To: <20131223165934.GB6810@lintop.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2013 6:59 PM, Shawn Bohrer wrote:
> On Mon, Dec 23, 2013 at 10:29:58AM -0600, Shawn Bohrer wrote:
>> On Sun, Dec 22, 2013 at 03:13:12PM +0200, Hadar Hen Zion wrote:
>>> On 12/17/2013 10:32 PM, Shawn Bohrer wrote:
>>>> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
>>>>
>>>> This adds a PHC to the mlx4_en driver.  The code is largely based off of
>>>> the e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
>>>> very similar.
>>>>
>>>> This driver has been tested with both Documentation/ptp/testptp and the
>>>> linuxptp project (http://linuxptp.sourceforge.net/) and appears to work
>>>> on a Mellanox ConnectX-3 card.
>>>>
>>>> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
>>>> ---
>>>>   drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  192 ++++++++++++++++++++++-
>>>>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
>>>>   drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
>>>>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
>>>>   4 files changed, 196 insertions(+), 8 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>>>> index fd64410..9b0d515 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>>>> @@ -103,17 +103,187 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
>>>>   			    struct skb_shared_hwtstamps *hwts,
>>>>   			    u64 timestamp)
>>>>   {
>>>> +	unsigned long flags;
>>>>   	u64 nsec;
>>>>
>>>> +	spin_lock_irqsave(&mdev->clock_lock, flags);
>>>
>>> 1. Missing initialization for clock_lock
>>> 2. Adding spin lock in the data path reduce performance by 15% when
>>> HW timestamping is enabled. I did some testing and replacing
>>> spin_lock_irqsave with read/write_lock_irqsave prevents the
>>> performance decrease.
>>
>> Thanks Hadar,
>>
>> I'm testing this change now, and will resend when I'm done.  However,
>> I noticed the following in Documentation/spinlocks.txt
>>
>>     NOTE! We are working hard to remove reader-writer spinlocks in most
>>     cases, so please don't add a new one without consensus.  (Instead, see
>>     Documentation/RCU/rcu.txt for complete information.)
>>
>> So is there consensus for a rwlock here?
>
> Also just to make sure I'm testing the correct thing.  These all need
> to be write_lock_irqsave() except for the one in
> mlx4_en_fill_hwtstamps() protecting timecounter_cyc2time() which can
> be a read_lock_irqsave().  All of the other timecounter* calls write
> to the timecounter including timecounter_read().  I'm assuming that is
> what you tested and that should still eliminate the performance loss
> since mlx4_en_fill_hwtstamps() should be the bottleneck.
>
> Thanks,
> Shawn
>
Yes, you were testing the correct thing.

But, after another check, I'm not sure we need any lock in 
mlx4_en_fill_hwtstamps() data path function.
Adding lock to mlx4_en_fill_hwtstamps() protects timecounter_cyc2time() 
which doesn't read hardware registers.
As you explained in your RFC mail:

 > In e1000e driver they protect the timecounter code with a spinlock
 > because the hardware reports the time in two 32bit registers.  The
 > Mellanox code looks similar.

The spin lock is needed when reading hardware registers.
My suggestion is to stay with spin locks in all the places protecting 
timecounter_read()/timecounter_init() and just remove the spin lock from 
timecounter_cyc2time()

Thanks,
Hadar
