From: weidong <weidong@cn.fujitsu.com>
Subject: Re: Fix "ipOutNoRoutes" counter error for TCP and UDP
Date: Fri, 01 Jun 2007 13:37:08 +0800
Message-ID: <465FB084.70609@cn.fujitsu.com>
References: <465E2202.3000607@cn.fujitsu.com> <20070531.214104.31597841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030103060107010502010303"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56851 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbXFAFjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 01:39:43 -0400
In-Reply-To: <20070531.214104.31597841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030103060107010502010303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Mr David

    Sorry to trouble many times, I will attention to this next time.

    I have made this patch again, and I tried, it can be patched to the recently
    kernel of linux-2.6.21.3. following is the patch, and I also attach this
    patch to the attachment.

    Signed-off-by: Wei Dong <weidong@cn.fujitsu.com>

diff -Nurp a/net/ipv4/datagram.c b/net/ipv4/datagram.c
--- a/net/ipv4/datagram.c       2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/datagram.c       2007-06-01 13:24:21.000000000 +0800
@@ -50,8 +50,12 @@ int ip4_datagram_connect(struct sock *sk
                                RT_CONN_FLAGS(sk), oif,
                                sk->sk_protocol,
                                inet->sport, usin->sin_port, sk, 1);
-       if (err)
+       if (err) {
+               if (err == -ENETUNREACH)
+                       IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
                 return err;
+       }
+
         if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
                 ip_rt_put(rt);
                 return -EACCES;
diff -Nurp a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c       2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/tcp_ipv4.c       2007-06-01 13:25:07.000000000 +0800
@@ -192,8 +192,11 @@ int tcp_v4_connect(struct sock *sk, stru
                                RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
                                IPPROTO_TCP,
                                inet->sport, usin->sin_port, sk, 1);
-       if (tmp < 0)
+       if (tmp < 0) {
+               if (tmp == -ENETUNREACH)
+                       IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
                 return tmp;
+       }

         if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
                 ip_rt_put(rt);
diff -Nurp a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c    2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/udp.c    2007-06-01 13:26:47.000000000 +0800
@@ -631,8 +631,11 @@ int udp_sendmsg(struct kiocb *iocb, stru
                                                  .dport = dport } } };
                 security_sk_classify_flow(sk, &fl);
                 err = ip_route_output_flow(&rt, &fl, sk, 1);
-               if (err)
+               if (err) {
+                       if (err == -ENETUNREACH)
+                               IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
                         goto out;
+               }

                 err = -EACCES;
                 if ((rt->rt_flags & RTCF_BROADCAST) &&



David Miller wrote:
> From: Wei Dong <weidong@cn.fujitsu.com>
> Date: Thu, 31 May 2007 09:16:50 +0800
> 
>> Hi Mr. David
>>   I have modified my patch according to you advice. I think -
>> EHOSTUNREACH is only for "input path". In "output" path, we can just
>> simply check-ENETUNREACH  (^_^), the patch is shown in the end of this mail.
>>
>>  I send this patch to you several weeks ago, but you have not replied to me.
>> This patch is not correctly?
> 
> Your email client is still corrupting the patch, it changes
> tab characters into spaces.  This makes the patch not apply.
> 
> Please do not send the same unusable patch so many times.
> Instead, I recommend to email the patch to yourself, and
> you try to apply it, in the same way someone else receiving
> your patch posting would.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

--------------030103060107010502010303
Content-Type: text/x-patch;
 name="ipOutNoRoutes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipOutNoRoutes.patch"

diff -Nurp a/net/ipv4/datagram.c b/net/ipv4/datagram.c
--- a/net/ipv4/datagram.c	2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/datagram.c	2007-06-01 13:24:21.000000000 +0800
@@ -50,8 +50,12 @@ int ip4_datagram_connect(struct sock *sk
 			       RT_CONN_FLAGS(sk), oif,
 			       sk->sk_protocol,
 			       inet->sport, usin->sin_port, sk, 1);
-	if (err)
+	if (err) {
+		if (err == -ENETUNREACH)
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES); 
 		return err;
+	}
+
 	if ((rt->rt_flags & RTCF_BROADCAST) && !sock_flag(sk, SOCK_BROADCAST)) {
 		ip_rt_put(rt);
 		return -EACCES;
diff -Nurp a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/tcp_ipv4.c	2007-06-01 13:25:07.000000000 +0800
@@ -192,8 +192,11 @@ int tcp_v4_connect(struct sock *sk, stru
 			       RT_CONN_FLAGS(sk), sk->sk_bound_dev_if,
 			       IPPROTO_TCP,
 			       inet->sport, usin->sin_port, sk, 1);
-	if (tmp < 0)
+	if (tmp < 0) {
+		if (tmp == -ENETUNREACH)
+			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return tmp;
+	}
 
 	if (rt->rt_flags & (RTCF_MULTICAST | RTCF_BROADCAST)) {
 		ip_rt_put(rt);
diff -Nurp a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2007-06-01 13:22:39.000000000 +0800
+++ b/net/ipv4/udp.c	2007-06-01 13:26:47.000000000 +0800
@@ -631,8 +631,11 @@ int udp_sendmsg(struct kiocb *iocb, stru
 						 .dport = dport } } };
 		security_sk_classify_flow(sk, &fl);
 		err = ip_route_output_flow(&rt, &fl, sk, 1);
-		if (err)
+		if (err) {
+			if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 			goto out;
+		}
 
 		err = -EACCES;
 		if ((rt->rt_flags & RTCF_BROADCAST) &&

--------------030103060107010502010303--
