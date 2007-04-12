From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 14:15:50 -0700 (PDT)
Message-ID: <20070412.141550.133265618.davem@davemloft.net>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: coroberti@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42689
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753856AbXDLVPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 17:15:49 -0400
In-Reply-To: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert Iakobashvili" <coroberti@gmail.com>
Date: Thu, 12 Apr 2007 23:11:14 +0200

> It works good with  2.6.11.8 and debian 2.6.18.3-i686 image.
> 
> At the same Intel Pentium-4 PC with the same about kernel configuration
> (make oldconfig using Debian config-2.6.18.3-i686) the setup fails with the
> tcp-connections stalled after 1000 established connections when the kernel
> is 2.6.20.6 or 2.6.19.5.
> 
> It stalls even earlier, when lighttpd used with the default (poll ())
> demultiplexing
> after 500 connections or when apache2 web server used (memory?) - after 100
> connections.
> 
> I am currently going to try vanilla 2.6.18.3 and, if with it also
> fails, to look through
> Debian patches, trying to figure out, what is the delta.
> 
> strace-ing and logs has revealed actually 2 scenarios of failures.
> Connections are established successfully and:
> - request sent and there is no response;
> - partial response received and the connection stalls.

The following patch is not the cause, but it likely
exacerbates the problem, can you revert the following
patch from your kernel and see if it changes the behavior?

commit 7b4f4b5ebceab67ce440a61081a69f0265e17c2a
Author: John Heffner <jheffner@psc.edu>
Date:   Sat Mar 25 01:34:07 2006 -0800

    [TCP]: Set default max buffers from memory pool size
    
    This patch sets the maximum TCP buffer sizes (available to automatic
    buffer tuning, not to setsockopt) based on the TCP memory pool size.
    The maximum sndbuf and rcvbuf each will be up to 4 MB, but no more
    than 1/128 of the memory pressure threshold.
    
    Signed-off-by: John Heffner <jheffner@psc.edu>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4b0272c..591e96d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -276,8 +276,8 @@ atomic_t tcp_orphan_count = ATOMIC_INIT(0);
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
 int sysctl_tcp_mem[3];
-int sysctl_tcp_wmem[3] = { 4 * 1024, 16 * 1024, 128 * 1024 };
-int sysctl_tcp_rmem[3] = { 4 * 1024, 87380, 87380 * 2 };
+int sysctl_tcp_wmem[3];
+int sysctl_tcp_rmem[3];
 
 EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
@@ -2081,7 +2081,8 @@ __setup("thash_entries=", set_thash_entries);
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
-	int order, i;
+	unsigned long limit;
+	int order, i, max_share;
 
 	if (sizeof(struct tcp_skb_cb) > sizeof(skb->cb))
 		__skb_cb_too_small_for_tcp(sizeof(struct tcp_skb_cb),
@@ -2155,12 +2156,16 @@ void __init tcp_init(void)
 	sysctl_tcp_mem[1] = 1024 << order;
 	sysctl_tcp_mem[2] = 1536 << order;
 
-	if (order < 3) {
-		sysctl_tcp_wmem[2] = 64 * 1024;
-		sysctl_tcp_rmem[0] = PAGE_SIZE;
-		sysctl_tcp_rmem[1] = 43689;
-		sysctl_tcp_rmem[2] = 2 * 43689;
-	}
+	limit = ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT - 7);
+	max_share = min(4UL*1024*1024, limit);
+
+	sysctl_tcp_wmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_tcp_wmem[1] = 16*1024;
+	sysctl_tcp_wmem[2] = max(64*1024, max_share);
+
+	sysctl_tcp_rmem[0] = SK_STREAM_MEM_QUANTUM;
+	sysctl_tcp_rmem[1] = 87380;
+	sysctl_tcp_rmem[2] = max(87380, max_share);
 
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
