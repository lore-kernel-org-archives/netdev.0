From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Mon, 8 Jun 2015 14:33:02 +0200
Message-ID: <20150608123302.GA3634@pox.localdomain>
References: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com>
 <20150605091441.GA11896@pox.localdomain>
 <5571AF28.8000009@cumulusnetworks.com>
 <5571BF90.2070304@brocade.com>
 <557260E0.9060500@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Shearman <rshearma@brocade.com>, ebiederm@xmission.com,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36185 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbFHMdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 08:33:05 -0400
Received: by wigg3 with SMTP id g3so50675170wig.1
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 05:33:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <557260E0.9060500@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/15 at 07:54pm, roopa wrote:
> On 6/5/15, 8:26 AM, Robert Shearman wrote:
> >
> >It isn't clear to me what the strategy here is for dealing with tunnel
> >encaps that aren't bound to an interface.
> >
> >Thomas, I presume you would prefer not to force the user to keep track of
> >changes to the output interface and nexthop corresponding to the
> >destination of the outer IP header? And I presume that Eric is opposed to
> >the option of using a virtual interface here, i.e. falling back to the
> >approach I proposed?
> >
> >In which case, what will the nexthop output interface be set to?
> >Logically, it should have no interface. At the moment, the code assumes
> >that a nexthop will have a valid interface and I don't have a feel for
> >what the impact would be of changing that.
> 
> The nexthop interface is the final output interface. Any reason it should
> not be ?

Yes, the information used to determine the encapsulation and the
route used to select the outgoing interface might be coming from
different components. A simple and typical example is if you are
running quagga to for your underlay which determines which interface
to use for which tunnel endpoints. On top of that, somebody is
maintaining your virtual networks which is only aware of the tunnel
endpoint IP addresses but does not want to manage how to actually
reach them. So you would have:

ip route add 10.1.1.0/24 via tunnel 20.1.1.1 id 100 [dev vxlan0]
ip route add 20.1.1.1/24 dev eth0 

I've put "dev vxlan0" in brackets for now to indicate that it is
optional. I'm also using VXLAN as an examples as I think it's
easier to understand this separation of concern here. The point
is, whoever is adding the route with the encap information may
not know what interface to use to reach 20.1.1.1 and we may want
to rely on existing routes.

I think we want to support three models:

1. nexthop has encap and outgoing interface
   ip route add 10.1.1.0/24 via tunnel 20.1.1.1 dev eth0
   ip route add 20.1.1.1/24 dev eth0 

2. nexthop has endpoint but no dev
   ip route add 10.1.1.0/24 via tunnel 20.1.1.1
   ip route add 20.1.1.1/24 dev eth0 

   This would indicate to the routing subsystem to perform a
   fib lookup on 20.1.1.1 to determine the outgoing interface.

3. virtual tunnel interface to share configuration among routes
   ip route add 10.1.1.0/24 via tunnel 20.1.1.1 dev vxlan0
   ip route add 20.1.1.1/24 dev eth0

I think all of them are intuitive and easy to implement. This will
also allow to incorporate the bridge model.

> >However, with that resolved I'd be happy to work on a series together. The
> >remaining issue is whether to optimise for small encap that reside in the
> >same memory block as the fib_info, which aren't refcounted but instead are
> >copied around, or larger encaps that reside in their own memory block that
> >are refcounted and only a pointer passed around.
> I would prefer the latter (as shown in my incomplete patch) simply because
> it stays separate from fib_info and allows for extending it in the future.

I'm with Roopa on this one. Simply because it allows to keep the RX
and TX path more symmetric and it allows non-FIB users as well.

> >If the latter, then there really isn't much left in my patch series that
> >can be reused, other than references to the places in the code that need
> >to be changed to support multipath and to make fib_info matching work
> >correctly.

Your nexthop implementation seemed more correct based on the chunks
I went through. Can we combine the two series and make the RTA_OIF
in the nexthop optional if an RTA_ENCAP was provided and provide a
route lookup instead?
