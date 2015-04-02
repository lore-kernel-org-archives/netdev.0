From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/26] switchdev: introduce get/set attrs ops
Date: Thu, 2 Apr 2015 20:43:12 +0200
Message-ID: <20150402184312.GL10092@lunn.ch>
References: <1427882882-2533-2-git-send-email-sfeldma@gmail.com>
 <20150401.140822.2230858157895026713.davem@davemloft.net>
 <CAE4R7bC+fSjEP+uz19L9mbjf1Y+sPUM=Z7iuDtQdhPAZA1x3sA@mail.gmail.com>
 <20150402.120533.225417156120458098.davem@davemloft.net>
 <CAE4R7bD17Tv+4rFJDFeMQadPB=gj4dNktaT0wU7BksL-PB=NJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	=?iso-8859-1?B?Smk/P+0gUO1ya28=?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36411 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459AbbDBSrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 14:47:10 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bD17Tv+4rFJDFeMQadPB=gj4dNktaT0wU7BksL-PB=NJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2015 at 10:38:56AM -0700, Scott Feldman wrote:
> On Thu, Apr 2, 2015 at 9:05 AM, David Miller <davem@davemloft.net> wrote:
> > From: Scott Feldman <sfeldma@gmail.com>
> > Date: Thu, 2 Apr 2015 00:43:57 -0700
> >
> >> On Wed, Apr 1, 2015 at 11:08 AM, David Miller <davem@davemloft.net> wrote:
> >>> From: sfeldma@gmail.com
> >>> Date: Wed,  1 Apr 2015 03:07:37 -0700
> >>>
> >>>> +int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
> >>>> +{
> >>>> +     struct swdev_attr prev = *attr;
> >>>> +     int err, get_err, revert_err;
> >>>> +
> >>>> +     get_err = swdev_port_attr_get(dev, &prev);
> >>>> +
> >>>> +     err = __swdev_port_attr_set(dev, attr);
> >>>> +     if (err && !get_err && !(attr->flags & SWDEV_F_NO_RECOVER)) {
> >>>> +             /* Some err on set: revert to previous value */
> >>>> +             revert_err = __swdev_port_attr_set(dev, &prev);
> >>>> +             if (revert_err)
> >>>> +                     netdev_err(dev, "Reverting swdev port attr %d failed\n",
> >>>> +                                attr->id);
> >>>> +     }
> >>>> +
> >>>> +     return err;
> >>>
> >>> This style of error recovery doesn't work.
> >>>
> >>> You have to have a prepare/commit model to do this sanely, because
> >>> otherwise:
> >>>
> >>> 1) Partial state updates can be seen by the data plane (and other
> >>>    code paths) that do not use RTNL mutex protection.
> >>>
> >>> 2) It is absoultely expected that if some resource allocation failed
> >>>    when switching to the new attribute value, the same exactly thing
> >>>    is extremely likely during the rollback.
> >>>
> >>> So you have to code this in a way that no partial state updates are
> >>> ever visible, and also that rollbacks don't fail.
> >>
> >> I'm sending v3 with a prepare/commit model, for attr sets and obj
> >> adds.  The prepare phase asks driver(s) if set/add will work (is
> >> supported and device resource is available).  If yes, then do commit
> >> phase.   Commit could still fail due to failures outside the control
> >> of the driver, like ENOMEM.  In that case, WARN and return err.
> >
> > Scott, the whole purpose of the prepare phase is the allocate any
> > necessary resources so that they are available for the commit phase.
> > It needs to do this in addition to validating the incoming arguments.
> >
> > If some part of the prepare phase fails, you go back and release any
> > pre-allocated resources.
> >
> > The commit phase must not fail.
> 
> I was afraid you were going to say that :(
> 
> I looked at doing that with rocker for setting STP state.  The driver
> does allocate some system memory blocks, conditionally, about 4 call
> levels down, and then it may or may not free them it.

Probably a dumb question:

How many of the problems are limited to rocker, and not other switch
devices? DSA allocates all its memory at probe time. There is no
runtime memory allocation. So ENOMEM, with the current code, is not
going to be an issue. Setting STP state is only going to fail if the
switch chip stops responding to the MDIO bus etc. Joining a port to a
bridge will only fail if there is a bug in the DSA code such that
masks don't make sense.

Do we need a generic, complex rollback system, or can we push that
complexity down into rocker?

	   Andrew
