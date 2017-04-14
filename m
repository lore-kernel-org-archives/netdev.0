From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: repost: af_packet vs virtio (was packed ring layout proposal v2)
Date: Fri, 14 Apr 2017 05:50:41 +0300
Message-ID: <20170414054318-mutt-send-email-mst@kernel.org>
References: <20170414051304-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	virtio-dev@lists.oasis-open.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <virtio-dev-return-2086-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
In-Reply-To: <20170414051304-mutt-send-email-mst@kernel.org>
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2017 at 05:42:58AM +0300, Michael S. Tsirkin wrote:
> Hi all, I wanted to raise the question of similarities between virtio
> and new zero copy af_packet interfaces.
> 
> First I would like to mention that virtio device development isn't spec
> limited - spec is there to help interoperability and add peace of mind
> for people worried about IPR.
> 
> So I tend to accept patches without requiring people write it up in the
> spec as work on spec proceeds at its own pace - all I ask is that the
> virtio mailing list is copied, this requires contributor to subscribe
> and in the process contributor promises that it's ok for us to add this
> to spec in the future.
> 
> There shouldn't thus be a fundamental problem preventing use of virtio
> format or reusing some of the code for af_packet, but it still might or
> might not make sense - it was designed for CPU to CPU communication so
> it seems to make sense though.  So I would like that discussion to
> happen even if we decide against.
> 
> And even if people decide against, the problem space is very similar.  You
> can look up packed ring layout proposal v2 - should I repost here?  Our
> prototyping shows significant performance improvements from using it as
> compared to head/tail layout.
> 
> To start this discission I'm going to reply to this email reposting a
> copy of the simplified virtio layout that might be appropriate for
> af_packet as well.

Here's the repost (slightly cut down) sorry about the duplicates.

The idea is to have a r/w descriptor in a ring structure,
replacing the used and available ring, index and descriptor
buffer.

* Descriptor ring:

Guest adds descriptors with unique index values and DESC_HW set in flags.
Host overwrites used descriptors with correct len, index, and DESC_HW
clear.  Flags are always set/cleared last.

#define DESC_HW 0x0080

struct desc {
        __le64 addr;
        __le32 len;
        __le16 index;
        __le16 flags;
};

When DESC_HW is set, descriptor belongs to device. When it is clear,
it belongs to the driver.

We can use 1 bit to set direction
/* This marks a buffer as write-only (otherwise read-only). */
#define VRING_DESC_F_WRITE      2

* Scatter/gather support

We can use 1 bit to chain s/g entries in a request, same as virtio 1.0:

/* This marks a buffer as continuing via the next field. */
#define VRING_DESC_F_NEXT       1

Unlike virtio 1.0, all descriptors must have distinct ID values.

Also unlike virtio 1.0, use of this flag will be an optional feature
(e.g. VIRTIO_F_DESC_NEXT) so both devices and drivers can opt out of it.

* Indirect buffers

Can be marked like in virtio 1.0:

/* This means the buffer contains a table of buffer descriptors. */
#define VRING_DESC_F_INDIRECT   4

Unlike virtio 1.0, this is a table, not a list:
struct indirect_descriptor_table {
        /* The actual descriptors (16 bytes each) */
        struct virtq_desc desc[len / 16];
};

The first descriptor is located at start of the indirect descriptor
table, additional indirect descriptors come immediately afterwards.
DESC_F_WRITE is the only valid flag for descriptors in the indirect
table. Others should be set to 0 and are ignored.  id is also set to 0
and should be ignored.

virtio 1.0 seems to allow a s/g entry followed by
an indirect descriptor. This does not seem useful,
so we do not allow that anymore.

This support would be an optional feature, same as in virtio 1.0

* Batching descriptors:

virtio 1.0 allows passing a batch of descriptors in both directions, by
incrementing the used/avail index by values > 1.  We can support this by
chaining a list of descriptors through a bit the flags field.
To allow use together with s/g, a different bit will be used.

#define VRING_DESC_F_BATCH_NEXT 0x0010

Batching works for both driver and device descriptors.



* Processing descriptors in and out of order

Device processing all descriptors in order can simply flip
the DESC_HW bit as it is done with descriptors.

Device can write descriptors out in order as they are used, overwriting
descriptors that are there.

Device must not use a descriptor until DESC_HW is set.
It is only required to look at the first descriptor
submitted.

Driver must not overwrite a descriptor until DESC_HW is clear.
It is only required to look at the first descriptor
submitted.

* Device specific descriptor flags
We have a lot of unused space in the descriptor.  This can be put to
good use by reserving some flag bits for device use.
For example, network device can set a bit to request
that header in the descriptor is suppressed
(in case it's all 0s anyway). This reduces cache utilization.

Note: this feature can be supported in virtio 1.0 as well,
as we have unused bits in both descriptor and used ring there.

* Descriptor length in device descriptors

virtio 1.0 places strict requirements on descriptor length. For example
it must be 0 in used ring of TX VQ of a network device since nothing is
written.  In practice guests do not seem to use this, so we can simplify
devices a bit by removing this requirement - if length is unused it
should be ignored by driver.

Some devices use identically-sized buffers in all descriptors.
Ignoring length for driver descriptors there could be an option too.

* Writing at an offset

Some devices might want to write into some descriptors
at an offset, the offset would be in config space,
and a descriptor flag could indicate this:

#define VRING_DESC_F_OFFSET 0x0020

How exactly to use the offset would be device specific,
for example it can be used to align beginning of packet
in the 1st buffer for mergeable buffers to cache line boundary
while also aligning rest of buffers.

* Non power-of-2 ring sizes

As the ring simply wraps around, there's no reason to
require ring size to be power of two.
It can be made a separate feature though.


* Interrupt/event suppression

virtio 1.0 has two mechanisms for suppression but only
one can be used at a time. we pack them together
in a structure - one for interrupts, one for notifications:

struct event {
	__le16 idx;
	__le16 flags;
}

Both fields would be optional, with a feature bit:
VIRTIO_F_EVENT_IDX
VIRTIO_F_EVENT_FLAGS

* Flags can be used like in virtio 1.0, by storing a special
value there:

#define VRING_F_EVENT_ENABLE  0x0

#define VRING_F_EVENT_DISABLE 0x1

* Event index would be in the range 0 to 2 * Queue Size
(to detect wrap arounds) and wrap to 0 after that.

The assumption is that each side maintains an internal
descriptor counter 0 to 2 * Queue Size that wraps to 0.
In that case, interrupt triggers when counter reaches
the given value.

* If both features are negotiated, a special flags value
can be used to switch to event idx:

#define VRING_F_EVENT_IDX     0x2


* Prototype

A partial prototype can be found under
tools/virtio/ringtest/ring.c

Test run:
[mst@tuck ringtest]$ time ./ring 
real    0m0.399s
user    0m0.791s
sys     0m0.000s
[mst@tuck ringtest]$ time ./virtio_ring_0_9
real    0m0.503s
user    0m0.999s
sys     0m0.000s

This seems to match the theoretical analysis showing marking
descriptors themselves as invalid works better than a head/tail design.
Future changes and enhancements can be tested against this prototype.

A dpdk based implementation can be found here:

git://dpdk.org/next/dpdk-next-virtio    for-testing



-- 
MST
