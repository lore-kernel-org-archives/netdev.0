From: Simon Kirby <sim@netnation.com>
Subject: Route cache performance
Date: Mon, 15 Aug 2005 14:38:55 -0700
Message-ID: <20050815213855.GA17832@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

Well, after a few years of other work :), I have finally got around to
setting up some more permanent forwarding / route cache performance
test boxes.  I noticed the route trie option in the newer 2.6 kernels
and figured it would be a good time to revisit things.

Test setup:

[Xeon w/e1000]---[Opteron w/dual e1000]---[Xeon w/e1000]

The Xeons are 2.4 GHz boxes and the Opteron is a 140.  At some point
I intend to compare the performance of a 32 bit versus 64 bit kernel.

I'm only able to get pktgen to spit out about 660 kpps from the test 2.4
Xeon box with onboard e1000 (pause disabled), but already I notice some
disappointing results.  The old 2.4.27 kernel I last did tests with seems
to do a much better job of forwarding small packets (static src/dst) than
2.4.31 and 2.6.12.

On the (leftmost) sending box, 2.4.27, 2.4.31, and 2.6.12 all seem to do
fairly well at transmission with pktgen.  The 2.6 pktgen seems a little
better (no transmission errors and a few more Mbps), so I've been using
2.6.12.  With fixed dst packets and pause disabled via ethtool, about
660 kpps is sent continuously.  juno (spoofed source, userspace) seems to
do about 360 kpps.  The routes and packets are set up to route through
the Opteron box to the receiving (rightmost) box.

I've noticed that e1000 changes integrated in 2.6.11-bk2 are resulting in
the forwarding test box slowing down enough that it seems to be exposing
"dst cache overflow", even though under slightly less load the gc seems
to be able to keep up.  Robert, if I read correctly it seems that the
e1000 NAPI changes were some fixes you submitted?

Something appears to be different in the rtcache GC or perhaps NAPI or
some other interaction, because firing juno at 2.4 does not show any
problems while I can't seem to get 2.6.12 to _not_ print "dst cache
overflow".  2.6.11 (pre-bk2) seems a little better at start, but any kind
of burst seems to make the route cache entries exceed gc and then the
slower hash lookups seem to make it get stuck at max_size (and printing
"dst cache overflow") until the attack stops, even with gc_min_interval
set to 0 (really 0).

Anyway, I'm still in early testing stages here but it seems it's still as
easy as ever to destroy routers (and hosts?) with a fairly small stream
of small packets which create new rtcache entries.  These days, 184 Mbps
is starting to fall under the "small" DoS attack category, too.

I notice the hash table size is still only 4096 buckets for 512 MB, which
isn't that wonderful when it hits a max_size of 65536 (w/512 MB)...

Simon-
