From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible race condition in conntracking
Date: Tue, 27 Jan 2009 10:20:33 +0100
Message-ID: <497ED1E1.40304@trash.net>
References: <20090127075744.GA19875@eric.schwarzvogel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Tobias Klausmann <klausman@schwarzvogel.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090127075744.GA19875@eric.schwarzvogel.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CCed netfilter-devel]

Tobias Klausmann wrote:
> Hi!
> 
> I'm resending this to netdev (sent it to linux-net yesterday)
> because I was told all the cool and relevant kids hang out here
> rather than there.
> 
> It seems I've stumbled across a bug in the way Netfilter handles
> packets. I have only been able to reproduce this with UDP, but it
> might also affect other IP protocols. This first bit me when
> updating from glibc 2.7 to 2.9.
> 
> Suppose a program calls getaddrinfo() to find the address of a
> given hostname. Usually, the glibc resolver asks the name server
> for both the A and AAAA records, gets two answers (addresses or
> NXDOMAIN) and happily continues on. What is new with glibc 2.9 is
> that it doesn't serialize the two requests in the same way as 2.7
> did. The older version will ask for the A record, wait for the
> answer, ask for the AAAA record, then wait for that answer. The
> newer lib will fire off both requests in short time (usually 5-20
> microseconds apart on the systems I tested with). Not only that,
> it also uses the same socket fd (and thus source port) for both
> requests.
> 
> Now if those packets traverse a Netfilter firewall, in the
> glibc-2.7 case, they will create two conntrack entries, allowing
> the answers back[0] and everything is peachy. In the glibc-2.9
> case, sometimes, the second packet gets lost[1]. After
> eliminating other causes (buggy checksum offloading, packetloss,
> busy firewall and/or DNS server and a host of others), I'm sure
> it's lost inside the firewall's Netfilter code. 
> 
> Using counting-only rules and building a dedicated setup with a
> minimal Netfilter rule set, we could watch the counters, finding
> two interesting facts for the failing case:
> 
> - The count in the NAT pre/postrouting chains is higher than for
>   the case where the requests work. This points to the second
>   packet being counted although it's part of the same connection
>   as the first.
>   
> - All other counters increase, up to and including
>   mangle/POSTROUTING. 
> 
> In essence, if you have N tries and one of them fails, you have
> 2N packets counted everywhere except the NAT chains, where it's
> N+1.
> 
> Since neither QoS nor tunneling is involved, the second packet
> appears to be dropped by Netfilter or the NICs code. Since we see
> this behaviour on varying hardware, I'm rather sure it's the
> former.
> 
> The working hypothesis of what happens is this:
> 
> - The first packet enters Netfilter code, triggering a check if a
>   conntrack entry is relevant for it. Since there is no entry,
>   the packet creates a new conntrack that isn't yet in the global
>   hash of conntrack entries. Since the chains could modify the
>   packet's relevant info, the entry can not be added to the hash
>   then and there (aka unconfirmed conntrack).
> 
> - The second packet enters Netfilter code. Again, no conntrack
>   entry is relevant since the first packet has not gotten to the
>   point where its conntrack would have been added to the global
>   hash, so the second packet gets an unconfirmed conntrack, too.
> 
> - The first packet reaches the point where the conntrack entry is
>   added to the global hash.
> 
> - The second packet reaches the same point but since it has the
>   same src/sport-dst/dport-proto tuple, its conntrack causes a
>   clash with the existing entry and both (packet and entry) are
>   discarded.

That sounds plausible, but we only discard the new conntrack
entry on clashes. The packet should be fine, unless you drop
INVALID packets in your ruleset.

> Since the timing is very critical on this, it only happens if an
> application (such as the glibc resolver of 2.9) fires two packets
> rapidly *and* those have the same 5-tuple *and* they are
> processed in parallel (e.g. on a multicore machine). 
> 
> Another observation is that this happens much less often with
> some kernels. While the on one it can be triggered about 50% of
> the cases, on another you can go for 20k rounds of two packets
> before the bug is triggered. Note, however, that the
> probabilities vary wildly: I've seen the program break on the
> first 100 packets a dozen times in a row and later not breaking
> for 50k tries in a row on the same kernel.
> 
> Since glibc 2.7 is using different ports and waiting for answers,
> it doesn't trigger this race. I guess there are very few
> applications where normal operations allow for a quickfire of the
> first two UDP packets in this manner. As a result, this has gone
> unnoticed for quite a while - and even if it happens, it may look
> like a fluke.
> 
> When looking at the conntrack stats, we also see that
> insert_failed in /proc/net/stat/nf_conntrack does indeed increase
> when the routing of the second packet fails.
> 
> The kernels used on the firewall (all vanilla versions):
> 2.6.25.16 
> 2.4.19pre1
> 2.6.28.1
> 
> All of them show this behaviour. On the clients, we only have
> 2.6-series kernels, but I doubt they influence this scenario
> (much).

Try tracing the packet using the TRACE target. That should show
whether it really disappears within netfilter and where.
