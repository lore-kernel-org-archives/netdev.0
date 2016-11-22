From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Tue, 22 Nov 2016 12:07:05 -0800
Message-ID: <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com, allan.nielsen@microsemi.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33161 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcKVUHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 15:07:07 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so2950043pgd.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 12:07:07 -0800 (PST)
In-Reply-To: <20161122200228.GG14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2016 12:02 PM, Andrew Lunn wrote:
>> +static int bcm7xxx_28nm_set_tunable(struct phy_device *phydev,
>> +				    struct ethtool_tunable *tuna,
>> +				    const void *data)
>> +{
>> +	u8 count = *(u8 *)data;
>> +	int ret;
>> +
>> +	switch (tuna->id) {
>> +	case ETHTOOL_PHY_DOWNSHIFT:
>> +		ret = bcm_phy_downshift_set(phydev, count);
>> +		break;
>> +	default:
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	if (ret)
>> +		return ret;
>> +
>> +	/* Disable EEE advertisment since this prevents the PHY
>> +	 * from successfully linking up, trigger auto-negotiation restart
>> +	 * to let the MAC decide what to do.
>> +	 */
>> +	ret = bcm_phy_set_eee(phydev, count == DOWNSHIFT_DEV_DISABLE);
>> +	if (ret)
>> +		return ret;
>> +
>> +	return genphy_restart_aneg(phydev);
>> +}
> 
> Hi Florian
> 
> Is the locking O.K. here? The core code does not take the phy lock.
> But i think your shadow register accesses at least need to be
> protected by the lock?

There should be some kind of protection, but I was expecting it to be
done at the caller level, so that when {get,set}_tunable run, they are
serialized with respect to each other, clearly, by looking at the code,
this is not the case.

> 
> Maybe we should think about this locking a bit. It is normal for the
> lock to be held when using ops in the phy driver structure. The
> exception is suspend/resume. Maybe we should also take the lock before
> calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?

Yes, that certainly seems like a good approach to me, let me cook a
patch doing that.
-- 
Florian
