From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 09:49:32 -0400
Message-ID: <20150603134931.GD588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <1433324109.1444360.285555441.44C7F90D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:33657 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbbFCNtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 09:49:36 -0400
Received: by qcmi9 with SMTP id i9so4004246qcm.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 06:49:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433324109.1444360.285555441.44C7F90D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 11:35:09AM +0200, Hannes Frederic Sowa wrote:
> On Wed, Jun 3, 2015, at 05:07, Andy Gospodarek wrote:
> > This patch adds the ability to have the Linux kernel track whether or
> > not a particular route should be used based on the link-status of the
> > interface associated with the next-hop.
> > 
> > Before this patch any link-failure on an interface that was serving as a
> > gateway for some systems could result in those systems being isolated
> > from the rest of the network as the stack would continue to attempt to
> > send frames out of an interface that is actually linked-down.  When the
> > kernel is responsible for all forwarding, it should also be responsible
> > for taking action when the traffic can no longer be forwarded -- there
> > is no real need to outsource link-monitoring to userspace anymore.
> > 
> > This feature is only enabled with the new sysctl set (default is off):
> > net.core.kill_routes_on_linkdown = 1
> > 
> > When this is set, the following behavior can be observed (interface p8p1
> > is link-down):
> > 
> > # ip route show 
> > default via 10.0.5.2 dev p9p1 
> > 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
> > 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
> > 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead 
> > 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead 
> > 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
> > # ip route get 90.0.0.1 
> > 90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1 
> >     cache 
> > # ip route get 80.0.0.1 
> > local 80.0.0.1 dev lo  src 80.0.0.1 
> >     cache <local> 
> > # ip route get 80.0.0.2
> > 80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15 
> >     cache 
> > 
> > While the route does remain in the table (so it can be modified if
> > needed rather than being wiped away as it would be if IFF_UP was
> > cleared), the proper next-hop is chosen automatically when the link is
> > down.  Now interface p8p1 is linked-up:
> > 
> > # ip route show 
> > default via 10.0.5.2 dev p9p1 
> > 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
> > 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
> > 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 
> > 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 
> > 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
> > 192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
> > # ip route get 90.0.0.1 
> > 90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1 
> >     cache 
> > # ip route get 80.0.0.1 
> > local 80.0.0.1 dev lo  src 80.0.0.1 
> >     cache <local> 
> > # ip route get 80.0.0.2
> > 80.0.0.2 dev p8p1  src 80.0.0.1 
> >     cache 
> > 
> > and the output changes to what one would expect.
> > 
> > Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> > Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> > 
> > ---
> > Though there were some that preferred not to have a configuration option
> > and to make this behavior the default when it was discussed in Ottawa
> > earlier this year since "it was time to do this."  I wanted to propose
> > the config option to preserve the current behavior for those that desire
> > it.  I'll happily remove it if Dave and Linus approve.
> 
> I raised the concern that in case we don't have any other fallback route
> and the kernel decides to send back ICMP errors to the end host, we
> could kill TCP connections with those error messages. The current
> behavior is that the packet gets silently dropped and TCP will retry, no
> ICMP error message is send by immediate routers. This is especially
> important if only a short link loss event happens on a default route.
If you do not have any default route configured (or your default route
is the one that went down!), then you could see this happening.
> 
[...]
> 
> This is a great feature, thanks!
Glad you like it.

> Hannes
