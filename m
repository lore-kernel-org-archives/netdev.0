From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 18 Aug 2010 10:25:05 +0200
Message-ID: <1282119905.2194.38.camel@edumazet-laptop>
References: <E1Olbcq-0006hZ-00.xeb-mail-ru@f272.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51859 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab0HRIZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 04:25:14 -0400
Received: by wyb32 with SMTP id 32so491859wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 01:25:12 -0700 (PDT)
In-Reply-To: <E1Olbcq-0006hZ-00.xeb-mail-ru@f272.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 09:55 +0400, Dmitry Kozlov a =C3=A9=
crit :
> This patch contains:
> 1. pptp driver
> 2. gre demultiplexer driver for demultiplexing gre packets with diffe=
rent gre version so
>    ip_gre and pptp may coexists
> 3. ip_gre modification
> 4. other stuff
>=20
> --

Hi Dmitry

I added some comments in your patch.

Plus, could you please run scripts/checkpatch.pl on it to correct some
style issues ?

>  MAINTAINERS              |   14 +
>  drivers/net/Kconfig      |   11 +
>  drivers/net/Makefile     |    1 +
>  drivers/net/pptp.c       |  747 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  include/linux/if_pppox.h |   20 ++-
>  include/net/gre.h        |   18 ++
>  net/ipv4/Kconfig         |    7 +
>  net/ipv4/Makefile        |    1 +
>  net/ipv4/gre.c           |  147 +++++++++
>  net/ipv4/ip_gre.c        |   10 +-
>  10 files changed, 970 insertions(+), 6 deletions(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 02f75fc..191d7c4 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
>  S:	Maintained
>  F:	drivers/serial/zs.*
> =20
> +GRE DEMULTIPLEXER DRIVER
> +M:	Dmitry Kozlov <D.Kozlov@protek-vrn.ru>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	net/ipv4/gre.c
> +F:	include/net/gre.h
> +
> +PPTP DRIVER
> +M:	Dmitry Kozlov <D.Kozlov@protek-vrn.ru>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/pptp.c
> +W:	http://sourceforge.net/projects/accel-pptp
> +
>  THE REST
>  M:	Linus Torvalds <torvalds@linux-foundation.org>
>  L:	linux-kernel@vger.kernel.org
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index ce2fcdd..2fa0516 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -3167,6 +3167,17 @@ config PPPOE
>  	  which contains instruction on how to use this driver (under=20
>  	  the heading "Kernel mode PPPoE").
> =20
> +config PPTP
> +	tristate "PPP over IPv4 (PPTP) (EXPERIMENTAL)"
> +	depends on EXPERIMENTAL && PPP && NET_IPGRE_DEMUX
> +	help
> +	  Support for PPP over IPv4.(Point-to-Point Tunneling Protocol)
> +
> +	  This driver requires pppd plugin to work in client mode or
> +	  modified pptpd (poptop) to work in server mode.
> +	  See http://accel-pptp.sourceforge.net/ for information how to
> +	  utilize this module.
> +
>  config PPPOATM
>  	tristate "PPP over ATM"
>  	depends on ATM && PPP
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 0a0512a..b33fef1 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -162,6 +162,7 @@ obj-$(CONFIG_PPP_BSDCOMP) +=3D bsd_comp.o
>  obj-$(CONFIG_PPP_MPPE) +=3D ppp_mppe.o
>  obj-$(CONFIG_PPPOE) +=3D pppox.o pppoe.o
>  obj-$(CONFIG_PPPOL2TP) +=3D pppox.o
> +obj-$(CONFIG_PPTP) +=3D pppox.o pptp.o
> =20
>  obj-$(CONFIG_SLIP) +=3D slip.o
>  obj-$(CONFIG_SLHC) +=3D slhc.o
> diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
> new file mode 100644
> index 0000000..5dad2f0
> --- /dev/null
> +++ b/drivers/net/pptp.c
> @@ -0,0 +1,747 @@
> +/*
> + *  Point-to-Point Tunneling Protocol for Linux
> + *
> + *	Authors: Dmitry Kozlov <xeb@mail.ru>
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + *
> + */
> +
> +#include <linux/string.h>
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/net.h>
> +#include <linux/skbuff.h>
> +#include <linux/init.h>
> +#include <linux/ppp_channel.h>
> +#include <linux/ppp_defs.h>
> +#include <linux/if_pppox.h>
> +#include <linux/if_ppp.h>
> +#include <linux/notifier.h>
> +#include <linux/file.h>
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <linux/netfilter.h>
> +#include <linux/netfilter_ipv4.h>
> +#include <linux/version.h>
> +//#include <linux/spinlock.h>

just delete this line

> +#include <linux/rcupdate.h>
> +#include <linux/semaphore.h>
> +
> +
> +#include <net/sock.h>
> +#include <net/protocol.h>
> +#include <net/ip.h>
> +#include <net/icmp.h>
> +#include <net/route.h>
> +#include <net/gre.h>
> +
> +#include <asm/uaccess.h>
> +
> +#define PPTP_DRIVER_VERSION "0.8.4"
> +
> +#define MAX_CALLID 65535
> +#define PPP_LCP_ECHOREQ 0x09
> +#define PPP_LCP_ECHOREP 0x0A
> +#define SC_RCV_BITS	(SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP=
)
> +
> +static unsigned long *callid_bitmap =3D NULL;

Check DECLARE_BITMAP(). I think it is ok in 2010 to add 8192 bytes of
bss in a module, considering typical kernels already use 10 Mbytes of
bss.


> +static struct pppox_sock **callid_sock=3DNULL;

