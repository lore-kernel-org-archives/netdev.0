From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 02:28:05 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF339FA69C.C0404720-ON88256ED2.002C1123-88256ED2.002E61B7@us.ibm.com>
References: <1089871078.3571.56.camel@bach>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1089871078.3571.56.camel@bach>
To: "Rusty Russell (IBM)" <rusty@au1.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rusty,
        Those ideas should work if both sides are Linux, but not
when mixing with something else. A non-Linux receiver won't
detect wrap and drop the packet, generally, even if the fragments
overlap and don't match, and a non-Linux sender will send
(typically) same-sized fragments that aren't offset. Doesn't hurt
anything for those cases, so maybe in addition:

My idea for solving this problem is to create an estimator for the
reassembly timer. The fundamental problem as I see it is that the
reassembly timer is fixed, and about 6000 times too long on a
fast network (and worse the faster networks get).

In the typical case, you'll receive lots of successfully reassembled
packets from the same destination and, from those, you can build
a good time estimate for how long it takes you to receive all the
fragments, when you're going to. The reassembly timeout ought
to be a little longer than that estimator, which might be a fraction of
a millisecond on a local link, and maybe tens of seconds going across
the Internet. Then you can time out and release the frags based on
the expected behavior, rather than waiting so long the other side
has time to wrap while you still have a valid frag queue.

It also has the advantage that, on a faster link, a higher loss rate
doesn't have you wasting memory holding fragments that aren't
ever going to be reassembled successfully, anyway.

The estimator could be very much like the TCP rtt estimator, and
could go in the routing table (not so good for asymmetric paths),
the fib, or its own little cache w/ timeout maintained by the reassembly
code.

There are some problems with this scheme, too, but I think it fixes
most bad behavior on the receiver side with unmodified senders.

Comments?
                                        +-DLS
