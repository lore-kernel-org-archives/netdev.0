From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Fri, 16 Sep 2016 13:38:46 -0600
Message-ID: <0e4071d6-a3cc-37a7-6a32-2169e0e3b305@cumulusnetworks.com>
References: <20160916125531.3486-1-vincent@bernat.im>
 <adff2e07-75e1-d44c-4799-0920ffcd2622@cumulusnetworks.com>
 <m3twdfk665.fsf@neo.luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34172 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934583AbcIPTit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 15:38:49 -0400
Received: by mail-pf0-f178.google.com with SMTP id p64so30160418pfb.1
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 12:38:49 -0700 (PDT)
In-Reply-To: <m3twdfk665.fsf@neo.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/16/16 1:15 PM, Vincent Bernat wrote:
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index ad4a7ff301fc..48bae2ee2e18 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1991,9 +1991,19 @@ static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
>>                         if (!(gwa_type & IPV6_ADDR_UNICAST))
>>                                 goto out;
>>
>> -                       if (cfg->fc_table)
>> +                       if (cfg->fc_table) {
>>                                 grt = ip6_nh_lookup_table(net, cfg, gw_addr);
>>
>> +                               /* a nexthop lookup can not go through a gw.
>> +                                * if this happens on a table based lookup
>> +                                * then fallback to a full lookup
>> +                                */
>> +                               if (grt && grt->rt6i_flags & RTF_GATEWAY) {
>> +                                       ip6_rt_put(grt);
>> +                                       grt = NULL;
>> +                               }
>> +                       }
>> +
>>                         if (!grt)
>>                                 grt = rt6_lookup(net, gw_addr, NULL,
>>                                                  cfg->fc_ifindex, 1);
> 
> OK. Should the dev check be dismissed or do we add "dev && dev !=
> grt->dst.dev" just as a safety net (this would be a convulated setup,
> but the correct direct route could be in an ip rule with higher priority
> while the one in this table is incorrect)?
> 

yes. So the validity check becomes:

	grt = ip6_nh_lookup_table(net, cfg, gw_addr);
	if (grt) {
		if (grt->rt6i_flags & RTF_GATEWAY ||
		    dev && dev != grt->dst.dev) {
			ip6_rt_put(grt);
			grt = NULL;            <---- causes the full rt6_lookup
		}
	}