No need for the "=3DNULL"

> +
> +
> +static DECLARE_MUTEX(chan_lock);

Hmm... semaphores are deprecated, please use a mutex

static DEFINE_MUTEX(chan_lock);

(check drivers/net/ppp_generic.c for example)

> +
> +static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb);
> +static int pptp_ppp_ioctl(struct ppp_channel *chan, unsigned int cmd=
,
> +			   unsigned long arg);
> +static int pptp_rcv_core(struct sock *sk,struct sk_buff *skb);
> +
> +static struct ppp_channel_ops pptp_chan_ops =3D {

static const ?

> +	.start_xmit =3D pptp_xmit,
> +	.ioctl      =3D pptp_ppp_ioctl,
> +};
> +
> +
> +#define MISSING_WINDOW 20
> +#define WRAPPED( curseq, lastseq) \
> +    ((((curseq) & 0xffffff00) =3D=3D 0) && \
> +     (((lastseq) & 0xffffff00 ) =3D=3D 0xffffff00))
> +
> +/* gre header structure: -------------------------------------------=
- */
> +
> +#define PPTP_GRE_PROTO  0x880B
> +#define PPTP_GRE_VER    0x1
> +
> +#define PPTP_GRE_FLAG_C	0x80
> +#define PPTP_GRE_FLAG_R	0x40
> +#define PPTP_GRE_FLAG_K	0x20
> +#define PPTP_GRE_FLAG_S	0x10
> +#define PPTP_GRE_FLAG_A	0x80
> +
> +#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
> +#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
> +#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
> +#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
> +#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
> +
> +#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
> +struct pptp_gre_header {
> +  u8  flags;       /* bitfield */
> +  u8  ver;			   /* should be PPTP_GRE_VER (enhanced GRE) */
> +  u16 protocol;		 /* should be PPTP_GRE_PROTO (ppp-encaps) */
> +  u16 payload_len; /* size of ppp payload, not inc. gre header */
> +  u16 call_id;		 /* peer's call_id for this session */
> +  u32 seq;		     /* sequence number.  Present if S=3D=3D1 */
> +  u32 ack;		     /* seq number of highest packet recieved by */
> +       				     /*  sender in this session */
> +};
> +
> +static struct pppox_sock * lookup_chan(__u16 call_id, __be32 s_addr)
> +{
> +	struct pppox_sock *sock;
> +	struct pptp_opt *opt;
> +=09
> +	rcu_read_lock();
> +	sock =3D rcu_dereference(callid_sock[call_id]);
> +	if (sock) {
> +		opt =3D &sock->proto.pptp;
> +		if (opt->dst_addr.sin_addr.s_addr !=3D s_addr) sock =3D NULL;
> +		else sock_hold(sk_pppox(sock));
> +	}
> +	rcu_read_unlock();
> +=09
> +	return sock;
> +}
> +
> +static int lookup_chan_dst(__u16 call_id, __be32 d_addr)
> +{
> +	struct pppox_sock *sock;
> +	struct pptp_opt *opt;
> +	int i;
> +=09
> +	down(&chan_lock);

 mutex_lock(&chan_lock) ?

> +	for(i =3D find_next_bit(callid_bitmap,MAX_CALLID,1); i < MAX_CALLID=
; i =3D find_next_bit(callid_bitmap,MAX_CALLID,i+1)) {
> +	    sock =3D callid_sock[i];
> +	    opt =3D &sock->proto.pptp;
> +	    if (opt->dst_addr.call_id =3D=3D call_id && opt->dst_addr.sin_a=
ddr.s_addr =3D=3D d_addr) break;
> +	}
> +	up(&chan_lock);

mutex_unlock()

> +=09
> +	return i < MAX_CALLID;
> +}
> +
> +static int add_chan(struct pppox_sock *sock)
> +{
> +	static int call_id =3D 0;
> +	int res =3D -1;
> +
> +	synchronize_rcu();
> +

Why is this synchronize_rcu() necessary ?

> +	down(&chan_lock);
> +	if (!sock->proto.pptp.src_addr.call_id)	{
> +	    call_id =3D find_next_zero_bit(callid_bitmap,MAX_CALLID,call_id=
+1);
> +	    if (call_id =3D=3D MAX_CALLID)
> +				call_id =3D find_next_zero_bit(callid_bitmap,MAX_CALLID,1);
> +	    sock->proto.pptp.src_addr.call_id =3D call_id;
> +	} else if (test_bit(sock->proto.pptp.src_addr.call_id,callid_bitmap=
))
> +			goto exit;
> +=09
> +	set_bit(sock->proto.pptp.src_addr.call_id,callid_bitmap);
> +	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id],s=
ock);
> +	res =3D 0;
> +
> +exit:=09
> +	up(&chan_lock);
> +=09
> +	return res;
> +}
> +
> +static void del_chan(struct pppox_sock *sock)
> +{
> +	synchronize_rcu();

Are you sure it is at the right place ?

> +=09
> +	down(&chan_lock);
> +	clear_bit(sock->proto.pptp.src_addr.call_id,callid_bitmap);
> +	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id],N=
ULL);
> +	up(&chan_lock);
> +}
> +
> +static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
> +{
> +	struct sock *sk =3D (struct sock *) chan->private;
> +	struct pppox_sock *po =3D pppox_sk(sk);
> +	struct pptp_opt *opt =3D &po->proto.pptp;
> +	struct pptp_gre_header *hdr;
> +	unsigned int header_len =3D sizeof(*hdr);
> +	int err =3D 0;
> +	int islcp;
> +	int len;
> +	unsigned char *data;
> +	__u32 seq_recv;
> +=09
> +=09
> +	struct rtable *rt;     			/* Route to the other host */
> +	struct net_device *tdev;			/* Device to other host */
> +	struct iphdr  *iph;			/* Our new IP header */
> +	int    max_headroom;			/* The extra header space needed */
> +
> +	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
> +	    goto tx_error;
> +
> +	{
> +		struct flowi fl =3D { .oif =3D 0,
> +				    .nl_u =3D { .ip4_u =3D
> +					      { .daddr =3D opt->dst_addr.sin_addr.s_addr,
> +						.saddr =3D opt->src_addr.sin_addr.s_addr,
> +						.tos =3D RT_TOS(0) } },
> +				    .proto =3D IPPROTO_GRE };
> +		if ((err=3Dip_route_output_key(&init_net,&rt, &fl))) {
> +			goto tx_error;
> +		}
> +	}
> +	tdev =3D rt->u.dst.dev;
> +
> +	max_headroom =3D LL_RESERVED_SPACE(tdev) + sizeof(*iph)+sizeof(*hdr=
)+2;
> +
> +	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shar=
ed(skb)) {
> +		struct sk_buff *new_skb =3D skb_realloc_headroom(skb, max_headroom=
);
> +		if (!new_skb) {
> +			ip_rt_put(rt);
> +			goto tx_error;
> +		}
> +		if (skb->sk)
> +		skb_set_owner_w(new_skb, skb->sk);
> +		kfree_skb(skb);
> +		skb =3D new_skb;
> +	}
> +
> +	data =3D skb->data;
> +	islcp =3D ((data[0] << 8) + data[1])=3D=3D PPP_LCP && 1 <=3D data[2=
] && data[2] <=3D 7;
> +
> +	/* compress protocol field */
> +	if ((opt->ppp_flags & SC_COMP_PROT) && data[0] =3D=3D 0 && !islcp)
> +		skb_pull(skb,1);
> +
> +	/*
> +		* Put in the address/control bytes if necessary
> +		*/

