From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Tue, 10 Mar 2009 19:01:51 +0300
Message-ID: <20090310160151.GA13742@ioremap.net>
References: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:37650 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756673AbZCJQB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 12:01:58 -0400
Content-Disposition: inline
In-Reply-To: <20090310151357.GA10658@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 06:13:57PM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> Passive OS fingerprinting netfilter module allows to passively detect
> remote OS and perform various netfilter actions based on that knowledge.
> This module compares some data (WS, MSS, options and it's order, ttl, df
> and others) from packets with SYN bit set with dynamically loaded OS
> fingerprints.
> 
> Fingerprint matching rules can be downloaded from OpenBSD source tree
> and loaded via netlink connector into the kernel via special util found
> in archive. It will also listen for events about matching packets.
> 
> Archive also contains library file (also attached), which was shipped
> with iptables extensions some time ago (at least when ipt_osf existed
> in patch-o-matic).
> 
> This release implements suggestions found during the code review like
> codying style, structure split and tighter packing, bool and %pi4
> usage and similar changes.

Not the latest version, it misses the following fix from the parallel
tree.

    Fixed TCP header copy to the userspace when given option is enabled.

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 3114bbd..e619f09 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -83,7 +83,7 @@ static void ipt_osf_send_connector(struct ipt_osf_user_finger *f,
 	struct ipt_osf_message *msg = &per_cpu(ipt_osf_mbuf, smp_processor_id());
 	struct ipt_osf_nlmsg *data = &msg->nlmsg;
 	struct iphdr *iph = ip_hdr(skb);
-	struct tcphdr *tcph = tcp_hdr(skb);
+	struct tcphdr *tcp;
 
 	memcpy(&msg->cmsg.id, &cn_osf_id, sizeof(struct cn_msg));
 	msg->cmsg.seq = osf_seq++;
@@ -92,7 +92,9 @@ static void ipt_osf_send_connector(struct ipt_osf_user_finger *f,
 
 	memcpy(&data->f, f, sizeof(struct ipt_osf_user_finger));
 	memcpy(&data->ip, iph, sizeof(struct iphdr));
-	memcpy(&data->tcp, tcph, sizeof(struct tcphdr));
+	tcp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(struct tcphdr), &data->tcp);
+	if (tcp)
+		memcpy(&data->tcp, tcp, sizeof(struct tcphdr));
 
 	cn_netlink_send(&msg->cmsg, CN_IDX_OSF, GFP_ATOMIC);
 }


-- 
	Evgeniy Polyakov
