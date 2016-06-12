From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 6/8] Add TSN event-tracing
Date: Sun, 12 Jun 2016 23:25:10 +0200
Message-ID: <20160612212510.GD32724@icarus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <1465686096-22156-7-git-send-email-henrik@austad.us>
 <20160612125803.27f401cc@gandalf.local.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yudcn1FV7Hsu/q59"
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	henrik@austad.us, Henrik Austad <haustad@cisco.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160612125803.27f401cc@gandalf.local.home>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yudcn1FV7Hsu/q59
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 12, 2016 at 12:58:03PM -0400, Steven Rostedt wrote:
> On Sun, 12 Jun 2016 01:01:34 +0200
> Henrik Austad <henrik@austad.us> wrote:
>=20
> > From: Henrik Austad <haustad@cisco.com>
> >=20
> > This needs refactoring and should be updated to use TRACE_CLASS, but for
> > now it provides a fair debug-window into TSN.
> >=20
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Steven Rostedt <rostedt@goodmis.org> (maintainer:TRACING)
> > Cc: Ingo Molnar <mingo@redhat.com> (maintainer:TRACING)
> > Signed-off-by: Henrik Austad <haustad@cisco.com>
> > ---
> >  include/trace/events/tsn.h | 349 +++++++++++++++++++++++++++++++++++++=
++++++++
> >  1 file changed, 349 insertions(+)
> >  create mode 100644 include/trace/events/tsn.h
> >=20
> > diff --git a/include/trace/events/tsn.h b/include/trace/events/tsn.h
> > new file mode 100644
> > index 0000000..ac1f31b
> > --- /dev/null
> > +++ b/include/trace/events/tsn.h
> > @@ -0,0 +1,349 @@
> > +#undef TRACE_SYSTEM
> > +#define TRACE_SYSTEM tsn
> > +
> > +#if !defined(_TRACE_TSN_H) || defined(TRACE_HEADER_MULTI_READ)
> > +#define _TRACE_TSN_H
> > +
> > +#include <linux/tsn.h>
> > +#include <linux/tracepoint.h>
> > +
> > +#include <linux/if_ether.h>
> > +#include <linux/if_vlan.h>
> > +/* #include <linux/skbuff.h> */
> > +
> > +/* FIXME: update to TRACE_CLASS to reduce overhead */
>=20
> I'm curious to why I didn't do this now. A class would make less
> duplication of typing too ;-)

Yeah, I found this in a really great article written by some tracing-dude,=
=20
I hear he talks really, really fast!

https://lwn.net/Articles/381064/

> > +TRACE_EVENT(tsn_buffer_write,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		size_t bytes),
> > +
> > +	TP_ARGS(link, bytes),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(size_t, size)
> > +		__field(size_t, bsize)
> > +		__field(size_t, size_left)
> > +		__field(void *, buffer)
> > +		__field(void *, head)
> > +		__field(void *, tail)
> > +		__field(void *, end)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->size =3D bytes;
> > +		__entry->bsize =3D link->used_buffer_size;
> > +		__entry->size_left =3D (link->head - link->tail) % link->used_buffer=
_size;
>=20
> Move this logic into the print statement, since you save head and tail.

Ok, any particular reason?

> > +		__entry->buffer =3D link->buffer;
> > +		__entry->head =3D link->head;
> > +		__entry->tail =3D link->tail;
> > +		__entry->end =3D link->end;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu, copy=3D%zd, buffer: %zd, avail=3D%zd, [b=
uffer=3D%p, head=3D%p, tail=3D%p, end=3D%p]",
> > +		__entry->stream_id, __entry->size, __entry->bsize, __entry->size_lef=
t,
>=20
>  __entry->stream_id, __entry->size, __entry->bsize,
>  (__entry->head - __entry->tail) % __entry->bsize,
>=20

Ok, so is this about saving space by dropping one intermediate value, or is=
=20
it some other point I'm missing here?

