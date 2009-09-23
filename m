From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] af_packet: add interframe drop cmsg
Date: Wed, 23 Sep 2009 19:17:11 -0400
Message-ID: <20090923231711.GA13719@localhost.localdomain>
References: <20090923203202.GA13805@hmsreliant.think-freely.org> <4ABA8B30.9060904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32866 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbZIWXRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 19:17:14 -0400
Content-Disposition: inline
In-Reply-To: <4ABA8B30.9060904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2009 at 10:55:12PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> >     Add Ancilliary data to better represent loss information
> >    =20
> >     I've had a few requests recently to provide more detail regardi=
ng frame loss
> >     during an AF_PACKET packet capture session.  Specifically the r=
equestors want to
> >     see where in a packet sequence frames were lost, i.e. they want=
 to see that 40
> >     frames were lost between frames 302 and 303 in a packet capture=
 file.  In order
> >     to do this we need:
> >    =20
> >     1) The kernel to export this data to user space
> >     2) The applications to make use of it
> >    =20
> >     This patch addresses item (1).  It does this by doing the follo=
wing:
> >    =20
> >     A) attaching ancilliary data to any skb enqueued to a socket re=
cieve queue for
> >     which frames were lost between it and the previously enqueued f=
rame.  Note I use
> >     a ring buffer with a correlator value (the skb pointer) to do t=
his.  This was
> >     done because the skb->cb array is exhausted already for AF_PACK=
ET
>=20
> Hmm, how mmap() users can find this information ? I thought recent li=
bpcap were
> using mmap(), in order to reduce losses :)
>=20
Yeah, in some/most cases it does, but to be honest, I think any solutio=
n for
determining frame loss with sequence encoding is going to diverge betwe=
en a
descriptor based solution (i.e. recvmsg), and an mmap solution is going=
 to be
divergent.  About the only solution I could see that could be common wo=
uld be
the use of some sort of marker frame getting inserted into the receive =
queue,
and I'm pretty certain thats going to be a hard sell.

> >    =20
> >     B) For any frame dequeued that has ancilliary data in the ring =
buffer (as
> >     determined by the correlator value), we add a cmsg structure to=
 the msghdr that
> >     gets copied to user space, this cmsg structure is of cmsg_level=
 AF_PACKET, and
> >     cmsg_type PACKET_GAPDATA.  It contains a u32 value which counts=
 the number of
> >     frames lost between the reception of the frame being currently =
recevied and the
> >     frame most recently preceding it.  Note this creates a situatio=
n in which if we
> >     have packet loss followed immediately by a socket close operati=
on we might miss
> >     some gap information.  This situation is covered by the use of =
the
> >     PACKET_AUXINFO socket option, which provides total loss stats (=
from which the
> >     final gap can be computed).
> >    =20
> >     I've tested this patch myself, and it works well.
>=20
> Okay :)
>=20
Thanks for the vote of confidence :).  I augmented the patch to randoml=
y drop
frames, then wrote a applicatoin to loop on an AF_PACKET frame receive,=
 and
compared a printk showing the in-kernel drop rates with what the user s=
pace app
recorded.

> >    =20
> >     Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
> >=20
> >  include/linux/if_packet.h |    2 +
> >  net/packet/af_packet.c    |   90 +++++++++++++++++++++++++++++++++=
++++++++++++-
> >  2 files changed, 91 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
> > index dea7d6b..e5d200f 100644
> > --- a/include/linux/if_packet.h
> > +++ b/include/linux/if_packet.h
> > @@ -48,11 +48,13 @@ struct sockaddr_ll
> >  #define PACKET_RESERVE			12
> >  #define PACKET_TX_RING			13
> >  #define PACKET_LOSS			14
> > +#define PACKET_GAPDATA			15
> > =20
> >  struct tpacket_stats
> >  {
> >  	unsigned int	tp_packets;
> >  	unsigned int	tp_drops;
> > +	unsigned int    tp_gap;
> >  };
> > =20
> >  struct tpacket_auxdata
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index d3d52c6..b74a91c 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -179,6 +179,11 @@ static int tpacket_snd(struct packet_sock *po,=
 struct msghdr *msg);
