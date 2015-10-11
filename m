From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Sat, 10 Oct 2015 17:07:24 -0700
Message-ID: <CAGVrzcYJo5B_AzKN247_Knqq1r4FTz6cpFXvt927AnR162UoYg@mail.gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com> <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
 <20151010070434.GB1990@nanopsycho.orion> <20151010155619.GA14572@ketchup>
 <20151010210919.GA2217@nanopsycho.orion> <20151010224121.GA27091@ketchup.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36258 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbJKAIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 20:08:05 -0400
Received: by ioii196 with SMTP id i196so122768930ioi.3
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 17:08:04 -0700 (PDT)
In-Reply-To: <20151010224121.GA27091@ketchup.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-10 15:41 GMT-07:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> On Oct. Saturday 10 (41) 11:09 PM, Jiri Pirko wrote:
>> Sat, Oct 10, 2015 at 05:56:19PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>> >On Oct. Saturday 10 (41) 09:04 AM, Jiri Pirko wrote:
>> >> Sat, Oct 10, 2015 at 04:53:52AM CEST, sfeldma@gmail.com wrote:
>> >> >On Thu, Oct 8, 2015 at 9:38 PM, Premkumar Jonnala <pjonnala@broadcom.com> wrote:
>> >> >>
>> >> >>
>> >> >>> -----Original Message-----
>> >> >>> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
>> >> >>> Sent: Friday, October 09, 2015 7:53 AM
>> >> >>> To: netdev@vger.kernel.org
>> >> >>> Cc: davem@davemloft.net; jiri@resnulli.us; siva.mannem.lnx@gmail.com;
>> >> >>> Premkumar Jonnala; stephen@networkplumber.org;
>> >> >>> roopa@cumulusnetworks.com; andrew@lunn.ch; f.fainelli@gmail.com;
>> >> >>> vivien.didelot@savoirfairelinux.com
>> >> >>> Subject: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time down
>> >> >>> to switchdev
>> >> >>>
>> >> >>> From: Scott Feldman <sfeldma@gmail.com>
>> >> >>>
>> >> >>> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
>> >> >>> support setting ageing_time (or setting bridge attrs in general).
>> >> >>>
>> >> >>> If push fails, don't update ageing_time in bridge and return err to user.
>> >> >>>
>> >> >>> If push succeeds, update ageing_time in bridge and run gc_timer now to
>> >> >>> recalabrate when to run gc_timer next, based on new ageing_time.
>> >> >>>
>> >> >>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> >> >>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> >
>> >> ><snip>
>> >> >
>> >> >>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>> >> >>> +{
>> >> >>> +     struct switchdev_attr attr = {
>> >> >>> +             .id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>> >> >>> +             .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>> >> >>> +             .u.ageing_time = ageing_time,
>> >> >>> +     };
>> >> >>> +     unsigned long t = clock_t_to_jiffies(ageing_time);
>> >> >>> +     int err;
>> >> >>> +
>> >> >>> +     if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>> >> >>> +             return -ERANGE;
>> >> >>> +
>> >> >>> +     err = switchdev_port_attr_set(br->dev, &attr);
>> >> >>
>> >> >> A thought - given that the ageing time is not a per-bridge-port attr, why are we using a "port based api"
>> >> >> to pass the attribute down?  May be I'm missing something here?
>> >> >
>> >> >I think Florian raised the same point earlier.  Sigh, I think this
>> >> >should be addressed....v4 coming soon...thanks guys for keeping the
>> >> >standard high.
>> >>
>> >> Scott, can you tell us how do you want to address this? I like the
>> >> current implementation.
>> >
>> >Scott, didn't you have a plan to add a struct device for the parent of
>> >switchdev ports?
>> >
>> >I think it would be good to introduce such device with an helper to
>> >retrieve this upper parent, and move the switchdev ops to this guy.
>> >
>> >So switchdev drivers may implement such API calls:
>> >
>> >    .obj_add(struct device *swdev, struct switchdev_obj *obj);
>> >
>> >    .port_obj_add(struct device *swdev, struct net_device *port,
>> >                  struct switchdev_obj *obj);
>> >
>> >Then switchdev code may have a parent API and the current port API may
>> >look like this:
>> >
>> >    int switchdev_port_obj_add(struct net_device *dev,
>> >                               struct switchdev_obj *obj)
>> >    {
>> >        struct device *swdev = switchdev_get_parent(dev);
>> >        int err = -EOPNOTSUPP;
>> >
>> >        if (swdev && swdev->switchdev_ops &&
>> >            swdev->switchdev_ops->port_obj_add)
>> >            err = swdev->switchdev_ops->port_obj_add(swdev, dev, obj);
>> >
>> >        return err;
>> >    }
>>
>> Fro the record, I don't see any reason for this "device". It would just
>> introduce unnecessary complexicity. So far, we are fine without it.
>
> I wouldn't say that. I beleive that an Ethernet switch deserves its
> struct device in the tree, since it is a physical chip, like any other.

Agreed, but gating these patches because we do not yet have a device
driver model for an Ethernet switch outside of its individual ports
does not seem like it hurts the current patch series, nor the existing
model (and future).

>
> Configuring it through one of its port (net_device) is fine, since you
> want to change the port behavior, and Linux config is on per-port basis.
>
> But the complexity is already introduced in the struct net_device with
> the switchdev_ops. These ops really belong to the parent device, not to
> all of its ports.

I am not sure if complexity is the correct term here, bloat (to some
extent) maybe, since with what you are suggesting we could save one
set of function pointers per-port, and instead move that to a
global/switch-wide device implementing these operations. In essence,
there will be per-port switchdev_ops, bridge-specific, and maybe in
the future switch device specific.

>
> Ideally a switch device would be registered with this set of operations,
> creates its net_devices, and will be accessible from a port net_device
> through a netdev helper function.

I think the core of the discussion for a proper Ethernet switch device
model is precisely whether we want to have a special network device to
configure the switch as a whole. It sure would represent one facet of
the switch device, but not everything else for which we are still
trying to find out what that is.
-- 
Florian
