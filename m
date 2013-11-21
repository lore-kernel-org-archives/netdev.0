From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH RFC v1 7/7] net: cpsw: resume/suspend PHY on port start/stop
Date: Thu, 21 Nov 2013 09:41:13 +0100
Message-ID: <528DC729.1000506@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1384978913-8052-8-git-send-email-sebastian.hesselbarth@gmail.com> <528DC5DD.8040801@ti.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <528DC5DD.8040801@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/21/2013 09:35 AM, Mugunthan V N wrote:
> On Thursday 21 November 2013 01:51 AM, Sebastian Hesselbarth wrote:
>> Network PHYs consume a noticable amount of power. This adds phy_resume
>> on slave_open and phy_suspend on slave_stop to save this power if the
>> port is down anyway.
>>
>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>> ---
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>   drivers/net/ethernet/ti/cpsw.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 90d41d2..f1dc54f 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -1013,6 +1013,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>>   	} else {
>>   		dev_info(priv->dev, "phy found : id is : 0x%x\n",
>>   			 slave->phy->phy_id);
>> +		phy_resume(slave->phy);
>>   		phy_start(slave->phy);
>>
>>   		/* Configure GMII_SEL register */
>> @@ -1081,6 +1082,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
>>   	if (!slave->phy)
>>   		return;
>>   	phy_stop(slave->phy);
>> +	phy_suspend(slave->phy);
>>   	phy_disconnect(slave->phy);
>>   	slave->phy = NULL;
>>   }
>
> Can these be called from phy_start and phy_stop itself so that it
> reduces the effort of patching all drivers and also applies to all
> etherent drivers.

Mugunthan,

Florian already mentioned that and I was already guessing that it will
be better hidden within the PHY state machine, too.

My current idea is to have a new state, that Florian also mentioned,
with the following behavior: On phy_stop the PHY will drop down to
suspend if (a) the PHY driver provides a suspend callback and (b) if
there is nothing enabled that requires the PHY to remain powered, e.g.
WoL.

Anyway, I'll have to dig into PHY state machine internals for that
first.

Sebastian
