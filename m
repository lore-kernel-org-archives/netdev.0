From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] igmp: fix ip_mc_sf_allow race [v3]
Date: Wed, 6 Jan 2010 09:10:07 -0800
Message-ID: <20100106091007.3fcc7d9b@nehalam>
References: <4B42E252.1080405@gmail.com>
	<1262724742-5232-1-git-send-email-fleitner@redhat.com>
	<20100106164027.GB6824@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fleitner@redhat.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38829 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430Ab0AFRKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 12:10:41 -0500
In-Reply-To: <20100106164027.GB6824@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jan 2010 08:40:27 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> > -	if (inet->mc_list == NULL)
> > +	rcu_read_lock();
> > +	if (rcu_dereference(inet->mc_list) == NULL) {
> > +		rcu_read_unlock();
> >  		return;
> > +	}
> > +	rcu_read_unlock();  
> 
> I don't understand what rcu_read_lock() is protecting here.  The
> test is still unstable -- just after finding inet->mc_list non-NULL,
> ip_mc_leave_group() might cause it to become NULL.
> 
> Is there a need to protect sock_net(sk)?  (I don't believe so, but then
> again, I don't claim to understand locking in Linux networking.)
> If there is no need, it should be possible to drop the rcu_read_lock(),
> rcu_read_unlock(), and rcu_dereference() above.  (You might want them
> for documentation purposes, as they aren't hurting anything, just
> wondering what the intent is.)

I think code is trying to avoid looking at mc_list if no multicast
addresses. But it is an unsafe check.

If mc_list was just converted to list_head this would all be clearer
