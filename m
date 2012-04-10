From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v1 7/7] macvlan: add FDB bridge ops and new
 macvlan mode
Date: Tue, 10 Apr 2012 17:33:07 +0300
Message-ID: <20120410143306.GC19556@redhat.com>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
 <20120409220053.3288.40867.stgit@jf-dev1-dcblab>
 <20120410080916.GB26540@redhat.com>
 <20120410081418.GC26540@redhat.com>
 <4F843AB2.5060901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roprabhu@cisco.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gregory.v.rose@intel.com, krkumar2@in.ibm.com, sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15602 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758789Ab2DJOdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:33:07 -0400
Content-Disposition: inline
In-Reply-To: <4F843AB2.5060901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 06:50:42AM -0700, John Fastabend wrote:
> On 4/10/2012 1:14 AM, Michael S. Tsirkin wrote:
> > On Tue, Apr 10, 2012 at 11:09:16AM +0300, Michael S. Tsirkin wrote:
> >> On Mon, Apr 09, 2012 at 03:00:54PM -0700, John Fastabend wrote:
> >>> This adds a new macvlan mode MACVLAN_PASSTHRU_NOPROMISC
> >>> this mode acts the same as the original passthru mode _except_
> >>> it does not set promiscuous mode on the lowerdev. Because the
> >>> lowerdev is not put in promiscuous mode any unicast or multicast
> >>> addresses the device should receive must be explicitely added
> >>> with the FDB bridge ops. In many use cases the management stack
> >>> will know the mac addresses needed (maybe negotiated via EVB/VDP)
> >>> or may require only receiving known "good" mac addresses. This
> >>> mode with the FDB ops supports this usage model.
> >>
> >>
> >> Looks good to me. Some questions below:
> >>
> >>> This patch is a result of Roopa Prabhu's work. Follow up
> >>> patches are needed for VEPA and VEB macvlan modes.
> >>
> >> And bridge too?
> >>
> >> Also, my understanding is that other modes won't need a flag
> >> like this since they don't put the device in promisc mode initially,
> >> so no assumptions are broken if we require all addresses
> >> to be declared, right?
> >>
> >> A final question: I think we'll later add a macvlan mode
> >> that does not flood all multicasts. This would change behaviour
> >> in an incompatible way so we'll probably need yet another
> >> flag. Would it make sense to combine this functionality
> >> with nopromisc so we have less modes to support?
> > 
> > One other question I forgot:
> > 
> 
> [...]
> 
> >>>  
> >>> @@ -344,12 +346,15 @@ static int macvlan_stop(struct net_device *dev)
> >>>  	struct macvlan_dev *vlan = netdev_priv(dev);
> >>>  	struct net_device *lowerdev = vlan->lowerdev;
> >>>  
> >>> +	dev_uc_unsync(lowerdev, dev);
> >>> +	dev_mc_unsync(lowerdev, dev);
> >>> +
> >>>  	if (vlan->port->passthru) {
> >>> -		dev_set_promiscuity(lowerdev, -1);
> >>> +		if (vlan->mode == MACVLAN_MODE_PASSTHRU)
> >>> +			dev_set_promiscuity(lowerdev, 1);
> >>>  		goto hash_del;
> >>>  	}
> >>>  
> >>> -	dev_mc_unsync(lowerdev, dev);
> >>>  	if (dev->flags & IFF_ALLMULTI)
> >>>  		dev_set_allmulti(lowerdev, -1);
> >>>  
> >>> @@ -399,10 +404,11 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
> >>>  		dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
> > 
> > In the new mode, do we want to have promisc on lowerdev follow whatever
> > is set on the macvlan, like we do for allmulti?
> > I'm not sure at this point - what do others think?
> > 
> 
> Just to enumerate why you would need this: (1) socket set with
> PACKET_MR_MULTICAST and (2) something like mrouted is running
> on the macvlan (3) maybe some case I missed?
> 
> Don't you need CAP_NET_RAW to set these though anyways? So I
> wouldn't think it would be a problem. I assume if a user has
> CAP_NET_RAW or UUID 0 they really should be able to set this
> up.
> 
> .John

I am not sure, really.
But I note that with a security mechanism such as selinux, CAP_NET_RAW
might be insufficient to change the underlying device.
So there might be value in being able to change it in
a controlled manner through macvlan.

There's also something to be said for being able to let
management deal with macvlan devices (and there are
some very complex tools for that around) while
keeping a simple script around for the physical
one and knowing that they won't disrupt each other.

-- 
MST
