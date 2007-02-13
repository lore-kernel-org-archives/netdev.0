From: Pete Clements <clem@clem.clem-digital.net>
Subject: Re: 2.6.20-git8 fails compile -- net/built-in.o __ipv6_addr_type
Date: Mon, 12 Feb 2007 22:13:07 -0500 (EST)
Message-ID: <200702130313.l1D3D7hI014740@clem.clem-digital.net>
References: <20070213.115510.21486123.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clem@clem.clem-digital.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki /
	=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
Return-path: <netdev-owner@vger.kernel.org>
Received: from clem.clem-digital.net ([68.16.168.10]:56129 "EHLO
	clem.clem-digital.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030628AbXBMDNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 22:13:14 -0500
In-Reply-To: <20070213.115510.21486123.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patched, compiles.
--
Pete Clements

Quoting YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
  > 
  > Ah, this is because of new ipv6 support in sunrpc code.
  > Enable it if it is statically compiled.
  > 
  > Alternatively, we could 
  > - export __ipv6_addr_type in new net/ipv6/addrconf_core.c
  > or
  > - introduce tiny inline for chcking if the address is link-local.
  > 
  > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  > 
  > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
  > index 63ae947..27dcb31 100644
  > --- a/net/sunrpc/svcsock.c
  > +++ b/net/sunrpc/svcsock.c
  > @@ -107,12 +107,12 @@ static inline void svc_reclassify_socket
  >  		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
  >  		    &svc_slock_key[0], "sk_lock-AF_INET-NFSD", &svc_key[0]);
  >  		break;
  > -
  > +#ifdef CONFIG_IPV6
  >  	case AF_INET6:
  >  		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFSD",
  >  		    &svc_slock_key[1], "sk_lock-AF_INET6-NFSD", &svc_key[1]);
  >  		break;
  > -
  > +#endif
  >  	default:
  >  		BUG();
  >  	}
  > @@ -131,7 +131,7 @@ static char *__svc_print_addr(struct soc
  >  			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
  >  			htons(((struct sockaddr_in *) addr)->sin_port));
  >  		break;
  > -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
  > +#if defined(CONFIG_IPV6)
  >  	case AF_INET6:
  >  		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
  >  			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
  > @@ -449,7 +449,7 @@ svc_wake_up(struct svc_serv *serv)
  >  
  >  union svc_pktinfo_u {
  >  	struct in_pktinfo pkti;
  > -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
  > +#if defined(CONFIG_IPV6)
  >  	struct in6_pktinfo pkti6;
  >  #endif
  >  };
  > @@ -467,7 +467,7 @@ static void svc_set_cmsg_data(struct svc
  >  			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
  >  		}
  >  		break;
  > -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
  > +#if defined(CONFIG_IPV6)
  >  	case AF_INET6: {
  >  			struct in6_pktinfo *pki = CMSG_DATA(cmh);
  >  
  > @@ -737,7 +737,7 @@ static void svc_udp_get_sender_address(s
  >  			rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
  >  		}
  >  		break;
  > -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
  > +#if defined(CONFIG_IPV6)
  >  	case AF_INET6: {
  >  		/* this is derived from net/ipv6/udp.c:udpv6_recvmesg */
  >  			struct sockaddr_in6 *sin6 = svc_addr_in6(rqstp);
  > @@ -977,7 +977,7 @@ static inline int svc_port_is_privileged
  >  	case AF_INET:
  >  		return ntohs(((struct sockaddr_in *)sin)->sin_port)
  >  			< PROT_SOCK;
  > -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
  > +#if defined(CONFIG_IPV6)
  >  	case AF_INET6:
  >  		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
  >  			< PROT_SOCK;
  > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
  > index 49cabff..877b52b 100644
  > --- a/net/sunrpc/xprtsock.c
  > +++ b/net/sunrpc/xprtsock.c
  > @@ -1187,11 +1187,12 @@ static inline void xs_reclassify_socket(
  >  			&xs_slock_key[0], "sk_lock-AF_INET-NFS", &xs_key[0]);
  >  		break;
  >  
  > +#ifdef CONFIG_IPV6
  >  	case AF_INET6:
  >  		sock_lock_init_class_and_name(sk, "slock-AF_INET6-NFS",
  >  			&xs_slock_key[1], "sk_lock-AF_INET6-NFS", &xs_key[1]);
  >  		break;
  > -
  > +#endif
  >  	default:
  >  		BUG();
  >  	}
  > 
  > 
  > -- 
  > YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
  > GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
  > 
