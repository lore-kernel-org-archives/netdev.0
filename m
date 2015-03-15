From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using netlink.
Date: Sat, 14 Mar 2015 18:16:20 -0700
Message-ID: <CAE4R7bCfheBYqGaDA1-QmvYv+e1gK+daHqkg9i_hDoY+qNiG4g@mail.gmail.com>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
	<CAE4R7bCAfrJDMZMEKhurd2axe0vpo+peZt7DdUMKwWhtwNaMnw@mail.gmail.com>
	<CA+CtxLQXOqO6FvB4=8YzXmUDDhEa1HmoNYbMyOwnOB=xBxZ4WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:33437 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbCOBQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 21:16:20 -0400
Received: by qcyi15 with SMTP id i15so17952035qcy.0
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 18:16:20 -0700 (PDT)
In-Reply-To: <CA+CtxLQXOqO6FvB4=8YzXmUDDhEa1HmoNYbMyOwnOB=xBxZ4WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 14, 2015 at 4:36 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> On Sun, Mar 15, 2015 at 3:47 AM, Scott Feldman <sfeldma@gmail.com> wrote:
>> On Fri, Mar 13, 2015 at 6:40 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
>>> This patch allows user to configure bridge's FDB ageing using
>>> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
>>> as per ieee8021QBridgeFdbAgingTime.
>>>
>>> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
>>> ---
>>> Changes in v2:
>>>  - Added commit message.
>>>  - Fix style problems reported by checkpatch.pl.
>>
>>
>>> +
>>> +int br_set_ageing_time(struct net_bridge *br, unsigned long val)
>>> +{
>>> +       unsigned long t = clock_t_to_jiffies(val);
>>> +
>>> +       if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>>> +               return -ERANGE;
>>> +
>>> +       spin_lock_bh(&br->lock);
>>> +       br->ageing_time = t;
>>
>> I wonder if you need to call mod_timer(&br->gc_timer, jiffies) after
>> adjusting the time, to make new ageing_time effective?  The worst-case
>> scenario I'm thinking about is if the initial br->ageing_time is the
>> max value (1000000 seconds) and the user changes it the min value (10
>> seconds), will the original 1000000 seconds need to expire before the
>> gc_timer is called again and reset to 10 seconds?
>>
> Yes, the new ageing_time becomes effective only after the current timer expires.
> The behavior when ageing_time is set via netlink  is similar to setting it using
> sysfs and brctl. I want to keep the behavior same when the ageing_time is
> configured using any of the existing mechanisms.

Right, looks like sysfs and brctl (ioctl) don't reset gc_timer, so
you're consistent there.  :)

Consistency is good.  What do you think about a new func that's called
from either of the three interfaces (sysfs, ioctl, netlink) that:

1) validates range, like in your br_set_ageing_time() func.
2) reset gc_timer if setting ageing_time to lower value

?
