From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v4 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Sun, 3 Apr 2016 17:41:45 -0600
Message-ID: <5701AA39.5010002@cumulusnetworks.com>
References: <1459711147-18825-1-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1604040039020.1534@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37946 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbcDCXlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 19:41:51 -0400
Received: by mail-ig0-f182.google.com with SMTP id ui10so55788620igc.1
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 16:41:51 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1604040039020.1534@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/16 3:57 PM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Sun, 3 Apr 2016, David Ahern wrote:
>
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -63,6 +63,16 @@ fwmark_reflect - BOOLEAN
>>   	fwmark of the packet they are replying to.
>>   	Default: 0
>>
>> +fib_multipath_use_neigh - BOOLEAN
>> +	Use status of existing neighbor entry when determining nexthop for
>> +	multipath routes. If disabled neighbor information is not used and
>
> 	Comma from v3 is removed?
>
>> +	packets could be directed to a failed nexthop. Only valid for kernels
>
>> --- a/net/ipv4/fib_semantics.c
>> +++ b/net/ipv4/fib_semantics.c
>>   void fib_select_multipath(struct fib_result *res, int hash)
>>   {
>>   	struct fib_info *fi = res->fi;
>> +	struct net *net = fi->fib_net;
>> +	bool first = false;
>>
>>   	for_nexthops(fi) {
>>   		if (hash > atomic_read(&nh->nh_upper_bound))
>>   			continue;
>>
>> -		res->nh_sel = nhsel;
>> -		return;
>> +		if (!net->ipv4.sysctl_fib_multipath_use_neigh ||
>> +		    fib_good_nh(nh)) {
>> +			res->nh_sel = nhsel;
>> +			return;
>> +		}
>> +		if (!first) {
>> +			res->nh_sel = nhsel;
>> +			first = true;
>> +		}
>>   	} endfor_nexthops(fi);
>>
>>   	/* Race condition: route has just become dead. */
>
> 	The 'res->nh_sel = 0;' that is here should be
> removed because it invalidates the above assignment.
>

right. will send a v5
