From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net v4] ipv6: fix multipath route replace error recovery
Date: Tue, 8 Sep 2015 21:59:50 +0200
Message-ID: <55EF3E36.7090405@cumulusnetworks.com>
References: <1441734784-34416-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, mkubecek@suse.cz,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35561 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbbIHT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 15:59:54 -0400
Received: by wicge5 with SMTP id ge5so129979106wic.0
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 12:59:52 -0700 (PDT)
In-Reply-To: <1441734784-34416-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2015 07:53 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Problem:
> The ecmp route replace support for ipv6 in the kernel, deletes the
> existing ecmp route too early, ie when it installs the first nexthop.
> If there is an error in installing the subsequent nexthops, its too late
> to recover the already deleted existing route leaving the fib
> in an inconsistent state.
> 
> This patch reduces the possibility of this by doing the following:
> a) Changes the existing multipath route add code to a two stage process:
>   build rt6_infos + insert them
> 	ip6_route_add rt6_info creation code is moved into
> 	ip6_route_info_create.
> b) This ensures that most errors are caught during building rt6_infos
>   and we fail early
> c) Separates multipath add and del code. Because add needs the special
>   two stage mode in a) and delete essentially does not care.
> d) In any event if the code fails during inserting a route again, a
>   warning is printed (This should be unlikely)
> 
> Before the patch:
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024
> 
> /* Try replacing the route with a duplicate nexthop */
> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
> RTNETLINK answers: File exists
> 
> $ip -6 route show
> /* previously added ecmp route 3000:1000:1000:1000::2 dissappears from
>  * kernel */
> 
> After the patch:
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024
> 
> /* Try replacing the route with a duplicate nexthop */
> $ip -6 route change 3000:1000:1000:1000::2/128 nexthop via
> fe80::202:ff:fe00:b dev swp49s0 nexthop via fe80::202:ff:fe00:d dev
> swp49s1 nexthop via fe80::202:ff:fe00:d dev swp49s1
> RTNETLINK answers: File exists
> 
> $ip -6 route show
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:b dev swp49s0 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:d dev swp49s1 metric 1024
> 3000:1000:1000:1000::2 via fe80::202:ff:fe00:f dev swp49s2 metric 1024
> 
> Fixes: 27596472473a ("ipv6: fix ECMP route replacement")
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> v1 - v2 : fix leak
> v2 - v3: fix 'Fixes' tag and warn msg (feedback from nicolas)
>          resending against net
> v3 - v4: reword warn msg (feedback from nicolas). I still print the
>          nexthops in the warning to help user know the offending
>          route replace. The msg is printed for each nexthop which I
>          think should be ok because this is consistent with all other cases
>          (notifications etc) where IPV6 multipath nexthops are
>          treated as individual routes and this warn should be very
>          unlikely.
> ---
>  net/ipv6/route.c | 201 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 175 insertions(+), 26 deletions(-)
> 

I went over it and also ran a few tests with the change, IMO printing
the offending entry is helpful to analyze the problem.
FWIW,

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
