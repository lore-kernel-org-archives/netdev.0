From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Wed, 1 Feb 2017 10:55:46 -0800
Message-ID: <264c73a7-8294-23f0-88e9-1f27d558cbf8@gmail.com>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
 <20170201102208.GM27312@n2100.armlinux.org.uk>
 <20170201105121.GA8191@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        Mao Wenan <maowenan@huawei.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33729 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752862AbdBASzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 13:55:49 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so32316118pfg.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 10:55:49 -0800 (PST)
In-Reply-To: <20170201105121.GA8191@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 02:51 AM, Russell King - ARM Linux wrote:
> On Wed, Feb 01, 2017 at 10:22:08AM +0000, Russell King - ARM Linux wrote:
>> On Tue, Jan 31, 2017 at 06:46:43PM -0800, Florian Fainelli wrote:
>>> From: Mao Wenan <maowenan@huawei.com>
>>>
>>> There is currently no reference count being held on the PHY driver,
>>> which makes it possible to remove the PHY driver module while the PHY
>>> state machine is running and polling the PHY. This could cause crashes
>>> similar to this one to show up:
>>
>> Does this really solve the problem?  What if you use sysfs to unbind the
>> driver but without removing the module?
> 
> I think that's a problem, and the patch is just solving a symptom of
> it.

You are right, but there is still a fundamental problem IMHO in that you
should not be able to rmmod a PHY driver as long as a network device is
attached to the PHY, and if the PHY driver is attached from several
different network devices, they should all have a way to prevent a PHY
driver rmmod, each of them incrementing the driver refcount, which is
what the patche from Maowan does here.


> 
> If a phy driver is unbound from a device, phy_remove() will be called.
> This will set the state to PHY_DOWN (under the mutex) before calling
> the driver's remove function (if any), and finally setting phydev->drv
> to NULL.
> 
> If phy_state_machine() is called after that point, then:
> 
> void phy_state_machine(struct work_struct *work)
> {
> ...
>         if (phydev->drv->link_change_notify)
>                 phydev->drv->link_change_notify(phydev);
> 
> which happens unconditionally, causes a NULL pointer dereference, which
> is probably the same NULL pointer dereference given in Mao Wenan's patch
> description.

Yep, that's exactly the location, but then after fixing that, we can
still crash in other locations, e.g: if we bring down an interface that
was attached to the PHY we would now crash in phy_suspend ->
phy_ethtool_get_wol

All of that can be fixed, and actually should be fixed, but it still
feels like we should have an easier way to prevent the driver removal IMHO.

> 
> It looks to me as if that's the only case where this can happen, so maybe
> the above needs to be:
> 
>         if (phydev->drv && phydev->drv->link_change_notify)
>                 phydev->drv->link_change_notify(phydev);
> 
> Also, I'd suggest making sure that the workqueue is flushed in
> phy_remove() after setting phydev->drv to NULL to ensure that the
> workqueue isn't running while the phy driver is being unbound, which
> should also make module removal safe(r).  I haven't fully analysed
> that though.

That is reasonable to do as well, thanks!
-- 
Florian
