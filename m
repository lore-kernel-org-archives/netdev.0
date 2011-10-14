From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Fri, 14 Oct 2011 14:53:11 +0200
Message-ID: <1318596791.2223.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
	 <1318586017-17207-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mirq-linux@rere.qmqm.pl, therbert@google.com,
	jpirko@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dbaluta@ixiacom.com,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318586017-17207-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 14 octobre 2011 =C3=A0 12:53 +0300, Mihai Maruseac a =C3=A9=
crit :
> Instead of using the dev->next chain and trying to resync at each cal=
l to
> dev_seq_start, use the ifindex, keeping the last index in seq->privat=
e field.
>=20
> Tests revealed the following results for ifconfig > /dev/null
> 	* 1000 interfaces:
> 		* 0.114s without patch
> 		* 0.089s with patch
> 	* 3000 interfaces:
> 		* 0.489s without patch
> 		* 0.110s with patch
> 	* 5000 interfaces:
> 		* 1.363s without patch
> 		* 0.250s with patch
> 	* 128000 interfaces (other setup):
> 		* ~100s without patch
> 		* ~30s with patch
>=20
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
> ---
>  net/core/dev.c |   55 ++++++++++++++++++++++++++++++++++------------=
---------
>  1 files changed, 34 insertions(+), 21 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 70ecb86..ea24445 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4041,6 +4041,37 @@ static int dev_ifconf(struct net *net, char __=
user *arg)
>  }
> =20
>  #ifdef CONFIG_PROC_FS
> +
> +struct dev_iter_state {
> +	struct seq_net_private p;
> +	int ifindex;
> +};
> +
> +static struct net_device *__dev_seq_next(struct seq_file *seq, loff_=
t *pos)
> +{
> +	struct dev_iter_state *state =3D seq->private;
> +	struct net *net =3D seq_file_net(seq);
> +	struct net_device *dev;
> +	loff_t off;
> +
> +	dev =3D dev_get_by_index_rcu(net, state->ifindex);
> +	if (likely(dev))
> +		goto found;
> +
> +	off =3D 0;
> +	for_each_netdev_rcu(net, dev)
> +		if (off++ =3D=3D *pos) {
> +			state->ifindex =3D dev->ifindex;
> +			goto found;
> +		}
> +
> +	return NULL;
> +found:
> +	state->ifindex++;

This assumes device ifindexes are contained in a small range=20
[N .. N + X]

I understand this can help some benchmarks, but in real world this wont
help that much once ifindexes are 'fragmented' (If really this multi
thousand devices stuff is for real)

Listen, we currently have 256 slots in the hash table.

Can we try to make 'offset' something like  (slot_number<<24) +
(position in hash chain [slot_number]), instead of (position in devices
global list)
