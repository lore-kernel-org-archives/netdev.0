From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v3] ipv6: fix multipath route replace error recovery
Date: Mon, 07 Sep 2015 17:14:15 -0700
Message-ID: <55EE2857.2090402@cumulusnetworks.com>
References: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com> <55ED8524.8030109@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35579 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbbIHAOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 20:14:16 -0400
Received: by pacfv12 with SMTP id fv12so109778677pac.2
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 17:14:16 -0700 (PDT)
In-Reply-To: <55ED8524.8030109@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/15, 5:37 AM, Nicolas Dichtel wrote:
> Le 06/09/2015 22:46, Roopa Prabhu a =C3=A9crit :
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> I've sent you some comments about the v2, so please keep me in CC for=
=20
> the next
> versions.
>
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
> It does not really 'fix' the problem, it only reduces the probability=
=20
> to have
> an error. This is really different. The status is much better after=20
> this patch,
> but it could be good to reword a bit the commitlog to reflect that.

sure.
>
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
>> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
> As said in the v2 thread, I still don't agree with this tag.
>
> [snip]
>> +static void ip6_print_replace_route_err(struct list_head *rt6_nh_li=
st)
>> +{
>> +    struct rt6_nh *nh;
>> +
>> +    list_for_each_entry(nh, rt6_nh_list, next) {
>> +        pr_warn("IPV6: replace premature del %pI6 nexthop %pI6 ifi=20
>> %d\n",
> I don't think that a user (who didn't read the code) can understand t=
his
> sentence. Another suggestion:
> "ECMPv6: route replacement failed (check the consistency of the=20
> installed route)". Not sure that the nexthops should be listed after.
sure, i don't have a preference. I will resubmit if we converge on the=20
commit message.
