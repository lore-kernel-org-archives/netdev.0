From: Li Yewang <lyw@nanjing-fnst.com>
Subject: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Thu, 16 Nov 2006 23:57:50 -0500
Message-ID: <1163739471.2802.7.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:6334 "EHLO proxy.fnst.com.cn")
	by vger.kernel.org with ESMTP id S1162324AbWKQChx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 21:37:53 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[1]Summary of the problem:
On IA32 system, If jiffies - b > 0x7fffffff, router can not send
redirect packet.unsigned long b = rt->u.dst.rate_last
+(ip_rt_redirect_load << rt->u.dst.rate_tokens)

[2]Full description of the problem:
In linux kernel, if time_after(jiffies, (rt->u.dst.rate_last
+(ip_rt_redirect_load << rt->u.dst.rate_tokens)) == false,
router will not send redirect packet. Here define b = rt-
>u.dst.rate_last +(ip_rt_redirect_load << rt->u.dst.rate_tokens):

1. If (jiffies - b <= 0x7fffffff), time_after(jiffies, b) == true,
router will send redirect packet. 

2. If (jiffies - b > 0x7fffffff), time_after(jiffies, b) == false,
router will not send redirect packet. For example: when I add a router
after system boot, jiffies = (unsigned long)(-300000), 
rt->u.dst.rate_last = 0, rt->u.dst.rate_tokens = 0, b = 20, 
time_after((unsigned long)(-300000), 20) == false, send redirect packet
can not be send even if router is used in the first time.

When router send a  redirect packet in time b, and before jiffies
increased to 0x7fffffff + b, router can send redirect packet.
But if a redirect packet must be send in 0x80000000+ b, 
time_after(jiffies, b) == false, redirect packet will not be send also.
So between time (0x80000000+ b) to time b, router do not send redirect
packet. That is to say, in a circle of jiffies, router has 24.9 days can
not send redirect packet (0x80000000/1000/60/60/24=24.9).

    jiffies                          b

------|------------------------------|----------------------|---->time
 0x80000000+b                        b                0x7fffffff+b
      |<--jiffies - b < 0x7fffffff-->|

Following is my patch.

Signed-off-by: Li Yewang <lyw@nanjing-fnst.com>

--- linux-2.6.9/net/ipv4/route.c.org	2006-11-16 08:49:48.000000000 +0800
+++ linux-2.6.9/net/ipv4/route.c	2006-11-16 08:51:30.000000000 +0800
@@ -1196,7 +1196,8 @@ void ip_rt_send_redirect(struct sk_buff 
 	/* No redirected packets during ip_rt_redirect_silence;
 	 * reset the algorithm.
 	 */
-	if (time_after(jiffies, rt->u.dst.rate_last + ip_rt_redirect_silence)
+	if (time_after(jiffies, rt->u.dst.rate_last + ip_rt_redirect_silence) ||
+	    time_after(rt->u.dst.rate_last, jiffies))
 		rt->u.dst.rate_tokens = 0;
 
 	/* Too many ignored redirects; do not send anything
@@ -1212,7 +1213,8 @@ void ip_rt_send_redirect(struct sk_buff 
 	 */
 	if (time_after(jiffies,
 		       (rt->u.dst.rate_last +
-			(ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
+			(ip_rt_redirect_load << rt->u.dst.rate_tokens))) ||
+	    time_after(rt->u.dst.rate_last, jiffies)) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
 		rt->u.dst.rate_last = jiffies;
 		++rt->u.dst.rate_tokens;


