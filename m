From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs ops
Date: Thu, 2 Apr 2015 00:43:57 -0700
Message-ID: <CAE4R7bC+fSjEP+uz19L9mbjf1Y+sPUM=Z7iuDtQdhPAZA1x3sA@mail.gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
	<1427882882-2533-2-git-send-email-sfeldma@gmail.com>
	<20150401.140822.2230858157895026713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:34057 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbDBHn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 03:43:58 -0400
Received: by qcay5 with SMTP id y5so61003570qca.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 00:43:57 -0700 (PDT)
In-Reply-To: <20150401.140822.2230858157895026713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 1, 2015 at 11:08 AM, David Miller <davem@davemloft.net> wrote:
> From: sfeldma@gmail.com
> Date: Wed,  1 Apr 2015 03:07:37 -0700
>
>> +int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>> +{
>> +     struct swdev_attr prev = *attr;
>> +     int err, get_err, revert_err;
>> +
>> +     get_err = swdev_port_attr_get(dev, &prev);
>> +
>> +     err = __swdev_port_attr_set(dev, attr);
>> +     if (err && !get_err && !(attr->flags & SWDEV_F_NO_RECOVER)) {
>> +             /* Some err on set: revert to previous value */
>> +             revert_err = __swdev_port_attr_set(dev, &prev);
>> +             if (revert_err)
>> +                     netdev_err(dev, "Reverting swdev port attr %d failed\n",
>> +                                attr->id);
>> +     }
>> +
>> +     return err;
>
> This style of error recovery doesn't work.
>
> You have to have a prepare/commit model to do this sanely, because
> otherwise:
>
> 1) Partial state updates can be seen by the data plane (and other
>    code paths) that do not use RTNL mutex protection.
>
> 2) It is absoultely expected that if some resource allocation failed
>    when switching to the new attribute value, the same exactly thing
>    is extremely likely during the rollback.
>
> So you have to code this in a way that no partial state updates are
> ever visible, and also that rollbacks don't fail.

I'm sending v3 with a prepare/commit model, for attr sets and obj
adds.  The prepare phase asks driver(s) if set/add will work (is
supported and device resource is available).  If yes, then do commit
phase.   Commit could still fail due to failures outside the control
of the driver, like ENOMEM.  In that case, WARN and return err.

> I also agree with Jamal that you should use the netlink attribute
> values for these attributes rather than inventing yet another
> namespace of ID numbers.

That doesn't work.  The netlink ids are distributed across multiple
enum lists, so you'll inevitably have collisions in ID number.
