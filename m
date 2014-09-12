From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [BUG REPORT]  Unencrypted packets after SNAT, allthough
 IPSEC-Policies are present
Date: Fri, 12 Sep 2014 11:31:43 +0200
Message-ID: <20140912093143.GN6390@secunet.com>
References: <541089DD.6060307@sirrix.com>
 <20140911115401.GL6390@secunet.com>
 <54119F75.8090305@sirrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<herbert@gondor.apana.org.au>
To: Konstantinos Kolelis <k.kolelis@sirrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54967 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbaILJbv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 05:31:51 -0400
Content-Disposition: inline
In-Reply-To: <54119F75.8090305@sirrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014 at 03:11:17PM +0200, Konstantinos Kolelis wrote:
> Am 11.09.2014 13:54, schrieb Steffen Klassert:
> > On Wed, Sep 10, 2014 at 07:26:53PM +0200, Konstantinos Kolelis wrote:
> >> Hi all,
> >>
> >> i' ve observed a problem with xfrm lookups, SNAT, blackhole route and
> >> missing SAs.
> >> The problem occures with all Kernels above 3.6.x and might has to do
> >> with the changes in
> >> ip4_blackhole_route() function in net/route.c.
> > 
> > Thanks for the report!
> > 
> > Is kernel v3.6 the first kernel with this issue? It seems that
> > we have this problem already longer, at least if my analysis
> > is correct.
> > 
> 
> It worked until Kernel 3.4.103, i did not check with v3.5 though.

Hm. I thought the problem exists already for longer, so I did
a bisect. To my surprise, the following commit introduced the bug:

commit a263b3093641fb1ec377582c90986a7fd0625184
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jul 2 02:02:15 2012 -0700

    ipv4: Make neigh lookups directly in output packet path.
    
    Do not use the dst cached neigh, we'll be getting rid of that.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

But this is not really the offending commit. As I said, the problem
was introduced by git commit 2774c131 ("xfrm: Handle blackhole route
creation via afinfo.") because the assumption that dst_output() is
called always after a  xfrm_lookup() is wrong. On postrouting nat,
dst_output() is not called for blackholed packets. But we were in luck
because ip_finish_output2() tried to use a dst cached neigh entry.
On blackhole routes we did not cache neigh entries, so the packets
were dropped in the last moment. The above commit finally opened the
door by replacing the usage of a dst cached neigh entry by a direct
lookup.

So we need to ensure that a blackhole route is generated only by the
route lookup functions.

> 
> >>
> >> Let say you have two network interfaces:
> >> eth0 with ip 172.16.0.10/24
> >> and
> >> eth1 with ip 192.168.0.1/24
> >>
> >> and you have done the following configuration:
> >>
> >> iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source
> >> 172.16.0.10
> >>
> >> and
> >>
> >> ip xfrm policy add dir out  src 172.16.0.10 dst 0.0.0.0/0 tmpl proto esp
> >> src 172.16.0.10 dst 172.31.0.10 mode tunnel
> >>
> >> with the following routes:
> >> default via 172.16.0.1 dev eth0  proto static
> >> 172.16.0.0/24 dev eth0  proto kernel  scope link  src 172.16.0.10
> >> 192.168.0.0/24 dev eth1  proto kernel  scope link  src 192.168.0.1
> >>
> >> If for what ever reason IPSEC-SAs can not be established, maybe because
> >> 172.31.0.10 is down,
> >> the traffic comming from 192.168.0.0/24 will leave unencrypted the
> >> external (eth0) interface.
> > 
> > I can reproduce it with SNAT and MASQUERADE. Looks like this was
> > introduced back in 2011 with git commit 2774c131 ("xfrm: Handle
> > blackhole route creation via afinfo.").
> > 
> > Before that commit, xfrm_lookup() and __xfrm_lookup() returned
> > an error if we have a matching policy but no states. The route
> > lookup functions used __xfrm_lookup() and generated a blackhole
> > route if __xfrm_lookup() returned -EREMOTE. All other functions
> > used xfrm_lookup() which returned -EAGAIN. This was treated as
> > as an error and the packet was dropped immediately.
> > 
> > After this commit all callers to xfrm_lookup() rely that
> > dst_output() is called afterwards. This seems to be not the
> > case, at least when postrouting nat is used.
> > 
> > Maybe we should go back to let only the route lookup functions
> > genarate a blackhole route. Everyone else should better drop
> > the packets immediately.
> > 
> > I'll try to do a patch.
> > 
> 
> You should also check what happens if xfrm_larval_drop is false.
> Allthough blackhole route was not used, you could still run into the
> same problem. It just took a while longer.
> 

Yes, I'm aware of that. Thanks for the hint!
