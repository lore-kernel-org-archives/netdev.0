From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [UDP(-Lite)]: consolidate v4 and v6 get|setsockopt code
Date: Mon, 27 Nov 2006 09:31:34 -0800 (PST)
Message-ID: <20061127.093134.45504470.davem@davemloft.net>
References: <200611271044.34091@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:20879
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1754447AbWK0Rbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 12:31:32 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611271044.34091@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 10:44:33 +0000

> [UDP(-Lite)]: consolidate v4 and v6 get|setsockopt code
> 
> This is for 2.6.20.
> 
> This patch consolidates set/getsockopt code between UDP(-Lite) v4 and 6. The 
> justification is that UDP(-Lite) is a transport-layer protocol and therefore
> the socket option code (at least in theory) should be AF-independent. 
> 
> Furthermore, there is the following code reduplication:
>  * do_udp{,v6}_getsockopt is 100% identical between v4 and v6
>  * do_udp{,v6}_setsockopt is identical up to the following differerence
> 	--v4 in contrast to v4 additionally allows the experimental encapsulation
>           types  UDP_ENCAP_ESPINUDP and UDP_ENCAP_ESPINUDP_NON_IKE
> 	--the remainder is identical between v4 and v6
>    I believe that this difference is of little relevance. 
> 
> The advantages in not duplicating twice almost completely identical code.
> 
> The patch further simplifies the interface of udp{,v6}_push_pending_frames,
> since for the second argument (struct udp_sock *up) it always holds that
> up = udp_sk(sk); where sk is the first function argument.
> 
> 
> Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>

Applied, except that I fixed up the extraneous spaces here:

> @@ -1366,7 +1368,8 @@ int udp_setsockopt(struct sock *sk, int 
>  		   char __user *optval, int optlen)
>  {
>  	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
> -		return do_udp_setsockopt(sk, level, optname, optval, optlen);
> +		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
> +					  udp_push_pending_frames           );
>  	return ip_setsockopt(sk, level, optname, optval, optlen);
>  }
>  
> @@ -1375,13 +1378,14 @@ int compat_udp_setsockopt(struct sock *s
>  			  char __user *optval, int optlen)
>  {
>  	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
> -		return do_udp_setsockopt(sk, level, optname, optval, optlen);
> +		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
> +					  udp_push_pending_frames           );
>  	return compat_ip_setsockopt(sk, level, optname, optval, optlen);
>  }
>  #endif

and here:

>  int udpv6_setsockopt(struct sock *sk, int level, int optname,
>  		     char __user *optval, int optlen)
>  {
>  	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
> -		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
> +		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
> +					  udp_v6_push_pending_frames         );
>  	return ipv6_setsockopt(sk, level, optname, optval, optlen);
>  }
>  
> @@ -919,58 +860,17 @@ int compat_udpv6_setsockopt(struct sock 
>  			    char __user *optval, int optlen)
>  {
>  	if (level == SOL_UDP  ||  level == SOL_UDPLITE)
> -		return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
> +		return udp_lib_setsockopt(sk, level, optname, optval, optlen,
> +					  udp_v6_push_pending_frames         );
>  	return compat_ipv6_setsockopt(sk, level, optname, optval, optlen);
>  }
>  #endif

Specifically, the space between the push_pending_frames final argument
passed and the closing parenthesis was removed.  Why did you put
that there?  It looks fugly :)
