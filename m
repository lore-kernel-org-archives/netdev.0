From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BUG] can't unload network device's if IPV6 is loaded
Date: Thu, 11 Dec 2003 16:18:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031211161856.6960c479.davem@redhat.com>
References: <20031211153334.0c59214b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031211153334.0c59214b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Dec 2003 15:33:34 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> In 2.6.0-test11, IPV6 is not correctly cleaning up the network
> device reference's (ie missing dev_put).  So if I do:
> 	rmmod e100
> it hangs forever and complains about that not all references have
> been cleaned up.
> 
> This happens even if no IPV6 addresses have been set up. Just having
> ipv6 available to be loaded at boot up.  The vendor startup scripts
> (SuSe 9) may be setting something.

Ugh, I thought we had killed all of this kind of crap.
We had so many issues in this area wrt. the autoconf and mcast
but those all got fixed up.

Yoshfuji is very busy at this time, probably until the new year.
So we need to try and figure this one out ourselves.

Even without configuring anything, IPV6 does things to all active
devices when it is loaded.

1) It assigns link-local IPV6 addresses to interfaces it understands.
2) It joins the standard default multicast groups necessary for a
   device to take part in ipv6 operations on a network.

So when the device is brought down all this stuff has to be undone.
This is where the problems are likely to be, and where they in
fact were in previous cases where we fixed this bug.

The setup of each device occurs in net/ipv6/addrconf.c in
addrconf_init().  It loops over all devices and configures them
for ipv6 operation.

For ethernet devices it would call addrconf_dev_config().  This also
happens when NETDEV_UP events are sent out.  It allocates the ipv6
device private data, gives it a link-local address (which is usually
formed using a fixed constant prefix with the device hardware address
added to the end).  This is also where the default multicast and link
local routes are added via addrconf_add_mroute() and
addrconf_add_lroute() respectively.  If all of this succeeds, the
duplicate address detection process is begun via addrconf_dad_start().

addrconf_ifdown() is supposed to undo and clean all of this crap up
when the interfaces goes down or is unregistered.

One problem we had previously was due to the fact that if it was an
unregister causing addrconf_ifdown() to run, the first thing this
function will do is NULL out dev->ip6_ptr, which causes things like
{,__}in6_dev_get() to return NULL.  This causes problems for cleaning
up the multicast references, in mcast.c:ipv6_mc_destroy_dev().

We had to change that multicast code to pass the 'idev' around
directly instead of obtaining it via __in6_dev_get().  There are even
comments in ipv6_mc_destroy_dev() which were added to explain this
problem.

The other area we had a refcount problem was wrt. the addrconf
per-device timers used for implementation of the privacy extension.
I forget the exact nature of the bug, but Herbert Xu coded up the
patch to fix that stuff, you should be able to see it in the BK
revision history of addrconf.c

I hope this can help you search down the problem further.  These areas
(addrconf and mcast) should be the only sources of device references
in your case.