> > +		__entry->buffer,    __entry->head, __entry->tail,  __entry->end)
> > +
> > +	);
> > +
> > +TRACE_EVENT(tsn_buffer_write_net,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		size_t bytes),
> > +
> > +	TP_ARGS(link, bytes),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(size_t, size)
> > +		__field(size_t, bsize)
> > +		__field(size_t, size_left)
> > +		__field(void *, buffer)
> > +		__field(void *, head)
> > +		__field(void *, tail)
> > +		__field(void *, end)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->size =3D bytes;
> > +		__entry->bsize =3D link->used_buffer_size;
> > +		__entry->size_left =3D (link->head - link->tail) % link->used_buffer=
_size;
> > +		__entry->buffer =3D link->buffer;
> > +		__entry->head =3D link->head;
> > +		__entry->tail =3D link->tail;
> > +		__entry->end =3D link->end;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu, copy=3D%zd, buffer: %zd, avail=3D%zd, [b=
uffer=3D%p, head=3D%p, tail=3D%p, end=3D%p]",
> > +		__entry->stream_id, __entry->size, __entry->bsize, __entry->size_lef=
t,
> > +		__entry->buffer,    __entry->head, __entry->tail,  __entry->end)
> > +
> > +	);
> > +
> > +
> > +TRACE_EVENT(tsn_buffer_read,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		size_t bytes),
> > +
> > +	TP_ARGS(link, bytes),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(size_t, size)
> > +		__field(size_t, bsize)
> > +		__field(size_t, size_left)
> > +		__field(void *, buffer)
> > +		__field(void *, head)
> > +		__field(void *, tail)
> > +		__field(void *, end)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->size =3D bytes;
> > +		__entry->bsize =3D link->used_buffer_size;
> > +		__entry->size_left =3D (link->head - link->tail) % link->used_buffer=
_size;
> > +		__entry->buffer =3D link->buffer;
> > +		__entry->head =3D link->head;
> > +		__entry->tail =3D link->tail;
> > +		__entry->end =3D link->end;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu, copy=3D%zd, buffer: %zd, avail=3D%zd, [b=
uffer=3D%p, head=3D%p, tail=3D%p, end=3D%p]",
> > +		__entry->stream_id, __entry->size, __entry->bsize, __entry->size_lef=
t,
> > +		__entry->buffer,    __entry->head, __entry->tail,  __entry->end)
> > +
> > +	);
> > +
> > +TRACE_EVENT(tsn_refill,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		size_t reported_avail),
> > +
> > +	TP_ARGS(link, reported_avail),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(size_t, bsize)
> > +		__field(size_t, size_left)
> > +		__field(size_t, reported_left)
> > +		__field(size_t, low_water)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->bsize =3D link->used_buffer_size;
> > +		__entry->size_left =3D (link->head - link->tail) % link->used_buffer=
_size;
>=20
> As you don't save head and tail here, this logic needs to remain.
>=20
> > +		__entry->reported_left =3D reported_avail;
> > +		__entry->low_water =3D link->low_water_mark;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu, buffer=3D%zd, avail=3D%zd, reported=3D%z=
d, low=3D%zd",
> > +		__entry->stream_id, __entry->bsize, __entry->size_left, __entry->rep=
orted_left, __entry->low_water)
> > +	);
> > +
> > +TRACE_EVENT(tsn_send_batch,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		int num_send,
> > +		u64 ts_base_ns,
> > +		u64 ts_delta_ns),
> > +
> > +	TP_ARGS(link, num_send, ts_base_ns, ts_delta_ns),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(int, seqnr)
> > +		__field(int, num_send)
> > +		__field(u64, ts_base_ns)
> > +		__field(u64, ts_delta_ns)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id   =3D link->stream_id;
> > +		__entry->seqnr	     =3D (int)link->last_seqnr;
> > +		__entry->ts_base_ns  =3D ts_base_ns;
> > +		__entry->ts_delta_ns =3D ts_delta_ns;
> > +		__entry->num_send    =3D num_send;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu, seqnr=3D%d, num_send=3D%d, ts_base_ns=3D=
%llu, ts_delta_ns=3D%llu",
> > +		__entry->stream_id, __entry->seqnr, __entry->num_send, __entry->ts_b=
ase_ns, __entry->ts_delta_ns)
> > +	);
> > +
> > +
> > +TRACE_EVENT(tsn_rx_handler,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		const struct ethhdr *ethhdr,
> > +		u64 sid),
> > +
> > +	TP_ARGS(link, ethhdr, sid),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(char *, name)
> > +		__field(u16, proto)
> > +		__field(u64, sid)
> > +		__field(u64, link_sid)
> > +		),
> > +	TP_fast_assign(
> > +		__entry->name  =3D link->nic->name;
> > +		__entry->proto =3D ethhdr->h_proto;
> > +		__entry->sid   =3D sid;
> > +		__entry->link_sid =3D link->stream_id;
> > +		),
> > +
> > +	TP_printk("name=3D%s, proto: 0x%04x, stream_id=3D%llu, link->sid=3D%l=
lu",
> > +		__entry->name, ntohs(__entry->proto), __entry->sid, __entry->link_si=
d)
> > +	);
> > +
> > +TRACE_EVENT(tsn_du,
> > +
> > +	TP_PROTO(struct tsn_link *link,
> > +		size_t bytes),
> > +
> > +	TP_ARGS(link, bytes),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, link_sid)
> > +		__field(size_t, bytes)
> > +		),
> > +	TP_fast_assign(
> > +		__entry->link_sid =3D link->stream_id;
> > +		__entry->bytes =3D bytes;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu,bytes=3D%zu",
> > +		__entry->link_sid, __entry->bytes)
> > +);
> > +
> > +TRACE_EVENT(tsn_set_buffer,
> > +
> > +	TP_PROTO(struct tsn_link *link, size_t bufsize),
> > +
> > +	TP_ARGS(link, bufsize),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64,  stream_id)
> > +		__field(size_t, size)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->size =3D bufsize;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu,buffer_size=3D%zu",
> > +		__entry->stream_id, __entry->size)
> > +
> > +	);
> > +
> > +TRACE_EVENT(tsn_free_buffer,
> > +
> > +	TP_PROTO(struct tsn_link *link),
> > +
> > +	TP_ARGS(link),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64,  stream_id)
> > +		__field(size_t,	 bufsize)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->bufsize =3D link->buffer_size;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu,size:%zd",
> > +		__entry->stream_id, __entry->bufsize)
> > +
> > +	);
> > +
> > +TRACE_EVENT(tsn_buffer_drain,
> > +
> > +	TP_PROTO(struct tsn_link *link, size_t used),
> > +
> > +	TP_ARGS(link, used),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(size_t, used)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->used =3D used;
> > +	),
> > +
> > +	TP_printk("stream_id=3D%llu,used=3D%zu",
> > +		__entry->stream_id, __entry->used)
> > +
> > +);
> > +/* TODO: too long, need cleanup.
> > + */
> > +TRACE_EVENT(tsn_pre_tx,
> > +
> > +	TP_PROTO(struct tsn_link *link, struct sk_buff *skb, size_t bytes),
> > +
> > +	TP_ARGS(link, skb, bytes),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(u64, stream_id)
> > +		__field(u32, vlan_tag)
> > +		__field(size_t, bytes)
> > +		__field(size_t, data_len)
> > +		__field(unsigned int, headlen)
> > +		__field(u16, protocol)
> > +		__field(u16, prot_native)
> > +		__field(int, tx_idx)
> > +		__field(u16, mac_len)
> > +		__field(u16, hdr_len)
> > +		__field(u16, vlan_tci)
> > +		__field(u16, mac_header)
> > +		__field(unsigned int, tail)
> > +		__field(unsigned int, end)
> > +		__field(unsigned int, truesize)
> > +		),
> > +
> > +	TP_fast_assign(
> > +		__entry->stream_id =3D link->stream_id;
> > +		__entry->vlan_tag =3D (skb_vlan_tag_present(skb) ? skb_vlan_tag_get(=
skb) : 0);
> > +		__entry->bytes =3D bytes;
> > +		__entry->data_len =3D skb->data_len;
> > +		__entry->headlen =3D skb_headlen(skb);
> > +		__entry->protocol =3D ntohs(vlan_get_protocol(skb));
>=20
> Maybe it would be better to do the ntohs() in the TP_printk() as well.
>=20
> > +		__entry->prot_native =3D ntohs(skb->protocol);
>=20
> here too.
>=20
> > +		__entry->tx_idx =3D skb_get_queue_mapping(skb);
> > +
> > +		__entry->mac_len =3D skb->mac_len;
> > +		__entry->hdr_len =3D skb->hdr_len;
> > +		__entry->vlan_tci =3D skb->vlan_tci;
> > +		__entry->mac_header =3D skb->mac_header;
> > +		__entry->tail =3D (unsigned int)skb->tail;
> > +		__entry->end  =3D (unsigned int)skb->end;
> > +		__entry->truesize =3D skb->truesize;
> > +		),
> > +
> > +	TP_printk("stream_id=3D%llu,vlan_tag=3D0x%04x,data_size=3D%zd,data_le=
n=3D%zd,headlen=3D%u,proto=3D0x%04x (0x%04x),tx_idx=3D%d,mac_len=3D%u,hdr_l=
en=3D%u,vlan_tci=3D0x%02x,mac_header=3D0x%02x,tail=3D%u,end=3D%u,truesize=
=3D%u",
> > +		__entry->stream_id,
> > +		__entry->vlan_tag,
> > +		__entry->bytes,
> > +		__entry->data_len,
> > +		__entry->headlen,
> > +		__entry->protocol,
> > +		__entry->prot_native, __entry->tx_idx,
> > +		__entry->mac_len,
> > +		__entry->hdr_len,
> > +		__entry->vlan_tci,
> > +		__entry->mac_header,
>=20
> Is this an ether mac header? If so we support %M. But as it's defined
> as only u16, it doesn't seem like it can be.

Actually, looking at the output, I'm not quite sure what it is that I=20
wanted to grab with that, the skb->mac_header should give an offset into=20
the header-area of skb, so it should be a constant offset from skb->head=20
(that is an actual pointer).

I *think* I wanted to make sure I updated things correctly so that the=20
offset didn't suddenly change, but the fact that I'm no longer sure=20
indicates that I should just drop that one. That whole printout is too long=
=20
anyway..

Thanks for pointing a finger at this!


I'm still a bit stymied as to why logic should be in TP_printk() and not=20
TP_fast_assign(). Not that I really have any preferences either way, just=
=20
curious.



--=20
Henrik Austad

--yudcn1FV7Hsu/q59
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldd0zYACgkQ6k5VT6v45lmZZgCgqcu6l96xsPUxksK27dYNkcdC
VekAnAnVqN1kBWIqF1XeKpCR9ToS1dH1
=Wx6T
-----END PGP SIGNATURE-----

--yudcn1FV7Hsu/q59--
