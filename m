From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 1/1] net: ipv4: Refine the
 ipv4_default_advmss
Date: Tue, 11 Apr 2017 20:57:24 -0700
Message-ID: <1491969444.17839.30.camel@perches.com>
References: <1491964333-69989-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Gao Feng <fgao@ikuai8.com>
To: gfree.wind@foxmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0121.hostedemail.com ([216.40.44.121]:60213 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751992AbdDLD5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 23:57:30 -0400
In-Reply-To: <1491964333-69989-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 10:32 +0800, gfree.wind@foxmail.com wrote:
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c

more trivia:

> @@ -1250,14 +1250,11 @@ static void set_class_tag(struct rtable *rt, u32 tag)
>  
>  static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
>  {
> -	unsigned int advmss = dst_metric_raw(dst, RTAX_ADVMSS);
> +	unsigned int header_size = sizeof(struct tcphdr) + sizeof(struct iphdr);
> +	unsigned int advmss = max_t(unsigned int, dst->dev->mtu - header_size,
> +				    ip_rt_min_advmss);
>  
> -	if (advmss == 0) {
> -		advmss = max_t(unsigned int, dst->dev->mtu - 40,
> -			       ip_rt_min_advmss);
> -		if (advmss > 65535 - 40)
> -			advmss = 65535 - 40;
> -	}
> +	advmss = min(advmss, IPV4_MAX_PMTU - header_size);
>  	return advmss;
>  }

This would probably be simpler to read as:

	return min(advmss, IPV4_MAX_PMTU - header_size);

though it's almost certain that the compiler emits identical
object code.
