From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 4/6] netfilter: abstract xt_counters
Date: Sun, 01 Feb 2009 13:25:26 +0100
Message-ID: <498594B6.6000905@cosmosbay.com>
References: <20090130215700.965611970@vyatta.com> <20090130215729.416851870@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48702 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbZBAMZg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 07:25:36 -0500
In-Reply-To: <20090130215729.416851870@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Break out the parts of the x_tables code that manipulates counters so
> changes to locking are easier.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
>=20
> ---
>  include/linux/netfilter/x_tables.h |    6 +++++-
>  net/ipv4/netfilter/arp_tables.c    |    9 +++++----
>  net/ipv4/netfilter/ip_tables.c     |    9 +++++----
>  net/ipv6/netfilter/ip6_tables.c    |   21 +++++++++++----------
>  net/netfilter/x_tables.c           |   15 +++++++++++++++
>  5 files changed, 41 insertions(+), 19 deletions(-)
>=20
> --- a/include/linux/netfilter/x_tables.h	2009-01-30 08:31:48.63045449=
3 -0800
> +++ b/include/linux/netfilter/x_tables.h	2009-01-30 09:14:01.29468033=
9 -0800
> @@ -105,13 +105,17 @@ struct _xt_align
>  #define XT_ERROR_TARGET "ERROR"
> =20
>  #define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); =
} while(0)
> -#define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p)=
; } while(0)
> =20
>  struct xt_counters
>  {
>  	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
>  };
> =20
> +extern void xt_add_counter(struct xt_counters *c, unsigned b, unsign=
ed p);
> +extern void xt_sum_counter(struct xt_counters *t,
> +			   int cpu, const struct xt_counters *c);
> +
> +
>  /* The argument to IPT_SO_ADD_COUNTERS. */
>  struct xt_counters_info
>  {
> --- a/net/ipv4/netfilter/arp_tables.c	2009-01-30 08:31:48.569479503 -=
0800
> +++ b/net/ipv4/netfilter/arp_tables.c	2009-01-30 09:12:40.181542286 -=
0800
> @@ -256,7 +256,7 @@ unsigned int arpt_do_table(struct sk_buf
> =20
>  			hdr_len =3D sizeof(*arp) + (2 * sizeof(struct in_addr)) +
>  				(2 * skb->dev->addr_len);
> -			ADD_COUNTER(e->counters, hdr_len, 1);
> +			xt_add_counter(&e->counters, hdr_len, 1);
> =20
>  			t =3D arpt_get_target(e);
> =20
> @@ -662,10 +662,11 @@ static int translate_table(const char *n
> =20
>  /* Gets counters. */
>  static inline int add_entry_to_counter(const struct arpt_entry *e,
> +				       int cpu,
>  				       struct xt_counters total[],
>  				       unsigned int *i)
>  {
> -	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
> +	xt_sum_counter(total, cpu, &e->counters);
> =20
>  	(*i)++;
>  	return 0;
> @@ -709,6 +710,7 @@ static void get_counters(const struct xt
>  		ARPT_ENTRY_ITERATE(t->entries[cpu],
>  				   t->size,
>  				   add_entry_to_counter,
> +				   cpu,
>  				   counters,
>  				   &i);
>  	}
> @@ -1082,8 +1084,7 @@ static inline int add_counter_to_entry(s
>  				       const struct xt_counters addme[],
>  				       unsigned int *i)
>  {
> -
> -	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
> +	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
> =20
>  	(*i)++;
>  	return 0;
> --- a/net/ipv4/netfilter/ip_tables.c	2009-01-30 08:31:48.538730580 -0=
800
> +++ b/net/ipv4/netfilter/ip_tables.c	2009-01-30 09:12:40.169542168 -0=
800
> @@ -366,7 +366,7 @@ ipt_do_table(struct sk_buff *skb,
>  			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) !=3D 0)
>  				goto no_match;
> =20
> -			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
> +			xt_add_counter(&e->counters, ntohs(ip->tot_len), 1);
> =20
>  			t =3D ipt_get_target(e);
>  			IP_NF_ASSERT(t->u.kernel.target);
> @@ -872,10 +872,11 @@ translate_table(const char *name,
>  /* Gets counters. */
>  static inline int
>  add_entry_to_counter(const struct ipt_entry *e,
> +		     int cpu,
>  		     struct xt_counters total[],
>  		     unsigned int *i)
>  {
> -	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
> +	xt_sum_counter(total, cpu, &e->counters);
> =20
>  	(*i)++;
>  	return 0;
> @@ -921,6 +922,7 @@ get_counters(const struct xt_table_info=20
>  		IPT_ENTRY_ITERATE(t->entries[cpu],
>  				  t->size,
>  				  add_entry_to_counter,
> +				  cpu,
>  				  counters,
>  				  &i);
>  	}
> @@ -1327,8 +1329,7 @@ add_counter_to_entry(struct ipt_entry *e
>  		 (long unsigned int)addme[*i].pcnt,
>  		 (long unsigned int)addme[*i].bcnt);
>  #endif
> -
> -	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
> +	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
> =20
>  	(*i)++;
>  	return 0;
> --- a/net/ipv6/netfilter/ip6_tables.c	2009-01-30 08:31:48.605479850 -=
0800
> +++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-30 09:12:40.205542065 -=
0800
> @@ -392,9 +392,9 @@ ip6t_do_table(struct sk_buff *skb,
>  			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) !=3D 0)
>  				goto no_match;
> =20
> -			ADD_COUNTER(e->counters,
> -				    ntohs(ipv6_hdr(skb)->payload_len) +
> -				    sizeof(struct ipv6hdr), 1);
> +			xt_add_counter(&e->counters,
> +					ntohs(ipv6_hdr(skb)->payload_len) +
> +					sizeof(struct ipv6hdr), 1);
> =20
>  			t =3D ip6t_get_target(e);
>  			IP_NF_ASSERT(t->u.kernel.target);
> @@ -901,10 +901,11 @@ translate_table(const char *name,
>  /* Gets counters. */
>  static inline int
>  add_entry_to_counter(const struct ip6t_entry *e,
> +		     int cpu,
>  		     struct xt_counters total[],
>  		     unsigned int *i)
>  {
> -	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
> +	xt_sum_counter(total, cpu, &e->counters);
> =20
>  	(*i)++;
>  	return 0;
> @@ -948,10 +949,11 @@ get_counters(const struct xt_table_info=20
>  			continue;
>  		i =3D 0;
>  		IP6T_ENTRY_ITERATE(t->entries[cpu],
> -				  t->size,
> -				  add_entry_to_counter,
> -				  counters,
> -				  &i);
> +				   t->size,
> +				   add_entry_to_counter,
> +				   cpu,
> +				   counters,
> +				   &i);
>  	}
>  }
> =20
> @@ -1357,8 +1359,7 @@ add_counter_to_entry(struct ip6t_entry *
>  		 (long unsigned int)addme[*i].pcnt,
>  		 (long unsigned int)addme[*i].bcnt);
>  #endif
> -
> -	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
> +	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
> =20
>  	(*i)++;
>  	return 0;
> --- a/net/netfilter/x_tables.c	2009-01-30 08:38:32.949293300 -0800
> +++ b/net/netfilter/x_tables.c	2009-01-30 09:13:27.636792850 -0800
> @@ -577,6 +577,21 @@ int xt_compat_target_to_user(struct xt_e
>  EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
>  #endif
> =20
> +void xt_add_counter(struct xt_counters *c, unsigned b, unsigned p)
> +{
> +	c->bcnt +=3D b;
> +	c->pcnt +=3D p;
> +}
> +EXPORT_SYMBOL_GPL(xt_add_counter);
> +
> +void xt_sum_counter(struct xt_counters *t, int cpu,
> +		    const struct xt_counters *c)
> +{
> +	t->pcnt +=3D c->pcnt;
> +	t->bcnt +=3D c->bcnt;
> +}
> +EXPORT_SYMBOL_GPL(xt_sum_counter);
> +
>  struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  {
>  	struct xt_table_info *newinfo;
>=20

=46irst I wondered if adding out of line xt_add_counter() could slow fi=
rewalls,
I did some testings, with tbench and a small iptables setup (about 16 m=
atched rules per packet)


CPU: Core 2, speed 3000.11 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        symbol name
3166081  12.8996  ipt_do_table
2471426  10.0694  copy_from_user
1016717   4.1424  copy_to_user
902072    3.6753  schedule
687266    2.8001  xt_add_counter
589899    2.4034  tcp_sendmsg
579619    2.3615  tcp_ack
455883    1.8574  tcp_transmit_skb
=20


c044d110 <xt_add_counter>: /* xt_add_counter total: 687266  2.8001 */
 80675  0.3287 :c044d110:       push   %ebp
 15574  0.0635 :c044d111:       mov    %esp,%ebp
     2 8.1e-06 :c044d113:       sub    $0xc,%esp
 39583  0.1613 :c044d116:       mov    %ebx,(%esp)
  4387  0.0179 :c044d119:       mov    %edi,0x8(%esp)
  1187  0.0048 :c044d11d:       mov    %esi,0x4(%esp)
  1601  0.0065 :c044d121:       mov    $0xc068ae4c,%edi
 38881  0.1584 :c044d126:       mov    %fs:0xc0688540,%ebx
  5585  0.0228 :c044d12d:       add    %ebx,%edi
  3910  0.0159 :c044d12f:       incl   (%edi)
133482  0.5438 :c044d131:       xor    %esi,%esi
    32 1.3e-04 :c044d133:       add    %edx,0x8(%eax)
 71181  0.2900 :c044d136:       mov    %ecx,%edx
  7986  0.0325 :c044d138:       adc    %esi,0xc(%eax)
 88695  0.3614 :c044d13b:       xor    %ecx,%ecx
    15 6.1e-05 :c044d13d:       add    %edx,(%eax)
 41496  0.1691 :c044d13f:       adc    %ecx,0x4(%eax)
 52944  0.2157 :c044d142:       incl   (%edi)
 30759  0.1253 :c044d144:       mov    (%esp),%ebx
 20241  0.0825 :c044d147:       mov    0x4(%esp),%esi
  5662  0.0231 :c044d14b:       mov    0x8(%esp),%edi
  2288  0.0093 :c044d14f:       leave
 41100  0.1675 :c044d150:       ret

tbench 8 results here, after all your patches applied :

Throughput 2331 MB/sec 8 procs

And if inlined :

Throughput 2359.06 MB/sec 8 procs

and if we check inlined code/costs we see :

  2597  0.1719 :c048dfee:       mov    -0x64(%ebp),%edx
   182  0.0120 :c048dff1:       movzwl 0x2(%edx),%eax
   524  0.0347 :c048dff5:       mov    %fs:0xc0688540,%ecx
     7 4.6e-04 :c048dffc:       add    -0x70(%ebp),%ecx
  2465  0.1632 :c048dfff:       incl   (%ecx)
  9476  0.6273 :c048e001:       addl   $0x1,0x60(%edi)
 10068  0.6665 :c048e005:       adcl   $0x0,0x64(%edi)
  6543  0.4332 :c048e009:       xor    %edx,%edx
     1 6.6e-05 :c048e00b:       rol    $0x8,%ax
   234  0.0155 :c048e00f:       movzwl %ax,%eax
  2198  0.1455 :c048e012:       add    %eax,0x68(%edi)
    80  0.0053 :c048e015:       adc    %edx,0x6c(%edi)
  2858  0.1892 :c048e018:       incl   (%ecx)


With upcoming work on fast percpu accesses, we might in the future see =
following code:
(no need for registers to compute address of variable)

      mov    -0x64(%ebp),%edx
      movzwl 0x2(%edx),%eax
      incl   %fs:xt_counter_sequence
      addl   $0x1,0x60(%edi)
      adcl   $0x0,0x64(%edi)
      xor    %edx,%edx
      rol    $0x8,%ax
      movzwl %ax,%eax
      add    %eax,0x68(%edi)
      adc    %edx,0x6c(%edi)
      incl   %fs:xt_counter_sequence