> > =20
> >  static void packet_flush_mclist(struct sock *sk);
> > =20
> > +struct packet_gap_record {
> > +		struct sk_buff *skb;
> > +		__u32 gap;
> > +};
> > +
> >  struct packet_sock {
> >  	/* struct sock has to be the first member of packet_sock */
> >  	struct sock		sk;
> > @@ -197,6 +202,11 @@ struct packet_sock {
> >  	int			ifindex;	/* bound device		*/
> >  	__be16			num;
> >  	struct packet_mclist	*mclist;
> > +	struct packet_gap_record *gaps;
> > +	unsigned int gap_head;
> > +	unsigned int gap_tail;
> > +	unsigned int gap_list_size;
> > +
> >  #ifdef CONFIG_PACKET_MMAP
> >  	atomic_t		mapped;
> >  	enum tpacket_versions	tp_version;
> > @@ -524,6 +534,55 @@ static inline unsigned int run_filter(struct s=
k_buff *skb, struct sock *sk,
> >  }
> > =20
> >  /*
> > + * If we've lost frames since the last time we queued one to the
> > + * sk_receive_queue, we need to record it here.
> > + * This must be called under the protection of the socket lock
> > + * to prevent racing with other softirqs and user space
> > + */
> > +static void record_packet_gap(struct sk_buff *skb, struct packet_s=
ock *po)
> > +{
> > +	/*
> > +	 * do nothing if there is no gap
> > +	 */
> > +	if (!po->stats.tp_gap)
> > +		return;
> > +
> > +	/*
> > +	 * If there is, check the gap list tail to make sure we
> > +	 * have an open entry
> > +	 */
> > +	if (po->gaps[po->gap_tail].skb !=3D NULL) {
> > +		if (net_ratelimit())
> > +			printk(KERN_WARNING "packet socket gap list is full!\n");
>=20
> New code can use pr_warning() macro
>=20
good point.

> > +		return;
> > +	}
> > +
> > +	/*
> > +	 * We have a free entry, record it
> > +	 */
> > +	po->gaps[po->gap_tail].skb =3D skb;
> > +	po->gaps[po->gap_tail].gap =3D po->stats.tp_gap;
> > +	po->gap_tail =3D (po->gap_tail+1) % po->gap_list_size;
>=20
> you could avoid this divide
>=20
> 	if (++po->gap_tail =3D=3D po->gap_list_size)
> 		po->gap_tail =3D 0;
>=20
Yup, I can do that.

> > +	po->stats.tp_gap =3D 0;
> > +	return;
> > +
> > +}
> > +
> > +static __u32 check_packet_gap(struct sk_buff *skb, struct packet_s=
ock *po)
> > +{
> > +	__u32 gap =3D 0;
> > +
> > +	if (po->gaps[po->gap_head].skb !=3D skb)
> > +		return 0;
> > +
> > +	gap =3D po->gaps[po->gap_head].gap;
> > +	po->gaps[po->gap_head].skb =3D NULL;
> > +	po->gap_head =3D (po->gap_head + 1) % po->gap_list_size;
>=20
> ditto
>=20
ditto :)

> > +	return gap;
> > +}
> > +
> > +
> > +/*
> >     This function makes lazy skb cloning in hope that most of packe=
ts
> >     are discarded by BPF.
> > =20
> > @@ -626,6 +685,7 @@ static int packet_rcv(struct sk_buff *skb, stru=
ct net_device *dev,
> > =20
> >  	spin_lock(&sk->sk_receive_queue.lock);
> >  	po->stats.tp_packets++;
> > +	record_packet_gap(skb, po);
> >  	__skb_queue_tail(&sk->sk_receive_queue, skb);
> >  	spin_unlock(&sk->sk_receive_queue.lock);
> >  	sk->sk_data_ready(sk, skb->len);
> > @@ -634,6 +694,7 @@ static int packet_rcv(struct sk_buff *skb, stru=
ct net_device *dev,
> >  drop_n_acct:
> >  	spin_lock(&sk->sk_receive_queue.lock);
> >  	po->stats.tp_drops++;
> > +	po->stats.tp_gap++;
> >  	spin_unlock(&sk->sk_receive_queue.lock);
> > =20
> >  drop_n_restore:
> > @@ -811,6 +872,7 @@ drop:
> > =20
> >  ring_is_full:
> >  	po->stats.tp_drops++;
> > +	po->stats.tp_gap++;
> >  	spin_unlock(&sk->sk_receive_queue.lock);
> > =20
> >  	sk->sk_data_ready(sk, 0);
> > @@ -1223,6 +1285,8 @@ static int packet_release(struct socket *sock=
)
> >  	skb_queue_purge(&sk->sk_receive_queue);
> >  	sk_refcnt_debug_release(sk);
> > =20
> > +	kfree(po->gaps);
> > +
> >  	sock_put(sk);
> >  	return 0;
> >  }
> > @@ -1350,6 +1414,7 @@ static int packet_create(struct net *net, str=
uct socket *sock, int protocol)
> >  	struct packet_sock *po;
> >  	__be16 proto =3D (__force __be16)protocol; /* weird, but document=
ed */
> >  	int err;
> > +	unsigned int num_records =3D PAGE_SIZE/sizeof(struct packet_gap_r=
ecord);
> > =20
> >  	if (!capable(CAP_NET_RAW))
> >  		return -EPERM;
> > @@ -1360,6 +1425,7 @@ static int packet_create(struct net *net, str=
uct socket *sock, int protocol)
> >  	sock->state =3D SS_UNCONNECTED;
> > =20
> >  	err =3D -ENOBUFS;
> > +
> >  	sk =3D sk_alloc(net, PF_PACKET, GFP_KERNEL, &packet_proto);
> >  	if (sk =3D=3D NULL)
> >  		goto out;
> > @@ -1374,6 +1440,19 @@ static int packet_create(struct net *net, st=
ruct socket *sock, int protocol)
> >  	sk->sk_family =3D PF_PACKET;
> >  	po->num =3D proto;
> > =20
> > +	err =3D -ENOMEM;
> > +	po->gaps =3D kmalloc(sizeof(struct packet_gap_record)*num_records=
,
> > +				GFP_KERNEL);
>=20
> kzalloc(), and no need for some following lines
>=20
Will do.

> > +	if (!po->gaps)
> > +		goto out_free;
> > +	po->gap_tail =3D po->gap_head =3D 0;
> > +	po->gap_list_size =3D num_records;
> > +
> > +	for (num_records =3D 0; num_records < po->gap_list_size; num_reco=
rds++) {
> > +		po->gaps[num_records].skb =3D NULL;
> > +		po->gaps[num_records].gap =3D 0;
> > +	}
> > +
> >  	sk->sk_destruct =3D packet_sock_destruct;
> >  	sk_refcnt_debug_inc(sk);
> > =20
> > @@ -1402,6 +1481,9 @@ static int packet_create(struct net *net, str=
uct socket *sock, int protocol)
> >  	sock_prot_inuse_add(net, &packet_proto, 1);
> >  	write_unlock_bh(&net->packet.sklist_lock);
> >  	return 0;
> > +
> > +out_free:
> > +	sk_free(sk);
> >  out:
> >  	return err;
> >  }
> > @@ -1418,6 +1500,7 @@ static int packet_recvmsg(struct kiocb *iocb,=
 struct socket *sock,
> >  	struct sk_buff *skb;
> >  	int copied, err;
> >  	struct sockaddr_ll *sll;
> > +	__u32 gap;
> > =20
> >  	err =3D -EINVAL;
> >  	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
> > @@ -1492,10 +1575,15 @@ static int packet_recvmsg(struct kiocb *ioc=
b, struct socket *sock,
> >  		aux.tp_mac =3D 0;
> >  		aux.tp_net =3D skb_network_offset(skb);
> >  		aux.tp_vlan_tci =3D skb->vlan_tci;
> > -
>=20
> Please dont mix cleanups=20
>=20
Doh, I thought I'd removed that.  Thanks

> >  		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
> >  	}
> > =20
> > +	lock_sock(sk);
>=20
> strange locking here. this doesnt match locking used at record time.
>=20
> ( spin_lock(&sk->sk_receive_queue.lock);)
>=20
Not sure why AF_PACKET didn't use sock_lock_bh, there, I think that pro=
bably
requires a cleanup.  The intent was to protect the ring buffer using th=
e socket
lock.  I think we likey need to change the existing lock usage in af_pa=
cket.c to
use sock_lock_bh in this case.

> > +	gap =3D check_packet_gap(skb, pkt_sk(sk));
> > +	release_sock(sk);
> > +	if (gap)
> > +		put_cmsg(msg, SOL_PACKET, PACKET_GAPDATA, sizeof(u32), &gap);
> > +
> >  	/*
> >  	 *	Free or return the buffer as appropriate. Again this
> >  	 *	hides all the races and re-entrancy issues from us.
>=20
> Thanks
>=20
Thanks for the notes Eric, I'll cleanup and repost in the AM.

Regards
Neil

>=20
