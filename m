From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 5/7] can: clear ctrlmode when close candev
Date: Mon, 03 Nov 2014 19:25:12 +0100
Message-ID: <5457C888.5010000@hartkopp.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-5-git-send-email-b29396@freescale.com> <5457AD40.7020606@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Dong Aisheng <b29396@freescale.com>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5457AD40.7020606@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/03/2014 05:28 PM, Marc Kleine-Budde wrote:
> On 10/29/2014 11:45 AM, Dong Aisheng wrote:
>> Currently priv->ctrlmode is not cleared when close_candev, so next time
>> the driver will still use this value to set controller even user
>> does not set any ctrl mode.
>> e.g.
>> Step 1. ip link set can0 up type can0 bitrate 1000000 loopback on
>> Controller will be in loopback mode
>> Step 2. ip link set can0 down
>> Step 3. ip link set can0 up type can0 bitrate 1000000
>> Controller will still be set to loopback mode in driver due to saved
>> priv->ctrlmode.
>>
>> This patch clears priv->ctrlmode when the CAN interface is closed,
>> and set it to correct mode according to next user setting.
> 
> Oliver, what do you think of this patch? It will introduce a subtle
> change to the userspace.

Hi Marc,

indeed the current policy is that ifdown/ifup doesn't change any setting.
When we start to clear priv->ctrlmode when setting the interface down the
question arises whether the bitrate(s) has/have to be wiped too.

Setting the interface down/up can be done with ip or ifconfig without changing
the controller settings.

So IMO we can not assume that people always use the 'all-in-one'

	ip link set can0 up type can0 bitrate 1000000

command as given in the example above.

You might also do it like this:

	ip link set can0 up type can0 bitrate 1000000 loopback on
	ip link set can0 down
	ip link set can0 type can0 loopback off
	ip link set can0 up

Finally I would vote to reject this patch to stay consistent.

When users like to fiddle with options like loopback they need to take care
about their 'expert' settings too.

Regards,
Oliver


> 
>> Signed-off-by: Dong Aisheng <b29396@freescale.com>
>> ---
>>  drivers/net/can/dev.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
>> index 02492d2..1fce485 100644
>> --- a/drivers/net/can/dev.c
>> +++ b/drivers/net/can/dev.c
>> @@ -671,6 +671,7 @@ void close_candev(struct net_device *dev)
>>  
>>  	del_timer_sync(&priv->restart_timer);
>>  	can_flush_echo_skb(dev);
>> +	priv->ctrlmode = 0;
>>  }
>>  EXPORT_SYMBOL_GPL(close_candev);
>>  
>>
> 
> 
