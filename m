From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fragment ID wrap workaround (read-only, untested).
Date: Thu, 15 Jul 2004 07:49:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF97127705.C0C08B6A-ON88256ED2.004DB9A5-88256ED2.005146DA@us.ibm.com>
References: <20040715092715.GA23131@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, "Rusty Russell (IBM)" <rusty@au1.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040715092715.GA23131@wotan.suse.de>
To: Andi Kleen <ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@suse.de> wrote on 07/15/2004 02:27:17 AM:

> Won't that make the worst case behaviour on a congested link much worse?

> e.g. consider a very congested link with variable RTTs. Or a
> link that works relatively smoothly and suddenly the RTT increases.

I know what you mean here, but just to be precise, this isn't an RTT
estimator, but an estimator for the time to receive a complete set
of fragments. And, of course, it'd need to be scaled to a (potential)
max-sized packet, since the number of fragments isn't known in advance,
and could be larger. Better multiple the time-out for a 4K reassembly
by 16, in case you get a 64K datagram next.

> Yes, running fragmentation over those is not a good idea, but
> still it should not be made worse.

Delivery to the user of incorrect data is the problem, and, no, it doesn't
make that worse. :-) The scenario, to make it clear for everyone, is a
small loss rate on a fast network leads to reassembling packets with the
same IP ID that are not the same packet when the ID wraps before the frag
queue timer has expired. If you're blasting away on a gigabit network (or
faster) and you drop one fragment (or more) from a packet you've received,
that frag queue will be there 65536 packets later when you reuse the same 
ID
for a different packet. I think that works out to be 7 secs or so at full
rate-- well within the 1-4 minute typical frag queue timer on most 
systems.
When the second packet arrives, if it's big enough that the missing frag
offsets can fulfill reassembly, it'll use them. So, 100% of the time when
sending same-sized packets, like NFS mostly does, and you lose 1 fragment,
you'll reassemble garbage when the IP ID wraps (well before the frag queue
expires). And the checksum will pass anyway on average about 1/64K of the
time. If you send at full rate and drop, say, 100 frags a second, it
doesn't take too long to get a Frankenpacket-- reassembled from parts of
others. :-)

That's the problem the timer idea is trying to solve, and a higher loss
rate here is acceptable-- the checksum only fails to catch the problem
1/64K of the time, so you probably have a relatively high loss rate to
start with when it's occurring.

> Your variable timer even with a smoothing algorithm in the RTT
> estimator will expire far too early and very likely drop a lot more
> fragments in this scenario than before.

Not necessarily, because it doesn't at all have to be a "near" estimate,
the way TCP is trying to make it. It can solve the problem by taking a
close estimate to the actual time and then using a frag timeout that's
10 times bigger. As long as the frag timeout isn't thousands of times too
large (as it is now), IP ID wrap can't happen before you dump the frag
queue-- the whole point.

> In general handling a link where the RTT increases would seem
> tricky with your scheme. Unlike TCP there is no retransmit
> to save the day.

In the particular case (NFS over UDP), there is both a retransmit (done
by RPC) and significant loss rate to start with. As long as the time-out
is conservative, I don't think this has to affect other cases
significantly.

                                                +-DLS
