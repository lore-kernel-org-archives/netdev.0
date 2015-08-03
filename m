From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] lwtunnel: encap locally-generated ipv4 packets
Date: Mon, 03 Aug 2015 14:41:07 -0700
Message-ID: <55BFDFF3.2030309@cumulusnetworks.com>
References: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32997 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbbHCVlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:41:09 -0400
Received: by padck2 with SMTP id ck2so98949876pad.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 14:41:08 -0700 (PDT)
In-Reply-To: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/3/15, 9:39 AM, Robert Shearman wrote:
> Locally-generated IPv4 packets, such as from applications running on
> the host or traceroute/ping currently don't have lwtunnel output
> redirected encap applied. However, they should do in the same way as
> for forwarded packets and this patch series addresses that.
>
> Robert Shearman (2):
>    lwtunnel: set skb protocol and dev
>    ipv4: apply lwtunnel encap for locally-generated packets
>
>   net/core/lwtunnel.c | 12 ++++++++++--
>   net/ipv4/route.c    |  2 ++
>   2 files changed, 12 insertions(+), 2 deletions(-)
>
Thanks for this patch Robert. Looks good.
I have been thinking of sending a similar patch out for this and
since i was also looking at ip fragmentation, I have a slightly 
different patch which I think should also take care of
encapsulating locally generated packets too. This patch moves the output 
redirection to after ip fragmentation.
What do you think about the below (I have briefly tested it. Was 
planning to test some more before sending it out as RFC) ?

[PATCH net-next] lwtunnel: move output redirection to after ip fragmentation

This patch adds tunnel headroom in lwtstate to make
sure we account for tunnel data in mtu calculations and
moves tunnel output redirection after ip fragmentation.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
  include/net/lwtunnel.h   |    1 +
  net/ipv4/ip_output.c     |    4 ++++
  net/ipv4/route.c         |    5 +++--
  net/mpls/mpls_iptunnel.c |    1 +
  4 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 918e03c..7816805 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -18,6 +18,7 @@ struct lwtunnel_state {
         __u16           flags;
         atomic_t        refcnt;
         int             len;
+       __u16           headroom;
         __u8            data[0];
  };

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6bf89a6..ae3119f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -73,6 +73,7 @@
  #include <net/icmp.h>
  #include <net/checksum.h>
  #include <net/inetpeer.h>
+#include <net/lwtunnel.h>
  #include <linux/igmp.h>
  #include <linux/netfilter_ipv4.h>
  #include <linux/netfilter_bridge.h>
@@ -201,6 +202,9 @@ static int ip_finish_output2(struct sock *sk, struct 
sk_buff *skb)
                 skb = skb2;
         }

+       if (lwtunnel_output_redirect(rt->rt_lwtstate))
+               return lwtunnel_output(sk, skb);
+
         rcu_read_lock_bh();
         nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
         neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d3964fa..4e07b9a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1234,6 +1234,9 @@ static unsigned int ipv4_mtu(const struct 
dst_entry *dst)

         mtu = dst->dev->mtu;

+       if (lwtunnel_output_redirect(rt->rt_lwtstate))
+               mtu -= rt->rt_lwtstate->headroom;
+
         if (unlikely(dst_metric_locked(dst, RTAX_MTU))) {
                 if (rt->rt_uses_gateway && mtu > 576)
                         mtu = 576;
@@ -1634,8 +1637,6 @@ static int __mkroute_input(struct sk_buff *skb,
         rth->dst.output = ip_output;

         rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
-       if (lwtunnel_output_redirect(rth->rt_lwtstate))
-               rth->dst.output = lwtunnel_output;
         skb_dst_set(skb, &rth->dst);
  out:
         err = 0;
