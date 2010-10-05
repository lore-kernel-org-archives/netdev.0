From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH v2] bonding: rejoin multicast groups on VLANs
Date: Tue, 5 Oct 2010 19:07:57 -0300
Message-ID: <20101005220757.GB19931@redhat.com>
References: <20100929131713.GB2857@redhat.com>
 <1285879524-7046-1-git-send-email-fleitner@redhat.com>
 <20101004132409.GA7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052Ab0JEWIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 18:08:10 -0400
Content-Disposition: inline
In-Reply-To: <20101004132409.GA7497@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 09:24:10AM -0400, Andy Gospodarek wrote:
> On Thu, Sep 30, 2010 at 05:45:24PM -0300, Flavio Leitner wrote:
> > It fixes bonding to rejoin multicast groups added
> > to VLAN devices on top of bonding when a failover
> > happens.
> > 
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> > ---
> >  drivers/net/bonding/bond_main.c |   61 +++++++++++++++++++++++++++++++++-----
> >  drivers/net/bonding/bonding.h   |    1 +
> >  2 files changed, 54 insertions(+), 8 deletions(-)
> > 
> [...]
> > @@ -944,7 +979,9 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
> >  
> >  		netdev_for_each_mc_addr(ha, bond->dev)
> >  			dev_mc_add(new_active->dev, ha->addr);
> > -		bond_resend_igmp_join_requests(bond);
> > +
> > +		/* rejoin multicast groups */
> > +		queue_delayed_work(bond->wq, &bond->mcast_work, 0);
> >  	}
> >  }
> >  
> 
> I was hoping that one patch would just make the changes so
> retransmission was supported on VLANs and the second patch would queue
> the work and add the tunable for multiple retransmissions, but I guess
> it wasn't clear enough.
> 
> I felt like that would divide the patches up into the bug-fix (VLANs +
> multicast not working) and the new feature (multiple retransmissions
> from the workqueue).

I'm not seeing how to that because the first patch changes to send
the membership directly and not using timers anymore, so the call
trace usually is:

 write_lock_bh(&bond->curr_slave_lock); <-- hold lock
 bond_select_active_slave() 
  ->bond_change_active_slave()
     ->bond_mc_swap()
        ->tx membership reports
 

then trying to send the IGMP packet directly, it will end up at:
  bond_start_xmit()
   ->bond_xmit_activebackup() (mode=1, for example)
      ->read_lock(&bond->lock);
      ->read_lock(&bond->curr_slave_lock); <-- deadlock


> I will test these out this morning and make sure things look good.

I have a better patch sequence which I'm planning post replying to
this thread as soon as I finish up testing them. It is still using
workqueue though.

--
Flavio
