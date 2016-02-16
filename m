From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 16 Feb 2016 08:16:47 -0700
Message-ID: <56C33D5F.2060005@cumulusnetworks.com>
References: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
 <56C2E1BD.30006@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36657 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbcBPPRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 10:17:23 -0500
Received: by mail-ob0-f171.google.com with SMTP id gc3so161555453obb.3
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 07:17:22 -0800 (PST)
In-Reply-To: <56C2E1BD.30006@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/16 1:45 AM, YOSHIFUJI Hideaki wrote:
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 24ce97f42d35..7ddbbb67f0db 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -1563,6 +1563,12 @@ temp_prefered_lft - INTEGER
>>   	Preferred lifetime (in seconds) for temporary addresses.
>>   	Default: 86400 (1 day)
>>   
>> +keep_addr_on_down - BOOLEAN
>> +	Keep all IPv6 addresses on an interface down event. If set static
>> +	global addresses with no expiration time are not flushed.
>> +
>> +	Default: disabled
>> +
> 
> How about this:
>     1: enabled
>     0: system default
>    -1: disabled
> so that an iterface can override system-wide config?

It is my understanding that the 'all' settings override the individual
interface settings. From Documentation/networking/ip-sysctl.txt +1346:

conf/all/*:
        Change all the interface-specific settings.


-----8<-----


>> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
>> index 1c8b6820b694..01ba6a286a4b 100644
>> --- a/include/net/if_inet6.h
>> +++ b/include/net/if_inet6.h
>> @@ -72,6 +72,7 @@ struct inet6_ifaddr {
>>   	int			regen_count;
>>   
>>   	bool			tokenized;
>> +	bool			user_managed;
> 
> Can't we use IFA_F_PERMANENT?

I think so. Will fix.


-----8<-----

>> @@ -3356,7 +3413,9 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>>   {
>>   	struct net *net = dev_net(dev);
>>   	struct inet6_dev *idev;
>> -	struct inet6_ifaddr *ifa;
>> +	struct inet6_ifaddr *ifa, *tmp;
>> +	struct list_head del_list;
>> +	int keep_addr;
>>   	int state, i;
>>   
>>   	ASSERT_RTNL();
>> @@ -3383,6 +3442,10 @@ static int addrconf_ifdown(struct net_device *dev, int how)
>>   
>>   	}
>>   
>> +	keep_addr = net->ipv6.devconf_all->keep_addr_on_down;
>> +	if (!keep_addr)
>> +		keep_addr = idev->cnf.keep_addr_on_down;
>> +
>>   	/* Step 2: clear hash table */
>>   	for (i = 0; i < IN6_ADDR_HSIZE; i++) {
>>   		struct hlist_head *h = &inet6_addr_lst[i];

So what I have here is if the system-wide setting says keep the address
it is kept. Else if the individual interface setting is enabled the
address is kept.
