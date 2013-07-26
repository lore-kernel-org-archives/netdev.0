From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Fri, 26 Jul 2013 18:32:39 +0200
Message-ID: <20130726163239.GE3890@order.stressinduktion.org>
References: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com> <1374754445-5608-1-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41512 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683Ab3GZQck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 12:32:40 -0400
Content-Disposition: inline
In-Reply-To: <1374754445-5608-1-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 01:14:04PM +0100, William Manley wrote:
> If an IGMP join packet is lost you will not receive data sent to the
> multicast group so if no data arrives from that multicast group in a
> period of time after the IGMP join a second IGMP join will be sent.  The
> delay between joins is the "IGMP Unsolicited Report Interval".
> 
> Previously this value was hard coded to be chosen randomly between 0-10s.
> This can be too long for some use-cases, such as IPTV as it can cause
> channel change to be slow in the presence of packet loss.
> 
> The value 10s has come from IGMPv2 RFC2236, which was reduced to 1s in
> IGMPv3 RFC3376.  This patch makes the kernel use the 1s value from the
> later RFC if we are operating in IGMPv3 mode.  IGMPv2 behaviour is
> unaffected.
> 
> Tested with Wireshark and a simple program to join a (non-existent)
> multicast group.  The distribution of timings for the second join differ
> based upon setting /proc/sys/net/ipv4/conf/eth0/force_igmp_version.
> 
> Signed-off-by: William Manley <william.manley@youview.com>
> ---
>  net/ipv4/igmp.c |   16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index d8c2327..12ffc2b 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -113,7 +113,8 @@
>  
>  #define IGMP_V1_Router_Present_Timeout		(400*HZ)
>  #define IGMP_V2_Router_Present_Timeout		(400*HZ)
> -#define IGMP_Unsolicited_Report_Interval	(10*HZ)
> +#define IGMP_V2_Unsolicited_Report_Interval	(10*HZ)
> +#define IGMP_V3_Unsolicited_Report_Interval	(1*HZ)
>  #define IGMP_Query_Response_Interval		(10*HZ)
>  #define IGMP_Unsolicited_Report_Count		2
>  
> @@ -138,6 +139,14 @@
>  	 ((in_dev)->mr_v2_seen && \
>  	  time_before(jiffies, (in_dev)->mr_v2_seen)))
>  
> +static int unsolicited_report_interval(struct in_device *in_dev)
> +{
> +	if (IGMP_V2_SEEN(in_dev))
> +		return IGMP_V2_Unsolicited_Report_Interval;
> +	else /* v3 */
> +		return IGMP_V3_Unsolicited_Report_Interval;
> +}

if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))

Otherwise I am fine with it.

Thanks,

  Hannes
