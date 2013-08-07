From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH v4 1/3] net: igmp: Reduce Unsolicited report interval to 1s when using IGMPv3
Date: Wed, 7 Aug 2013 09:43:20 -0400
Message-ID: <20130807134320.GL8043@kvack.org>
References: <20130731063442.GA10498@order.stressinduktion.org> <1375812195-6575-1-git-send-email-william.manley@youview.com> <1375812195-6575-2-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net, hannes@stressinduktion.org
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:36116 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933144Ab3HGNnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 09:43:21 -0400
Content-Disposition: inline
In-Reply-To: <1375812195-6575-2-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 07:03:13PM +0100, William Manley wrote:
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

Acked-by: Benjamin LaHaise <bcrl@kvack.org>

		-ben

> ---
>  net/ipv4/igmp.c |   16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index d8c2327..9f0aaea 100644
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
> +	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
> +		return IGMP_V2_Unsolicited_Report_Interval;
> +	else /* v3 */
> +		return IGMP_V3_Unsolicited_Report_Interval;
> +}
> +
>  static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im);
>  static void igmpv3_del_delrec(struct in_device *in_dev, __be32 multiaddr);
>  static void igmpv3_clear_delrec(struct in_device *in_dev);
> @@ -719,7 +728,8 @@ static void igmp_ifc_timer_expire(unsigned long data)
>  	igmpv3_send_cr(in_dev);
>  	if (in_dev->mr_ifc_count) {
>  		in_dev->mr_ifc_count--;
> -		igmp_ifc_start_timer(in_dev, IGMP_Unsolicited_Report_Interval);
> +		igmp_ifc_start_timer(in_dev,
> +				     unsolicited_report_interval(in_dev));
>  	}
>  	__in_dev_put(in_dev);
>  }
> @@ -744,7 +754,7 @@ static void igmp_timer_expire(unsigned long data)
>  
>  	if (im->unsolicit_count) {
>  		im->unsolicit_count--;
> -		igmp_start_timer(im, IGMP_Unsolicited_Report_Interval);
> +		igmp_start_timer(im, unsolicited_report_interval(in_dev));
>  	}
>  	im->reporter = 1;
>  	spin_unlock(&im->lock);
> -- 
> 1.7.10.4

-- 
"Thought is the essence of where you are now."
