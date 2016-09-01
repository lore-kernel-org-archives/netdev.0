From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 1/2] net: smsc911x: Fix register_netdev, phy startup,
 driver unload ordering
Date: Thu, 1 Sep 2016 13:42:59 -0500
Message-ID: <a33771de-a591-d65e-90e8-33860100e40a@arm.com>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-2-git-send-email-jeremy.linton@arm.com>
 <20160901165806.GC10951@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38634 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757050AbcIAVIw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:08:52 -0400
In-Reply-To: <20160901165806.GC10951@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2016 11:58 AM, Andrew Lunn wrote:
>> @@ -1520,17 +1513,22 @@ static int smsc911x_open(struct net_device *dev)
>>  	unsigned int timeout;
>>  	unsigned int temp;
>>  	unsigned int intcfg;
>> +	int retval;
>>
>> -	/* if the phy is not yet registered, retry later*/
>> +	/* find and start the given phy */
>>  	if (!dev->phydev) {
>> -		SMSC_WARN(pdata, hw, "phy_dev is NULL");
>> -		return -EAGAIN;
>> +		if (smsc911x_mii_probe(dev) < 0) {
>> +			SMSC_WARN(pdata, probe, "Error starting phy");
>> +			retval = -EAGAIN;
>
> smsc911x_mii_probe() returns an error code. It is better to use that,
> than -EAGAIN, which is rather odd to start with.

	Thats a good point, I was just maintaining the existing behavior, but 
its definitely better to just return the actual error.

>
>> +			goto out;
>> +		}
>>  	}
>>
>>  	/* Reset the LAN911x */
>>  	if (smsc911x_soft_reset(pdata)) {
>>  		SMSC_WARN(pdata, hw, "soft reset failed");
>> -		return -EIO;
>> +		retval = -EIO;
>> +		goto mii_free_out;
>
> smsc911x_soft_reset() also returns an error code you should use.
>
> This patch also seems to do quite a few different things. Please can
> you break it up into multiple patches.
	

	That was the comment from the previous patch, but It confused me 
because it was only really moving the MDIO startup, the rest was a side 
effect of that and atomic to it (AKA it wasn't clear how to make it 
smaller). I read it as Steve misinterpreting the laundry list of fixes 
as things being individually fixed, rather than one thing fixing a bunch 
of stuff.

This patch does add additional code I overlooked to cleanup the phy if 
it fails, I guess in theory that portion could be a prereq patch, I will 
break that portion out. I'm still not sure how to partially move the 
MDIO startup...
