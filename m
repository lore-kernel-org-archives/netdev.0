From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 23:48:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41324F2C.4090003@trash.net>
References: <412A8FB5.4080700@trash.net>	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com> <20040828231529.051a73cc.davem@davemloft.net> <4132303C.2060807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090202080509080400070005"
Cc: "David S. Miller" <davem@davemloft.net>,
        David Stevens <dlstevens@us.ibm.com>, davem@redhat.com,
        laforge@netfilter.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4132303C.2060807@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090202080509080400070005
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:

> Attached. The first patch still crashed, we need to prevent new
> fragments from getting queued after the queue is flushed until the
> hook in unregistered.

The patch is racy, another CPU could already have passed the check
for ip_ct_no_defrag and queue the packet after __ip_evictor calculated
the work to do, so the packet (or another one) will not get evicted.
This patch on top calls synchronize_net() to prevent this.

>
>@@ -1181,6 +1183,12 @@
> #ifdef CONFIG_NETFILTER_DEBUG
> 	unsigned int olddebug = skb->nf_debug;
> #endif
>+
>+	if (unlikely(ip_ct_no_defrag)) {
>+		kfree_skb(skb);
>+		return NULL;
>+	}
>+
> 	if (sk) {
> 		sock_hold(sk);
> 		skb_orphan(skb);
>diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
>--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 20:55:13 +02:00
>+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 20:55:13 +02:00
>@@ -805,6 +805,12 @@
>  cleanup_defraglocalops:
> 	nf_unregister_hook(&ip_conntrack_defrag_local_out_ops);
>  cleanup_defragops:
>+	/* Frag queues may hold fragments with skb->dst == NULL */
>+	ip_ct_no_defrag = 1;
>+	smp_wmb();
>+	local_bh_disable();
>+	ipfrag_flush();
>+	local_bh_enable();
> 	nf_unregister_hook(&ip_conntrack_defrag_ops);
>  cleanup_proc_stat:
> 	proc_net_remove("ip_conntrack_stat");
>  
>


--------------090202080509080400070005
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/29 23:36:17+02:00 kaber@coreworks.de 
#   [NETFILTER]: Fix race when flushing fragment queue
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/08/29 23:35:54+02:00 kaber@coreworks.de +1 -1
#   [NETFILTER]: Fix race when flushing fragment queue
# 
diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 23:39:07 +02:00
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	2004-08-29 23:39:07 +02:00
@@ -807,7 +807,7 @@
  cleanup_defragops:
 	/* Frag queues may hold fragments with skb->dst == NULL */
 	ip_ct_no_defrag = 1;
-	smp_wmb();
+	synchronize_net();
 	local_bh_disable();
 	ipfrag_flush();
 	local_bh_enable();

--------------090202080509080400070005--
