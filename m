From: Steven Luong <sluong99@gmail.com>
Subject: Re: repost: af_packet vs virtio (was packed ring layout
 proposal v2)
Date: Tue, 1 Aug 2017 20:54:27 -0700
Message-ID: <CAJR92jnV1VgBs567QNjO1fHKDgMX=1j1aJJ2gK-TqMB5E1=fvw@mail.gmail.com>
References: <20170414051304-mutt-send-email-mst@kernel.org> <20170414054318-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="94eb2c1990687c77800555bd3832"
Cc: john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, virtio-dev@lists.oasis-open.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtio-dev-return-2431-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <20170414054318-mutt-send-email-mst@kernel.org>
List-Id: netdev.vger.kernel.org

--94eb2c1990687c77800555bd3832
Content-Type: text/plain; charset="UTF-8"

Michael,

I  have a question on s/g

On Thu, Apr 13, 2017 at 7:50 PM, Michael S. Tsirkin <mst@redhat.com> wrote:

> On Fri, Apr 14, 2017 at 05:42:58AM +0300, Michael S. Tsirkin wrote:
> > Hi all, I wanted to raise the question of similarities between virtio
> > and new zero copy af_packet interfaces.
> >
> > First I would like to mention that virtio device development isn't spec
> > limited - spec is there to help interoperability and add peace of mind
> > for people worried about IPR.
> >
> > So I tend to accept patches without requiring people write it up in the
> > spec as work on spec proceeds at its own pace - all I ask is that the
> > virtio mailing list is copied, this requires contributor to subscribe
> > and in the process contributor promises that it's ok for us to add this
> > to spec in the future.
> >
> > There shouldn't thus be a fundamental problem preventing use of virtio
> > format or reusing some of the code for af_packet, but it still might or
> > might not make sense - it was designed for CPU to CPU communication so
> > it seems to make sense though.  So I would like that discussion to
> > happen even if we decide against.
> >
> > And even if people decide against, the problem space is very similar.
> You
> > can look up packed ring layout proposal v2 - should I repost here?  Our
> > prototyping shows significant performance improvements from using it as
> > compared to head/tail layout.
> >
> > To start this discission I'm going to reply to this email reposting a
> > copy of the simplified virtio layout that might be appropriate for
> > af_packet as well.
>
> Here's the repost (slightly cut down) sorry about the duplicates.
>
> The idea is to have a r/w descriptor in a ring structure,
> replacing the used and available ring, index and descriptor
> buffer.
>
> * Descriptor ring:
>
> Guest adds descriptors with unique index values and DESC_HW set in flags.
> Host overwrites used descriptors with correct len, index, and DESC_HW
> clear.  Flags are always set/cleared last.
>
> #define DESC_HW 0x0080
>
> struct desc {
>         __le64 addr;
>         __le32 len;
>         __le16 index;
>         __le16 flags;
> };
>
> When DESC_HW is set, descriptor belongs to device. When it is clear,
> it belongs to the driver.
>
> We can use 1 bit to set direction
> /* This marks a buffer as write-only (otherwise read-only). */
> #define VRING_DESC_F_WRITE      2
>
> * Scatter/gather support
>
> We can use 1 bit to chain s/g entries in a request, same as virtio 1.0:
>
> /* This marks a buffer as continuing via the next field. */
>

This comment here is confusing to me. In 1.0, virtq_desc has the next
field. When the flag VRING_DESC_F_NEXT is set, the next entry to continue
is specified in the next field.

Here in 1.1, struct desc does not have the next field, only addr, len,
index, and flags. So when VRING_DESC_F_NEXT is set in struct desc's flags
field, where is the next entry to continue the current descriptor, the
entry immediately following the current entry? ie, if the current entry is
at index 10 in the descriptor table and its flags is set for
VRING_DESC_F_NEXT, is the entry continuing the current entry in index 11?

Steven


