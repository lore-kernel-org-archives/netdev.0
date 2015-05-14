From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v7 00/24] switchdev: spring cleanup
Date: Thu, 14 May 2015 18:30:47 +0900
Message-ID: <20150514093044.GA2218@penelope.isobedori.kobe.vergenet.net>
References: <1431276489-64199-1-git-send-email-sfeldma@gmail.com>
 <20150512.184532.1368324454021599990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, joe@perches.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33159 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932682AbbENJbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 05:31:00 -0400
Received: by pacwv17 with SMTP id wv17so79671238pac.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 02:31:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150512.184532.1368324454021599990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 06:45:32PM -0400, David Miller wrote:
> From: sfeldma@gmail.com
> Date: Sun, 10 May 2015 09:47:45 -0700
> 
> > The main theme of this patch set is to cleanup swdev in preparation for
> > new features or fixes to be added soon.  We have a pretty good idea now how
> > to handle stacked drivers in swdev, but there where some loose ends.  For
> > example, if a set failed in the middle of walking the lower devs, we would
> > leave the system in an undefined state...there was no way to recover back to
> > the previous state.  Speaking of sets, also recognize a pattern that most
> > swdev API accesses are gets or sets of port attributes, so go ahead and make
> > port attr get/set the central swdev API, and convert everything that is
> > set-ish/get-ish to this new API.
> > 
> > Features/fixes that should follow from this cleanup:
> > 
> >  - solve the duplicate pkt forwarding issue
> >  - get/set bridge attrs, like ageing_time, from/to device
> >  - get/set more bridge port attrs from/to device
> > 
> > There are some rename cleanups tagging along at the end, to give swdev
> > consistent naming.
> > 
> > And finally, some much needed updates to the switchdev.txt documentation to
> > hopefully capture the state-of-the-art of swdev.  Hopefully, we can do a better
> > job keeping this document up-to-date.
> > 
> > Tested with rocker, of course, to make sure nothing functional broke.  There
> > are a couple minor tweaks to DSA code for getting switch ID and setting STP
> > updates to use new API, but not expecting amy breakage there.
> 
> Ok, this series looks good for the most part so I'll apply it, thanks
> Scott.
> 
> One thing that worries me is that deferral of operations when rtnl
> isn't held.  You've lost the ability there to signal an error back
> to the user, so you just return zero and BUG() if it does actually
> error.
> 
> You'll need to do something better in that situation in my opinion.
> 
> My preference would be to require that RTNL is held on any traversal
> into those code paths.


FWIW I seem to be hitting.


static int rocker_port_attr_set(struct net_device *dev,
				struct switchdev_attr *attr)
{
	struct rocker_port *rocker_port = netdev_priv(dev);
	int err = 0;

	switch (attr->trans) {
	case SWITCHDEV_TRANS_PREPARE:
		BUG_ON(!list_empty(&rocker_port->trans_mem));

It seems that this may be due to outstanding work created by
rocker_wait_create().  I suspect that RTNL is held when the work is created
but not when it is completed.

Or more to the point, I am reliably hitting the BUG_ON() above
and so far my investigations point at rocker_wait_create.

My test case is as follows:

ip link add br0 type bridge
ip addr add 10.0.99.192/24 dev br0
ip link set down dev eth0
ip link set up dev eth0
ip link set dev eth0 master br0


I have observed the above with my "[PATCH v2 net-next 0/2] rocker: unused
parameter and const cleanups" patchset applied but I'm not sure if that is
strictly related.
