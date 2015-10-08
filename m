From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next RFC 2/3] switchdev: allow caller to explicitly
 use deferred attr_set version
Date: Wed, 7 Oct 2015 23:03:35 -0700
Message-ID: <CAE4R7bCozKS8e4SLKHLZVkq8n-OYXyjEni=vyZHo540WbxvbiA@mail.gmail.com>
References: <1444242652-17260-1-git-send-email-jiri@resnulli.us>
 <1444242652-17260-3-git-send-email-jiri@resnulli.us> <CAE4R7bAUQ+bPe0fMZsULnTuZKg4t2-RterSqKDS2H=OzZpW1Nw@mail.gmail.com>
 <20151008053933.GA2186@nanopsycho.orion>
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
Received: from mail-oi0-f45.google.com ([209.85.218.45]:32953 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbJHGDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 02:03:55 -0400
Received: by oixx17 with SMTP id x17so21696892oix.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 23:03:54 -0700 (PDT)
In-Reply-To: <20151008053933.GA2186@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 10:39 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Oct 08, 2015 at 06:27:07AM CEST, sfeldma@gmail.com wrote:
>>On Wed, Oct 7, 2015 at 11:30 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Caller should know if he can call attr_set directly (when holding RTNL)
>>> or if he has to use deferred version of this function.
>>>
>>> This also allows drivers to sleep inside attr_set and report operation
>>> status back to switchdev core. Switchdev core then warns if status is
>>> not ok, instead of silent errors happening in drivers.
>>>
>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>> ---
>>>  include/net/switchdev.h   |   2 +
>>>  net/bridge/br_stp.c       |   4 +-
>>>  net/switchdev/switchdev.c | 113 +++++++++++++++++++++++++---------------------
>>>  3 files changed, 65 insertions(+), 54 deletions(-)
>>>
>>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>> index 89266a3..320be44 100644
>>> --- a/include/net/switchdev.h
>>> +++ b/include/net/switchdev.h
>>> @@ -168,6 +168,8 @@ int switchdev_port_attr_get(struct net_device *dev,
>>>                             struct switchdev_attr *attr);
>>>  int switchdev_port_attr_set(struct net_device *dev,
>>>                             struct switchdev_attr *attr);
>>> +int switchdev_port_attr_set_deferred(struct net_device *dev,
>>> +                                    struct switchdev_attr *attr);
>>
>>Rather than adding another op, use attr->flags and define:
>>
>>#define SWITCHDEV_F_DEFERRED          BIT(x)
>>
>>So we get:
>>
>>void br_set_state(struct net_bridge_port *p, unsigned int state)
>>{
>>        struct switchdev_attr attr = {
>>                .id = SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>>+              .flags = SWITCHDEV_F_DEFERRED,
>>                .u.stp_state = state,
>>        };
>>        int err;
>>
>>        p->state = state;
>>        err = switchdev_port_attr_set(p->dev, &attr);
>>        if (err && err != -EOPNOTSUPP)
>>                br_warn(p->br, "error setting offload STP state on
>>port %u(%s)\n",
>>                                (unsigned int) p->port_no,
>>p->dev->name);
>>}
>>
>>(And add obj->flags to do the same).
>
> That's what I wanted to avoid. Also because the obj is const and for
> call from work, this flag would have to be removed.

What did you want to avoid?
