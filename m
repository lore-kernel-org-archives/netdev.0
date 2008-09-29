From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Mon, 29 Sep 2008 22:22:03 +0200
Message-ID: <48E138EB.1080001@cosmosbay.com>
References: <20080929191254.GA20074@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.139]:2562 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbYI2UWV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 16:22:21 -0400
In-Reply-To: <20080929191254.GA20074@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Hey all-
> 	We currently have the ability to disable our route cache secret inte=
rval
> rebuild timer (by setting it to zero), but if we do that its possible=
 for an
> attacker (if they guess our route cache hash secret, to fill our syst=
em with
> routes that all hash to the same bucket, destroying our performance. =
 This patch
> provides a backstop for that issues.  In the event that our rebuild i=
nterval is
> disabled (or very large), if any hash chain exceeds ip_rt_gc_elastici=
ty, we do
> an emergency hash rebuild.  During the hash rebuild we:
> 1) warn the user of the emergency
> 2) disable the rebuild timer
> 3) invalidate the route caches
> 4) re-enable the rebuild timer with its old value
>=20
> Regards
> Neil

This sounds not good at all to me.

1) Dont set ip_rt_secret_interval to zero, this is plain silly, since
   you give attackers infinite time to break your machine.

To quote Herbert (who allowed to set this interval to 0)

    "Let me first state that disabling the route cache hash rebuild
     should not be done without extensive analysis on the risk profile
     and careful deliberation.

     However, there are times when this can be done safely or for
     testing.  For example, when you have mechanisms for ensuring
     that offending parties do not exist in your network."


2) Many machines have ip_rt_gc_elasticity set to 2,
   because they have a huge hash table, but low chain depths.


>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20
>=20
>  route.c |   36 +++++++++++++++++++++++++++++++++++-
>  1 file changed, 35 insertions(+), 1 deletion(-)
>=20
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ee5354..b95e02a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -145,7 +145,7 @@ static struct dst_entry *ipv4_negative_advice(str=
uct dst_entry *dst);
>  static void		 ipv4_link_failure(struct sk_buff *skb);
>  static void		 ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
>  static int rt_garbage_collect(struct dst_ops *ops);
> -
> +static void rt_emergency_hash_rebuild(void);
> =20
>  static struct dst_ops ipv4_dst_ops =3D {
>  	.family =3D		AF_INET,
> @@ -1056,6 +1056,15 @@ restart:
>  			*candp =3D cand->u.dst.rt_next;
>  			rt_free(cand);
>  		}
> +	} else if (chain_length > ip_rt_gc_elasticity) {
> +		/*
> +		 * We didn't find a route entry we could safely free,
> +		 * yet our chain length is over our elasticity value.
> +		 * Someone may have guessed our hash secret and is artifically
> +		 * filling up our route cache.  Lets do an emergency rebuild
> +		 * to be safe
> +		 */
> +		rt_emergency_hash_rebuild();
>  	}
> =20
>  	/* Try to bind route to arp only if it is output
> @@ -2946,6 +2955,31 @@ static void rt_secret_reschedule(int old)
>  	rtnl_unlock();
>  }
> =20
> +static void rt_secret_rebuild_oneshot(void) {
> +	struct net *net;
> +	int old_interval =3D ip_rt_secret_interval;
> +
> +	ip_rt_secret_interval =3D 0;
> +
> +	rt_secret_reschedule(old_interval);
> +
> +	for_each_net(net)=20
> +		rt_cache_invalidate(net);
> +
> +	ip_rt_secret_interval =3D old_interval;
> +
> +	rt_secret_reschedule(0);
> +}
> +
> +static void rt_emergency_hash_rebuild(void) {
> +	if (net_ratelimit()) {
> +		printk(KERN_WARNING "Route hash chain too long!\n");
> +		printk(KERN_WARNING "Adjust your secret_interval!\n");
> +	}
> +
> +	rt_secret_rebuild_oneshot();
> +}
> +
>  static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
>  					  struct file *filp,
>  					  void __user *buffer, size_t *lenp,




