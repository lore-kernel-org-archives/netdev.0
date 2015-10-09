From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 2/3] switchdev: allow caller to explicitly
 use deferred attr_set version
Date: Thu, 8 Oct 2015 21:39:41 -0700
Message-ID: <CAE4R7bAXqd6HeO-FxONXJgJTGVvgv5JawxGtZJvidZ4Uc4ePJw@mail.gmail.com>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
 <1444242652-17260-3-git-send-email-jiri@resnulli.us> <CAE4R7bAUQ+bPe0fMZsULnTuZKg4t2-RterSqKDS2H=OzZpW1Nw@mail.gmail.com>
 <20151008053933.GA2186@nanopsycho.orion> <CAE4R7bCozKS8e4SLKHLZVkq8n-OYXyjEni=vyZHo540WbxvbiA@mail.gmail.com>
 <20151008082631.GB2186@nanopsycho.orion>
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
Received: from mail-ob0-f177.google.com ([209.85.214.177]:34376 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933105AbbJIEkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 00:40:02 -0400
Received: by obbda8 with SMTP id da8so54478026obb.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 21:40:01 -0700 (PDT)
In-Reply-To: <20151008082631.GB2186@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 1:26 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 08, 2015 at 08:03:35AM CEST, sfeldma@gmail.com wrote:
>>On Wed, Oct 7, 2015 at 10:39 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Oct 08, 2015 at 06:27:07AM CEST, sfeldma@gmail.com wrote:
>>>>On Wed, Oct 7, 2015 at 11:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>>
>>>>> Caller should know if he can call attr_set directly (when holding RTNL)
>>>>> or if he has to use deferred version of this function.
>>>>>
>>>>> This also allows drivers to sleep inside attr_set and report operation
>>>>> status back to switchdev core. Switchdev core then warns if status is
>>>>> not ok, instead of silent errors happening in drivers.
>>>>>
>>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>>> ---
>>>>>  include/net/switchdev.h   |   2 +
>>>>>  net/bridge/br_stp.c       |   4 +-
>>>>>  net/switchdev/switchdev.c | 113 +++++++++++++++++++++++++---------------------
>>>>>  3 files changed, 65 insertions(+), 54 deletions(-)
>>>>>
>>>>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>>>> index 89266a3..320be44 100644
>>>>> --- a/include/net/switchdev.h
>>>>> +++ b/include/net/switchdev.h
>>>>> @@ -168,6 +168,8 @@ int switchdev_port_attr_get(struct net_device *dev,
>>>>>                             struct switchdev_attr *attr);
>>>>>  int switchdev_port_attr_set(struct net_device *dev,
>>>>>                             struct switchdev_attr *attr);
>>>>> +int switchdev_port_attr_set_deferred(struct net_device *dev,
>>>>> +                                    struct switchdev_attr *attr);
>>>>
>>>>Rather than adding another op, use attr->flags and define:
>>>>
>>>>#define SWITCHDEV_F_DEFERRED          BIT(x)
>>>>
>>>>So we get:
>>>>
>>>>void br_set_state(struct net_bridge_port *p, unsigned int state)
>>>>{
>>>>        struct switchdev_attr attr = {
>>>>                .id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>>>>+              .flags = SWITCHDEV_F_DEFERRED,
>>>>                .u.stp_state = state,
>>>>        };
>>>>        int err;
>>>>
>>>>        p->state = state;
>>>>        err = switchdev_port_attr_set(p->dev, &attr);
>>>>        if (err && err != -EOPNOTSUPP)
>>>>                br_warn(p->br, "error setting offload STP state on
>>>>port %u(%s)\n",
>>>>                                (unsigned int) p->port_no,
>>>>p->dev->name);
>>>>}
>>>>
>>>>(And add obj->flags to do the same).
>>>
>>> That's what I wanted to avoid. Also because the obj is const and for
>>> call from work, this flag would have to be removed.
>>
>>What did you want to avoid?
>
> Having this as a flag. I don't like it too much.
> But that is cosmetics. Other than that, does the patchset make sense?
> Do you see some possible issues?

patch 1/3 makes sense, I tested it out and no issues.  (Looks like
there are other places to assert rtnl_lock, are you going to add
those?)

patch 2/3: Rather than trying to guess the call context in the core,
make the caller call the right variant for its context.  That part is
good.  On the flag vs. no flags, the reasons why I want this as a flag
are:

a) I want to keep the switchdev ops set to the core set: get/set attr
and add/del/dump objs.  I've pushed back on changing this before.  I
don't want ops explosion (like netdev_ops), and I'd like to avoid the
1000-line patch when the arg list in an op changes, and we need to
update N drivers.  The flags lets the caller modify the algo behavior,
while keeping the core call (and args) fixed.

b) the caller can combine flags, where it makes sense.  For example,
maybe I'm in a locked context and I don't want to recurse the device
tree, so I would make the call with NO_RECURSE | DEFERRED.  If we
didn't use flags, then we need to supply ops for each variant on the
call, and then things explode.

patch 3/3 I haven't looked at yet...I'm stuck on 2/3.
