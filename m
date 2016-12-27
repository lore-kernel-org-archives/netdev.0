From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH] net: dev_weight: TX/RX orthogonality
Date: Tue, 27 Dec 2016 18:29:32 +0100
Message-ID: <8a82a8e2-55d9-3dec-b82b-1121976ae3f5@gmx.net>
References: <20161226.115818.1691666598003246082.davem@davemloft.net>
 <1482827147-7535-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161227164758.GA10870@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha384;
 protocol="application/pgp-signature";
 boundary="rBU2dLxt5FH5VSo3vqkb3Nxg4blxucFp7"
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:64651 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755906AbcL0R35 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Dec 2016 12:29:57 -0500
In-Reply-To: <20161227164758.GA10870@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--rBU2dLxt5FH5VSo3vqkb3Nxg4blxucFp7
Content-Type: multipart/mixed; boundary="dHEL9ruMCRxqVh7ENbGDqgplAjMVm4TXQ";
 protected-headers="v1"
From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
 edumazet@google.com, daniel@iogearbox.net
Message-ID: <8a82a8e2-55d9-3dec-b82b-1121976ae3f5@gmx.net>
Subject: Re: [PATCH] net: dev_weight: TX/RX orthogonality
References: <20161226.115818.1691666598003246082.davem@davemloft.net>
 <1482827147-7535-1-git-send-email-matthias.tafelmeier@gmx.net>
 <20161227164758.GA10870@localhost.localdomain>
In-Reply-To: <20161227164758.GA10870@localhost.localdomain>

--dHEL9ruMCRxqVh7ENbGDqgplAjMVm4TXQ
Content-Type: multipart/mixed;
 boundary="------------04B997E5024D3BF297626AC2"

This is a multi-part message in MIME format.
--------------04B997E5024D3BF297626AC2
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/27/2016 05:47 PM, Marcelo Ricardo Leitner wrote:
> On Tue, Dec 27, 2016 at 09:25:47AM +0100, Matthias Tafelmeier wrote:
>> Oftenly, introducing side effects on packet processing on the other ha=
lf
>> of the stack by adjusting one of TX/RX via sysctl is not desirable.
>> There are cases of demand for asymmetric, orthogonal configurability.
>>
>> This holds true especially for nodes where RPS for RFS usage on top is=