bad indent ?

Also, dont use 3 lines for small comments :

	/* Put in the address/control bytes if necessary */

> +	if ((opt->ppp_flags & SC_COMP_AC) =3D=3D 0 || islcp) {
> +		data =3D skb_push(skb,2);
> +		data[0] =3D PPP_ALLSTATIONS;
> +		data[1] =3D PPP_UI;
> +	}
> +=09
> +	len =3D skb->len;
> + =20
> +	seq_recv =3D opt->seq_recv;
> + =20
> +	if (opt->ack_sent =3D=3D seq_recv) header_len -=3D sizeof(hdr->ack)=
;
> +
> +	// Push down and install GRE header
> +	skb_push(skb,header_len);
> +	hdr =3D (struct pptp_gre_header *)(skb->data);
> +
> +	hdr->flags       =3D PPTP_GRE_FLAG_K;
> +	hdr->ver         =3D PPTP_GRE_VER;
> +	hdr->protocol    =3D htons(PPTP_GRE_PROTO);
> +	hdr->call_id     =3D htons(opt->dst_addr.call_id);
> +
> +	hdr->flags      |=3D PPTP_GRE_FLAG_S;
> +	hdr->seq         =3D htonl(++opt->seq_sent);
> +	if (opt->ack_sent !=3D seq_recv)	{
> +	/* send ack with this message */
> +		hdr->ver |=3D PPTP_GRE_FLAG_A;
> +		hdr->ack  =3D htonl(seq_recv);
> +		opt->ack_sent =3D seq_recv;
> +	}
> +	hdr->payload_len =3D htons(len);
> +
> +	/*
> +	 *	Push down and install the IP header.
> +	 */

	ditto , one line is ok
