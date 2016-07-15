From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Fri, 15 Jul 2016 15:18:12 -0700
Message-ID: <57896124.6090402@gmail.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
 <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
 <20160714234207.GA93671@ast-mbp.thefacebook.com> <57882945.4090101@gmail.com>
 <20160715132329.0d04ac42@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, fw@strlen.de,
	jhs@mojatatu.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34374 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbcGOWS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 18:18:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so7093549pfb.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 15:18:26 -0700 (PDT)
In-Reply-To: <20160715132329.0d04ac42@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-15 04:23 AM, Jesper Dangaard Brouer wrote:
> On Thu, 14 Jul 2016 17:07:33 -0700
> John Fastabend <john.fastabend@gmail.com> wrote:
>=20
>> On 16-07-14 04:42 PM, Alexei Starovoitov wrote:
>>> On Wed, Jul 13, 2016 at 11:23:12PM -0700, John Fastabend wrote: =20
>>>> This converts the pfifo_fast qdisc to use the alf_queue enqueue an=
d
>>>> dequeue routines then sets the NOLOCK bit.
>>>>
>>>> This also removes the logic used to pick the next band to dequeue =
from
>>>> and instead just checks each alf_queue for packets from top priori=
ty
>>>> to lowest. This might need to be a bit more clever but seems to wo=
rk
>>>> for now.
>>>>
>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>> ---
>>>>  net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++-------=
------------- =20
>>>  =20
>>>>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *=
qdisc,
>>>>  			      struct sk_buff **to_free)
>>>>  {
>>>> -	return qdisc_drop(skb, qdisc, to_free);
>>>> +	err =3D skb_array_produce_bh(q, skb); =20
>>> .. =20
>>>>  static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
>>>>  {
>>>> +		skb =3D skb_array_consume_bh(q); =20
>>>
>>> For this particular qdisc the performance gain should come from
>>> granularityof spin_lock, right? =20
>>
>> And the fact that the consumer and producer are using different
>> locks now.
>=20
> Yes. Splitting up enqueue'ers (producer's) from the dequeuer (consume=
r)
> is an important step, because today the qdisc layer have this problem
> that enqueue'ers can starve the single dequeuer.  The current
> mitigation tricks are the enq busy_lock and bulk dequeue.
>=20
> As John says, using skb_array cause producers and consumer to use
> different locks.
>=20
>>> Before we were taking the lock much earlier. Here we keep the lock,
>>> but for the very short time.
>>>         original pps        lockless        diff
>>>         1       1418168             1269450         -148718
>>>         2       1587390             1553408         -33982
>>>         4       1084961             1683639         +598678
>>>         8       989636              1522723         +533087
>>>         12      1014018             1348172         +334154
>>>
>=20

I was able to recover the performance loss here and actually improve it
by fixing a few things in the patchset. Namely qdisc_run was
being called in a few places unnecessarily creating a fairly large per
packet cost overhead and then using the _bh locks was costing quite a
bit and is not needed as Jesper pointer out.

So new pps data here in somewhat raw format. I ran five iterations of
each thread count (1,2,4,8,12)

nolock (pfifo_fast)
1:  1440293 1421602 1409553 1393469 1424543
2:  1754890 1819292 1727948 1797711 1743427
4:  3282665 3344095 3315220 3332777 3348972
8:  2940079 1644450 2950777 2922085 2946310
12: 2042084 2610060 2857581 3493162 3104611

lock (pfifo_fast)
1:  1471479 1469142 1458825 1456788 1453952
2:  1746231 1749490 1753176 1753780 1755959
4:  1119626 1120515 1121478 1119220 1121115
8:  1001471  999308 1000318 1000776 1000384
12:  989269  992122  991590  986581  990430

nolock (mq)
1:   1435952  1459523  1448860  1385451   1435031
2:   2850662  2855702  2859105  2855443   2843382
4:   5288135  5271192  5252242  5270192   5311642
8:  10042731 10018063  9891813  9968382   9956727
12: 13265277 13384199 13438955 13363771  13436198

lock (mq)
1:   1448374  1444208  1437459  1437088  1452453
2:   2687963  2679221  2651059  2691630  2667479
4:   5153884  4684153  5091728  4635261  4902381
8:   9292395  9625869  9681835  9711651  9660498
12: 13553918 13682410 14084055 13946138 13724726

So then if we just use the first test example because I'm being a
bit lazy and don't want to calculate the avg/mean/whatever we get
a pfifo_fast chart like,

      locked             nolock           diff
---------------------------------------------------
1     1471479            1440293          =E2=88=92  31186
2     1746231            1754890          +   8659
4     1119626            3282665          +2163039
8     1119626            2940079          +1820453
12     989269            2857581*         +1868312

[*] I pulled the 3rd iteration here as the 1st one seems off

And the mq chart looks reasonable again with these changes,


       locked            nolock           diff
---------------------------------------------------
1       1448374          1435952          -  12422
2       2687963          2850662          + 162699
4       5153884          5288135          + 134251
8       9292395         10042731          + 750336
12     13553918         13265277          - 288641

So the mq case is a bit of a wash from my point of view which I sort
of expected seeing in this test case there is no contention on the
enqueue()/producer or dequeue()/consumer case when running pktgen
at 1 thread per qdisc/queue. A better test would be to fire up a few
thousand udp sessions and bang on the qdiscs to get contention on the
enqueue side. I'll try this next. On another note the variance is a
touch concerning in the data above for the no lock case so might look
into that a bit more to see why we can get 1mpps swing in one of those
cases I sort of wonder if something kicked off on my test machine
to cause that.

Also I'm going to take a look at Jesper's microbenchmark numbers but I
think if I can convince myself that using skb_array helps or at least
does no harm I might push to have this include with skb_array and then
work on optimizing the ring type/kind/etc. as a follow up patch.
Additionally it does seem to provide goodness on the pfifo_fast single
queue case.

=46inal point is there are more optimizations we can do once the enqueu=
e
and dequeue is separated. For example two fairly easy things include
removing HARD_TX_LOCK nn NICs with a ring per core and adding bulk
dequeue() to the skb_array or alf queue or whatever object we end up
on. And I expect this will provide additional perf boost.

Thanks,
John
