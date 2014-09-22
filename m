From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: do not use this_cpu_ptr() in preemptible context
Date: Mon, 22 Sep 2014 10:21:53 -0700
Message-ID: <1411406513.26859.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140922090242.5ef15c83@urahara>
	 <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	joe9mail@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36027 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572AbaIVRV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 13:21:56 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so5486965pad.21
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 10:21:56 -0700 (PDT)
In-Reply-To: <1411405767.26859.128.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

this_cpu_ptr() in preemptible context is generally bad

Sep 22 05:05:55 br kernel: [   94.608310] BUG: using smp_processor_id() in
preemptible [00000000] code: ip/2261
Sep 22 05:05:55 br kernel: [   94.608316] caller is
tunnel_dst_set.isra.28+0x20/0x60 [ip_tunnel]
Sep 22 05:05:55 br kernel: [   94.608319] CPU: 3 PID: 2261 Comm: ip Not tainted
3.17.0-rc5 #82

We can simply use __this_cpu_ptr(), as preemption is safe in these contexts.

Should fix https://bugzilla.kernel.org/show_bug.cgi?id=84991

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Joe <joe9mail@gmail.com>
Fixes: 9a4aa9af447f ("ipv4: Use percpu Cache route in IP tunnels")
---
 net/ipv4/ip_tunnel.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index afed1aac2638..421b4f01ee29 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -82,7 +82,7 @@ static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
 static void tunnel_dst_set(struct ip_tunnel *t,
 			   struct dst_entry *dst, __be32 saddr)
 {
-	__tunnel_dst_set(this_cpu_ptr(t->dst_cache), dst, saddr);
+	__tunnel_dst_set(__this_cpu_ptr(t->dst_cache), dst, saddr);
 }
 
 static void tunnel_dst_reset(struct ip_tunnel *t)
@@ -106,7 +106,7 @@ static struct rtable *tunnel_rtable_get(struct ip_tunnel *t,
 	struct dst_entry *dst;
 
 	rcu_read_lock();
-	idst = this_cpu_ptr(t->dst_cache);
+	idst = __this_cpu_ptr(t->dst_cache);
 	dst = rcu_dereference(idst->dst);
 	if (dst && !atomic_inc_not_zero(&dst->__refcnt))
 		dst = NULL;
