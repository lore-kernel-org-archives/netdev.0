From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 09:53:47 -0400
Message-ID: <20150603135347.GA10203@neilslaptop.think-freely.org>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55135 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739AbbFCNyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 09:54:03 -0400
Content-Disposition: inline
In-Reply-To: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2015 at 11:07:19PM -0400, Andy Gospodarek wrote:
> This patch adds the ability to have the Linux kernel track whether or
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.
> 
> Before this patch any link-failure on an interface that was serving as a
> gateway for some systems could result in those systems being isolated
> from the rest of the network as the stack would continue to attempt to
> send frames out of an interface that is actually linked-down.  When the
> kernel is responsible for all forwarding, it should also be responsible
> for taking action when the traffic can no longer be forwarded -- there
> is no real need to outsource link-monitoring to userspace anymore.
> 
> This feature is only enabled with the new sysctl set (default is off):
> net.core.kill_routes_on_linkdown = 1
> 
> When this is set, the following behavior can be observed (interface p8p1
> is link-down):
> 
> # ip route show 
> default via 10.0.5.2 dev p9p1 
> 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
> 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
> 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead 
> 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 dead 
> 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
> # ip route get 90.0.0.1 
> 90.0.0.1 via 70.0.0.2 dev p7p1  src 70.0.0.1 
>     cache 
> # ip route get 80.0.0.1 
> local 80.0.0.1 dev lo  src 80.0.0.1 
>     cache <local> 
> # ip route get 80.0.0.2
> 80.0.0.2 via 10.0.5.2 dev p9p1  src 10.0.5.15 
>     cache 
> 
> While the route does remain in the table (so it can be modified if
> needed rather than being wiped away as it would be if IFF_UP was
> cleared), the proper next-hop is chosen automatically when the link is
> down.  Now interface p8p1 is linked-up:
> 
> # ip route show 
> default via 10.0.5.2 dev p9p1 
> 10.0.5.0/24 dev p9p1  proto kernel  scope link  src 10.0.5.15 
> 70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
> 80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 
> 90.0.0.0/24 via 80.0.0.2 dev p8p1  metric 1 
> 90.0.0.0/24 via 70.0.0.2 dev p7p1  metric 2 
> 192.168.56.0/24 dev p2p1  proto kernel  scope link  src 192.168.56.2 
> # ip route get 90.0.0.1 
> 90.0.0.1 via 80.0.0.2 dev p8p1  src 80.0.0.1 
>     cache 
> # ip route get 80.0.0.1 
> local 80.0.0.1 dev lo  src 80.0.0.1 
>     cache <local> 
> # ip route get 80.0.0.2
> 80.0.0.2 dev p8p1  src 80.0.0.1 
>     cache 
> 
> and the output changes to what one would expect.
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> 
> ---
> Though there were some that preferred not to have a configuration option
> and to make this behavior the default when it was discussed in Ottawa
> earlier this year since "it was time to do this."  I wanted to propose
> the config option to preserve the current behavior for those that desire
> it.  I'll happily remove it if Dave and Linus approve.
> 
> An IPv6 implementation is also needed (DECnet too!), but I wanted to
> start with the IPv4 implementation to get people comfortable with the
> idea before moving forward.  If this is accepted the IPv6 implementation
> can be posted shortly.  
> 
> FWIW, we have been running this patch with the sysctl setting above and
> our customers have been happily using a backported version for IPv4 and
> IPv6 for >6 months.
> 
>  include/linux/netdevice.h      |  1 +
>  include/net/fib_rules.h        |  1 +
>  include/net/ip_fib.h           |  1 +
>  include/uapi/linux/rtnetlink.h |  1 +
>  include/uapi/linux/sysctl.h    |  1 +
>  kernel/sysctl_binary.c         |  1 +
>  net/core/dev.c                 |  2 ++
>  net/core/sysctl_net_core.c     |  7 +++++++
>  net/ipv4/fib_frontend.c        | 12 +++++++++--
>  net/ipv4/fib_rules.c           |  7 ++++++-
>  net/ipv4/fib_semantics.c       | 46 ++++++++++++++++++++++++++++++++++++------
>  net/ipv4/fib_trie.c            | 19 +++++++++++++----
>  12 files changed, 86 insertions(+), 13 deletions(-)
> 

Hey Andy-
	So, the implementation looks great.  That said, a question comes up in
my mind that I can't quite resolve.  In looking at your code, and seeing how it
fit into the routing path, I came accross the function sync_fib_down_dev, which
appears to be called in response to NETDEV_DOWN events.  Its purpose from my
read is to interrogate the fib for routes that specify the device going down as
the egress device, and mark said routes as dead.  I'm guessing that I'm missing
something here, but it seems as though this patch shouldn't be needed in light
of that behavior (unless the existing code is somehow broken, or I'm confused
about its purpose).  Could it be that whats really needed here is for Network
Manager (or other user space programs ) to stop removing routes in response to
NETDEV_DOWN events so that the above kernel code can do its job?

Regards
Neil
