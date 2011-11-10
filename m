From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: creating netdev queues on the fly?
Date: Thu, 10 Nov 2011 15:47:38 +0100
Message-ID: <CAA93jw6NZc4qP5ArK6tFF1DhP3_Rxsr8VFusU-nSzLHb6tnxjQ@mail.gmail.com>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1320933501.3967.68.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2011 at 2:58 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> Hi,

>
> Am I completely crazy?

Somewhat. :)

Much of your thinking aligns with mine, however my goal was to try and
reduce latencies on wireless-n, where we send variable size truckloads
of packets to each destination.

Solving that one is hard, and requires two levels of active queue
management in the packet scheduler layer, and a bit more communication
up from the driver itself.

We could have a unique 'station identifier' which fits handily into 32
bits as the max allowed range is 0-2008 and map from MAC to that on tx
entry. Having that as a flow classifier lets us have per station
destination queues easily split up via a std tc filter... and then  we
have the ability, finally, to manage queue depth on a per station
basis.

So you end up with four queues, each tied to a hardware queue that
then splits things up on a per station basis, fair queues within the
queues to each station, and recombines them at the end on a basis
bursty enough to aggregate as they exit the radio.

I don't mind at all up to 8000 queues, honestly, wasting 99% on mostly
unused queue structures via pouring megabytes into useless
bufferbloated FIFO only packet buffers seems an acceptible compromise,
but I'm easy...

As for managing queue depth on a per station basis, some of what has
been discussed on "byte queue limits" applies, but given wireless's
peculiarites, tsf timestamping on entry to the first qdisc, doing fair
queuing inside the per-sta queue (QFQ?), and checking the timestamp on
exit from the queue against a sane limit for the queue type would do
wonders for overall latencies and network responsiveness.

Done right, instead of seeing a single tcp stream capable of inducing
multi-second latencies for the next stream, latencies would stay flat
up unto the max aggregation depth of different streams on a given sta,
subject only the how many other competing stations there are, the net
effect of packet loss would be vastly lessened, and world peace,
achieved. I dream of 2ms pings and dns lookups, even gaming, under
load, on wireless. I do.

=46irst steps are getting a station identifier and some useful
statistics regarding that stations max (that quantum) packet bundle
size, and completion rate, mostly from minstrel... on each packet...

a tc classifier that can use it to toss into the tcindex mechanism (if
that is what is used), another sane classifier for something like QFQ
per station, and a packet 'grouper' that can output correctly sized
bursts of packets on a sane basis from the queues in a randomly sane
order (not round robin per se', to even out the load it has to start
dequeuing groups)

How to do all that within tc? Well... I like the idea of throwing out
the 32 bitness of tc's calssifiers (mac hashing and ipv6 hashing is
not very effective), but I doubt that will fly..

So to fit into the the existing structures the idea of adding the
concept of a  tc qdisc 'grouper'  along with all the other tc filter
'splitters' - that could be multiqueue and multiple hardware queue
aware - seems like an answer.

Another crazy piece of the idea (courtesy nbd - I'd rather go crazy
adding fields to the skb) is to wedge that id and some minstrel
statistics and completion rates and the timestamp into each skb's
mostly unused 48 byte 'reserved for special uses field... which it has
to do under rcu lock anyway.

I started coding up time based queue limits the other weekend,
actually... some of this has been discussed on the bloat list.

>
>
> johannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
