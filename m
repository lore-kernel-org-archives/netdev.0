From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0-test11: dst_cache_overflow causing unresponsive box
Date: Tue, 2 Dec 2003 03:26:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202032606.28db927b.davem@redhat.com>
References: <072501c3b874$2542ae70$15fea8c0@fortress>
	<16332.27919.502097.988522@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: francois@baligant.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16332.27919.502097.988522@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 11:44:31 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> No experience with 90k TCP-flows but it seems GC is not able to free some 
> the dst-entries for some reason. This will slowly kill your box with 
> symptoms you describe. We have ask TCP-experts for timer settings to avoid
> pending sessions etc. Also check slab for any other objects growing as 
> dst cache overflow is most likely secondary effect in your case. rtstat 
> looks sane expect for the high number of dst-entries. Tuning is another 
> story.

Let us assume, for the sake of back of the envelope calculations, that
all 90k TCP connections speak to unique destinations.  Let us further
assume that all of them have at least one packet in flight.

This means the routing cache must be able to hold at least 90k entries.
All of these routing cache entires will be referenced by the packets
in the TCP retransmission queues of all the sockets, and thus the
entries are unreclaimable.

You are setting net.ipv4.route.max_size to 655360 which should be more
than enough.  But you also have to make the net.ipv4.route.gc_thresh
more reasonable as well, perhaps 90K as a test.

If net.ipv4.route.gc_thresh is lower than 90K and my assertions above
hold, then the kernel will try to garbage collect too early, all the
routing cache entries will be in use and therefore uncollectable,
and you'll get the message you're seeing.

Try to pump up gc_thresh and see if that helps.
