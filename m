From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Tue, 25 Mar 2014 15:40:18 -0400
Message-ID: <20140325194018.GG8102@hmsreliant.think-freely.org>
References: <1395243232-32630-1-git-send-email-jiri@resnulli.us>
 <532AD5B3.6020205@mojatatu.com>
 <20140320124021.GA2946@minipsycho.orion>
 <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <CAGVrzcacuU=RsnBOQh2-u+AjsMvznUYWFJru86w09+Vpdta2KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy <andy@greyhouse.net>,
	tgraf <tgraf@suug.ch>, dborkman <dborkman@redhat.com>,
	ogerlitz <ogerlitz@mellanox.com>, jesse <jesse@nicira.com>,
	pshelar <pshelar@nicira.com>, azhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60275 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754784AbaCYTkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:40:46 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcacuU=RsnBOQh2-u+AjsMvznUYWFJru86w09+Vpdta2KQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2014 at 11:33:22AM -0700, Florian Fainelli wrote:
> 2014-03-25 10:39 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> > On Mon, Mar 24, 2014 at 07:07:35PM -0400, Jamal Hadi Salim wrote:
> >> On 03/22/14 05:48, Jiri Pirko wrote:
> >> >Fri, Mar 21, 2014 at 01:04:20PM CET, jhs@mojatatu.com wrote:
> >>
> >> >Hmm. This got me thinking about netdev and switches well and perhaps the
> >> >switchdev api could be mostly implemented by couple of more ndos and
> >> >feature flags. That way we could stick to your immortal netdev :)
> >> >
> >> >
> >>
> >> Perhaps ;->
> >>
> >> >>
> >> >>In my view: that (immortal) device for L2/bridging is the bridge or
> >> >>maybe a more barebone version of the bridge (since it has gained a
> >> >>little more weight in recent times).
> >> >
> >> >Well, I do not think that bridge is ideal abstraction for modern switch
> >> >chips. Bridge is very limited.
> >> >
> >>
> >> True - but i was more thinking of being inclusive of the smaller
> >> devices. They are mostly L2 only and in very limited scope. And thats
> >> probably 95% of the population. The things you are talking about
> >> are very high end and they can do more. Florian's taxanomy was useful.
> >>
> >> >But I don't necessary think it is needed to "mask" as a bride or mimic a
> >> >bridge in any way. DSA does not do that either.
> > No, but it would be really nice if these smaller devices could take advantage of
> > this infrastructure.  Looking at it, I don't see why thats not possible.  The
> > big trick (as we've discussed in the past), is using a net_device structure to
> > take advantage of all the features that net_devices offer while not enabling the
> > device specific features that some hardware doesn't allow.
> >
> > For instance the broadcom chips that live in many wireless routers would be well
> > served by the model jiri has here as far as Media level interface control is
> > concerned (i.e. ifup/down/speed/duplex/etc), but its a bit lacking in that
> > net_devices are assumed to support L3 protocol configuration (i.e. they can have
> > ip addresses assigned to them), which you can't IIRC do on these chips.
> 
> In fact, some switches could have valid L3 configurations, what you
> usually do is have the switch be configured such that it selectively
> inserts Broadcom tags for a given set of physical ports, such that
> your CPU port (In-band Management port in Broadcom terminology), gets
> flooded with such packets, and can dispatch those packets to the
> per-port netdevices. Then you can take any decisions based on those
> received packets, such as bridging this per-port netdevice with
> another one for instance, or any switch topology change.
> 
> >
> > Would it be worth considering a private interface model?  That is to say:
> >
> > 1) Ports on a switch chip are accessed using net_device structures, but
> > registered to a private list contained within the switch device, rather than to
> > the net namespaces device list.
> 
> I think this would be a good model for simple embedded switches that
> only support 802.1q VLANs for instance, since we won't be able to get
> any actual data to be sent/received to any per-port netdevice, those
> per-port netdevices would only be effective for control at the L2
> level.
> 
> For switches that do support tags, I think we do want per-port
> netdevices to appear in the regular netdevices namespace as those
> might be able to get actual data sent to/received from by using these
> tags, at least momentarily until a higher-level entity decides
> otherwise (e.g: by bridging, disabling interfaces...).
> 
Well, perhaps thats the answer then  - Augment the model to allow for the
registration of net_devices to private lists within a switch device, but don't
require it.  If a given chip supports the assignment of L3 data by the cpu, the
use of iptables etc, let the switch driver do so, its not like we can't do that
already, but for the smaller devices, keeping them tightly controled via the
switch driver in such a way that user space can only access them with permission
from the switch driver.

Does that seem reasonable?

Neil
