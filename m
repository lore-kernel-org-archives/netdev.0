From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Mon, 24 Aug 2009 15:36:01 -0700
Message-ID: <1251153361.29173.25.camel@w-sridhar.beaverton.ibm.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>
	 <4A89C026.4030402@us.ibm.com>
	 <alpine.DEB.1.10.0908171642500.20399@gentwo.org>
	 <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
	 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908171848370.15956@gentwo.org>
	 <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.DEB.1.10.0908241334230.30487@gentwo.org>
	 <4A930DEF.5000008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:56023 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885AbZHXWgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 18:36:02 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7OMTcAL018171
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 18:29:38 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7OMa4UQ070396
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 18:36:04 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7OMa3jh022542
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2009 18:36:04 -0400
In-Reply-To: <4A930DEF.5000008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-25 at 00:02 +0200, Eric Dumazet wrote:
> Christoph Lameter a =C3=A9crit :
> > On Mon, 17 Aug 2009, Sridhar Samudrala wrote:
> >=20
> >> So it is possible that there is some other place in the stack wher=
e the packets
> >> are gettting dropped but not counted.
> >=20
> > Such a deed occurs in ip_push_pending_frames():
> >=20
> >         /* Netfilter gets whole the not fragmented skb. */
> >         err =3D ip_local_out(skb);
> >         if (err) {
> >                 if (err > 0)
> >                         err =3D inet->recverr ? net_xmit_errno(err)=
 : 0;
> > 			^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> >                 if (err)
> >                         goto error;
> >         }
> >=20
> > out:
> >         ip_cork_release(inet);
> >         return err;
> >=20
> > error:
> >         IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
> >         goto out;
> >=20
> >=20
> > So if ip_local_out returns NET_XMIT_DROP then its simply going to b=
e
> > replaced by 0. Then we check err again and there is no error!!!!

Christoph,

So are you hitting this case with your workload and does this account f=
or all the
packet losses you are seeing?=20

If we are dropping the packet and returing NET_XMIT_DROP, should
we also increment qdisc drop stats (sch->qstats.drops)?

In dev_queue_xmit(), we have

        if (q->enqueue) {
                spinlock_t *root_lock =3D qdisc_lock(q);

                spin_lock(root_lock);

                if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->st=
ate))) {
                        kfree_skb(skb);
                        rc =3D NET_XMIT_DROP;
                } else {
                        rc =3D qdisc_enqueue_root(skb, q);
                        qdisc_run(q);
                }
                spin_unlock(root_lock);

                goto out;
        }

Here, if QDISC_STATE_DEACTIVATED is true, the skb is dropped and NET_XM=
IT_DROP
is returned, but not accounted in qdisc drop stats.
However it is incremented when NET_XMIT_DROP is returned via qdisc_drop=
().

If we count these drops as qdisc drops, should we also count them as IP=
 OUTDISCARDS?

Thanks
Sridhar

> >=20
> NET_XMIT_CN strikes again :)
>=20
> Well, if ip_local_out() returns a negative error (say -EPERM for exam=
ple),
>  your patch disables OUTDISCARDS increments.
>=20
> Maybe a simpler patch like this one ?
>=20
> [PATCH] net: correctly updates OUTDISCARDS in ip_push_pending_frames(=
)
>=20
> ip_push_pending_frames() can fail to send a frame because of a conges=
tioned
> device. In this case, we increment SNMP OUTDISCARDS only if user set
> IP_RECVERR, which is not RFC conformant.
>=20
> Only case where we should not update OUTDISCARDS is when
> ip_local_output() return value is NET_XMIT_CN (meaning
> skb was xmitted but future frames might be dropped)
>=20
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 7d08210..27a5b79 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1301,19 +1301,15 @@ int ip_push_pending_frames(struct sock *sk)
>  	/* Netfilter gets whole the not fragmented skb. */
>  	err =3D ip_local_out(skb);
>  	if (err) {
> +		if (err !=3D NET_XMIT_CN)
> +			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
>  		if (err > 0)
>  			err =3D inet->recverr ? net_xmit_errno(err) : 0;
> -		if (err)
> -			goto error;
>  	}
>=20
>  out:
>  	ip_cork_release(inet);
>  	return err;
> -
> -error:
> -	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
> -	goto out;
>  }
>=20
>  /*


