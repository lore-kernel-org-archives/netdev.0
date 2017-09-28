From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC net-next] ravb: RX checksum offload
Date: Thu, 28 Sep 2017 22:56:32 +0300
Message-ID: <cc6f731d-2192-995f-4194-5dd6600c4d5b@cogentembedded.com>
References: <1505221489-12870-1-git-send-email-horms+renesas@verge.net.au>
 <9dcbc418-128b-2eff-970f-b586b9a3cee6@cogentembedded.com>
 <20170928104918.GA11212@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170928104918.GA11212@verge.net.au>
Content-Language: en-MW
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 09/28/2017 01:49 PM, Simon Horman wrote:

>>> Add support for RX checksum offload. This is enabled by default and
>>> may be disabled and re-enabled using ethtool:
>>>
>>>   # ethtool -K eth0 rx off
>>>   # ethtool -K eth0 rx on
>>>
>>> The RAVB provides a simple checksumming scheme which appears to be
>>> completely compatible with CHECKSUM_COMPLETE: a 1's complement sum of
>>
>>     Hm, the gen2/3 manuals say calculation doesn't involve bit inversion...
> 
> Yes, I believe that matches my observation of the values supplied by
> the hardware. Empirically this appears to be what the kernel expects.

    Then why you talk of 1's complement here?

>>> all packet data after the L2 header is appended to packet data; this may
>>> be trivially read by the driver and used to update the skb accordingly.
>>>
>>> In terms of performance throughput is close to gigabit line-rate both with
>>> and without RX checksum offload enabled. Perf output, however, appears to
>>> indicate that significantly less time is spent in do_csum(). This is as
>>> expected.
>>
>> [...]
>>
>>> By inspection this also appears to be compatible with the ravb found
>>> on R-Car Gen 2 SoCs, however, this patch is currently untested on such
>>> hardware.
>>
>>     I probably won't be able to test it on gen2 too...
>>
>>> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>>
>>     I'm generally OK with the patch but have some questions/comments below...
> 
> Thanks, I will try to address them.
> 
>>> ---
>>>   drivers/net/ethernet/renesas/ravb_main.c | 58 +++++++++++++++++++++++++++++++-
>>>   1 file changed, 57 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
>>> index fdf30bfa403b..7c6438cd7de7 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>> [...]
>>> @@ -1842,6 +1859,41 @@ static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
>>>   	return phy_mii_ioctl(phydev, req, cmd);
>>>   }
>>> +static void ravb_set_rx_csum(struct net_device *ndev, bool enable)
>>> +{
>>> +	struct ravb_private *priv = netdev_priv(ndev);
>>> +	unsigned long flags;
>>> +
>>> +	spin_lock_irqsave(&priv->lock, flags);
>>> +
>>> +	/* Disable TX and RX */
>>> +	ravb_rcv_snd_disable(ndev);
>>> +
>>> +	/* Modify RX Checksum setting */
>>> +	if (enable)
>>> +		ravb_modify(ndev, ECMR, 0, ECMR_RCSC);
>>
>>     Please use ECMR_RCSC as the 3rd argument too to conform the common driver
>> style.
>>
>>> +	else
>>> +		ravb_modify(ndev, ECMR, ECMR_RCSC, 0);
>>
>>     This *if* can easily be folded into a single ravb_modify() call...
> 
> Thanks, something like this?
> 
> 	ravb_modify(ndev, ECMR, ECMR_RCSC, enable ? ECMR_RCSC : 0);

    Yes, exactly! :-)

>> [...]
>>> @@ -2004,6 +2057,9 @@ static int ravb_probe(struct platform_device *pdev)
>>>   	if (!ndev)
>>>   		return -ENOMEM;
>>> +	ndev->features |= NETIF_F_RXCSUM;
>>> +	ndev->hw_features |= ndev->features;
>>
>>     Hum, both fields are 0 before this? Then why not use '=' instead of '|='?
>> Even if not, why not just use the same value as both the rvalues?
> 
> I don't feel strongly about this, how about?
> 
> 	ndev->features = NETIF_F_RXCSUM;
> 	ndev->hw_features = NETIF_F_RXCSUM;

    Yes, I think it should work...

MBR, Sergei
