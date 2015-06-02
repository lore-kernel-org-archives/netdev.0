From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 2/3] ipv4: storing and retrieval of per-nexthop
 encap
Date: Tue, 2 Jun 2015 17:35:18 +0100
Message-ID: <556DDB46.9010701@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <1433177175-16775-3-git-send-email-rshearma@brocade.com> <556DD368.8070806@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	"Vivek Venkatraman" <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:54887 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752625AbbFBQgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 12:36:05 -0400
In-Reply-To: <556DD368.8070806@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 17:01, roopa wrote:
> On 6/1/15, 9:46 AM, Robert Shearman wrote:
>> Parse RTA_ENCAP attribute for one path and multipath routes. The encap
>> length is stored in a newly added field to fib_nh, nh_encap_len,
>> although this is added to a padding hole in the structure so that it
>> doesn't increase the size at all. The encap data itself is stored at
>> the end of the array of nexthops. Whilst this means that retrieval
>> isn't optimal, especially if there are multiple nexthops, this avoids
>> the memory cost of an extra pointer, as well as any potential change
>> to the cache or instruction layout that could cause a performance
>> impact.
>>
>> Currently, the dst structure allocated to represent the destination of
>> the packet and used for retrieving the encap by the encap-type
>> interface has been grown through the addition of the rt_encap_len and
>> rt_encap fields. This isn't desirable and could be fixed by defining a
>> new destination type with operations copied from the normal case,
>> other than the addition of the get_encap operation.
>>
>> Signed-off-by: Robert Shearman <rshearma@brocade.com>
...
>> @@ -434,6 +445,83 @@ static int fib_detect_death(struct fib_info *fi,
>> int order,
>>       return 1;
>>   }
>> +static int fib_total_encap(struct fib_config *cfg)
>> +{
>> +    struct net *net = cfg->fc_nlinfo.nl_net;
>> +    int total_encap_len = 0;
>> +
>> +    if (cfg->fc_mp) {
>> +        int remaining = cfg->fc_mp_len;
>> +        struct rtnexthop *rtnh = cfg->fc_mp;
>> +
>> +        while (rtnh_ok(rtnh, remaining)) {
>> +            struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
>> +            int attrlen;
>> +
>> +            attrlen = rtnh_attrlen(rtnh);
>> +            nla = nla_find(attrs, attrlen, RTA_ENCAP);
>> +            if (nla) {
>> +                struct net_device *dev;
>> +                int len;
>> +
>> +                dev = __dev_get_by_index(net,
>> +                             rtnh->rtnh_ifindex);
>> +                if (!dev)
>> +                    return -EINVAL;
>> +
>> +                /* Determine space required */
>> +                len = rtnl_parse_encap(dev, nla, NULL);
>> +                if (len < 0)
>> +                    return len;
>> +
>> +                total_encap_len += len;
>> +            }
>> +
>> +            rtnh = rtnh_next(rtnh, &remaining);
>> +        }
>> +    } else {
>> +        if (cfg->fc_encap) {
>> +            struct net_device *dev;
>> +            int len;
>> +
>> +            dev = __dev_get_by_index(net, cfg->fc_oif);
>> +            if (!dev)
>> +                return -EINVAL;
>> +
>> +            /* Determine space required */
>> +            len = rtnl_parse_encap(dev, cfg->fc_encap, NULL);
>> +            if (len < 0)
>> +                return len;
>> +
>> +            total_encap_len += len;
>> +        }
>> +    }
>> +
>> +    return total_encap_len;
>> +}
> we could avoid parsing and finding this device twice, if fib_nh just
> held a pointer to the encap_info
> (or tunnel info) ?. And the encap_info/tun_info could be refcounted and
> shared between
> nexthops ?. In my implementation i have just a pointer to parsed encap
> state
> in fib_nh

Right - I took the approach here to avoid any extra memory use if encap 
isn't in use for the nexthop/route, and to avoid any potential 
performance penalty caused by extra cache misses. It would certainly 
make things simpler if those weren't concerns. I'd appreciate input from 
the community on this.

>> @@ -1403,6 +1418,15 @@ static void rt_set_nexthop(struct rtable *rt,
>> __be32 daddr,
>>   #ifdef CONFIG_IP_ROUTE_CLASSID
>>           rt->dst.tclassid = nh->nh_tclassid;
>>   #endif
>> +
>> +        nh_encap = fib_get_nh_encap(fi, nh);
>> +        if (unlikely(nh_encap)) {
>> +            rt->rt_encap = kmemdup(nh_encap, nh->nh_encap_len,
>> +                           GFP_KERNEL);
>> +            if (rt->rt_encap)
>> +                rt->rt_encap_len = nh->nh_encap_len;
>> +        }
>> +
>
> And..., you could make the rtable point to the same encap info.

Ack.

Thanks,
Rob
