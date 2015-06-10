From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Wed, 10 Jun 2015 08:22:35 -0500
Message-ID: <55783A1B.3070207@akamai.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>	<20150608.121601.1357405469784892473.davem@davemloft.net> <m2mw08kx7b.wl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: Hajime Tazaki <thehajime@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:65212 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933329AbbFJNWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 09:22:37 -0400
In-Reply-To: <m2mw08kx7b.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2015 11:24 PM, Hajime Tazaki wrote:
>
> Hello Josh, Dave,
>
> my mobile ipv6 test on libos failed with this commit.
>
> This commit makes a destination option header handling (i.e.,
> ipprot->handler == ipv6_destopt_rcv) failed since
> ipv6_destopt_rcv() seems to return a positive value to
> indicate to goto resubmission label.
>
> I will look for more detail.
>
> -- Hajime

Hajime

Thanks for the report. I mentioned in an earlier post this might be a 
problem.

Dave, what if we restore the old behavior, but add a new label to handle 
the case where the decapsulating protocol returns the nexthdr value? 
Allowing for migration over to this method over time. I've pasted in a 
patch doing so below.

The other solution I guess is to change how the udp handler works, but I 
was hoping to keep it behaving the same as v4.

Josh

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 41a73da..a4fab24 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -212,13 +212,13 @@ static int ip6_input_finish(struct sock *sk, 
struct sk_buff *skb)
          */

         rcu_read_lock();
+resubmit:
         idev = ip6_dst_idev(skb_dst(skb));
         if (!pskb_pull(skb, skb_transport_offset(skb)))
                 goto discard;
         nhoff = IP6CB(skb)->nhoff;
         nexthdr = skb_network_header(skb)[nhoff];
-
-resubmit:
+resubmit_nexthdr:
         raw = raw6_local_deliver(skb, nexthdr);
         ipprot = rcu_dereference(inet6_protos[nexthdr]);
         if (ipprot) {
@@ -246,9 +246,11 @@ resubmit:
                         goto discard;

                 ret = ipprot->handler(skb);
-               if (ret < 0) {
-                       nexthdr = -ret;
+               if (ret > 0) {
                         goto resubmit;
+               } else if (ret < 0) {
+                       nexthdr = -ret;
+                       goto resubmit_nexthdr;
                 } else if (ret == 0) {
                         IP6_INC_STATS_BH(net, idev, 
IPSTATS_MIB_INDELIVERS);
                 }
