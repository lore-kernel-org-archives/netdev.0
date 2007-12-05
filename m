From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 05 Dec 2007 10:36:40 +0100
Message-ID: <47567128.2060008@cosmosbay.com>
References: <20071204125844.GA2750@gondor.apana.org.au> <20071204130109.GA3098@gondor.apana.org.au> <47560215.6050104@cn.fujitsu.com> <20071205021559.GA27707@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54574 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbXLEJhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:37:45 -0500
In-Reply-To: <20071205021559.GA27707@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> On Wed, Dec 05, 2007 at 09:42:45AM +0800, Wang Chen wrote:
>> I apologize for my miss in previous patch.
>>
>> Herbert, don't you think the udp6inDatagrams should be counted too
>> in xprtsock?
>=20
> Good point.  Here's a better version.
>=20
> [UDP]: Restore missing inDatagrams increments
>    =20
> The previous move of the the UDP inDatagrams counter caused the
> counting of encapsulated packets, SUNRPC data (as opposed to call)
> packets and RXRPC packets to go missing.
>    =20
> This patch restores all of these.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index e90f962..a84f3f6 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -164,15 +164,6 @@ DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6ms=
g_statistics);
>  #define ICMP6MSGIN_INC_STATS_USER(idev, field) \
>  	_DEVINC(icmpv6msg, _USER, idev, field)
> =20
> -DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
> -DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
> -#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
> -	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);       =
  \
> -	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
> -#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
> -	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);     =
    \
> -	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
> -
>  struct ip6_ra_chain
>  {
>  	struct ip6_ra_chain	*next;
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 98755eb..87170bb 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -139,6 +139,12 @@ extern int 	udp_lib_setsockopt(struct sock *sk, =
int level, int optname,
>  				   int (*push_pending_frames)(struct sock *));
> =20
>  DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
> +DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
> +
> +/* UDP-Lite does not have a standardized MIB yet, so we inherit from=
 UDP */
> +DECLARE_SNMP_STAT(struct udp_mib, udplite_statistics);
> +DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
> +
>  /*
>   * 	SNMP statistics for UDP and UDP-Lite
>   */
> @@ -149,6 +155,21 @@ DECLARE_SNMP_STAT(struct udp_mib, udp_statistics=
);
>  	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);      =
   \
>  	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
> =20
> +#define UDP6_INC_STATS_BH(field, is_udplite) 			      do  {  \
> +	if (is_udplite) SNMP_INC_STATS_BH(udplite_stats_in6, field);       =
  \
> +	else		SNMP_INC_STATS_BH(udp_stats_in6, field);    } while(0)
> +#define UDP6_INC_STATS_USER(field, is_udplite)			       do {    \
> +	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);     =
    \
> +	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
> +
> +#define UDPX_INC_STATS_BH(sk, field) \
> +	do { \
> +		if ((sk)->sk_family =3D=3D AF_INET) \
> +			UDP_INC_STATS_BH(field, 0); \
> +		else \
> +			UDP6_INC_STATS_BH(field, 0); \
> +	} while (0);
> +

Hum, what happens if I have in my .config file :

CONFIG_IPV6=3Dn

I suggest something like

#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
# define UDPX_INC_STATS_BH(sk, field) \
	do { \
		if ((sk)->sk_family =3D=3D AF_INET) \
			UDP_INC_STATS_BH(field, 0); \
		else \
			UDP6_INC_STATS_BH(field, 0); \
	} while (0);
#else
# define UDPX_INC_STATS_BH(sk, field) \
			UDP_INC_STATS_BH(field, 0);
#endif




