From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 09:48:03 -0400
Message-ID: <1493214483.3041.108.camel@redhat.com>
References: <CAJ3xEMg4_2ph7QwPsUb-tX-K4d2ppkqz98sPzytsmBCK=29WHw@mail.gmail.com>
         <CAAk-MO8O19iC2Yn-BMn5pKTAYxaSzGPMyta=fwes3XSvzmz_cQ@mail.gmail.com>
         <CAJ3xEMgw=9sj3rdahPEiST_yDfDJPNSZZLRn43tnb3bK4_RPzg@mail.gmail.com>
         <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
         <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
         <1493134815.3041.72.camel@redhat.com>
         <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
         <1493192794.2409.3.camel@redhat.com>
         <20170426125230.GB19179@dhcp-13-42.nay.redhat.com>
         <1493213258.3041.98.camel@redhat.com>
         <20170426133353.GA7898@dhcp-13-42.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>, Or Gerlitz <gerlitz.or@gmail.com>,
        Erez Shitrit <erezsh@dev.mellanox.co.il>,
        Erez Shitrit <erezsh@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Honggang LI <honli@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1040111AbdDZNsL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 09:48:11 -0400
In-Reply-To: <20170426133353.GA7898@dhcp-13-42.nay.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-26 at 21:33 +0800, Honggang LI wrote:
> Yes, it is during the process of removing the final slave. The
> reproducer looks like this:
> 
> ping remote_ip_over_bonding_interface &
> while 1; do
> 	ifdown bond0
> 	ifup   bond0
> done

Honestly, I would suspect the problem here is not when removing the
busy interface, but when bringing the interface back up.  IIRC, the
bonding driver defaults to assuming it will be used on an Ethernet
interface.  Once you attach an IB slave, it reconfigures itself for
running over IB instead.  But once it's configured it should stay
configured until after the last IB slave is removed (and once that
slave it removed, the bond should no longer even possess the pointer to
the ipoib_hard_header routine, so we should never call it).

The process, in the bonding driver, for going down and coming back up
needs to look something like this:

ifdown bond0:
  stop all queues
  remove all slaves
  possibly reconfigure to default state which is Ethernet suitable

ifup bond0:
  add first slave
  configure for IB instead of Ethernet
  start queues
  add additional slaves

I'm wondering if, when we have a current backlog, we aren't
accidentally doing this instead:

ifup bond0:
  add first slave
  release backlog queue
  configure for IB instead of Ethernet
  add additional slaves

Or, it might even be more subtle, such as:

ifup bond0:
  add first slave
  configure for IB instead of Ethernet
  start queues
   -> however, there was a backlog item on the queue from prior to
      the first slave being added and the port configured for IB mode,
      so the backlog skb is still configured for the default Ethernet
      mode, hence the failure
  add additional slaves

Maybe the real issue is that inside the bonding driver, when we
reconfigure the queue type from IB to Ethernet or Ethernet to IB, we
need to force either a drop or a reconfiguration of any packets already
currently in our waiting backlog queue of skbs.  Paolo?

> > 
> > but I don't think it can be after the final slave has been fully
> > removed from the bond.  Paolo, what should the bond driver be doing
> > once the slaves are gone?  Wouldn't it just be dropping every skb
> > on
> > the floor without calling anyone's hard header routine?
> > 
> > > 
> > >  so it is better to immediately
> > > give up and return error.
> > > 
> > > > 
> > > > 
> > > > +       if (ret)
> > > > +               return ret;
> > > >  
> > > >         header = (struct ipoib_header *) skb_push(skb, sizeof
> > > > *header);
> > > > ---
> > > > 
> > > > Paolo
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe
> > > > linux-
> > > > rdma" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  http://vger.kernel.org/majordomo-info.h
> > > > tml
> > -- 
> > Doug Ledford <dledford@redhat.com>
> >     GPG KeyID: B826A3330E572FDD
> >    
> > Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57
> > 2FDD
> > 
-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
