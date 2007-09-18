From: mel@skynet.ie (Mel Gorman)
Subject: Re: 2.6.23-rc6-mm1: Build failure on ppc64 drivers/net/ehea/ehea_main.c
Date: Tue, 18 Sep 2007 17:41:26 +0100
Message-ID: <20070918164126.GB1804@skynet.ie>
References: <20070918011841.2381bd93.akpm@linux-foundation.org> <20070918162039.GA1804@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-kernel@vger.kernel.org, themann@de.ibm.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gir.skynet.ie ([193.1.99.77]:55388 "EHLO gir.skynet.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759142AbXIRQl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 12:41:28 -0400
Content-Disposition: inline
In-Reply-To: <20070918162039.GA1804@skynet.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My apologies for the repost, this should have gone to netdev and Dave Miller
as well.

On (18/09/07 17:20), Mel Gorman didst pronounce:
> Hi Andrew,
> 
> PPC64 failed to build with the driver drivers/net/ehea with the
> following error
> 
>   CC [M]  drivers/net/ehea/ehea_main.o
> drivers/net/ehea/ehea_main.c: In function `ehea_open':
> drivers/net/ehea/ehea_main.c:2322: error: implicit declaration of function `port_napi_enable'
> drivers/net/ehea/ehea_main.c: At top level:
> drivers/net/ehea/ehea_main.c:2340: error: conflicting types for 'port_napi_enable'
> drivers/net/ehea/ehea_main.c:2322: error: previous implicit declaration of 'port_napi_enable' was here
> make[1]: *** [drivers/net/ehea/ehea_main.o] Error 1
> 
> It's buried in git-net.patch and I've cc'd a potential owner based simply
> on the mention of EHEA in a leader. I've included a candidate fix for the
> error. It seems to be a simple case of port_napi_enable being defined in
> the wrong place.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> ---
>  ehea_main.c |   32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc6-mm1-005_fix-rpadlpar_sysfs/drivers/net/ehea/ehea_main.c linux-2.6.23-rc6-mm1-010_fix_ehea_main/drivers/net/ehea/ehea_main.c
> --- linux-2.6.23-rc6-mm1-005_fix-rpadlpar_sysfs/drivers/net/ehea/ehea_main.c	2007-09-18 11:29:28.000000000 +0100
> +++ linux-2.6.23-rc6-mm1-010_fix_ehea_main/drivers/net/ehea/ehea_main.c	2007-09-18 17:15:27.000000000 +0100
> @@ -2307,6 +2307,22 @@ out:
>  	return ret;
>  }
>  
> +static void port_napi_disable(struct ehea_port *port)
> +{
> +	int i;
> +
> +	for (i = 0; i < port->num_def_qps; i++)
> +		napi_disable(&port->port_res[i].napi);
> +}
> +
> +static void port_napi_enable(struct ehea_port *port)
> +{
> +	int i;
> +
> +	for (i = 0; i < port->num_def_qps; i++)
> +		napi_enable(&port->port_res[i].napi);
> +}
> +
>  static int ehea_open(struct net_device *dev)
>  {
>  	int ret;
> @@ -2328,22 +2344,6 @@ static int ehea_open(struct net_device *
>  	return ret;
>  }
>  
> -static void port_napi_disable(struct ehea_port *port)
> -{
> -	int i;
> -
> -	for (i = 0; i < port->num_def_qps; i++)
> -		napi_disable(&port->port_res[i].napi);
> -}
> -
> -static void port_napi_enable(struct ehea_port *port)
> -{
> -	int i;
> -
> -	for (i = 0; i < port->num_def_qps; i++)
> -		napi_enable(&port->port_res[i].napi);
> -}
> -
>  static int ehea_down(struct net_device *dev)
>  {
>  	int ret;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
