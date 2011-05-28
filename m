From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Use unsigned variables for packet lengths in ip[6]_queue.
Date: Fri, 27 May 2011 20:36:51 -0400
Message-ID: <20110528003651.GA8380@redhat.com>
References: <20110420014221.GC26949@redhat.com>
 <20110419.204105.68144653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757560Ab1E1Agz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 20:36:55 -0400
Content-Disposition: inline
In-Reply-To: <20110419.204105.68144653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2011 at 08:41:05PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Tue, 19 Apr 2011 21:42:22 -0400
 > 
 > > Not catastrophic, but ipqueue seems to be too trusting of what it gets
 > > passed from userspace, and passes it on down to the page allocator,
 > > where it will spew warnings if the page order is too high.
 > > 
 > > __ipq_rcv_skb has several checks for lengths too small, but doesn't
 > > seem to have any for oversized ones.   I'm not sure what the maximum
 > > we should check for is. I'll code up a diff if anyone has any ideas
 > > on a sane maximum.
 > 
 > Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
 > in netlink_ack()?
 > 
 > Anyone else have a better idea?

So I went back to this today, and found something that doesn't look right.
After adding some instrumentation, and re-running my tests, I found that
the reason we were blowing up with enormous allocations was that we
were passing down a nlmsglen's like -1061109568

Is there any reason for that to be signed ?
The nlmsg_len entry of nlmsghdr is a u32, so I'm assuming this is a bug.

With the patch below, I haven't been able to reproduce the problem, but
I don't know if I've inadvertantly broken some other behaviour somewhere
deeper in netlink where this is valid.

	Dave

-- 

Netlink message lengths can't be negative, so use unsigned variables.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index d2c1311..f7f9bd7 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -402,7 +402,8 @@ ipq_dev_drop(int ifindex)
 static inline void
 __ipq_rcv_skb(struct sk_buff *skb)
 {
-	int status, type, pid, flags, nlmsglen, skblen;
+	int status, type, pid, flags;
+	unsigned int nlmsglen, skblen;
 	struct nlmsghdr *nlh;
 
 	skblen = skb->len;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 413ab07..065fe40 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -403,7 +403,8 @@ ipq_dev_drop(int ifindex)
 static inline void
 __ipq_rcv_skb(struct sk_buff *skb)
 {
-	int status, type, pid, flags, nlmsglen, skblen;
+	int status, type, pid, flags;
+	unsigned int nlmsglen, skblen;
 	struct nlmsghdr *nlh;
 
 	skblen = skb->len;

