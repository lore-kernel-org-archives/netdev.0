From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] tc: report informations for multiqueue
 devices
Date: Wed, 2 Sep 2009 09:23:51 -0700
Message-ID: <20090902092351.11649796@nehalam>
References: <20090902081429.GB4878@ff.dom.local>
	<4A9E2CC7.1010103@gmail.com>
	<20090902.013002.181288977.davem@davemloft.net>
	<4A9E6551.4030209@gmail.com>
	<4A9E699B.7080400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	cl@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46220 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbZIBQXz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 12:23:55 -0400
In-Reply-To: <4A9E699B.7080400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Sep 2009 14:48:27 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > David Miller a =C3=A9crit :
> >> From: Eric Dumazet <eric.dumazet@gmail.com>
> >> Date: Wed, 02 Sep 2009 10:28:55 +0200
> >>
> >>> What naming convention should we choose for multiqueue devices ?
> >> We could give an index field to multiple root qdiscs assigned
> >> to a device.
> >=20
> > Here is a patch then :)
> >=20
> > Only point is that I am iterating from 0 to dev->real_num_tx_queues
> > instead of dev->num_tx_queues. I hope it's fine, because there are
> > allocated qdisc, but not really used.
> >=20
> > Next patches to allow selective qdisc change/fetch (providing a TCA=
_QINDEX
> > selector value to kernel)
> >=20
> > Thanks
> >=20
> >=20
> > [PATCH net-next-2.6] tc: report informations for multiqueue devices
> >=20
> > qdisc and classes are not yet displayed by "tc -s -d {qdisc|class} =
show"
> > for multiqueue devices.
> >=20
> > We use a new TCA_QINDEX attribute, to report queue index to user sp=
ace.
> > iproute2 tc should be changed to eventually display this queue inde=
x as in :
> >=20
> > $ tc -s -d qdisc
> > qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 =
1 1 1 1 1 1 1 1
> >  Sent 52498 bytes 465 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> > qdisc pfifo_fast 0: dev eth0 qindex 1 root bands 3 priomap  1 2 2 2=
 1 2 0 0 1 1 1 1 1 1 1 1
> >  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >  rate 0bit 0pps backlog 0b 0p requeues 0
> >=20
>=20
>=20
> Here is the iproute2 patch as well, to display queue indexes
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index ba3254e..b80e0f6 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -490,6 +490,7 @@ enum
>  	TCA_FCNT,
>  	TCA_STATS2,
>  	TCA_STAB,
> +	TCA_QINDEX,
>  	__TCA_MAX
>  };
> =20
> diff --git a/tc/tc_class.c b/tc/tc_class.c
> index 9d4eea5..1bc4bc6 100644
> --- a/tc/tc_class.c
> +++ b/tc/tc_class.c
> @@ -196,6 +196,13 @@ int print_class(const struct sockaddr_nl *who,
>  	if (filter_ifindex =3D=3D 0)
>  		fprintf(fp, "dev %s ", ll_index_to_name(t->tcm_ifindex));
> =20
> +	if (tb[TCA_QINDEX]) {
> +		int qindex =3D 0;
> +
> +		memcpy(&qindex, RTA_DATA(tb[TCA_QINDEX]), MIN(RTA_PAYLOAD(tb[TCA_Q=
INDEX]), sizeof(int)));
> +		fprintf(fp, "qindex %d ", qindex);
> +	}
> +
>  	if (t->tcm_parent =3D=3D TC_H_ROOT)
>  		fprintf(fp, "root ");
>  	else {

Even if the kernel keeps the value in something else for the API
QINDEX needs to be a fixed size unsigned type like u32.


