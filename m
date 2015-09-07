From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v3] ipv6: fix multipath route replace error recovery
Date: Mon, 7 Sep 2015 14:37:56 +0200
Message-ID: <55ED8524.8030109@6wind.com>
References: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38291 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbbIGMh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 08:37:59 -0400
Received: by wiclk2 with SMTP id lk2so82830302wic.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 05:37:58 -0700 (PDT)
In-Reply-To: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2015 22:46, Roopa Prabhu a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
I've sent you some comments about the v2, so please keep me in CC for t=
he next
versions.

>
> Problem:
> The ecmp route replace support for ipv6 in the kernel, deletes the
> existing ecmp route too early, ie when it installs the first nexthop.
> If there is an error in installing the subsequent nexthops, its too l=
ate
> to recover the already deleted existing route
>
> This patch fixes the problem with the following:
It does not really 'fix' the problem, it only reduces the probability t=
o have
an error. This is really different. The status is much better after thi=
s patch,
but it could be good to reword a bit the commitlog to reflect that.

> a) Changes the existing multipath route add code to a two stage proce=
ss:
>    build rt6_infos + insert them
> 	ip6_route_add rt6_info creation code is moved into
> 	ip6_route_info_create.
> b) This ensures that all errors are caught during building rt6_infos
>    and we fail early
> c) Separates multipath add and del code. Because add needs the specia=
l
>    two stage mode in a) and delete essentially does not care.
> d) In any event if the code fails during inserting a route again, a
>    warning is printed (This should be unlikely)
>
> Before the patch:
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 102=
4
>
> /* Try replacing the route with a duplicate nexthop */
> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
> RTNETLINK answers: File exists
>
> $ip -6 route show
> /* previously added ecmp route 3000:1000:1000:1000::2 dissappears fro=
m
>   * kernel */
>
> After the patch:
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 102=
4
>
> /* Try replacing the route with a duplicate nexthop */
> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
> RTNETLINK answers: File exists
>
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 102=
4
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 102=
4
>
> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
As said in the v2 thread, I still don't agree with this tag.

[snip]
> +static void ip6_print_replace_route_err(struct list_head *rt6_nh_lis=
t)
> +{
> +	struct rt6_nh *nh;
> +
> +	list_for_each_entry(nh, rt6_nh_list, next) {
> +		pr_warn("IPV6: replace premature del %pI6 nexthop %pI6 ifi %d\n",
I don't think that a user (who didn't read the code) can understand thi=
s
sentence. Another suggestion:
"ECMPv6: route replacement failed (check the consistency of the install=
ed=20
route)". Not sure that the nexthops should be listed after.
