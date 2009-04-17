From: Yuta sugiura <ysugiura@miraclelinux.com>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Fri, 17 Apr 2009 12:44:13 +0900
Message-ID: <49E7FB0D.3040100@miraclelinux.com>
References: <49E710E1.3060209@miraclelinux.com>	<20090416.043800.171462037.davem@davemloft.net>	<20090416083031.1cc24489@nehalam>	<m2y6u07dh3.fsf@igel.home> <20090416102731.459f9558@nehalam>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090901070002070704060602"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Andreas Schwab <schwab@linux-m68k.org>,
	David Miller <davem@davemloft.net>, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:42606 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbZDQDm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 23:42:27 -0400
In-Reply-To: <20090416102731.459f9558@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090901070002070704060602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Thank you for respons to my e-mail.
I read net-snmp's patch as reference.
How about this method?

Stephen Hemminger wrote:
> On Thu, 16 Apr 2009 18:47:04 +0200
> Andreas Schwab <schwab@linux-m68k.org> wrote:
>
>   
>> Stephen Hemminger <shemminger@vyatta.com> writes:
>>
>>     
>>> On Thu, 16 Apr 2009 04:38:00 -0700 (PDT)
>>> David Miller <davem@davemloft.net> wrote:
>>>
>>>       
>>>> From: Yuta sugiura <ysugiura@miraclelinux.com>
>>>> Date: Thu, 16 Apr 2009 20:05:05 +0900
>>>>
>>>>         
>>>>> Hi,
>>>>> I have a suggestion about /proc/net/IPv6_route format.
>>>>> In rt6_info_route(), interface name is treated as a maximum 8
>>>>> characters.
>>>>> But the type of (struct rt6_inf *)->u.dst.dev->name is char[IFNAMESIZ=
>>>>> 16]
>>>>> so, I think that it should change "%8s" to "%16s".
>>>>>           
>>>> Isn't there a way to pass the field length as a paramenter
>>>> to formatting functions?  Then we can just pass in
>>>> IFNAMESIZE as that parameter.
>>>>         
>>> 	seq_printf(m, " %08x %08x %08x %08x %*s\n"
>>>                    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
>>>  		   rt->u.dst.__use, rt->rt6i_flags,
>>>                    IFNAMESIZE, 
>>>  		   rt->rt6i_dev ? rt->rt6i_dev->name : "")
>>>       
>> Actually since it is the last item on the line a field width does not
>> make much sense, and omitting it would print the name left justified.
>>
>> (And RT6_INFO_LEN is not used any more.)
>>
>> Andreas.
>>
>>     
>
> The issue is what happens if name is not null terminated. in this case
> I bet the kernel already handles that.
>
>   


--------------090901070002070704060602
Content-Type: text/plain;
 name="ipv6_route_ifnamesiz2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6_route_ifnamesiz2.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1394ddb..a532dda 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2434,7 +2434,8 @@ static int ip6_route_dev_notify(struct notifier_block *this,
 
 #ifdef CONFIG_PROC_FS
 
-#define RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 40 + 5 + 1)
+#define RT6_INFO_LEN (32 + 4 + 32 + 4 + 32 + 48 + 5 + 1)
+#define RT6_VAL_TO_STR(s) #s
 
 struct rt6_proc_arg
 {
@@ -2462,7 +2463,8 @@ static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 	} else {
 		seq_puts(m, "00000000000000000000000000000000");
 	}
-	seq_printf(m, " %08x %08x %08x %08x %8s\n",
+	seq_printf(m, " %08x %08x %08x %08x %"
+		   RT6_VAL_TO_STR(IFNAMSIZ) "s\n",
 		   rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
 		   rt->u.dst.__use, rt->rt6i_flags,
 		   rt->rt6i_dev ? rt->rt6i_dev->name : "");

--------------090901070002070704060602--
