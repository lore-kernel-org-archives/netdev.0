From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] ipv6: fix multipath route replace error recovery
Date: Mon, 07 Sep 2015 17:01:05 -0700
Message-ID: <55EE2541.8030707@cumulusnetworks.com>
References: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com> <55E95285.6020102@6wind.com> <55ECA62F.9070905@cumulusnetworks.com> <55ED7D00.3050202@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Michal Kubecek <mkubecek@suse.cz>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34459 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbIHABH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 20:01:07 -0400
Received: by padhy16 with SMTP id hy16so104864032pad.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 17:01:06 -0700 (PDT)
In-Reply-To: <55ED7D00.3050202@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/7/15, 5:03 AM, Nicolas Dichtel wrote:
> The bug you're trying to fix has been introduced by the commit 
> 51ebd3181572
> ("ipv6: add support of equal cost multipath (ECMP)").
> Commit 27596472473a ("ipv6: fix ECMP route replacement") didn't try to 
> fix this
> problem.
The reason I say "27596472473a ("ipv6: fix ECMP route replacement") ", 
has introduced the problem
  i am trying to fix is because of the below change. The part where it 
deletes all siblings of an existing route

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 96dbfff..bde57b1 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
[..snip]
@@ -835,8 +851,27 @@ add:
info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
                         fn->fn_flags |= RTN_RTINFO;
                 }
+               nsiblings = iter->rt6i_nsiblings;
                 fib6_purge_rt(iter, fn, info->nl_net);
                 rt6_release(iter);
+
+               if (nsiblings) {
+                       /* Replacing an ECMP route, remove all siblings */
+                       ins = &rt->dst.rt6_next;
+                       iter = *ins;
+                       while (iter) {
+                               if (rt6_qualify_for_ecmp(iter)) {
+                                       *ins = iter->dst.rt6_next;
+                                       fib6_purge_rt(iter, fn, 
info->nl_net);
+                                       rt6_release(iter);
+                                       nsiblings--;
+                               } else {
+                                       ins = &iter->dst.rt6_next;
+                               }
+                               iter = *ins;
+                       }
+                       WARN_ON(nsiblings != 0);
+               }
         }

         return 0;

>
> Note that the first patch you submitted to fix this pb (cf
> http://patchwork.ozlabs.org/patch/362296/) was in June 2014, ie one 
> year before
> the commit 27596472473a.
>
yes, i had submitted the patch you mention above to fix a slightly 
different problem that existed then..which
was introduced by "51ebd3181572 ("ipv6: add support of equal cost 
multipath (ECMP)")".
Commit "35f1b4e96b9258a3668872b1139c51e5a23eb876 ipv6: do not delete 
previously existing ECMP routes if add fails"
subsequently fixed it.

Thanks,
Roopa
