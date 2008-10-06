From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Mon, 06 Oct 2008 12:49:33 +0200
Message-ID: <48E9ED3D.2020005@cosmosbay.com>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com> <20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com> <20081003003158.GA19230@localhost.localdomain> <20081003203640.GA13354@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090401070401090204040803"
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:4670 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbYJFL3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2008 07:29:45 -0400
In-Reply-To: <20081003203640.GA13354@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090401070401090204040803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Neil Horman a =E9crit :
> Hey all-
> 	So, I've been doing some testing here with this patch, and am
> comfortable that the sd estimation is working reasonably well. For a ha=
sh table
> with an average chain length of 1, it computes the stadard deviation to=
 be 2,
> which gives us a max chain length of 9 (4*sd + avg), and it manages to =
do that
> in about 7 jiffies over about 524000 hash buckets.  I'm reasonably plea=
sed with
> that speed I think, and after thinking about it, I like this implementa=
tion
> somewhat better, as it doesn't create a window in which chains can be
> artifically overrun (until the nect gc round) (although I'm happy to he=
ar
> arguments against my implementation).  Anywho here it is, comments and =
thoughts
> welcome!
>=20
> Thanks & Regards
> Neil
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20
>  route.c |  121 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++--
>  1 file changed, 118 insertions(+), 3 deletions(-)
>=20
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ee5354..4f8c5b5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -145,6 +145,7 @@ static struct dst_entry *ipv4_negative_advice(struc=
t dst_entry *dst);
>  static void		 ipv4_link_failure(struct sk_buff *skb);
>  static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
>  static int rt_garbage_collect(struct dst_ops *ops);
> +static void rt_emergency_hash_rebuild(struct net *net);
> =20
> =20
>  static struct dst_ops ipv4_dst_ops =3D {
> @@ -200,7 +201,14 @@ const __u8 ip_tos2prio[16] =3D {
> =20
>  struct rt_hash_bucket {
>  	struct rtable	*chain;
> +	atomic_t	chain_length;
>  };
> +
> +atomic_t rt_hash_total_count;
> +atomic_t rt_hash_nz_count;
> +
> +static int rt_chain_length_max;
> +
>  #if defined(CONFIG_SMP) || defined(CONFIG_DEBUG_SPINLOCK) || \
>  	defined(CONFIG_PROVE_LOCKING)
>  /*
> @@ -601,6 +609,68 @@ static inline int ip_rt_proc_init(void)
>  }
>  #endif /* CONFIG_PROC_FS */
> =20
> +static void rt_hash_sd_update(void)
> +{
> +	int temp, i;
> +	unsigned long long sd;
> +	int average =3D atomic_read(&rt_hash_total_count);
> +	int nzcount =3D atomic_read(&rt_hash_nz_count);
> +
> +	/*
> + 	 * Don't divide by zero
> + 	 */
> +	if (!nzcount)
> +		return;
> +
> +	average =3D DIV_ROUND_UP(average, nzcount);
> +
> +	sd =3D 0;
> +	for (i =3D 0; i < (1 << rt_hash_log); i++) {
> +		temp =3D atomic_read(&rt_hash_table[i].chain_length);
> +		/*
> + 		 * Don't count zero entries, as most of the table
> + 		 * will likely be empty.  We don't want to unfairly
> + 		 * bias our average chain length down so far
> + 		 */

Empty chains should be accounted for, or average and standard
deviation are not correct.

> +		if (unlikely(temp))
> +			sd +=3D (temp-average)^2;

Out of curiosity, what do you expect to do here ?

(temp-average) XOR 2
or=20
(temp-average) * (temp-average)=20

Also, your computations use integer arithmetic.

If avg =3D 2.5 and sd =3D 1.9, avg+4*sd you'll find 6 instead of 10=20

Anyway, we wont add so many atomic operations and double
hash table size in order to be able to compute sd.

If we really want to be smart, we can have a pretty good
 estimate of average and sd for free in rt_check_expire()

Something like this untested patch. (We should make sure
we dont overflow sum2 for example)


--------------090401070401090204040803
Content-Type: text/plain;
 name="avg_sd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="avg_sd.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6ee5354..85182d9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -125,6 +125,7 @@ static int ip_rt_redirect_silence __read_mostly	= ((HZ / 50) << (9 + 1));
 static int ip_rt_error_cost __read_mostly	= HZ;
 static int ip_rt_error_burst __read_mostly	= 5 * HZ;
 static int ip_rt_gc_elasticity __read_mostly	= 8;
+static int rt_chain_length_max __read_mostly    = 32;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
@@ -748,11 +749,24 @@ static void rt_do_flush(int process_context)
 	}
 }
 
+/*
+ * While freeing expired entries, we compute average chain length
+ * and standard deviation, using fixed-point arithmetic.
+ * This to have an estimation of rt_chain_length_max
+ *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
+ * We use 3 bits for frational part, and 29 (or 61) for magnitude.
+ */
+
+#define FRACT_BITS 3
+#define ONE (1UL << FRACT_BITS)
+
 static void rt_check_expire(void)
 {
 	static unsigned int rover;
 	unsigned int i = rover, goal;
 	struct rtable *rth, **rthp;
+	unsigned long sum = 0, sum2 = 0;
+	unsigned long length, samples = 0;
 	u64 mult;
 
 	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
@@ -770,8 +784,10 @@ static void rt_check_expire(void)
 		if (need_resched())
 			cond_resched();
 
+		samples++;
 		if (*rthp == NULL)
 			continue;
+		length = 0;
 		spin_lock_bh(rt_hash_lock_addr(i));
 		while ((rth = *rthp) != NULL) {
 			if (rt_is_expired(rth)) {
@@ -784,11 +800,13 @@ static void rt_check_expire(void)
 				if (time_before_eq(jiffies, rth->u.dst.expires)) {
 					tmo >>= 1;
 					rthp = &rth->u.dst.rt_next;
+					length += ONE;
 					continue;
 				}
 			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
 				tmo >>= 1;
 				rthp = &rth->u.dst.rt_next;
+				length += ONE;
 				continue;
 			}
 
@@ -797,6 +815,15 @@ static void rt_check_expire(void)
 			rt_free(rth);
 		}
 		spin_unlock_bh(rt_hash_lock_addr(i));
+		sum += length;
+		sum2 += length*length;
+	}
+	if (samples) {
+		unsigned long avg = sum / samples;
+		unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
+		rt_chain_length_max = max_t(unsigned long,
+					    ip_rt_gc_elasticity,
+					    (avg + 4*sd) >> FRACT_BITS);
 	}
 	rover = i;
 }

--------------090401070401090204040803--


