From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv6: fix multipath route replace error
 recovery
Date: Fri, 4 Sep 2015 10:12:53 +0200
Message-ID: <55E95285.6020102@6wind.com>
References: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:33486 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920AbbIDIM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 04:12:57 -0400
Received: by wiclk2 with SMTP id lk2so13987086wic.0
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 01:12:56 -0700 (PDT)
In-Reply-To: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/09/2015 01:44, Roopa Prabhu a =C3=A9crit :
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Problem:
> The ecmp route replace support for ipv6 in the kernel, deletes the
> existing ecmp route too early, ie when it installs the first nexthop.
> If there is an error in installing the subsequent nexthops, its too l=
ate
> to recover the already deleted existing route
>
> This patch fixes the problem with the following:
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
> Fixes: 4a287eba2de3 ("IPv6 routing, NLM_F_* flag support: REPLACE and=
 EXCL flags support, warn about missing CREATE flag")
ECMP was added one year after this patch. The right tag is:
=46ixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP=
)")

> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> v2 - fix a rt6_info leak in cleanup on error
>
> This bug is present in 4.1 kernel and 4.2 too.
> Since 4.2 is out or almost out, I am submitting the patch against net=
-next.
> I can respin against net if needed. I have tried to keep the changes =
local
> to route.c closer to the netlink message handling. Most of the change=
s move
> code into separate functions.
>
>   net/ipv6/route.c | 209 ++++++++++++++++++++++++++++++++++++++++++++=
++++-------
>   1 file changed, 183 insertions(+), 26 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
[snip]
> +static void ip6_print_replace_route_err(struct list_head *rt6_nh_lis=
t)
> +{
> +	struct rt6_nh *nh;
> +	char *errstr =3D "IPV6: unexpected error replacing route";
Generally, it's better to not break log. It eases grep.
Something shorter may be enough: "ECMPv6", the log level already indica=
tes
that it's an error (which is always unexpected ;-)).

> +
> +	list_for_each_entry(nh, rt6_nh_list, next) {
> +		printk(KERN_WARNING "%s: %pI6 nexthop %pI6 ifi %d\n",
pr_warn() or pr_err()?

> +		       errstr, &nh->r_cfg.fc_dst, &nh->r_cfg.fc_gateway,
> +		       nh->r_cfg.fc_ifindex);
> +	}
> +}
