From: Jon Grimm <jgrimm2@us.ibm.com>
Subject: [PATCH] Fix ip6_build_xmit bug
Date: Fri, 21 Mar 2003 18:21:18 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E7BAC7E.AEC59251@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wanting to play a bit with v6 fragmentation I started using ping6 to
send various message sizes.  Noticed that messages of sizes just under
where fragmentation would kick in, segfaulted in ip6_build_xmit().

Looks like ip6_build_xmit does not allocate room for the
dev->hard_header_len on the non-fragmentation path as is done in other
places.  The hard header len gets reserved even though room was not
allocated for it.  Consequenetly, the put of the raw data can overflow
the skb. 

Patch below for your consideration.

Best Regards,
Jon Grimm


--- lksctp-2.5/net/ipv6/ip6_output.c	Fri Mar 21 17:27:00 2003
+++ lksctp-2.5.work/net/ipv6/ip6_output.c	Fri Mar 21 17:24:38 2003
@@ -643,7 +643,8 @@
 		if (flags&MSG_PROBE)
 			goto out;
 		/* alloc skb with mtu as we do in the IPv4 stack for IPsec */
-		skb = sock_alloc_send_skb(sk, mtu, flags & MSG_DONTWAIT, &err);
+		skb = sock_alloc_send_skb(sk, mtu + dev->hard_header_len + 15,
+					  flags & MSG_DONTWAIT, &err);
 
 		if (skb == NULL) {
 			IP6_INC_STATS(Ip6OutDiscards);
