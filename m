From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Introduce FCLONE_SCRATCH skbs to reduce stack memory useage and
 napi jitter
Date: Thu, 27 Oct 2011 21:37:30 -0400
Message-ID: <20111028013729.GA6524@neilslaptop.think-freely.org>
References: <1319745221-30880-1-git-send-email-nhorman@tuxdriver.com>
 <1319756146.19125.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53154 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab1J1Bhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 21:37:39 -0400
Content-Disposition: inline
In-Reply-To: <1319756146.19125.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2011 at 12:55:46AM +0200, Eric Dumazet wrote:
> Le jeudi 27 octobre 2011 =E0 15:53 -0400, Neil Horman a =E9crit :
> > I had this idea awhile ago while I was looking at the receive path =
for multicast
> > frames.   The top of the mcast recieve path (in __udp4_lib_mcast_de=
liver, has a
> > loop in which we traverse a hash list linearly, looking for sockets=
 that are
> > listening to a given multicast group.  For each matching socket we =
clone the skb
> > to enqueue it to the corresponding socket.  This creates two proble=
ms:
> >=20
> > 1) Application driven jitter in the receive path
> >    As you add processes that listen to the same multcast group, you=
 increase the
> > number of iterations you have to preform in this loop, which can le=
ad to
> > increases in the amount of time you spend processing each frame in =
softirq
> > context, expecially if you are memory constrained, and the skb_clon=
e operation
> > has to call all the way back into the buddy allocator for more ram.=
  This can
> > lead to needlessly dropped frames as rx latency increases in the st=
ack.
> >=20
>=20
> Hmm... time to perform this loop not depends on memory constraints,
> since GFP_ATOMIC allocations are done. It succeed or not, immediately=
=2E
>=20
Thats not entirely correct.  The time it takes to allocate a new object=
 from the
slab can be very much affected by memory contraints.  Systems under mem=
ory
pressue may need to shrink slab caches, allocate from remote nodes, etc=
, all of
which contributes to additional allocation time.  This time is multipli=
ed by the
number of sockets listening to a particular group.  I'm not saying its =
a huge
change, but its a change that I saw the ability to address.   This chan=
ge (I
hope) tries, when able, to eliminate the jitter from that path.

> Time is consumed on the copy of the skb head, and refcnt
> increases/decreases on datarefcnt. Your patch doesnt avoid this.
>=20
No it doesn't, you're correct.  I was really looking at lower hanging f=
ruit with
this change.

> When application calls recvmsg() we then perform the two atomics on s=
kb
> refcnt and data refcnt and free them, with cache line false sharing..=
=2E
>=20
> > 2) Increased memory usage
> >    As you increase the number of listeners to a multicast group, yo=
u directly
> > increase the number of times you clone and skb, putting increased m=
emory
> > pressure on the system.
> >=20
>=20
> One skb_head is about 256 bytes (232 bytes on 64bit arches)
>=20
Yes, thats right.  Depending on the size of the received frame I can al=
locate
anywhere from 1 to 4 additional skbs using otherwise unused memory at t=
he tail
of the data segment with this patch.

> > while neither of these problems is a huge concern, I thought it wou=
ld be nice if
> > we could mitigate the effects of increased application instances on=
 performance
> > in this area.  As such I came up with this patch set.  I created a =
new skb
> > fclone type called FCLONE_SCRATCH.  When available, it commandeers =
the
> > internally fragmented space of an skb data buffer and uses that to =
allocate
> > additional skbs during the clone operation. Since the skb->data are=
a is
> > allocated with a kmalloc operation (and is therefore nominally a po=
wer of 2 in
> > size), and nominally network interfaces tend to have an mtu of arou=
nd 1500
> > bytes, we typically can reclaim several hundred bytes of space at t=
he end of an
> > skb (more if the incomming packet is not a full MTU in size).  This=
 space, being
> > exclusively accessible to the softirq doing the reclaim, can be qui=
ckly accesed
> > without the need for additional locking, potntially providing lower=
 jitter in
> > napi context per frame during a receive operation, as well as some =
memory
> > savings.
> >=20
> > I'm still collecting stats on its performance, but I thought I woul=
d post now to
> > get some early reviews and feedback on it.
> >=20
>=20
> I really doubt you'll find a significative performance increase.
>=20
With the perf script I included in this set, I'm currently reducing the=
 napi rx
