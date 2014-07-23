From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: phy: Ensure the MDIO bus module is held
Date: Wed, 23 Jul 2014 11:46:35 -0700
Message-ID: <CAGVrzcZOE8BFEM+7b_6tygi0FTRneEr2bGiRHW_+7bk3fqF1Fg@mail.gmail.com>
References: <1406074570-13246-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406074570-13246-3-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAGVrzcarnqLRnr97FRB-GVKwQLebpYtV7DXHp2ZTmm1gVfY30Q@mail.gmail.com> <20140723184041.GA24850@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:47377 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbaGWSrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 14:47:16 -0400
Received: by mail-oa0-f47.google.com with SMTP id g18so2214791oah.20
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 11:47:15 -0700 (PDT)
In-Reply-To: <20140723184041.GA24850@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-23 11:40 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>:
> On 23 Jul 11:22 AM, Florian Fainelli wrote:
>> 2014-07-22 17:16 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>:
>> > @@ -614,10 +623,14 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>> >          */
>> >         err = phy_init_hw(phydev);
>> >         if (err)
>> > -               phy_detach(phydev);
>> > -       else
>> > -               phy_resume(phydev);
>> > +               goto err_module_put;
>> >
>> > +       phy_resume(phydev);
>> > +       return err;
>> > +
>> > +err_module_put:
>> > +       module_put(bus_module);
>> > +       phy_detach(phydev);
>>
>> Since we are calling phy_detach() which is also attempting to do a
>> module_put(), does not that result in one too many calls to
>> module_put() on error path?
>>
>
> As far as I can see all that module_get() and module_put() do
> is increment and decrement refcounters. Therefore, I think you can
> have as many module_{get,put}() calls as you want on a path.

Ok, I was concerned that in case that specific PHY device cannot be
registered, we might be decrementing the reference count twice, hence
making it 0. There might be another PHY device sitting on this same
MDIO bus, and since the reference count for the MDIO driver is now 0,
we could end up unloading that module.

Exercising that specific case is not probably easy to trigger.
-- 
Florian
