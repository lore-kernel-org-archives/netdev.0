From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs
 ops
Date: Thu, 02 Apr 2015 12:05:33 -0400 (EDT)
Message-ID: <20150402.120533.225417156120458098.davem@davemloft.net>
References: <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
	<20150401.140822.2230858157895026713.davem@davemloft.net>
	<CAE4R7bC+fSjEP+uz19L9mbjf1Y+sPUM=Z7iuDtQdhPAZA1x3sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbbDBQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 12:05:41 -0400
In-Reply-To: <CAE4R7bC+fSjEP+uz19L9mbjf1Y+sPUM=Z7iuDtQdhPAZA1x3sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Thu, 2 Apr 2015 00:43:57 -0700

> On Wed, Apr 1, 2015 at 11:08 AM, David Miller <davem@davemloft.net> wrote:
>> From: sfeldma@gmail.com
>> Date: Wed,  1 Apr 2015 03:07:37 -0700
>>
>>> +int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
>>> +{
>>> +     struct swdev_attr prev = *attr;
>>> +     int err, get_err, revert_err;
>>> +
>>> +     get_err = swdev_port_attr_get(dev, &prev);
>>> +
>>> +     err = __swdev_port_attr_set(dev, attr);
>>> +     if (err && !get_err && !(attr->flags & SWDEV_F_NO_RECOVER)) {
>>> +             /* Some err on set: revert to previous value */
>>> +             revert_err = __swdev_port_attr_set(dev, &prev);
>>> +             if (revert_err)
>>> +                     netdev_err(dev, "Reverting swdev port attr %d failed\n",
>>> +                                attr->id);
>>> +     }
>>> +
>>> +     return err;
>>
>> This style of error recovery doesn't work.
>>
>> You have to have a prepare/commit model to do this sanely, because
>> otherwise:
>>
>> 1) Partial state updates can be seen by the data plane (and other
>>    code paths) that do not use RTNL mutex protection.
>>
>> 2) It is absoultely expected that if some resource allocation failed
>>    when switching to the new attribute value, the same exactly thing
>>    is extremely likely during the rollback.
>>
>> So you have to code this in a way that no partial state updates are
>> ever visible, and also that rollbacks don't fail.
> 
> I'm sending v3 with a prepare/commit model, for attr sets and obj
> adds.  The prepare phase asks driver(s) if set/add will work (is
> supported and device resource is available).  If yes, then do commit
> phase.   Commit could still fail due to failures outside the control
> of the driver, like ENOMEM.  In that case, WARN and return err.

Scott, the whole purpose of the prepare phase is the allocate any
necessary resources so that they are available for the commit phase.
It needs to do this in addition to validating the incoming arguments.

If some part of the prepare phase fails, you go back and release any
pre-allocated resources.

The commit phase must not fail.
