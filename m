From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] IB/IPoIB: Check the headroom size
Date: Wed, 26 Apr 2017 10:25:04 -0400
Message-ID: <1493216704.3041.115.camel@redhat.com>
References: <CAAk-MO-B8Liv6RyGye_Fx-9OELCUrGMj5SwK9UsciC=khSO5fA@mail.gmail.com>
         <CAJ3xEMgwS1Bq8+eZC1iAr6xi8ZPHrchsOJ5r4LNJxR8P+6VipA@mail.gmail.com>
         <1493134815.3041.72.camel@redhat.com>
         <CAJ3xEMjqkJrKi+6ronuPBn2P6y8p6sdhVppDzFtMwQrhL13bzg@mail.gmail.com>
         <1493192794.2409.3.camel@redhat.com>
         <20170426125230.GB19179@dhcp-13-42.nay.redhat.com>
         <1493213258.3041.98.camel@redhat.com>
         <20170426133353.GA7898@dhcp-13-42.nay.redhat.com>
         <1493214483.3041.108.camel@redhat.com>
         <1493214638.3041.110.camel@redhat.com>
         <20170426141139.GA14635@dhcp-13-42.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170426141139.GA14635-Y5OA6DF/u0nid9cnFhDO8BcY2uh10dtjAL8bYrjMMd8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-26 at 22:11 +0800, Honggang LI wrote:
> On Wed, Apr 26, 2017 at 09:50:38AM -0400, Doug Ledford wrote:
> > 
> > On Wed, 2017-04-26 at 09:48 -0400, Doug Ledford wrote:
> > > 
> > > On Wed, 2017-04-26 at 21:33 +0800, Honggang LI wrote:
> > > > 
> > > > 
> > > > Yes, it is during the process of removing the final slave. The
> > > > reproducer looks like this:
> > > > 
> > > > ping remote_ip_over_bonding_interface &
> > > > while 1; do
> > > > 	ifdown bond0
> > > > 	ifup   bond0
> > > > done
> > 
> > BTW, rerunning your test as:
> > 
> > ping remote_ip_over_bonding_interface &
> > while 1; do
> >     echo -n "Downing interface..."
> >     ifdown bond0
> 
> Confirmed panic in here.

OK, this leads me to suspect that the bonding driver is possibly
reconfiguring the skb setup to Ethernet mode before the last slave is
fully dropped from the bond, and so the slave is seeing a packet to its
hard header routine with the wrong headroom.  I think Paolo's patch is
probably the best way to go.  The reason I say that is because we can't
definitively say that this is the only pathway we will ever see that
causes us to get a packet with Ethernet headroom on our IPoIB
interface, and Paolo's patch gives us the possibility of recovering and
sending the packet out.  Even in this case, we are downing the
interface, but it isn't down entirely yet, so sending the packet out
isn't necessarily wrong.  So a method of fix that allows us to
recover/continue seems preferable to me.  Can you test Paolo's patch
and see if it resolves the problem?

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
