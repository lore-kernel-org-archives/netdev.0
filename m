From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V2 5/5] net/mlx4_en: Add a service task
Date: Tue, 23 Apr 2013 16:56:43 +0300
Message-ID: <5176931B.1010903@mellanox.com>
References: <1366631767-16493-1-git-send-email-amirv@mellanox.com>  <1366631767-16493-6-git-send-email-amirv@mellanox.com> <1366657270.16391.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:60746 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753062Ab3DWN4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 09:56:51 -0400
In-Reply-To: <1366657270.16391.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/04/2013 22:01, Eric Dumazet wrote:
> On Mon, 2013-04-22 at 14:56 +0300, Amir Vadai wrote:
>> Add a service task to run tasks that needed to be executed periodically.
>> Currently the only task is a watchdog to catch NIC clock overflow, to make
>> timestamping accurate.
>> Will move the statistics task into this framework in a later patch.
>>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/en_clock.c  |   20 ++++++++++++++++++++
>>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   24 ++++++++++++++++++++++++
>>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 ++++
>>  3 files changed, 48 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>> index 6d8227d..c1982a4 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
>> @@ -126,4 +126,24 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>>  
>>  	timecounter_init(&mdev->clock, &mdev->cycles,
>>  			 ktime_to_ns(ktime_get_real()));
>> +
>> +	/* Calculate period in seconds to call the overflow watchdog. Doing
>> +	 * that, by dividing the maximal cycles value in nano-seconds, convert
>> +	 * it to seconds, and divide by 2 - to make sure counter is checked at
>> +	 * least once every wrap around.
>> +	 */
>> +	mdev->overflow_period =
>> +		cyclecounter_cyc2ns(&mdev->cycles,
>> +				    mdev->cycles.mask) / 1000000 / 2;
>> +}
>> +
> 
> So this 1000000 looks like NSEC_PER_SEC/HZ ?
No. It is just a typo - used 10^6 instead of 10^9 for nano's.
But it is a good idea to have the HZ multiplied in the initialization of
overflow_period - will fix the calculation and change overflow_period
units to be jiffies, and not seconds.
> 
> What if HZ=100 ?
> 
> 
> 

Thanks,
Amir
