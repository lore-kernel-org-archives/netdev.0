From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 2/3] switchdev: allow caller to explicitly
 use deferred attr_set version
Date: Fri, 9 Oct 2015 19:43:43 -0700
Message-ID: <CAE4R7bACFY0npZ2UBcWf8J1YimnpZRWah0=4oQ=+y0fh7zEJVw@mail.gmail.com>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
 <1444242652-17260-3-git-send-email-jiri@resnulli.us> <CAE4R7bAUQ+bPe0fMZsULnTuZKg4t2-RterSqKDS2H=OzZpW1Nw@mail.gmail.com>
 <20151008053933.GA2186@nanopsycho.orion> <CAE4R7bCozKS8e4SLKHLZVkq8n-OYXyjEni=vyZHo540WbxvbiA@mail.gmail.com>
 <20151008082631.GB2186@nanopsycho.orion> <CAE4R7bAXqd6HeO-FxONXJgJTGVvgv5JawxGtZJvidZ4Uc4ePJw@mail.gmail.com>
 <20151009064638.GG2161@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	john fastabend <john.fastabend@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34139 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbJJCoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 22:44:04 -0400
Received: by oiak8 with SMTP id k8so39223466oia.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 19:44:03 -0700 (PDT)
In-Reply-To: <20151009064638.GG2161@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 11:46 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Oct 09, 2015 at 06:39:41AM CEST, sfeldma@gmail.com wrote:
>>On Thu, Oct 8, 2015 at 1:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Oct 08, 2015 at 08:03:35AM CEST, sfeldma@gmail.com wrote:
>>>>On Wed, Oct 7, 2015 at 10:39 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> Thu, Oct 08, 2015 at 06:27:07AM CEST, sfeldma@gmail.com wrote:
>>>>>>On Wed, Oct 7, 2015 at 11:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>>>>
>>>>>>> Caller should know if he can call attr_set directly (when holding RTNL)
>>>>>>> or if he has to use deferred version of this function.
>>>>>>>
>>>>>>> This also allows drivers to sleep inside attr_set and report operation
>>>>>>> status back to switchdev core. Switchdev core then warns if status is
>>>>>>> not ok, instead of silent errors happening in drivers.
>>>>>>>
>>>>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>>>>> ---
>>>>>>>  include/net/switchdev.h   |   2 +
>>>>>>>  net/bridge/br_stp.c       |   4 +-
>>>>>>>  net/switchdev/switchdev.c | 113 +++++++++++++++++++++++++---------------------
>>>>>>>  3 files changed, 65 insertions(+), 54 deletions(-)
>>>>>>>
>>>>>>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>>>>>> index 89266a3..320be44 100644
>>>>>>> --- a/include/net/switchdev.h
>>>>>>> +++ b/include/net/switchdev.h
>>>>>>> @@ -168,6 +168,8 @@ int switchdev_port_attr_get(struct net_device *dev,
>>>>>>>                             struct switchdev_attr *attr);
>>>>>>>  int switchdev_port_attr_set(struct net_device *dev,
>>>>>>>                             struct switchdev_attr *attr);
>>>>>>> +int switchdev_port_attr_set_deferred(struct net_device *dev,
>>>>>>> +                                    struct switchdev_attr *attr);
>>>>>>
>>>>>>Rather than adding another op, use attr->flags and define:
>>>>>>
>>>>>>#define SWITCHDEV_F_DEFERRED          BIT(x)
>>>>>>
>>>>>>So we get:
>>>>>>
>>>>>>void br_set_state(struct net_bridge_port *p, unsigned int state)
>>>>>>{
>>>>>>        struct switchdev_attr attr = {
>>>>>>                .id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>>>>>>+              .flags = SWITCHDEV_F_DEFERRED,
>>>>>>                .u.stp_state = state,
>>>>>>        };
>>>>>>        int err;
>>>>>>
>>>>>>        p->state = state;
>>>>>>        err = switchdev_port_attr_set(p->dev, &attr);
>>>>>>        if (err && err != -EOPNOTSUPP)
>>>>>>                br_warn(p->br, "error setting offload STP state on
>>>>>>port %u(%s)\n",
>>>>>>                                (unsigned int) p->port_no,
>>>>>>p->dev->name);
>>>>>>}
>>>>>>
>>>>>>(And add obj->flags to do the same).
>>>>>
>>>>> That's what I wanted to avoid. Also because the obj is const and for
>>>>> call from work, this flag would have to be removed.
>>>>
>>>>What did you want to avoid?
>>>
>>> Having this as a flag. I don't like it too much.
>>> But that is cosmetics. Other than that, does the patchset make sense?
>>> Do you see some possible issues?
>>
>>patch 1/3 makes sense, I tested it out and no issues.  (Looks like
>>there are other places to assert rtnl_lock, are you going to add
>>those?)
>
> Sure, can you pinpoint the places?

Isn't every place we use netdev_for_each_lower_dev, like you mentioned
in 1/3 patch?

>>patch 2/3: Rather than trying to guess the call context in the core,
>>make the caller call the right variant for its context.  That part is
>>good.  On the flag vs. no flags, the reasons why I want this as a flag
>>are:
>>
>>a) I want to keep the switchdev ops set to the core set: get/set attr
>>and add/del/dump objs.  I've pushed back on changing this before.  I
>>don't want ops explosion (like netdev_ops), and I'd like to avoid the
>>1000-line patch when the arg list in an op changes, and we need to
>>update N drivers.  The flags lets the caller modify the algo behavior,
>>while keeping the core call (and args) fixed.
>>
>>b) the caller can combine flags, where it makes sense.  For example,
>>maybe I'm in a locked context and I don't want to recurse the device
>>tree, so I would make the call with NO_RECURSE | DEFERRED.  If we
>>didn't use flags, then we need to supply ops for each variant on the
>>call, and then things explode.
>
> Fair enough. I'll process this in.

Actually, I realized later that my reply here was only half true.
Part b) to combine flags for various calling situation is good.   Part
a) is bogus because I confused adding a new op or adding a new wrapper
to call existing op.  You did the latter; but I was complaining about
the former.  Sorry about that.  Regardless, port b) I think justifies
using flags.

>
>>
>>patch 3/3 I haven't looked at yet...I'm stuck on 2/3.
>
> It is very similar to 2/3, only for obj_add/del.

Do we have examples of a deferred obj add or del?  Maybe we should
hold off adding that support until someone finds a use-case.  I'm kind
of hoping there isn't a use-case, but who knows?