> #define VRING_DESC_F_NEXT       1
>
> Unlike virtio 1.0, all descriptors must have distinct ID values.
>
> Also unlike virtio 1.0, use of this flag will be an optional feature
> (e.g. VIRTIO_F_DESC_NEXT) so both devices and drivers can opt out of it.
>
> * Indirect buffers
>
> Can be marked like in virtio 1.0:
>
> /* This means the buffer contains a table of buffer descriptors. */
> #define VRING_DESC_F_INDIRECT   4
>
> Unlike virtio 1.0, this is a table, not a list:
> struct indirect_descriptor_table {
>         /* The actual descriptors (16 bytes each) */
>         struct virtq_desc desc[len / 16];
> };
>
> The first descriptor is located at start of the indirect descriptor
> table, additional indirect descriptors come immediately afterwards.
> DESC_F_WRITE is the only valid flag for descriptors in the indirect
> table. Others should be set to 0 and are ignored.  id is also set to 0
> and should be ignored.
>
> virtio 1.0 seems to allow a s/g entry followed by
> an indirect descriptor. This does not seem useful,
> so we do not allow that anymore.
>
> This support would be an optional feature, same as in virtio 1.0
>
> * Batching descriptors:
>
> virtio 1.0 allows passing a batch of descriptors in both directions, by
> incrementing the used/avail index by values > 1.  We can support this by
> chaining a list of descriptors through a bit the flags field.
> To allow use together with s/g, a different bit will be used.
>
> #define VRING_DESC_F_BATCH_NEXT 0x0010
>
> Batching works for both driver and device descriptors.
>
>
>
> * Processing descriptors in and out of order
>
> Device processing all descriptors in order can simply flip
> the DESC_HW bit as it is done with descriptors.
>
> Device can write descriptors out in order as they are used, overwriting
> descriptors that are there.
>
> Device must not use a descriptor until DESC_HW is set.
> It is only required to look at the first descriptor
> submitted.
>
> Driver must not overwrite a descriptor until DESC_HW is clear.
> It is only required to look at the first descriptor
> submitted.
>
> * Device specific descriptor flags
> We have a lot of unused space in the descriptor.  This can be put to
> good use by reserving some flag bits for device use.
> For example, network device can set a bit to request
> that header in the descriptor is suppressed
> (in case it's all 0s anyway). This reduces cache utilization.
>
> Note: this feature can be supported in virtio 1.0 as well,
> as we have unused bits in both descriptor and used ring there.
>
> * Descriptor length in device descriptors
>
> virtio 1.0 places strict requirements on descriptor length. For example
> it must be 0 in used ring of TX VQ of a network device since nothing is
> written.  In practice guests do not seem to use this, so we can simplify
> devices a bit by removing this requirement - if length is unused it
> should be ignored by driver.
>
> Some devices use identically-sized buffers in all descriptors.
> Ignoring length for driver descriptors there could be an option too.
>
> * Writing at an offset
>
> Some devices might want to write into some descriptors
> at an offset, the offset would be in config space,
> and a descriptor flag could indicate this:
>
> #define VRING_DESC_F_OFFSET 0x0020
>
> How exactly to use the offset would be device specific,
> for example it can be used to align beginning of packet
> in the 1st buffer for mergeable buffers to cache line boundary
> while also aligning rest of buffers.
>
> * Non power-of-2 ring sizes
>
> As the ring simply wraps around, there's no reason to
> require ring size to be power of two.
> It can be made a separate feature though.
>
>
> * Interrupt/event suppression
>
> virtio 1.0 has two mechanisms for suppression but only
> one can be used at a time. we pack them together
> in a structure - one for interrupts, one for notifications:
>
> struct event {
>         __le16 idx;
>         __le16 flags;
> }
>
> Both fields would be optional, with a feature bit:
> VIRTIO_F_EVENT_IDX
> VIRTIO_F_EVENT_FLAGS
>
> * Flags can be used like in virtio 1.0, by storing a special
> value there:
>
> #define VRING_F_EVENT_ENABLE  0x0
>
> #define VRING_F_EVENT_DISABLE 0x1
>
> * Event index would be in the range 0 to 2 * Queue Size
> (to detect wrap arounds) and wrap to 0 after that.
>
> The assumption is that each side maintains an internal
> descriptor counter 0 to 2 * Queue Size that wraps to 0.
> In that case, interrupt triggers when counter reaches
> the given value.
>
> * If both features are negotiated, a special flags value
> can be used to switch to event idx:
>
> #define VRING_F_EVENT_IDX     0x2
>
>
> * Prototype
>
> A partial prototype can be found under
> tools/virtio/ringtest/ring.c
>
> Test run:
> [mst@tuck ringtest]$ time ./ring
> real    0m0.399s
> user    0m0.791s
> sys     0m0.000s
> [mst@tuck ringtest]$ time ./virtio_ring_0_9
> real    0m0.503s
> user    0m0.999s
> sys     0m0.000s
>
> This seems to match the theoretical analysis showing marking
> descriptors themselves as invalid works better than a head/tail design.
> Future changes and enhancements can be tested against this prototype.
>
> A dpdk based implementation can be found here:
>
> git://dpdk.org/next/dpdk-next-virtio    for-testing
>
>
>
> --
> MST
>
>
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: virtio-dev-unsubscribe@lists.oasis-open.org
> For additional commands, e-mail: virtio-dev-help@lists.oasis-open.org
>
>

--94eb2c1990687c77800555bd3832
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Michael,<br><br></div>I=C2=A0 have a question on s/g<=
br><div><div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On T=
hu, Apr 13, 2017 at 7:50 PM, Michael S. Tsirkin <span dir=3D"ltr">&lt;<a hr=
ef=3D"mailto:mst@redhat.com" target=3D"_blank">mst@redhat.com</a>&gt;</span=
> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">On Fri, Apr 14, 2017 at 05:42:58=
AM +0300, Michael S. Tsirkin wrote:<br>
&gt; Hi all, I wanted to raise the question of similarities between virtio<=
br>
&gt; and new zero copy af_packet interfaces.<br>
&gt;<br>
&gt; First I would like to mention that virtio device development isn&#39;t=
 spec<br>
&gt; limited - spec is there to help interoperability and add peace of mind=
<br>
&gt; for people worried about IPR.<br>
&gt;<br>
&gt; So I tend to accept patches without requiring people write it up in th=
e<br>
&gt; spec as work on spec proceeds at its own pace - all I ask is that the<=
br>
&gt; virtio mailing list is copied, this requires contributor to subscribe<=
br>
&gt; and in the process contributor promises that it&#39;s ok for us to add=
 this<br>
&gt; to spec in the future.<br>
&gt;<br>
&gt; There shouldn&#39;t thus be a fundamental problem preventing use of vi=
rtio<br>
&gt; format or reusing some of the code for af_packet, but it still might o=
r<br>
&gt; might not make sense - it was designed for CPU to CPU communication so=
<br>
&gt; it seems to make sense though.=C2=A0 So I would like that discussion t=
o<br>
&gt; happen even if we decide against.<br>
&gt;<br>
&gt; And even if people decide against, the problem space is very similar.=
=C2=A0 You<br>
&gt; can look up packed ring layout proposal v2 - should I repost here?=C2=
=A0 Our<br>
&gt; prototyping shows significant performance improvements from using it a=
s<br>
&gt; compared to head/tail layout.<br>
&gt;<br>
&gt; To start this discission I&#39;m going to reply to this email repostin=
g a<br>
&gt; copy of the simplified virtio layout that might be appropriate for<br>
&gt; af_packet as well.<br>
<br>
Here&#39;s the repost (slightly cut down) sorry about the duplicates.<br>
<br>
The idea is to have a r/w descriptor in a ring structure,<br>
replacing the used and available ring, index and descriptor<br>
buffer.<br>
<br>
* Descriptor ring:<br>
<br>
Guest adds descriptors with unique index values and DESC_HW set in flags.<b=
r>
Host overwrites used descriptors with correct len, index, and DESC_HW<br>
clear.=C2=A0 Flags are always set/cleared last.<br>
<br>
#define DESC_HW 0x0080<br>
<br>
struct desc {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le64 addr;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le32 len;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le16 index;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le16 flags;<br>
};<br>
<br>
When DESC_HW is set, descriptor belongs to device. When it is clear,<br>
it belongs to the driver.<br>
<br>
We can use 1 bit to set direction<br>
/* This marks a buffer as write-only (otherwise read-only). */<br>
#define VRING_DESC_F_WRITE=C2=A0 =C2=A0 =C2=A0 2<br>
<br>
* Scatter/gather support<br>
<br>
We can use 1 bit to chain s/g entries in a request, same as virtio 1.0:<br>
<br>
/* This marks a buffer as continuing via the next field. */<br></blockquote=
><div><br></div><div>This comment here is confusing to me. In 1.0, virtq_de=
sc has the next field. When the flag VRING_DESC_F_NEXT is set, the next ent=
ry to continue is specified in the next field.<br><br>Here in 1.1, struct d=
esc does not have the next field, only addr, len, index, and flags. So when=
 VRING_DESC_F_NEXT is set in struct desc&#39;s flags field, where is the ne=
xt entry to continue the current descriptor, the entry immediately followin=
g the current entry? ie, if the current entry is at index 10 in the descrip=
tor table and its flags is set for VRING_DESC_F_NEXT, is the entry continui=
ng the current entry in index 11?<br><br></div><div>Steven<br></div><div>=
=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">
#define VRING_DESC_F_NEXT=C2=A0 =C2=A0 =C2=A0 =C2=A01<br>
<br>
Unlike virtio 1.0, all descriptors must have distinct ID values.<br>
<br>
Also unlike virtio 1.0, use of this flag will be an optional feature<br>
(e.g. VIRTIO_F_DESC_NEXT) so both devices and drivers can opt out of it.<br=
>
<br>
* Indirect buffers<br>
<br>
Can be marked like in virtio 1.0:<br>
<br>
/* This means the buffer contains a table of buffer descriptors. */<br>
#define VRING_DESC_F_INDIRECT=C2=A0 =C2=A04<br>
<br>
Unlike virtio 1.0, this is a table, not a list:<br>
struct indirect_descriptor_table {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* The actual descriptors (16 bytes each) */<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct virtq_desc desc[len / 16];<br>
};<br>
<br>
The first descriptor is located at start of the indirect descriptor<br>
table, additional indirect descriptors come immediately afterwards.<br>
DESC_F_WRITE is the only valid flag for descriptors in the indirect<br>
table. Others should be set to 0 and are ignored.=C2=A0 id is also set to 0=
<br>
and should be ignored.<br>
<br>
virtio 1.0 seems to allow a s/g entry followed by<br>
an indirect descriptor. This does not seem useful,<br>
so we do not allow that anymore.<br>
<br>
This support would be an optional feature, same as in virtio 1.0<br>
<br>
* Batching descriptors:<br>
<br>
virtio 1.0 allows passing a batch of descriptors in both directions, by<br>
incrementing the used/avail index by values &gt; 1.=C2=A0 We can support th=
is by<br>
chaining a list of descriptors through a bit the flags field.<br>
To allow use together with s/g, a different bit will be used.<br>
<br>
#define VRING_DESC_F_BATCH_NEXT 0x0010<br>
<br>
Batching works for both driver and device descriptors.<br>
<br>
<br>
<br>
* Processing descriptors in and out of order<br>
<br>
Device processing all descriptors in order can simply flip<br>
the DESC_HW bit as it is done with descriptors.<br>
<br>
Device can write descriptors out in order as they are used, overwriting<br>
descriptors that are there.<br>
<br>
Device must not use a descriptor until DESC_HW is set.<br>
It is only required to look at the first descriptor<br>
submitted.<br>
<br>
Driver must not overwrite a descriptor until DESC_HW is clear.<br>
It is only required to look at the first descriptor<br>
submitted.<br>
<br>
* Device specific descriptor flags<br>
We have a lot of unused space in the descriptor.=C2=A0 This can be put to<b=
r>
good use by reserving some flag bits for device use.<br>
For example, network device can set a bit to request<br>
that header in the descriptor is suppressed<br>
(in case it&#39;s all 0s anyway). This reduces cache utilization.<br>
<br>
Note: this feature can be supported in virtio 1.0 as well,<br>
as we have unused bits in both descriptor and used ring there.<br>
<br>
* Descriptor length in device descriptors<br>
<br>
virtio 1.0 places strict requirements on descriptor length. For example<br>
it must be 0 in used ring of TX VQ of a network device since nothing is<br>
written.=C2=A0 In practice guests do not seem to use this, so we can simpli=
fy<br>
devices a bit by removing this requirement - if length is unused it<br>
should be ignored by driver.<br>
<br>
Some devices use identically-sized buffers in all descriptors.<br>
Ignoring length for driver descriptors there could be an option too.<br>
<br>
* Writing at an offset<br>
<br>
Some devices might want to write into some descriptors<br>
at an offset, the offset would be in config space,<br>
and a descriptor flag could indicate this:<br>
<br>
#define VRING_DESC_F_OFFSET 0x0020<br>
<br>
How exactly to use the offset would be device specific,<br>
for example it can be used to align beginning of packet<br>
in the 1st buffer for mergeable buffers to cache line boundary<br>
while also aligning rest of buffers.<br>
<br>
* Non power-of-2 ring sizes<br>
<br>
As the ring simply wraps around, there&#39;s no reason to<br>
require ring size to be power of two.<br>
It can be made a separate feature though.<br>
<br>
<br>
* Interrupt/event suppression<br>
<br>
virtio 1.0 has two mechanisms for suppression but only<br>
one can be used at a time. we pack them together<br>
in a structure - one for interrupts, one for notifications:<br>
<br>
struct event {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le16 idx;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __le16 flags;<br>
}<br>
<br>
Both fields would be optional, with a feature bit:<br>
VIRTIO_F_EVENT_IDX<br>
VIRTIO_F_EVENT_FLAGS<br>
<br>
* Flags can be used like in virtio 1.0, by storing a special<br>
value there:<br>
<br>
#define VRING_F_EVENT_ENABLE=C2=A0 0x0<br>
<br>
#define VRING_F_EVENT_DISABLE 0x1<br>
<br>
* Event index would be in the range 0 to 2 * Queue Size<br>
(to detect wrap arounds) and wrap to 0 after that.<br>
<br>
The assumption is that each side maintains an internal<br>
descriptor counter 0 to 2 * Queue Size that wraps to 0.<br>
In that case, interrupt triggers when counter reaches<br>
the given value.<br>
<br>
* If both features are negotiated, a special flags value<br>
can be used to switch to event idx:<br>
<br>
#define VRING_F_EVENT_IDX=C2=A0 =C2=A0 =C2=A00x2<br>
<br>
<br>
* Prototype<br>
<br>
A partial prototype can be found under<br>
tools/virtio/ringtest/ring.c<br>
<br>
Test run:<br>
[mst@tuck ringtest]$ time ./ring<br>
real=C2=A0 =C2=A0 0m0.399s<br>
user=C2=A0 =C2=A0 0m0.791s<br>
sys=C2=A0 =C2=A0 =C2=A00m0.000s<br>
[mst@tuck ringtest]$ time ./virtio_ring_0_9<br>
real=C2=A0 =C2=A0 0m0.503s<br>
user=C2=A0 =C2=A0 0m0.999s<br>
sys=C2=A0 =C2=A0 =C2=A00m0.000s<br>
<br>
This seems to match the theoretical analysis showing marking<br>
descriptors themselves as invalid works better than a head/tail design.<br>
Future changes and enhancements can be tested against this prototype.<br>
<br>
A dpdk based implementation can be found here:<br>
<br>
git://<a href=3D"http://dpdk.org/next/dpdk-next-virtio" rel=3D"noreferrer" =
target=3D"_blank">dpdk.org/next/dpdk-next-<wbr>virtio</a>=C2=A0 =C2=A0 for-=
testing<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
<br>
<br>
--<br>
MST<br>
<br>
<br>
------------------------------<wbr>------------------------------<wbr>-----=
----<br>
To unsubscribe, e-mail: <a href=3D"mailto:virtio-dev-unsubscribe@lists.oasi=
s-open.org">virtio-dev-unsubscribe@lists.<wbr>oasis-open.org</a><br>
For additional commands, e-mail: <a href=3D"mailto:virtio-dev-help@lists.oa=
sis-open.org">virtio-dev-help@lists.oasis-<wbr>open.org</a><br>
<br>
</font></span></blockquote></div><br></div></div></div></div>

--94eb2c1990687c77800555bd3832--
