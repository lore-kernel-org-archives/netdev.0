From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH]  netfilter: use per-CPU recursive lock {XIV}
Date: Fri, 24 Apr 2009 06:58:39 +0200
Message-ID: <49F146FF.5050200@cosmosbay.com>
References: <20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>	<20090420160121.268a8226@nehalam>	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>	<20090421111541.228e977a@nehalam>	<20090421193924.GA24404@elte.hu>	<20090421143927.52d7d89d@nehalam>	<alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753278AbZDXFEM@vger.kernel.org>
In-Reply-To: <20090423210938.1501507b@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> In days of old in 2.6.29, netfilter did locketh using a=20
> lock of the reader kind when doing its table business, and do
> a writer when with pen in hand like a overworked accountant
> did replace the tables. This sucketh and caused the single
> lock to fly back and forth like a poor errant boy.
>=20
> But then netfilter was blessed with RCU and the performance
> was divine, but alas there were those that suffered for
> trying to replace their many rules one at a time.
>=20
> So now RCU must be vanquished from the scene, and better
> chastity belts be placed upon this valuable asset most dear.
> The locks that were but one are now replaced by one per suitor.
>=20
> The repair was made after much discussion involving
> Eric the wise, and Linus the foul. With flowers springing
> up amid the thorns some peace has finally prevailed and
> all is soothed. This patch and purple prose was penned by
> in honor of "Talk like Shakespeare" day.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


Philip Davis of the university=92s School of English said :

  "Shakespeare surprises the brain and catches it off guard in
  a manner that produces a sudden burst of activity - a sense=20
  of drama created out of the simplest of things."

http://www.physorg.com/news85664210.html

>=20
> ---
> What hath changed over the last two setting suns:
>   * more words, mostly correct...
>=20
>   * no need to locketh for writeh on current cpu tis=20
>     always so
>=20
>   * the locking of all cpu's on replace is always done as
>     part of the get_counters cycle, so the sychronize swip
>     in replace tables is gone with only a comment remaing
>=20
>  include/linux/netfilter/x_tables.h |   55 ++++++++++++++--
>  net/ipv4/netfilter/arp_tables.c    |  125 ++++++++++----------------=
----------
>  net/ipv4/netfilter/ip_tables.c     |  126 ++++++++++----------------=
-----------
>  net/ipv6/netfilter/ip6_tables.c    |  123 ++++++++++----------------=
----------
>  net/netfilter/x_tables.c           |   55 ++++++++--------
>  5 files changed, 188 insertions(+), 296 deletions(-)
>=20


> =20
>  static int __init xt_init(void)
>  {
> -	int i, rv;
> +	unsigned int i;
> +	int rv;
> +	static struct lock_class_key xt_lock_key[NR_CPUS];

Could we avoid this [NR_CPUS] thing ?

> +
> +	for_each_possible_cpu(i) {
> +		rwlock_t *lock =3D &per_cpu(xt_info_locks, i);
> +
> +		rwlock_init(lock);
> +		lockdep_set_class(lock, xt_lock_key+i);
> +	}


Did you tried :

static DECLARE_PER_CPU(struct lock_class_key, xt_locks_key);

static int __init xt_init(void)
 {
	unsigned int i;
	int rv;

	for_each_possible_cpu(i) {
		rwlock_t *lock =3D &per_cpu(xt_info_locks, i);

		rwlock_init(lock);
		lockdep_set_class(lock, &per_cpu(&xt_locks_key, i));
	}
=2E..

Thanks
