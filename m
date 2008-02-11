From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] qeth: new qeth device driver
Date: Mon, 11 Feb 2008 09:11:32 -0800
Message-ID: <20080211171132.GB9652@linux.vnet.ibm.com>
References: <20080208140959.259912000@de.ibm.com> <20080208141535.271607000@de.ibm.com> <20080208155416.GB12085@linux.vnet.ibm.com> <47AFFF7D.70101@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:58018 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbYBKRLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 12:11:46 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BHBj33012058
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 12:11:45 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BHBbUX206050
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:11:39 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BHBWBA027107
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:11:33 -0700
Content-Disposition: inline
In-Reply-To: <47AFFF7D.70101@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 08:55:41AM +0100, Frank Blaschka wrote:
> Paul E. McKenney schrieb:
> > On Fri, Feb 08, 2008 at 03:10:00PM +0100, Frank.Blaschka@de.ibm.com wrote:
> >> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> >>
> >> List of major changes and improvements:
> >>  no manipulation of the global ARP constructor
> >>  clean code split into core, layer 2 and layer 3 functionality
> >>  better exploitation of the ethtool interface
> >>  better representation of the various hardware capabilities
> >>  fix packet socket support (tcpdump), no fake_ll required
> >>  osasnmpd notification via udev events
> >>  coding style and beautification
> > 
> > One question below...
> > 
> >> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> >> ---
> > 
> > [ . . . ]
> > 
> >> +static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
> >> +{
> >> +	struct net_device *vlandev;
> >> +	struct qeth_card *card = (struct qeth_card *) dev->priv;
> >> +	struct in_device *in_dev;
> >> +
> >> +	if (card->info.type == QETH_CARD_TYPE_IQD)
> >> +		return;
> >> +
> >> +	vlandev = vlan_group_get_device(card->vlangrp, vid);
> >> +	vlandev->neigh_setup = qeth_l3_neigh_setup;
> >> +
> >> +	in_dev = __in_dev_get_rcu(vlandev);
> > 
> > Is this really in an RCU read-side critical section?  Or is this just
> > using common code?
> > 
> > 						Thanx, Paul
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> Hi Paul,
> 
> thanks for pointing at this. Using __in_dev_get_rcu without the rcu lock
> is probably a bug at this place (right?).

It would be a bug -unless- you are holding the update-side lock.

>                                           Using in_dev_get/in_dev_put
> would be more appropriate. Same for qeth_l3_free_vlan_addresses4(), here
> we take the rcu read lock, but in_dev_get/in_dev_put would be the better
> choice. What do you think?

Ummm...  "It depends."  ;-)

Keeping in mind that I am not an expert on this part of the kernel, I
would guess that qeth_l3_free_vlan_addresses4() is not particularly
performance-sensitive, so I don't see any reason in_dev_get/in_dev_put
would be a problem.  If it turns out that qeth_l3_free_vlan_addresses4()
is in fact performance-sensitive, then rcu_read_lock()/rcu_read_unlock()
would be a better choice.

							Thanx, Paul
