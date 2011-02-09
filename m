From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: Network performance with small packets
Date: Wed, 9 Feb 2011 07:43:45 +0000
Message-ID: <AANLkTinmqRLyGUtyfkCnrgkBsh2frQ3oO8hd6uE2O0he@mail.gmail.com>
References: <20110127.130240.104065182.davem@davemloft.net>
	<201102091107.20270.rusty@rustcorp.com.au>
	<20110209005345.GA12055@redhat.com>
	<201102091209.36546.rusty@rustcorp.com.au>
	<20110209015506.GA13289@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	Shirley Ma <mashirle@us.ibm.com>, netdev@vger.kernel.org,
	steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:33462 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab1BIHnq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 02:43:46 -0500
In-Reply-To: <20110209015506.GA13289@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 9, 2011 at 1:55 AM, Michael S. Tsirkin <mst@redhat.com> wro=
te:
> On Wed, Feb 09, 2011 at 12:09:35PM +1030, Rusty Russell wrote:
>> On Wed, 9 Feb 2011 11:23:45 am Michael S. Tsirkin wrote:
>> > On Wed, Feb 09, 2011 at 11:07:20AM +1030, Rusty Russell wrote:
>> > > On Wed, 2 Feb 2011 03:12:22 pm Michael S. Tsirkin wrote:
>> > > > On Wed, Feb 02, 2011 at 10:09:18AM +0530, Krishna Kumar2 wrote=
:
>> > > > > > "Michael S. Tsirkin" <mst@redhat.com> 02/02/2011 03:11 AM
>> > > > > >
>> > > > > > On Tue, Feb 01, 2011 at 01:28:45PM -0800, Shirley Ma wrote=
:
>> > > > > > > On Tue, 2011-02-01 at 23:21 +0200, Michael S. Tsirkin wr=
ote:
>> > > > > > > > Confused. We compare capacity to skb frags, no?
>> > > > > > > > That's sg I think ...
>> > > > > > >
>> > > > > > > Current guest kernel use indirect buffers, num_free retu=
rns how many
>> > > > > > > available descriptors not skb frags. So it's wrong here.
>> > > > > > >
>> > > > > > > Shirley
>> > > > > >
>> > > > > > I see. Good point. In other words when we complete the buf=
fer
>> > > > > > it was indirect, but when we add a new one we
>> > > > > > can not allocate indirect so we consume.
>> > > > > > And then we start the queue and add will fail.
>> > > > > > I guess we need some kind of API to figure out
>> > > > > > whether the buf we complete was indirect?
>> > >
>> > > I've finally read this thread... I think we need to get more ser=
ious
>> > > with our stats gathering to diagnose these kind of performance i=
ssues.
>> > >
>> > > This is a start; it should tell us what is actually happening to=
 the
>> > > virtio ring(s) without significant performance impact...
>> > >
>> > > Subject: virtio: CONFIG_VIRTIO_STATS
>> > >
>> > > For performance problems we'd like to know exactly what the ring=
 looks
>> > > like. =A0This patch adds stats indexed by how-full-ring-is; we c=
ould extend
>> > > it to also record them by how-used-ring-is if we need.
>> > >
>> > > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>> >
>> > Not sure whether the intent is to merge this. If yes -
>> > would it make sense to use tracing for this instead?
>> > That's what kvm does.
>>
>> Intent wasn't; I've not used tracepoints before, but maybe we should
>> consider a longer-term monitoring solution?
>>
>> Patch welcome!
>>
>> Cheers,
>> Rusty.
>
> Sure, I'll look into this.

There are several virtio trace events already in QEMU today (see the
trace-events file):
virtqueue_fill(void *vq, const void *elem, unsigned int len, unsigned
int idx) "vq %p elem %p len %u idx %u"
virtqueue_flush(void *vq, unsigned int count) "vq %p count %u"
virtqueue_pop(void *vq, void *elem, unsigned int in_num, unsigned int
out_num) "vq %p elem %p in_num %u out_num %u"
virtio_queue_notify(void *vdev, int n, void *vq) "vdev %p n %d vq %p"
virtio_irq(void *vq) "vq %p"
virtio_notify(void *vdev, void *vq) "vdev %p vq %p"

These can be used by building QEMU with a suitable tracing backend
like SystemTap (see docs/tracing.txt).

Inside the guest I've used dynamic ftrace in the past, although static
tracepoints would be nice.

Stefan
