From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2]IP: Send  an ICMP "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Fri, 22 Jan 2010 10:22:27 +0800
Message-ID: <4B590BE3.40509@cn.fujitsu.com>
References: <4B57AC35.8070902@cn.fujitsu.com> <4B5844F2.30104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, david@blue-labs.org, jorge@dti2.net,
	opurdila@ixiacom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:65422 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755630Ab0AVCY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 21:24:26 -0500
In-Reply-To: <4B5844F2.30104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, at 01/21/2010 08:13 PM:
>> +			if (skb_rtable(head)->rt_type != RTN_LOCAL) {
>> +				skb_dst_drop(head);
> 
> Is manually dropping the dst entry necessary here? It will get released
> by the fragment destructor anyways if I'm not mistaken.

Yes, you are right.

--
[PATCH v2]IP: Send an ICMP "Fragment Reassembly Timeout" message when enabling connection track

No matter whether connection track is enabled, an end host should send 
an ICMPv4 "Fragment Reassembly Timeout" message when defrag timeout. 
The reasons are following two points:  

1. RFC 792 says:
   >>>> >> > >   If a host reassembling a fragmented datagram cannot complete the
   >>>> >> > >   reassembly due to missing fragments within its time limit it
   >>>> >> > >   discards the datagram, and it may send a time exceeded message.
   >>>> >> > > 
   >>>> >> > >   If fragment zero is not available then no time exceeded need be
   >>>> >> > >   sent at all.
   >>>> >> > > 
   >>>> >> > > Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp

2. Patrick McHardy also agrees with this opinion.   :-)   
   About the discussion of this opinion, refer to http://patchwork.ozlabs.org/patch/41649

The patch fixed the problem like this:
When enabling connection track, fragments are received at PRE_ROUTING HOOK.
If they are failed to reassemble, ip_expire() will be called. 
Before sending an ICMP "Fragment Reassembly Timeout" message, 
the patch searches router table to get the destination entry only for host type.

The patch has been tested on both host type and route type.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com> 
---
 net/ipv4/ip_fragment.c |   34 ++++++++++++++++++++++++++++++----
 1 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 86964b3..19aeef4 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -32,6 +32,8 @@
 #include <linux/netdevice.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
+#include <net/route.h>
+#include <net/dst.h>
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
@@ -205,13 +207,37 @@ static void ip_expire(unsigned long arg)
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
 
-		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		rcu_read_lock();
 		head->dev = dev_get_by_index_rcu(net, qp->iif);
-		if (head->dev)
-			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-		rcu_read_unlock();
+		if (!head->dev)
+			goto out_rcu_unlock;
+
+		/*
+		 * Only search router table for the head fragment,
+		 * when defraging timeout at PRE_ROUTING HOOK.
+		 */
+		if (qp->user == IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
+			const struct iphdr *iph = ip_hdr(head);
+			int err = ip_route_input(head, iph->daddr, iph->saddr,
+						 iph->tos, head->dev);
+			if (unlikely(err))
+				goto out_rcu_unlock;
+
+			/*
+			 * Only an end host needs to send an ICMP
+			 * "Fragment Reassembly Timeout" message, per RFC792.
+			 */
+			if (skb_rtable(head)->rt_type != RTN_LOCAL)
+				goto out_rcu_unlock;
+
+		}
+
+		/* Send an ICMP "Fragment Reassembly Timeout" message. */
+		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
 	}
+
+out_rcu_unlock:
+	rcu_read_unlock();
 out:
 	spin_unlock(&qp->q.lock);
 	ipq_put(qp);
--
1.6.3.3 
