From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 9 Mar 2005 13:05:24 +0100
Message-ID: <16942.59012.365490.619623@robur.slu.se>
References: <20050301220743.GF2554@netnation.com>
	<16940.9990.975632.115834@robur.slu.se>
	<20050309014516.GA806@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050309014516.GA806@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > Interesting patch!  I haven't had a chance to try it yet, but I have
 > been thinking about this sort of approach for some time.
 > 
 > I'm wondering, though, if this patch would ever be accepted upstream.
 > The preroute patches make it now require a full slow route lookup
 > before checking the route cache, right?  Eg: ip_route_input() is
 > replaced with a call to ip_route_input_nohash() which then might fall
 > back on ip_route_input() which checks the route cache.  The nohash
 > function, however, still appears to have to do the full fib_lookup()
 > which is the same as doing at least one slow route lookup for every
 > packet.

 Well the intention with the patch was to be able to test performance
 w/o route hash as many poeple think if just route hash goes away
 all things will be fine. Jamal and I starting hacking on this at OLS
 2004 and it was used to test LC-trie.

 IMO there is still no definitive answer and even the answer is dependent
 of other things i.e how much can we improve FIB lookup etc,

 Also a bit interesting is those DDOS stories/cases being heard, This
 as I'm involved in configuring and solving practical routing problems
 but never seen DDOS at the levels reported. We should design for worst 
 case but not for something that's totally broke.

 > The random src/dst DoS case really kills the route cache because of the
 > rehashing, locking, and memory allocation and freeing.  I see that the
 > RCU lists and locking now makes it very difficult to recycle the entries,
 > so I think this patch is probably the right idea for now (although the
 > route cache should probably still be optimized where possible).

 To some extent true... but you have the patches to test and copare 
 with pure FIB lookup yourself. Try single and DDOS and compare. DDOS 
 forces a lot of FIB lookups still and keeps your L2 cache very busy 
 you see degradation here to. I have some results to compare with,

 Also route hash can be improved and of course it can tuned but it needs 
 some effort.
 BTW I have some patches somewhere that makes input route hash per 
 device a bit NAPI thinking to get fairness in case of DDOS etc.

 I heard some examples of intelligent dropping at DDOS attacks in 
 the PREROUTE hook.

 > I was wondering if instead it makes sense to still check the route cache
 > first, but insert the bypass code as in ip_route_input_nohash() between
 > where the slow route lookup is done and the dst cache entry is created. 
 > In other words:
 > 
 > - The route cache is checked first.  Entries in the route cache will
 >   continue immediately as they do now.
 > 
 > - Entries not in the route cache will trigger a slow route lookup as they
 >   do now.
 > 
 > - Routes which are "INPUT" or "OUTPUT" routes (eg: in or out of the local
 >   machine) will be added to the route cache as normal.

 Maybe a variant. You have to lookup the hash and could still hold 
 src/local_IPs/tos entries so we open for DDOS again?

 We have some experiments to do...
 

					--ro
