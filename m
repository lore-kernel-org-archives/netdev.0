From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Tue, 31 Mar 2015 22:35:48 +0200
Message-ID: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
References: <20150329.124248.1745435092252856808.davem@davemloft.net>
 <1427718657-21674-1-git-send-email-klamm@yandex-team.ru>
 <20150331.160538.1808487957641759931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, klamm@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150331.160538.1808487957641759931.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015, at 22:05, David Miller wrote:
> From: Roman Gushchin <klamm@yandex-team.ru>
> Date: Mon, 30 Mar 2015 15:30:57 +0300
> 
> > This patch introduces new ipv6 sysctl: ra_default_route_mtu.
> > If it's set (> 0), it defines per-route MTU for any new default route
> > received by RA.
> > 
> > This sysctl will help in the following configuration: we want to use
> > jumbo-frames for internal networks and default ethernet frames for
> > default route. Per-route MTU can only lower per-link MTU, so link MTU
> > should be set to ~9000 (statically or via RA).
> > 
> > Due to dynamic nature of RA, setting MTU for default route will require
> > userspace agent, that will monitor changes of default route
> > and (re)configure it. Not simple. The suggested sysctl solves this
> > problem.
> > 
> > Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> I don't like this change at all.  The way I see things you already
> have the mechanisms necessary to do this.

This is totally understandable and the change seems not to fit because
it alters incoming information, but I try to quickly explain my
reasoning for the Ack:

Neighbour Discovery does not fit the way how linux handles MTUs. It is
only possible to send out one MTU option on the Router Advertisement and
we pick it up as the ipv6 MTU value for the interface. A RA can provide
further routing information but no MTU option is possible to be
specified on those route options, thus they will adapt the link MTU.
There is no differentiation between interface MTU and per-route MTU. 

One common setup is to have local jumbo frames to speed up e.g. NFS
traffic and use default routes with MTU 1500 to reach the outside world.
As I had no other idea how to solve this with in-kernel autoconf
mechanism I thought this change would be reasonable.

Obviously one can disable autoconf and set up routes by hand with
correct MTU values which should solve the problem - or use custom DHCPv6
options to do so.

> You obviously control the entity providing the default routes and
> these RA messages, therefore you absolutely can configure it to
> provide an appropriate MTU value in those RA messages.
> 
> Problem solved, and no kernel changes necessary.
> 
> I am warning you ahead of time that I will have a very low tolerance
> for replies to this email containing stories explaining why this is
> "difficult" to do.  The fact is that the mechanism is there and if you
> have designed things at your site in a way such that the mechanism
> designed for this has become less useful, that isn't my problem.
> 
> I'm not adding facilities that duplicated existing methods that
> already exist to accomplish this task.

Could you quickly comment on what you had in mind? I guess it is about
handling RA in user space on the end hosts and overwriting MTU during
insertion of the routes?

Thanks,
Hannes