> +
> +	skb_reset_transport_header(skb);
> +	skb_push(skb, sizeof(*iph));
> +	skb_reset_network_header(skb);
> +	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> +	IPCB(skb)->flags &=3D ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFO=
RMED | IPSKB_REROUTED);
> +
> +	iph =3D	ip_hdr(skb);
> +	iph->version =3D	4;
> +	iph->ihl =3D	sizeof(struct iphdr) >> 2;
> +	if (ip_dont_fragment(sk, &rt->u.dst))
> +		iph->frag_off	=3D	htons(IP_DF);
> +	else
> +		iph->frag_off	=3D	0;
> +	iph->protocol	=3D	IPPROTO_GRE;
> +	iph->tos		  =3D	0;
> +	iph->daddr		=3D	rt->rt_dst;
> +	iph->saddr		=3D	rt->rt_src;
> +	iph->ttl      =3D dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
> +	iph->tot_len  =3D htons(skb->len);
> +
> +	skb_dst_drop(skb);
> +	skb_dst_set(skb,&rt->u.dst);
> +
> +	nf_reset(skb);
> +
> +	skb->ip_summed =3D CHECKSUM_NONE;
> +	ip_select_ident(iph, &rt->u.dst, NULL);
> +	ip_send_check(iph);
> +
> + 	ip_local_out(skb);
> +
> +tx_error:
> +	return 1;
> +}
> +
> +static int pptp_rcv_core(struct sock *sk,struct sk_buff *skb)
> +{
> +	struct pppox_sock *po =3D pppox_sk(sk);
> +	struct pptp_opt *opt =3D &po->proto.pptp;
> +	int headersize,payload_len,seq;
> +	__u8 *payload;
> +	struct pptp_gre_header *header;
> +
> +	if (!(sk->sk_state & PPPOX_CONNECTED)) {
> +		if (sock_queue_rcv_skb(sk, skb))
> +			goto drop;
> +		return NET_RX_SUCCESS;
> +	}
> +=09
> +	header =3D (struct pptp_gre_header *)(skb->data);
> +
> +	/* test if acknowledgement present */
> +	if (PPTP_GRE_IS_A(header->ver)) {
> +			__u32 ack =3D (PPTP_GRE_IS_S(header->flags))?
> +					header->ack:header->seq; /* ack in different place if S =3D 0 *=
/
> +
> +			ack =3D ntohl( ack);
> +
> +			if (ack > opt->ack_recv) opt->ack_recv =3D ack;
> +			/* also handle sequence number wrap-around  */
> +			if (WRAPPED(ack,opt->ack_recv)) opt->ack_recv =3D ack;
> +	}
> +
> +	/* test if payload present */
> +	if (!PPTP_GRE_IS_S(header->flags)) {
> +		goto drop;
> +	}
> +
> +	headersize  =3D sizeof(*header);
> +	payload_len =3D ntohs(header->payload_len);
> +	seq         =3D ntohl(header->seq);
> +
> +	/* no ack present? */
> +	if (!PPTP_GRE_IS_A(header->ver)) headersize -=3D sizeof(header->ack=
);
> +	/* check for incomplete packet (length smaller than expected) */
> +	if (skb->len - headersize < payload_len) {
> +		goto drop;
> +	}
> +
> +	payload =3D skb->data+headersize;
> +	/* check for expected sequence number */
> +	if ( seq < opt->seq_recv + 1 || WRAPPED(opt->seq_recv, seq) ) {
> +		if ( (payload[0] =3D=3D PPP_ALLSTATIONS) && (payload[1] =3D=3D PPP=
_UI) &&
> +		     (PPP_PROTOCOL(payload) =3D=3D PPP_LCP) &&
> +		     ((payload[4] =3D=3D PPP_LCP_ECHOREQ) || (payload[4] =3D=3D PP=
P_LCP_ECHOREP)) ) {
> +			goto allow_packet;
> +		}
> +	}else{
> +		opt->seq_recv =3D seq;
> +allow_packet:
> +		skb_pull(skb,headersize);
> +
> +		if (payload[0] =3D=3D PPP_ALLSTATIONS && payload[1] =3D=3D PPP_UI)=
 {
> +			/* chop off address/control */
> +			if (skb->len < 3)
> +				goto drop;
> +			skb_pull(skb,2);
> +		}
> +
> +		if ((*skb->data) & 1) {
> +			/* protocol is compressed */
> +			skb_push(skb, 1)[0] =3D 0;
> +		}
> +
> +		skb->ip_summed =3D CHECKSUM_NONE;
> +		skb_set_network_header(skb,skb->head-skb->data);
> +		ppp_input(&po->chan,skb);
> +
> +		return NET_RX_SUCCESS;
> +	}
> +drop:
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +
> +static int pptp_rcv(struct sk_buff *skb)
> +{
> +	struct pppox_sock *po;
> +	struct pptp_gre_header *header;
> +	struct iphdr *iph;
> +
> +	if (skb->pkt_type !=3D PACKET_HOST)
> +		goto drop;
> +
> +	if (!pskb_may_pull(skb, 12))
> +		goto drop;
> +
> +	iph =3D ip_hdr(skb);
> +
> +	header =3D (struct pptp_gre_header *)skb->data;
> +
> +	if (    /* version should be 1 */
> +					((header->ver & 0x7F) !=3D PPTP_GRE_VER) ||
> +					/* PPTP-GRE protocol for PPTP */
> +					(ntohs(header->protocol) !=3D PPTP_GRE_PROTO)||
> +					/* flag C should be clear   */
> +					PPTP_GRE_IS_C(header->flags) ||
> +					/* flag R should be clear   */
> +					PPTP_GRE_IS_R(header->flags) ||
> +					/* flag K should be set     */
> +					(!PPTP_GRE_IS_K(header->flags)) ||
> +					/* routing and recursion ctrl =3D 0  */
> +					((header->flags&0xF) !=3D 0)) {
> +			/* if invalid, discard this packet */
> +		goto drop;
> +	}
> +
> +
> +	if ((po=3Dlookup_chan(htons(header->call_id),iph->saddr))) {
> +		skb_dst_drop(skb);
> +		skb_dst_set(skb,NULL);
> +		nf_reset(skb);
> +		return sk_receive_skb(sk_pppox(po), skb, 0);
> +	}
> +drop:
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +
> +static int pptp_bind(struct socket *sock,struct sockaddr *uservaddr,=
int sockaddr_len)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct sockaddr_pppox *sp =3D (struct sockaddr_pppox *) uservaddr;
> +	struct pppox_sock *po =3D pppox_sk(sk);
> +	struct pptp_opt *opt =3D &po->proto.pptp;
> +	int error =3D 0;
> +
> +	lock_sock(sk);
> +
> +	opt->src_addr =3D sp->sa_addr.pptp;
> +	if (add_chan(po)) {
> +	  release_sock(sk);
> +		error =3D -EBUSY;
> +	}
> +
> +	release_sock(sk);
> +	return error;
> +}
> +
> +static int pptp_connect(struct socket *sock, struct sockaddr *userva=
ddr,
> +		  int sockaddr_len, int flags)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct sockaddr_pppox *sp =3D (struct sockaddr_pppox *) uservaddr;
> +	struct pppox_sock *po =3D pppox_sk(sk);
> +	struct pptp_opt *opt =3D &po->proto.pptp;
> +	struct rtable *rt;     			/* Route to the other host */
> +	int error=3D0;
> +
> +	if (sp->sa_protocol !=3D PX_PROTO_PPTP)
> +		return -EINVAL;
> +=09
> +	if (lookup_chan_dst(sp->sa_addr.pptp.call_id,sp->sa_addr.pptp.sin_a=
ddr.s_addr))
> +		return -EALREADY;
> +
> +	lock_sock(sk);
> +	/* Check for already bound sockets */
> +	if (sk->sk_state & PPPOX_CONNECTED) {
> +		error =3D -EBUSY;
> +		goto end;
> +	}
> +
> +	/* Check for already disconnected sockets, on attempts to disconnec=
t */
> +	if (sk->sk_state & PPPOX_DEAD) {
> +		error =3D -EALREADY;
> +		goto end;
> +	}
> +
> +	if (!opt->src_addr.sin_addr.s_addr || !sp->sa_addr.pptp.sin_addr.s_=
addr) {
> +		error =3D -EINVAL;
> +		goto end;
> +	}
> +
> +	po->chan.private =3D sk;
> +	po->chan.ops =3D &pptp_chan_ops;
> +
> +	{
> +		struct flowi fl =3D {
> +				    .nl_u =3D { .ip4_u =3D
> +					      { .daddr =3D opt->dst_addr.sin_addr.s_addr,
> +						.saddr =3D opt->src_addr.sin_addr.s_addr,
> +						.tos =3D RT_CONN_FLAGS(sk) } },
> +				    .proto =3D IPPROTO_GRE };
> +		security_sk_classify_flow(sk, &fl);
> +		if (ip_route_output_key(&init_net, &rt, &fl)) {
> +			error =3D -EHOSTUNREACH;
> +			goto end;
> +		}
> +		sk_setup_caps(sk, &rt->u.dst);
> +	}
> +	po->chan.mtu =3D dst_mtu(&rt->u.dst);
> +	if (!po->chan.mtu) po->chan.mtu =3D PPP_MTU;
> +	ip_rt_put(rt);
> +	po->chan.mtu -=3D PPTP_HEADER_OVERHEAD;
> +
> +	po->chan.hdrlen =3D 2 + sizeof(struct pptp_gre_header);
> +	error =3D ppp_register_channel(&po->chan);
> +	if (error) {
> +		printk(KERN_ERR "PPTP: failed to register PPP channel (%d)\n",erro=
r);
> +		goto end;
> +	}
> +
> +	opt->dst_addr =3D sp->sa_addr.pptp;
> +	sk->sk_state =3D PPPOX_CONNECTED;
> +
> + end:
> +	release_sock(sk);
> +	return error;
> +}
> +
> +static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
> +		  int *usockaddr_len, int peer)
> +{
> +	int len =3D sizeof(struct sockaddr_pppox);
> +	struct sockaddr_pppox sp;
> +
> +	sp.sa_family	  =3D AF_PPPOX;
> +	sp.sa_protocol  =3D PX_PROTO_PPTP;
> +	sp.sa_addr.pptp =3D pppox_sk(sock->sk)->proto.pptp.src_addr;
> +
> +	memcpy(uaddr, &sp, len);
> +
> +	*usockaddr_len =3D len;
> +
> +	return 0;
> +}
> +
> +static int pptp_release(struct socket *sock)
> +{
> +	struct sock *sk =3D sock->sk;
> +	struct pppox_sock *po;
> +	struct pptp_opt *opt;
> +	int error =3D 0;
> +
> +	if (!sk)
> +	    return 0;
> +
> +	lock_sock(sk);
> +
> +	if (sock_flag(sk, SOCK_DEAD)) {
> +	    release_sock(sk);
> +	    return -EBADF;
> +	}
> +	=09
> +	po =3D pppox_sk(sk);
> +	opt =3D &po->proto.pptp;
> +	del_chan(po);
> +
> +	pppox_unbind_sock(sk);
> +	sk->sk_state =3D PPPOX_DEAD;
> +
> +	sock_orphan(sk);
> +	sock->sk =3D NULL;
> +
> +	release_sock(sk);
> +	sock_put(sk);
> +
> +	return error;
> +}
> +
> +
> +static struct proto pptp_sk_proto =3D {

static struct proto pptp_sk_proto __read_mostly =3D {

> +	.name	    =3D "PPTP",
> +	.owner	  =3D THIS_MODULE,
> +	.obj_size =3D sizeof(struct pppox_sock),
> +};
> +
> +static struct proto_ops pptp_ops =3D {

static const

> +    .family		  =3D AF_PPPOX,
> +    .owner		  =3D THIS_MODULE,
> +    .release    =3D pptp_release,
> +    .bind	   	  =3D pptp_bind,
> +    .connect	  =3D pptp_connect,
> +    .socketpair	=3D sock_no_socketpair,
> +    .accept		  =3D sock_no_accept,
> +    .getname		=3D pptp_getname,
> +    .poll	    	=3D sock_no_poll,
> +    .listen		  =3D sock_no_listen,
> +    .shutdown		=3D sock_no_shutdown,
> +    .setsockopt	=3D sock_no_setsockopt,
> +    .getsockopt	=3D sock_no_getsockopt,
> +    .sendmsg		=3D sock_no_sendmsg,
> +    .recvmsg		=3D sock_no_recvmsg,
> +    .mmap		    =3D sock_no_mmap,
> +    .ioctl		  =3D pppox_ioctl,
> +};
> +
> +static void pptp_sock_destruct(struct sock *sk)
> +{
> +    if (!(sk->sk_state & PPPOX_DEAD)) {
> +	    del_chan(pppox_sk(sk));
> +	    pppox_unbind_sock(sk);
> +    }
> +    skb_queue_purge(&sk->sk_receive_queue);
> +}
> +static int pptp_create(struct net *net, struct socket *sock)
> +{
> +	int error =3D -ENOMEM;
> +	struct sock *sk;
> +	struct pppox_sock *po;
> +	struct pptp_opt *opt;
> +
> +	sk =3D sk_alloc(net,PF_PPPOX, GFP_KERNEL, &pptp_sk_proto);
> +	if (!sk)
> +		goto out;
> +
> +	sock_init_data(sock, sk);
> +
> +	sock->state =3D SS_UNCONNECTED;
> +	sock->ops   =3D &pptp_ops;
> +
> +	sk->sk_backlog_rcv =3D pptp_rcv_core;
> +	sk->sk_state	     =3D PPPOX_NONE;
> +	sk->sk_type	       =3D SOCK_STREAM;
> +	sk->sk_family	     =3D PF_PPPOX;
> +	sk->sk_protocol	   =3D PX_PROTO_PPTP;
> +	sk->sk_destruct	   =3D pptp_sock_destruct;
> +
> +	po =3D pppox_sk(sk);
> +	opt =3D &po->proto.pptp;
> +
> +	opt->seq_sent =3D 0; opt->seq_recv =3D 0;
> +	opt->ack_recv =3D 0; opt->ack_sent =3D 0;
> +
> +	error =3D 0;
> +out:
> +	return error;
> +}
> +
> +static int pptp_ppp_ioctl(struct ppp_channel *chan, unsigned int cmd=
,
> +			   unsigned long arg)
> +{
> +	struct sock *sk =3D (struct sock *) chan->private;
> +	struct pppox_sock *po =3D pppox_sk(sk);
> +	struct pptp_opt *opt =3D &po->proto.pptp;
> +	void __user *argp =3D (void __user *)arg;
> +	int __user *p =3D argp;
> +	int err, val;
> +
> +	err =3D -EFAULT;
> +	switch (cmd) {
> +	case PPPIOCGFLAGS:
> +		val =3D opt->ppp_flags;
> +		if (put_user(val, p))
> +			break;
> +		err =3D 0;
> +		break;
> +	case PPPIOCSFLAGS:
> +		if (get_user(val, p))
> +			break;
> +		opt->ppp_flags =3D val & ~SC_RCV_BITS;
> +		err =3D 0;
> +		break;
> +	default:
> +		err =3D -ENOTTY;
> +	}
> +
> +	return err;
> +}
> +
> +
> +static struct pppox_proto pppox_pptp_proto =3D {
> +    .create	=3D pptp_create,
> +    .owner	=3D THIS_MODULE,
> +};
> +
> +
> +static struct gre_protocol gre_pptp_protocol =3D {
> +	.handler	=3D pptp_rcv,
> +	//.err_handler	=3D	pptp_err,

If you really want to use a comment, please use /* */ delimitors

> +};
> +
> +static int __init pptp_init_module(void)
> +{
> +	int err=3D0;
> +	printk(KERN_INFO "PPTP driver version " PPTP_DRIVER_VERSION "\n");
> +
> +	if (gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP) < 0) {
> +		printk(KERN_INFO "PPTP: can't add protocol\n");
> +		goto out;
> +	}
> +
> +	err =3D proto_register(&pptp_sk_proto, 0);
> +	if (err) {
> +		printk(KERN_INFO "PPTP: can't register sk_proto\n");
> +		goto out_inet_del_protocol;
> +	}
> +
> + 	err =3D register_pppox_proto(PX_PROTO_PPTP, &pppox_pptp_proto);
> +	if (err) {
> +		printk(KERN_INFO "PPTP: can't register pppox_proto\n");
> +		goto out_unregister_sk_proto;
> +	}
> +=09
> +=09
> +	//assuming PAGESIZE is 4096 bytes

Dont assume things like that ;)

