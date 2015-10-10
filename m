From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Sat, 10 Oct 2015 11:56:19 -0400
Message-ID: <20151010155619.GA14572@ketchup>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
 <20151010070434.GB1990@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54408 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbJJQCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 12:02:16 -0400
Content-Disposition: inline
In-Reply-To: <20151010070434.GB1990@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Saturday 10 (41) 09:04 AM, Jiri Pirko wrote:
> Sat, Oct 10, 2015 at 04:53:52AM CEST, sfeldma@gmail.com wrote:
> >On Thu, Oct 8, 2015 at 9:38 PM, Premkumar Jonnala <pjonnala@broadcom.com> wrote:
> >>
> >>
> >>> -----Original Message-----
> >>> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
> >>> Sent: Friday, October 09, 2015 7:53 AM
> >>> To: netdev@vger.kernel.org
> >>> Cc: davem@davemloft.net; jiri@resnulli.us; siva.mannem.lnx@gmail.com;
> >>> Premkumar Jonnala; stephen@networkplumber.org;
> >>> roopa@cumulusnetworks.com; andrew@lunn.ch; f.fainelli@gmail.com;
> >>> vivien.didelot@savoirfairelinux.com
> >>> Subject: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time down
> >>> to switchdev
> >>>
> >>> From: Scott Feldman <sfeldma@gmail.com>
> >>>
> >>> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
> >>> support setting ageing_time (or setting bridge attrs in general).
> >>>
> >>> If push fails, don't update ageing_time in bridge and return err to user.
> >>>
> >>> If push succeeds, update ageing_time in bridge and run gc_timer now to
> >>> recalabrate when to run gc_timer next, based on new ageing_time.
> >>>
> >>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> >>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> >
> ><snip>
> >
> >>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
> >>> +{
> >>> +     struct switchdev_attr attr = {
> >>> +             .id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
> >>> +             .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
> >>> +             .u.ageing_time = ageing_time,
> >>> +     };
> >>> +     unsigned long t = clock_t_to_jiffies(ageing_time);
> >>> +     int err;
> >>> +
> >>> +     if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
> >>> +             return -ERANGE;
> >>> +
> >>> +     err = switchdev_port_attr_set(br->dev, &attr);
> >>
> >> A thought - given that the ageing time is not a per-bridge-port attr, why are we using a "port based api"
> >> to pass the attribute down?  May be I'm missing something here?
> >
> >I think Florian raised the same point earlier.  Sigh, I think this
> >should be addressed....v4 coming soon...thanks guys for keeping the
> >standard high.
> 
> Scott, can you tell us how do you want to address this? I like the
> current implementation.

Scott, didn't you have a plan to add a struct device for the parent of
switchdev ports?

I think it would be good to introduce such device with an helper to
retrieve this upper parent, and move the switchdev ops to this guy.

So switchdev drivers may implement such API calls:

    .obj_add(struct device *swdev, struct switchdev_obj *obj);

    .port_obj_add(struct device *swdev, struct net_device *port,
                  struct switchdev_obj *obj);

Then switchdev code may have a parent API and the current port API may
look like this:

    int switchdev_port_obj_add(struct net_device *dev,
                               struct switchdev_obj *obj)
    {
        struct device *swdev = switchdev_get_parent(dev);
        int err = -EOPNOTSUPP;

        if (swdev && swdev->switchdev_ops &&
            swdev->switchdev_ops->port_obj_add)
            err = swdev->switchdev_ops->port_obj_add(swdev, dev, obj);

        return err;
    }

Thanks,
-v
