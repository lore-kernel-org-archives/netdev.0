From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Wed, 10 Sep 2003 21:49:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063226945.7869.325.camel@imladris.demon.co.uk>
References: <Pine.LNX.4.44.0309102147310.3223-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309102147310.3223-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-09-10 at 21:52 +0300, Pekka Savola wrote:
> Please don't do this, this is an ambomination.  Moreover, some time ago 
> the IETF decided to Deprecate Site-local addresses completely, because of 
> their problems.

Hmmm; bugger. 

I thought the site-local address concept was great. It was going to
allow us to keep external connectivity issues completely separate from
internal ones.

So is there still a range of IPv6 addresses analogous to the RFC1918
IPv4 ranges, which are purely internal-only? Or is everyone expected to
just use 'real' IPv6 addresses, and firewall appropriately?

I'll lay our our situation in a bit more detail... I don't think it's
too uncommon. 

We have a corporate IPv4 network. Multiple locations each have 'real'
IPv4 connections to local ISPs; we have a network of CIPE tunnels
between physical locations, over which we run the 172.16/12 IPv4
network. Internal boxen communicating to the outside world go via local
NAT, of course.

We want to deploy IPv6 internally. We have no overriding corporate
reason for doing this; for getting the IT people to spend their time on
it and overhaul all the CIPE boxes to be IPv6-capable, etc. It'll just
be useful for testing purposes, and because -- let's face it -- we're
geeks and we want IPv6 :)

Our criteria are these:
 - To connect between two internal hosts by IPv6 should not be
   noticeably less reliable, or slower, than the existing IPv4.

 - The setup should be as simple as possible, and to as large an extent
   as possible should not require infrastructure changes.

 - Connectivity to the _outside_ should go as directly as possible;
   not all via a single tunnel endpoint in headquarters. 

 - Security must be obvious. The IT people don't have time to spend on
   it; that includes auditing. Using site-local addresses and then doing
   NAT to the outside world, or using public addresses arranged
   individually for each location and then connection-tracking to allow
   only outgoing connections as _if_ it were behind NAT, is obviously
   correct. Anything else is significantly less obvious.

Using 6to4 for internal site-scope addresses would have given us direct
connection between individual machines -- no points of failure which
aren't already a point of failure for IPv4; unlike a scenario where we
have a single tunnel-concentrator somewhere. This gives us the speed and
reliability required in our first criterion, and also a trivial
configuration. No big lists of tunnel endpoints, etc. 

Then global addresses could just have been arranged with an appropriate
connection in each location and a connection-tracking firewall.

It was all nice and simple...

Now I'm going back to the drawing-board. If the distinction between
site-scope and global-scope is gone, then I suppose one possibility is
to muck around with destination-based source address selection to
achieve the same effect. Something like giving each internal machine two
global IPv6 addresses -- one in the 2002:ac10::/28 range, and one 'real'
globally-routable address. 

Then we configure them such that for communicating with other hosts in
2002:ac10::/28 they use that address, and for communicating with 'real'
hosts, they use the 'real' address. How feasible is that?

We may end up with the internal hosts sticking packets for 'real'
2002::/16 6to4 addresses inside IPv4 packets and sending them somewhere,
but since we control '$somewhere' and it's not hard-coded to 
192.88.99.1 we can deal with that -- as long as they're correctly using
their 'real' IPv6 addresses as the source. 

My main objection to this, although I think it can work and be secure,
is that it requires _thought_ to show it's secure. It really needs to be
obvious.

A second possibility, perhaps, would be to just get 'real' IPv6 networks
in all the locations, and route that publicly with connection-tracking
firewalls on the public-facing machines. Then to effectively punch holes
in those firewalls for 'internal' communication, by using
explicitly-configured tunnels to bypass the firewalls.

That one seems nicer, but has the severe disadvantage that we can't just
start doing it internally over the existing IPv4 network -- we have to
actually make changes to the network infrastructure, which means getting
real time (and downtime) allocated for it up front. Which is unlikely
for what's effectively a Skunkworks project.

Better suggestions are welcomed.

-- 
dwmw2
