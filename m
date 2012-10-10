From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V1 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Wed, 10 Oct 2012 16:06:00 +0200
Message-ID: <507580C8.2040808@mellanox.com>
References: <1349796013-31106-1-git-send-email-ogerlitz@mellanox.com> <1349796013-31106-4-git-send-email-ogerlitz@mellanox.com> <20121010033703.GA2304@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Tzahi Oved <tzahio@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:54040 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756325Ab2JJOGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 10:06:17 -0400
In-Reply-To: <20121010033703.GA2304@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2012 05:37, Richard Cochran wrote:
> On Tue, Oct 09, 2012 at 05:20:13PM +0200, Or Gerlitz wrote:
>
>> @@ -1542,6 +1611,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
>>   	.ndo_set_mac_address	= mlx4_en_set_mac,
>>   	.ndo_validate_addr	= eth_validate_addr,
>>   	.ndo_change_mtu		= mlx4_en_change_mtu,
>> +	.ndo_do_ioctl		= mlx4_en_ioctl,
>>   	.ndo_tx_timeout		= mlx4_en_tx_timeout,
>>   	.ndo_vlan_rx_add_vid	= mlx4_en_vlan_rx_add_vid,
>>   	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
> You should also provide a get_ts_info function to let the users know
> about the device's time stamping capabilities.

sure, will do.


>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_timestamp.c b/drivers/net/ethernet/mellanox
>> ...
>>
>> +void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>> +{
>> +	struct mlx4_dev *dev = mdev->dev;
>> +	u64 temp_mult;
>> +
>> +	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
>> +	mdev->cycles.read = mlx4_en_read_clock;
>> +	mdev->cycles.mask = CLOCKSOURCE_MASK(48);
>> +
>> +	/* we have hca_core_clock in MHz, so to translate cycles to nsecs
>> +	 * we need to divide cycles by freq and multiply by 1000;
>> +	 * in order to get precise result we shift left the value,
>> +	 * since we don't have floating point there;
>> +	 * at the end shift result back
>> +	 */
>> +	temp_mult = ((1ull * 1000) << 29) / dev->caps.hca_core_clock;
>> +	mdev->cycles.mult = (u32)temp_mult;
>> +	mdev->cycles.shift = 29;
>> +
>> +	timecounter_init(&mdev->clock, &mdev->cycles,
>> +			 ktime_to_ns(ktime_get_real()));
> I didn't see any watchdog code to read this clock periodically, in order to catch overflows.

Thanks for pointing this out, will look on that and see what needs to be 
fixed for V2

Or.