path runtime by about 2 microsecond per iteration when multiple process=
es are
listening to the same group, and we can allocate skbs from the data are=
a of the
received skb.  I'm not sure how accurate (or valuable) that is, but tha=
ts what
I'm getting.  While I've not measured, theres also the fact that kfree_=
skb doesn't
have any work to do with FCLONE_SCRATCH skbs, since they all get return=
ed when
the data area gets kfreed.  Lastly, theres the savings of 256 bytes per
listening app that uses an FCLONE_SCRATCH skb, since that memory is alr=
eady
reserved, and effectively free.  I can't really put a number on how sig=
nificant
that is, but I think its valuable.


> I do believe its a too complex : skb code is already a nightmare if y=
ou
> ask me.
>=20
I'm not sure I agree with that.  Its certainly complex in the sense tha=
t it adds
additional state to be checked in the skb_clone and kfree_skb paths, bu=
t beyond
that, it doesn't require any semantic changes to any of the other parts=
 of the
skb api(s).  Is there something specific about this change that you fin=
d
unacceptibly complex, or something I can do to make it simpler?

> And your hack/idea wont work quite well if you have 8 receivers for e=
ach
> frame.
>=20
It will work fine, to whatever degree its able, and this it will fall b=
ack on
the standard skb_clone behavior.  The performance gains will be reduced=
, of
course, which I think is what you are referring to, but the memory adva=
ntages
still exit.  If you have 8 receivers, but a given skb has only enough f=
ree space
at the end of the data segment to allocate 4 additional skbs, we'll all=
ocate
those 4, and do a real kmem_cache_alloc of 4 more in skb_clone.  The la=
st 4 have
to use the slab_allocation path as we otherwise would, so we're no wors=
e off
than before, but we still get the memory savings (which would be about =
1k per
received frame for this mcast group, which I think is significant).

> What about finding another way to queue one skb to N receive queue(s)=
,
> so that several multicast sockets can share same skb head ?
>=20
Yes, I'd experimented with some of this, and had mixed results.  Specif=
ically I
came up with a way to use the additional space as an array of list head=
s, with
backpointers to the socket_queue each list_head was owned by and the sk=
b that
owned the entry.  It was nice because it let me enqueue the same skb to=
 hundreds
of sockets at the same time, which was really nice.  It was bad however=
, because
it completely broke socket accounting (any likely anything else that re=
quired on
any part of the socket state).  Any thoughts on ways I might improve on=
 that.
If I could make some sort of reduced sk_buff so that I didn't have to a=
llocate
all 256 bytes of a full sk_buff, that would be great!

> I always found sk_receive queue being very inefficient, since a queue=
 or
> dequeue must dirty a lot of cache lines.
>=20
> This forces us to use a spinlock to protect queue/enqueue operations,
> but also the socket lock (because of the MSG_PEEK stuff and
> sk_rmem_alloc / sk_forward_alloc)
>=20
> sk_receive_queue.lock is the real jitter source.
>=20
> Ideally, we could have a fast path using a small circular array per
> socket, of say 8 or 16 pointers to skbs, or allow application or
> sysadmin to size this array.
>=20
> A circular buffer can be handled without any lock, using atomic
> operations (cmpxchg()) on load/unload indexes. The array of pointers =
is
> written only by the softirq handler cpu, read by consumers.
>=20
> Since this array is small [and finite size], and skb shared, we dont
> call skb_set_owner_r() anymore, avoiding expensive atomic ops on
> sk->sk_rmem_alloc.
>=20
> UDP receive path could become lockless, allowing the softirq handler =
to
> run without being slowed down by concurrent recvmsg()
>=20
> At recvmsg() time, N-1 threads would only perform the skb->refcnt
> decrement, and the last one would free the skb and data as well.
>=20
This seems like a reasonable idea, and I'm happy to experiment with it,=
 but I
still like the idea of using that often available space at the end of a=
n skb,
just because I think the memory savings is attractive.  Shall I roll th=
em into
the same patch series, or do them separately?
Neil

>=20
>=20
>=20
