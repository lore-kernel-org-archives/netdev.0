From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Tue, 8 Mar 2005 17:45:16 -0800
Message-ID: <20050309014516.GA806@netnation.com>
References: <20050301220743.GF2554@netnation.com> <16940.9990.975632.115834@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <16940.9990.975632.115834@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Mar 07, 2005 at 11:03:50AM +0100, Robert Olsson wrote:

> FYI. The preroute12 was incomplete... There is a number 13.

Hi Robert,

Interesting patch!  I haven't had a chance to try it yet, but I have
been thinking about this sort of approach for some time.

I'm wondering, though, if this patch would ever be accepted upstream.
The preroute patches make it now require a full slow route lookup
before checking the route cache, right?  Eg: ip_route_input() is
replaced with a call to ip_route_input_nohash() which then might fall
back on ip_route_input() which checks the route cache.  The nohash
function, however, still appears to have to do the full fib_lookup()
which is the same as doing at least one slow route lookup for every
packet.

The random src/dst DoS case really kills the route cache because of the
rehashing, locking, and memory allocation and freeing.  I see that the
RCU lists and locking now makes it very difficult to recycle the entries,
so I think this patch is probably the right idea for now (although the
route cache should probably still be optimized where possible).

I was wondering if instead it makes sense to still check the route cache
first, but insert the bypass code as in ip_route_input_nohash() between
where the slow route lookup is done and the dst cache entry is created. 
In other words:

- The route cache is checked first.  Entries in the route cache will
  continue immediately as they do now.

- Entries not in the route cache will trigger a slow route lookup as they
  do now.

- Routes which are "INPUT" or "OUTPUT" routes (eg: in or out of the local
  machine) will be added to the route cache as normal.

- Routes which are "FORWARD" routes will NOT be added to the route cache
  (and thus fall back to "slow" lookups up each time as with the preroute
  patch).  These slow lookups will be faster than maintaining route cache
  entries for these packets which we don't ever learn an MSS for anyway.

In fact, a heuristic could maybe be added to make the route cache bypass
conditional so that it only occurs when the table is full or there are
too many cache misses, or something.  This would maintain the route cache
performance in normal conditions but remove the route cache overhead in
spoofed src/dst type DoS loads that kill us today.

My guess is this would be an even simpler patch as some of the preroute
patch is a duplication of ip_route_input_slow() that has to happen in
this case anyway.

Simon-
