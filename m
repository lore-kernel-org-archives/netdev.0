From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Mon, 27 Sep 2010 12:24:51 -0700
Message-ID: <OFE2CC8708.AE88EB86-ON882577AB.00682F38-882577AB.006AA7EF@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <4C9A6D87.2000103@rincon.com> <alpine.DEB.2.00.1009221631520.32661@router.home> <OF5594D8AA.554725F5-ON882577A6.00768526-882577A6.00772BB2@us.ibm.com> <alpine.DEB.2.00.1009231021080.32567@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009231021080.32567-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote on 09/23/2010 08:37:48 AM:

> 
> On Wed, 22 Sep 2010, David Stevens wrote:
> 
> > >
> > > Also increment the frequency so that we get a 10 reports send over a
> > > few seconds.
> >
> >         Except you want to conform and not conform at the same time. 
:-)
> > IGMPv2 should be: default count 2, interval 10secs
> > IGMPv3 should be: default count 2, interval 1sec
> 
> This is during the period of unsolicited igmp reports. We do not know if
> this group is managed using V3 or V2 since no igmp query/report has been
> received yet.

        The default is IGMPv3 unless a v2 querier is present. You can 
force
it to be IGMPv2 with by having an IGMPv2 querier on the network or by 
using
the force_igmp_version tunable.

> > ...and no way is it a good idea to send 10 unsolicited reports on an
> > Ethernet.
> 
> Why would that be an issue?

        Because the traffic for all joins is multiplied by >3. If you're
joining 1 group, maybe that wouldn't be an issue, but what if I join
100, and what if hundreds of other hosts on that network do too? And
applications that dynamically join and leave groups may do this 
"normally."
Even 3 reports on switched networks with low loss is really unnecessary
overkill; 10 is just wasted bandwidth.

> The IGMPv2 RFC has no strict limit and RFC3376
> mentions that the retransmission occurs "Robustness Variable" times
> minus one. Choosing 10 for the "Robustness Variable" is certainly ok.

        Both of them specify the default value and say a querier is the
mechanism for changing that. If you want to follow the RFC, the default
is "2", not "10." While it'd be reasonable for a sysadmin to tune this
per-interface without a querier, it's not reasonable to make all linux
systems on all networks more than triple the number of reports they send
from the RFC-specified default. Right?!? :-)
 
> If we do not increase the number of reports but just limit the interval
> then the chance of outages of a second or so during mc group creation
> causing routers missing igmp reports is significantly increased.

        If you can't send on a group for 1 second, all of the initial
IGMPv3 reports will be lost about half of the time if we make that
conformant (it looks like it now uses the 10sec v2 time instead of the
1 sec v3 time it should). That's a problem IB needs to solve. Ideally,
you wouldn't want to return from the hardware join until you can actually
send the reports, but I expect there are locks held and that can't be 1 
second
of spinning on a processor. So, I think you really should put a queue in
IB for that hardware multicast address and send those packets when/if you
get positive acknowledgement (much as done for ARP completion, but maybe
queue more than 1) from the fabric that you can use it. If you don't get
any sort of ACK for that, then you can instrument a delay for it, but
any fixed number you use may be either too big or too small for a
particular fabric.

                                                                +-DLS



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
