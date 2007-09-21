From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/3 Rev4] Initialize and fill IPv6 route age
Date: Fri, 21 Sep 2007 08:35:11 +0530
Message-ID: <OF5159F66B.5A5F01B8-ON6525735D.000FD530-6525735D.0010F45F@in.ibm.com>
References: <20070920205903.e40b37af.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, socketcan@hartkopp.net,
	tgraf@suug.ch, Varun Chandramohan <varuncha@in.ibm.com>
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:50523 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbXIUDDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 23:03:54 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8L33iDH021869
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 13:03:44 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8L37HiN058952
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 13:07:18 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8L33gB5021857
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 13:03:43 +1000
In-Reply-To: <20070920205903.e40b37af.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote on 09/20/2007 08:59:03
PM:

> @@ -2123,6 +2131,7 @@ static int rt6_fill_node(struct sk_buff
>  {
>     struct rtmsg *rtm;
>     struct nlmsghdr *nlh;
> +   struct timeval tv;
>     long expires;
>     u32 table;
>
> @@ -2186,6 +2195,11 @@ static int rt6_fill_node(struct sk_buff
>        if (ipv6_get_saddr(&rt->u.dst, dst, &saddr_buf) == 0)
>           NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
>     }
> +
> +   do_gettimeofday(&tv);
> +   if (rt->rt6i_age) {
> +      NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - rt->rt6i_age));
> +   }

Will rt6i_age ever be zero with this new patch? If it can be zero,
the code should really be keeping the "tv" declaration and
do_gettimeofday() inside the "if (rt->rt6i_age)" check.

And from your Patch2/3:

int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-                          u32 tb_id, u8 type, u8 scope, __be32 dst, int
dst_len, u8 tos,
+                          u32 tb_id, u8 type, u8 scope, __be32 dst, int
dst_len, u8 tos, time_t age,
                           struct fib_info *fi, unsigned int flags)
 {
             struct nlmsghdr *nlh;
             struct rtmsg *rtm;
+            struct timeval tv;

             nlh = nlmsg_put(skb, pid, seq, event, sizeof(*rtm), flags);
             if (nlh == NULL)
@@ -985,6 +987,11 @@ int fib_dump_info(struct sk_buff *skb, u
                                     NLA_PUT_U32(skb, RTA_FLOW,
fi->fib_nh[0].nh_tclassid);
 #endif
             }
+
+            do_gettimeofday(&tv);
+            if (age) {
+                        NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - age));
+            }

Don't you want to return time the first time (and get zero)? Otherwise
RTA_AGE is not returned to user. Something like:

            do_gettimeofday(&tv);
            NLA_PUT_U32(skb, RTA_AGE, (tv.tv_sec - age));

Once again, can age ever be zero?

- KK