> +	callid_bitmap =3D (unsigned long*)__get_free_pages(GFP_KERNEL,1);
> +	memset(callid_bitmap,0,PAGE_SIZE << 1);

and prefer a kzalloc(65536/BITS_PER_BYTE, GFP_KERNEL) call here

> +
> +#if (BITS_PER_LONG =3D=3D 32)
> +	callid_sock =3D (struct pppox_sock **)__get_free_pages(GFP_KERNEL,6=
);
> +	memset(callid_sock,0,PAGE_SIZE << 6);

ditto here, please use vmalloc(65536 * sizeof(void *)) to avoid
BITS_PER_LONG games

> +#elif (BITS_PER_LONG =3D=3D 64)
> +	callid_sock =3D (struct pppox_sock **)__get_free_pages(GFP_KERNEL,7=
);
> +	memset(callid_sock,0,PAGE_SIZE << 7);
> +#else
> +#error unknown size of LONG
> +#endif
> +
> +out:
> +	return err;
> +out_unregister_sk_proto:
> +	proto_unregister(&pptp_sk_proto);
> +out_inet_del_protocol:
> +	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
> +	return err;
> +}
> +
> +static void __exit pptp_exit_module(void)
> +{
> +	unregister_pppox_proto(PX_PROTO_PPTP);
> +	proto_unregister(&pptp_sk_proto);
> +	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
> +	if (callid_bitmap) free_pages((unsigned long)callid_bitmap,1);
> +	if (callid_sock)
> +#if (BITS_PER_LONG =3D=3D 32)
> +		free_pages((unsigned long)callid_sock,6);
> +#elif (BITS_PER_LONG =3D=3D 64)
> +		free_pages((unsigned long)callid_sock,7);
> +#endif
> +}
> +
> +module_init(pptp_init_module);
> +module_exit(pptp_exit_module);
> +
> +MODULE_DESCRIPTION("Point-to-Point Tunneling Protocol");
> +MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
> +MODULE_LICENSE("GPL");
> +
> diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
> index a6577af..455ff56 100644
> --- a/include/linux/if_pppox.h
> +++ b/include/linux/if_pppox.h
> @@ -47,17 +47,27 @@ struct pppoe_addr{
>  };=20
>  =20
>  /*******************************************************************=
*****=20
> + * PPTP addressing definition=20
> + */=20
> +struct pptp_addr{

struct pptp_addr {

> +       __u16           call_id;
> +       struct in_addr  sin_addr;
> +};
> +
> +/*******************************************************************=
*****=20
>   * Protocols supported by AF_PPPOX=20
>   */=20
>  #define PX_PROTO_OE    0 /* Currently just PPPoE */
>  #define PX_PROTO_OL2TP 1 /* Now L2TP also */
> -#define PX_MAX_PROTO   2
> +#define PX_PROTO_PPTP  2
> +#define PX_MAX_PROTO   3
> =20
>  struct sockaddr_pppox {=20
>         sa_family_t     sa_family;            /* address family, AF_P=
PPOX */=20
>         unsigned int    sa_protocol;          /* protocol identifier =
*/=20
>         union{=20
>                 struct pppoe_addr       pppoe;=20
> +	       			 struct pptp_addr        pptp;
>         }sa_addr;=20
>  }__attribute__ ((packed));=20
> =20
> @@ -150,6 +160,13 @@ struct pppoe_opt {
>  					     relayed to (PPPoE relaying) */
>  };
> =20
> +struct pptp_opt {
> +	struct pptp_addr	src_addr;
> +	struct pptp_addr	dst_addr;
> +	__u32 ack_sent, ack_recv;
> +	__u32 seq_sent, seq_recv;
> +	int ppp_flags;
> +};
>  #include <net/sock.h>
> =20
>  struct pppox_sock {
> @@ -159,6 +176,7 @@ struct pppox_sock {
>  	struct pppox_sock	*next;	  /* for hash table */
>  	union {
>  		struct pppoe_opt pppoe;
> +		struct pptp_opt pptp;
>  	} proto;
>  	__be16			num;
>  };
> diff --git a/include/net/gre.h b/include/net/gre.h
> new file mode 100644
> index 0000000..31a0f76
> --- /dev/null
> +++ b/include/net/gre.h
> @@ -0,0 +1,18 @@
> +#ifndef __LINUX_GRE_H
> +#define __LINUX_GRE_H
> +
> +#include <linux/skbuff.h>
> +
> +#define GREPROTO_CISCO		0
> +#define GREPROTO_PPTP		1
> +#define GREPROTO_MAX		2
> +
> +struct gre_protocol {
> +	int		(*handler)(struct sk_buff *skb);
> +	void	(*err_handler)(struct sk_buff *skb, u32 info);
> +};
> +
> +int gre_add_protocol(const struct gre_protocol *proto, u8 version);
> +int gre_del_protocol(const struct gre_protocol *proto, u8 version);
> +
> +#endif
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 7c3a7d1..7458bda 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -215,8 +215,15 @@ config NET_IPIP
>  	  be inserted in and removed from the running kernel whenever you
>  	  want). Most people won't need this and can say N.
> =20
> +config NET_IPGRE_DEMUX
> +	tristate "IP: GRE demultiplexer"
> +	help
> +	 This is helper module to demultiplex GRE packets on GRE version fi=
eld criteria.
> +	 Required by ip_gre and pptp modules.
> +
>  config NET_IPGRE
>  	tristate "IP: GRE tunnels over IP"
> +	depends on NET_IPGRE_DEMUX
>  	help
>  	  Tunneling means encapsulating data of one protocol type within
>  	  another protocol and sending it over a channel that understands t=
he
> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 80ff87c..4978d22 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -20,6 +20,7 @@ obj-$(CONFIG_PROC_FS) +=3D proc.o
>  obj-$(CONFIG_IP_MULTIPLE_TABLES) +=3D fib_rules.o
>  obj-$(CONFIG_IP_MROUTE) +=3D ipmr.o
>  obj-$(CONFIG_NET_IPIP) +=3D ipip.o
> +obj-$(CONFIG_NET_IPGRE_DEMUX) +=3D gre.o
>  obj-$(CONFIG_NET_IPGRE) +=3D ip_gre.o
>  obj-$(CONFIG_SYN_COOKIES) +=3D syncookies.o
>  obj-$(CONFIG_INET_AH) +=3D ah4.o
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> new file mode 100644
> index 0000000..f54a0fc
> --- /dev/null
> +++ b/net/ipv4/gre.c
> @@ -0,0 +1,147 @@
> +/*
> + *	GRE over IPv4 demultiplexer driver
> + *
> + *	Authors: Dmitry Kozlov (xeb@mail.ru)
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	as published by the Free Software Foundation; either version
> + *	2 of the License, or (at your option) any later version.
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/kmod.h>
> +#include <linux/skbuff.h>
> +#include <linux/in.h>
> +#include <linux/netdevice.h>
> +#include <linux/version.h>
> +#include <linux/spinlock.h>
> +#include <net/protocol.h>
> +#include <net/gre.h>
> +
> +
> +const struct gre_protocol *gre_proto[GREPROTO_MAX] ____cacheline_ali=
gned_in_smp;

No need for ____cacheline_aligned_in_smp here.

Better would be to user __read_mostly

> +static DEFINE_RWLOCK(gre_proto_lock);

This could use RCU and a spinlock instead

> +
> +int gre_add_protocol(const struct gre_protocol *proto, u8 version)
> +{
> +	int ret;
> +
> +	if (version >=3D GREPROTO_MAX)
> +		return -1;
> +=09
> +	write_lock_bh(&gre_proto_lock);
> +	if (gre_proto[version]) {
> +		ret =3D -1;
> +	} else {
> +		gre_proto[version]=3Dproto;
> +		ret =3D 0;
> +	}
> +	write_unlock_bh(&gre_proto_lock);
> +
> +	return ret;
> +}
> +int gre_del_protocol(const struct gre_protocol *proto, u8 version)
> +{
> +	int ret;
> +
> +	if (version >=3D GREPROTO_MAX)
> +		return -1;
> +
> +	write_lock_bh(&gre_proto_lock);
> +	if (gre_proto[version] =3D=3D proto) {
> +		gre_proto[version] =3D NULL;
> +		ret =3D 0;
> +	} else {
> +		ret =3D -1;
> +	}
> +	write_unlock_bh(&gre_proto_lock);
> +
> +	return ret;
> +}
> +static int gre_rcv(struct sk_buff *skb)
> +{
> +	u8 ver;
> +	int ret;
> +
> +	if (!pskb_may_pull(skb, 12))
> +		goto drop_nolock;
> +
> +	ver =3D skb->data[1]&0x7f;
> +	if (ver >=3D GREPROTO_MAX)
> +		goto drop_nolock;
> +=09
> +	read_lock(&gre_proto_lock);
> +	if (!gre_proto[ver] || !gre_proto[ver]->handler)
> +		goto drop;
> +	ret =3D gre_proto[ver]->handler(skb);
> +	read_unlock(&gre_proto_lock);

rcu locking, no need to touch gre_proto_lock

> +	return ret;
> +
> +drop:
> +	read_unlock(&gre_proto_lock);
> +drop_nolock:
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
> +static void gre_err(struct sk_buff *skb, u32 info)
> +{
> +	u8 ver;
> +
> +	printk("err\n");

not very usefull string

> +
> +	if (!pskb_may_pull(skb, 12))
> +		goto drop_nolock;
> +
> +	ver=3Dskb->data[1];
> +	if (ver>=3DGREPROTO_MAX)
> +		goto drop_nolock;
> +	=09
> +	read_lock(&gre_proto_lock);
> +	if (!gre_proto[ver] || !gre_proto[ver]->err_handler)
> +		goto drop;
> +	gre_proto[ver]->err_handler(skb,info);
> +	read_unlock(&gre_proto_lock);
> +	return;
> +
> +drop:
> +	read_unlock(&gre_proto_lock);
> +drop_nolock:
> +	kfree_skb(skb);
> +}
> +
> +
> +static struct net_protocol net_gre_protocol =3D {

const ?

> +	.handler	=3D gre_rcv,
> +	.err_handler	=3D	gre_err,
> +	.netns_ok=3D1,

missing spaces around =3D

> +};
> +
> +static int __init gre_init(void)
> +{
> +	printk(KERN_INFO "GRE over IPv4 demultiplexor driver");
> +=09
> +	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
> +		printk(KERN_INFO "gre: can't add protocol\n");
> +		return -EAGAIN;
> +	}
> +
> +	return 0;
> +}
> +
> +static void __exit gre_exit(void)
> +{
> +	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
> +}
> +
> +module_init(gre_init);
> +module_exit(gre_exit);
> +
> +MODULE_DESCRIPTION("GRE over IPv4 demultiplexer driver");
> +MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
> +MODULE_LICENSE("GPL");
> +EXPORT_SYMBOL_GPL(gre_add_protocol);
> +EXPORT_SYMBOL_GPL(gre_del_protocol);
> +
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 32618e1..f0391b3 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -44,6 +44,7 @@
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  #include <net/rtnetlink.h>
> +#include <net/gre.h>
> =20
>  #ifdef CONFIG_IPV6
>  #include <net/ipv6.h>
> @@ -1276,10 +1277,9 @@ static void ipgre_fb_tunnel_init(struct net_de=
vice *dev)
>  }
> =20
>=20
> -static const struct net_protocol ipgre_protocol =3D {
> +static const struct gre_protocol ipgre_protocol =3D {
>  	.handler	=3D	ipgre_rcv,
>  	.err_handler	=3D	ipgre_err,
> -	.netns_ok	=3D	1,
>  };
> =20
>  static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list=
_head *head)
> @@ -1661,7 +1661,7 @@ static int __init ipgre_init(void)
>  	if (err < 0)
>  		return err;
> =20
> -	err =3D inet_add_protocol(&ipgre_protocol, IPPROTO_GRE);
> +	err =3D gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
>  	if (err < 0) {
>  		printk(KERN_INFO "ipgre init: can't add protocol\n");
>  		goto add_proto_failed;
> @@ -1681,7 +1681,7 @@ out:
>  tap_ops_failed:
>  	rtnl_link_unregister(&ipgre_link_ops);
>  rtnl_link_failed:
> -	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
> +	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
>  add_proto_failed:
>  	unregister_pernet_device(&ipgre_net_ops);
>  	goto out;
> @@ -1691,7 +1691,7 @@ static void __exit ipgre_fini(void)
>  {
>  	rtnl_link_unregister(&ipgre_tap_ops);
>  	rtnl_link_unregister(&ipgre_link_ops);
> -	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
> +	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
>  		printk(KERN_INFO "ipgre close: can't remove protocol\n");
>  	unregister_pernet_device(&ipgre_net_ops);
>  }


