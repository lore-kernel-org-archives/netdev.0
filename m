From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v3] route: do not cache fib route info on local routes
 with oif
Date: Fri, 8 Apr 2016 23:35:58 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1604082328460.2124@ja.home.ssi.bg>
References: <5706B250.1060303@windriver.com> <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg> <5707C950.6060806@windriver.com> <alpine.LFD.2.11.1604082207330.2124@ja.home.ssi.bg> <57080F7E.809@windriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35234 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753927AbcDHUgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 16:36:08 -0400
In-Reply-To: <57080F7E.809@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 8 Apr 2016, Chris Friesen wrote:

> For local routes that require a particular output interface we do not want to
> cache the result.  Caching the result causes incorrect behaviour when there are
> multiple source addresses on the interface.  The end result being that if the
> intended recipient is waiting on that interface for the packet he won't receive
> it because it will be delivered on the loopback interface and the IP_PKTINFO
> ipi_ifindex will be set to the loopback interface as well.
> 
> This can be tested by running a program such as "dhcp_release" which attempts
> to inject a packet on a particular interface so that it is received by another
> program on the same board.  The receiving process should see an IP_PKTINFO
> ipi_ifndex value of the source interface (e.g., eth1) instead of the loopback
> interface (e.g., lo).  The packet will still appear on the loopback interface
> in tcpdump but the important aspect is that the CMSG info is correct.
> 
> Sample dhcp_release command line:
> 
>    dhcp_release eth1 192.168.204.222 02:11:33:22:44:66
> 
> Signed-off-by: Allain Legacy <allain.legacy@windriver.com>
> Signed off-by: Chris Friesen <chris.friesen@windriver.com>

	Sorry, forgot to mention that patch has other errors:

scripts/checkpatch.pl --strict /tmp/file3.patch

	Its recommendations:

- prefer a maximum 75 chars per line
- code indent should use tabs where possible

> ---
>  net/ipv4/route.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 02c6229..437a377 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2045,6 +2045,18 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
>  		 */
>  		if (fi && res->prefixlen < 4)
>  			fi = NULL;
> +	} else if ((type == RTN_LOCAL) && (orig_oif != 0) &&
> +		   (orig_oif != dev_out->ifindex)) {
> +		/* For local routes that require a particular output interface
> +                 * we do not want to cache the result.  Caching the result
> +                 * causes incorrect behaviour when there are multiple source
> +                 * addresses on the interface, the end result being that if the
> +                 * intended recipient is waiting on that interface for the
> +                 * packet he won't receive it because it will be delivered on
> +                 * the loopback interface and the IP_PKTINFO ipi_ifindex will
> +                 * be set to the loopback interface as well.
> +		 */
> +		fi = NULL;
>  	}
>  
>  	fnhe = NULL;

Regards
