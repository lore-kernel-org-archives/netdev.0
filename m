From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/5] net: phy: bcm7xxx: Add support for
 downshift/Wirespeed
Date: Wed, 23 Nov 2016 10:16:00 -0800
Message-ID: <2cdf4aad-ed42-2065-f13e-dfea3069fef3@gmail.com>
References: <20161122194058.29820-1-f.fainelli@gmail.com>
 <20161122194058.29820-5-f.fainelli@gmail.com>
 <20161122200228.GG14947@lunn.ch>
 <1902f0f0-46e5-d3b3-90c1-10867f4fb826@gmail.com>
 <20161123114512.GB25778@microsemi.com> <20161123144636.GK14947@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        bcm-kernel-feedback-list@broadcom.com,
        raju.lakkaraju@microsemi.com, vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32768 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933077AbcKWSQD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 13:16:03 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so926326pfv.0
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 10:16:02 -0800 (PST)
In-Reply-To: <20161123144636.GK14947@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 06:46 AM, Andrew Lunn wrote:
>>>> Maybe we should think about this locking a bit. It is normal for the
>>>> lock to be held when using ops in the phy driver structure. The
>>>> exception is suspend/resume. Maybe we should also take the lock before
>>>> calling the phydev->drv->get_tunable() and phydev->drv->set_tunable()?
>>>
>>> Yes, that certainly seems like a good approach to me, let me cook a
>>> patch doing that.
>>
>> Just for my understanding (such that I will not make the same mistake again)...
>>
>> Why is it that phy functions such as get_wol needs to take the phy_lock and
>> others like get_tunable does not.
>>
>> I do understand the arguments on why the lock should be held by the caller of
>> get_tunable, but I do not understand why the same argument does not apply for
>> get_wol.
> 
> Hi Allan
> 
> phy_ethtool_get_wol and friends probably should take the
> phy_lock. This inconsistency is probably leading to locking
> bugs. e.g. at803x_set_wol() does a read-modify-write, and does not
> take the lock.
> 
> There is no comment in the patch adding phy_ethtool_set_wol() to say
> why the lock is not taken, and a quick look at the code does not
> suggest a reason why it could not be taken/released by
> phy_ethtool_set_wol().

Yes, this should happen. I don't see how we cannot have two user-space
processes not racing with each other here for instance, see
mv643xx_eth_get_wol and cpsw_get_wol.

> 
> I think it would be a good idea to change this.
> 
> phy_suspend()/phy_resume() might have good reasons to avoid the lock,
> i've no idea how it is supposed to work. Is there a danger something
> else is holding the lock and has already been suspended? I guess not,
> otherwise there is little hope suspend would work at all.

phy_suspend() and phy_resume() usually get called after phy_disconnect()
or phy_stop() have been invoked, and even then this is during the
Ethernet driver's suspend resume/resume path, so there is no room for
concurrency to occur (user space is quiesced, and the PHY state machine
is stopped/halted), but still, if we were to change the calling context
it would be a good idea to acquire phydev->lock.
-- 
Florian
