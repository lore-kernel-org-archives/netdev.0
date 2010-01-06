From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v3]
Date: Wed, 6 Jan 2010 10:50:11 -0800
Message-ID: <20100106185011.GD6824@linux.vnet.ibm.com>
References: <4B42E252.1080405@gmail.com> <1262724742-5232-1-git-send-email-fleitner@redhat.com> <20100106164027.GB6824@linux.vnet.ibm.com> <20100106091007.3fcc7d9b@nehalam>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Flavio Leitner <fleitner@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45239 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001Ab0AFSuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 13:50:14 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o06IiIet007729
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 13:44:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o06IoCP9114160
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 13:50:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o06IoBQW026170
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 13:50:12 -0500
Content-Disposition: inline
In-Reply-To: <20100106091007.3fcc7d9b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 09:10:07AM -0800, Stephen Hemminger wrote:
> On Wed, 6 Jan 2010 08:40:27 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > > -	if (inet->mc_list == NULL)
> > > +	rcu_read_lock();
> > > +	if (rcu_dereference(inet->mc_list) == NULL) {
> > > +		rcu_read_unlock();
> > >  		return;
> > > +	}
> > > +	rcu_read_unlock();  
> > 
> > I don't understand what rcu_read_lock() is protecting here.  The
> > test is still unstable -- just after finding inet->mc_list non-NULL,
> > ip_mc_leave_group() might cause it to become NULL.
> > 
> > Is there a need to protect sock_net(sk)?  (I don't believe so, but then
> > again, I don't claim to understand locking in Linux networking.)
> > If there is no need, it should be possible to drop the rcu_read_lock(),
> > rcu_read_unlock(), and rcu_dereference() above.  (You might want them
> > for documentation purposes, as they aren't hurting anything, just
> > wondering what the intent is.)
> 
> I think code is trying to avoid looking at mc_list if no multicast
> addresses. But it is an unsafe check.

Fair enough!  Might be worth a comment saying that the rcu_read_lock(),
rcu_read_unlock()s, and rcu_dereference() are just for show.

> If mc_list was just converted to list_head this would all be clearer

Agreed!  ;-)

							Thanx, Paul