>> configured and therefore use the 'old dev_weight'. This is quite a
>> common base configuration setup nowadays, even with NICs of superior p=
rocessing
>> support (e.g. aRFS).
>>
>> A good example use case are nodes acting as noSQL data bases with a
>> large number of tiny requests and rather fewer but large packets as re=
sponses.
>> It's affordable to have large budget and rx dev_weights for the
>> requests. But as a side effect having this large a number on TX
>> processed in one run can overwhelm drivers.
>>
>> This patch therefore introduces an independent configurability via sys=
ctl to
>> userland.
>> ---
>>  include/linux/netdevice.h  |  2 ++
>>  net/core/dev.c             |  4 +++-
>>  net/core/sysctl_net_core.c | 14 ++++++++++++++
>>  net/sched/sch_generic.c    |  2 +-
>>  4 files changed, 20 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 994f742..bb331e0 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -3795,6 +3795,8 @@ void netdev_stats_to_stats64(struct rtnl_link_st=
ats64 *stats64,
>>  extern int		netdev_max_backlog;
>>  extern int		netdev_tstamp_prequeue;
>>  extern int		weight_p;
>> +extern int		dev_w_rx_bias;
>> +extern int		dev_w_tx_bias;
>> =20
>>  bool netdev_has_upper_dev(struct net_device *dev, struct net_device *=
upper_dev);
>>  struct net_device *netdev_upper_get_next_dev_rcu(struct net_device *d=
ev,
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 8db5a0b..0dcbd28 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3428,6 +3428,8 @@ EXPORT_SYMBOL(netdev_max_backlog);
>>  int netdev_tstamp_prequeue __read_mostly =3D 1;
>>  int netdev_budget __read_mostly =3D 300;
>>  int weight_p __read_mostly =3D 64;            /* old backlog weight *=
/
>> +int dev_w_rx_bias __read_mostly =3D 1;            /* bias for backlog=
 weight */
>> +int dev_w_tx_bias __read_mostly =3D 1;            /* bias for output_=
queue quota */
>> =20
>>  /* Called with irq disabled */
>>  static inline void ____napi_schedule(struct softnet_data *sd,
>> @@ -4833,7 +4835,7 @@ static int process_backlog(struct napi_struct *n=
api, int quota)
>>  		net_rps_action_and_irq_enable(sd);
>>  	}
>> =20
>> -	napi->weight =3D weight_p;
>> +	napi->weight =3D weight_p * dev_w_rx_bias;
>>  	while (again) {
>>  		struct sk_buff *skb;
>> =20
>> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
>> index 2a46e40..a2ab149 100644
>> --- a/net/core/sysctl_net_core.c
>> +++ b/net/core/sysctl_net_core.c
>> @@ -276,6 +276,20 @@ static struct ctl_table net_core_table[] =3D {
>>  		.proc_handler	=3D proc_dointvec
>>  	},
>>  	{
>> +		.procname	=3D "dev_w_rx_bias",
>> +		.data		=3D &dev_w_rx_bias,
>> +		.maxlen		=3D sizeof(int),
>> +		.mode		=3D 0644,
>> +		.proc_handler	=3D proc_dointvec
>> +	},
>> +	{
>> +		.procname	=3D "dev_w_tx_bias",
>> +		.data		=3D &dev_w_tx_bias,
>> +		.maxlen		=3D sizeof(int),
>> +		.mode		=3D 0644,
>> +		.proc_handler	=3D proc_dointvec
>> +	},
>> +	{
> Please describe these at Documentation/sysctl/net.txt, probably right
> after dev_weight.=20
Sure, I'll do that.

> I'm not sure about the abbreviation, maybe it would be better the longe=
r
> name as it doesn't block tab completion.
> dev_weight_tx_bias
> dev_weight_rx_bias
> dev_weight
>
Do not find the abbreviation/naming satisfactory, either. Rather saw
them as a draft. Could think of dev_weight distant naming:

ns_rps_cpu_rx_bias
ns_cpu_tx_bias

Though, makes me concerned about association etc. Maybe, that's nit
picking.



--------------04B997E5024D3BF297626AC2
Content-Type: application/pgp-keys;
 name="0x8ADF343B.asc"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="0x8ADF343B.asc"

-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

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
qnlCR0LVNOnSE3Eb
=3D0oZJ
-----END PGP PUBLIC KEY BLOCK-----

--------------04B997E5024D3BF297626AC2--

--dHEL9ruMCRxqVh7ENbGDqgplAjMVm4TXQ--

--rBU2dLxt5FH5VSo3vqkb3Nxg4blxucFp7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCQAGBQJYYqT8AAoJEOAWT1uK3zQ7FqcH+gMbfcuCvxuViSfNveTw2ueO
xUmb5LHLWyx0kUdumVScN79/QUPab3XFiSQc1Df4WeHCT3Mi556hMAgRuYDsLbMs
1aYs5fSlFxGwxQoz3f2NzIQoIGIscoEfpbj1gx9SsSk+x8TuRS7WdNhhFqpsPmBh
JcyJ6faT4LIGg9c5MwUBzpLfzj8yONV5Cj7pCBxnNpfSFBt4soThAA+mcK/oG3vL
ldMrjSMJ0MRLLYMjGsdh205CUlI0exYtNYKA40KQvEMffaUJuGX8qyO2ldbDr6uI
/fmrNmx2qq0mYyvRWJbZQOcOSNxOyI0nKXLaXprj3+G62J2n4Fala2AsEWnTjtg=
=aVOe
-----END PGP SIGNATURE-----

--rBU2dLxt5FH5VSo3vqkb3Nxg4blxucFp7--
