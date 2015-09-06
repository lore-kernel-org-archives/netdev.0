From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv6: fix multipath route replace error recovery
Date: Sun, 06 Sep 2015 13:46:39 -0700
Message-ID: <55ECA62F.9070905@cumulusnetworks.com>
References: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com> <55E95285.6020102@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34246 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbbIFUqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 16:46:44 -0400
Received: by obbda8 with SMTP id da8so21735985obb.1
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2015 13:46:43 -0700 (PDT)
In-Reply-To: <55E95285.6020102@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/4/15, 1:12 AM, Nicolas Dichtel wrote:
> Le 03/09/2015 01:44, Roopa Prabhu a =C3=A9crit :
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Problem:
>> The ecmp route replace support for ipv6 in the kernel, deletes the
>> existing ecmp route too early, ie when it installs the first nexthop=
=2E
>> If there is an error in installing the subsequent nexthops, its too =
late
>> to recover the already deleted existing route
>>
>> This patch fixes the problem with the following:
>> a) Changes the existing multipath route add code to a two stage proc=
ess:
>>    build rt6_infos + insert them
>>     ip6_route_add rt6_info creation code is moved into
>>     ip6_route_info_create.
>> b) This ensures that all errors are caught during building rt6_infos
>>    and we fail early
>> c) Separates multipath add and del code. Because add needs the speci=
al
>>    two stage mode in a) and delete essentially does not care.
>> d) In any event if the code fails during inserting a route again, a
>>    warning is printed (This should be unlikely)
>>
>> Before the patch:
>> $ip -6 route show
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 10=
24
>>
>> /* Try replacing the route with a duplicate nexthop */
>> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
>> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
>> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
>> RTNETLINK answers: File exists
>>
>> $ip -6 route show
>> /* previously added ecmp route 3000:1000:1000:1000::2 dissappears fr=
om
>>   * kernel */
>>
>> After the patch:
>> $ip -6 route show
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 10=
24
>>
>> /* Try replacing the route with a duplicate nexthop */
>> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
>> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
>> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
>> RTNETLINK answers: File exists
>>
>> $ip -6 route show
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 10=
24
>> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 10=
24
>>
>> Fixes: 4a287eba2de3 ("IPv6 routing, NLM_F_* flag support: REPLACE an=
d=20
>> EXCL flags support, warn about missing CREATE flag")
> ECMP was added one year after this patch. The right tag is:
> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP=
)")
I went back and looked again. It is a recent one 27596472473a ("ipv6:=20
fix ECMP route replacement").

>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>> v2 - fix a rt6_info leak in cleanup on error
>>
>> This bug is present in 4.1 kernel and 4.2 too.
>> Since 4.2 is out or almost out, I am submitting the patch against=20
>> net-next.
>> I can respin against net if needed. I have tried to keep the changes=
=20
>> local
>> to route.c closer to the netlink message handling. Most of the=20
>> changes move
>> code into separate functions.
>>
>>   net/ipv6/route.c | 209=20
>> ++++++++++++++++++++++++++++++++++++++++++++++++-------
>>   1 file changed, 183 insertions(+), 26 deletions(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> [snip]
>> +static void ip6_print_replace_route_err(struct list_head *rt6_nh_li=
st)
>> +{
>> +    struct rt6_nh *nh;
>> +    char *errstr =3D "IPV6: unexpected error replacing route";
> Generally, it's better to not break log. It eases grep.
> Something shorter may be enough: "ECMPv6", the log level already=20
> indicates
> that it's an error (which is always unexpected ;-)).

correct. What i was trying to really say is 'replace failed but it=20
deleted already existing route'.
I have tried to reword it in v3. posting soon.
>
>> +
>> +    list_for_each_entry(nh, rt6_nh_list, next) {
>> +        printk(KERN_WARNING "%s: %pI6 nexthop %pI6 ifi %d\n",
> pr_warn() or pr_err()?

I will use pr_warn.
