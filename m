From: Kaiwen Xu <kevin@kevxu.net>
Subject: Re: loopback device reference count leakage
Date: Fri, 10 Feb 2017 05:45:36 +0000
Message-ID: <BY1PR17MB0101812AA1E386BB56CBF13BA1440@BY1PR17MB0101.namprd17.prod.outlook.com>
References: <BY1PR17MB0101922AF9444B40E31B3B3CA1750@BY1PR17MB0101.namprd17.prod.outlook.com>
 <CAM_iQpXQ5MyL_KYNctZuZLv_w-ai3pmXKswOLXYeEYmVBdQqJA@mail.gmail.com>
 <CO2PR17MB01050D56F6EE3C8D54B00CAAA1770@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CAM_iQpWJmXnsZ4D870aEZ+HL3pfaZU3HyunyxnhG9=EHS0Tcdg@mail.gmail.com>
 <CO2PR17MB01057D980A6B7827B48BD7A7A1760@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CO2PR17MB0105551B80302C4B5657CA80A1430@CO2PR17MB0105.namprd17.prod.outlook.com>
 <CAM_iQpVpjhSLGrqQAL4N=X3hqcZBQd1F+2QzO+7rmLJijq4hRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay004-omc4s15.hotmail.com ([65.54.190.217]:64777 "EHLO
        BAY004-OMC4S15.hotmail.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751000AbdBJFqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 00:46:25 -0500
In-Reply-To: <CAM_iQpVpjhSLGrqQAL4N=X3hqcZBQd1F+2QzO+7rmLJijq4hRA@mail.gmail.com>
Content-Language: en-US
Content-ID: <05429510766D5242B78B38761DDE4F45@namprd17.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using macvlan device inside the container. With following Docker
network plugin:

https://github.com/gopher-net/macvlan-docker-plugin

Each macvlan device, which gets assigned into the container network
namespace, is attached to host's vlan device, which is then attached to
host's eth0.

    eth0  <==  eth0.1000  <==  macvlan0 (host macvlan device)
                          \==  macvlan1 (container macvlan device)
                          \==  macvlan2 (container macvlan device)
                          ...

eth0 has a 10.x.x.x/24 IP address. eth0.1000 is able to use any of the
addresses in another 10.x.x.y/24 range (different from the /24 assigned to
eth0), but itself isn't directly assigned an IP address. macvlan0, which
is on the host, is assigned an IP address in the 10.x.x.y/24 range that
belongs to eth0.1000. When container start up, a new macvlan device is
created attaching to eth0.1000 with a different 10.x.x.y/24 address,
which is assigned into the container network namespace. The container's
10.x.x.y/24 address is directly reachable outside of the host.

Thanks,
Kaiwen

On Wed, Feb 08, 2017 at 01:50:57PM -0800, Cong Wang wrote:
> On Mon, Feb 6, 2017 at 6:32 PM, Kaiwen Xu <kevin@kevxu.net> wrote:
> > Hi Cong,
> >
> > I did some more testing, seems like your second assumption is correct.
> > There is indeed some things holding the references to a particular dst
> > which preventing it to be gc'ed.
> 
> Excellent!
> 
> >
> > I added logging to each dst_hold (or dst_hold_safe, or
> > skb_dst_force_safe) and dst_release, which formatted as following:
> >
> > <dev name> (<protocol>) [<dst addr>]: dst_release / dst_hold ... <refcnt> <caller function>
> >
> > And inside dst_gc_task(), I added logging when gc delay occurred,
> > formatted as:
> >
> > [dst_gc_task] <dev name> (<protocol>): delayed <refcnt>
> >
> > I have the log attached.
> 
> The following line looks suspicious:
> 
> Feb  6 16:27:24 <hostname> kernel: [63589.458067] [dst_gc_task]
> lodebug (2): delayed 19
> 
> Looks like you ended up having one dst whose refcnt is 19 in GC,
> and this lasted for a rather long time for some reason.
> 
> It is hard to know if it is a refcnt leak even with your log, since there were
> 4K+ refcnt'ing happened on that dst...
> 
> Meanwhile, can you share your setup of your container? What network device
> do you use in your container? How is it connected to outside?
> 
> Thanks.
