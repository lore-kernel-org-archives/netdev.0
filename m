From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 9/9] inet: frag: set limits and make init_net's high_thresh limit global
Date: Thu, 24 Jul 2014 16:50:37 +0200
Message-ID: <1406213437-6155-10-git-send-email-nikolay@redhat.com>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Cc: Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933576AbaGXOwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 10:52:15 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes init_net's high_thresh limit to be the maximum for all
namespaces, thus introducing a global memory limit threshold equal to the
sum of the individual high_thresh limits which are capped.
It also introduces some sane minimums for low_thresh as it shouldn't be
able to drop below 0 (or > high_thresh in the unsigned case), and
overall low_thresh should not ever be above high_thresh, so we make the
following relations for a namespace:
init_net:
 high_thresh - max(not capped), min(init_net low_thresh)
 low_thresh - max(init_net high_thresh), min (0)

all other namespaces:
 high_thresh = max(init_net high_thresh), min(namespace's low_thresh)
 low_thresh = max(namespace's high_thresh), min(0)

The major issue with having low_thresh > high_thresh is that we'll
schedule eviction but never evict anything and thus rely only on the
timers.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 Documentation/networking/ip-sysctl.txt  |  3 ++-
 net/ieee802154/reassembly.c             | 12 ++++++++++--
 net/ipv4/ip_fragment.c                  | 10 ++++++++--
 net/ipv6/netfilter/nf_conntrack_reasm.c | 12 ++++++++++--
 net/ipv6/reassembly.c                   | 12 ++++++++++--
 5 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index e8c304e37831..29a93518bf18 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -101,7 +101,8 @@ ipfrag_high_thresh - INTEGER
 	Maximum memory used to reassemble IP fragments. When
 	ipfrag_high_thresh bytes of memory is allocated for this purpose,
 	the fragment handler will toss packets until ipfrag_low_thresh
-	is reached.
+	is reached. This also serves as a maximum limit to namespaces
+	different from the initial one.
 
 ipfrag_low_thresh - INTEGER
 	Maximum memory used to reassemble IP fragments before the kernel
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 8da635d92a58..f13d4f32e207 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -386,20 +386,25 @@ err:
 EXPORT_SYMBOL(lowpan_frag_rcv);
 
 #ifdef CONFIG_SYSCTL
+static int zero;
+
 static struct ctl_table lowpan_frags_ns_ctl_table[] = {
 	{
 		.procname	= "6lowpanfrag_high_thresh",
 		.data		= &init_net.ieee802154_lowpan.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &init_net.ieee802154_lowpan.frags.low_thresh
 	},
 	{
 		.procname	= "6lowpanfrag_low_thresh",
 		.data		= &init_net.ieee802154_lowpan.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &init_net.ieee802154_lowpan.frags.high_thresh
 	},
 	{
 		.procname	= "6lowpanfrag_time",
@@ -446,7 +451,10 @@ static int __net_init lowpan_frags_ns_sysctl_register(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &ieee802154_lowpan->frags.high_thresh;
+		table[0].extra1 = &ieee802154_lowpan->frags.low_thresh;
+		table[0].extra2 = &init_net.ieee802154_lowpan.frags.high_thresh;
 		table[1].data = &ieee802154_lowpan->frags.low_thresh;
+		table[1].extra2 = &ieee802154_lowpan->frags.high_thresh;
 		table[2].data = &ieee802154_lowpan->frags.timeout;
 		table[3].data = &ieee802154_lowpan->max_dsize;
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index ccee68dffd6e..634fc31aa243 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -700,14 +700,17 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &init_net.ipv4.frags.low_thresh
 	},
 	{
 		.procname	= "ipfrag_low_thresh",
 		.data		= &init_net.ipv4.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &init_net.ipv4.frags.high_thresh
 	},
 	{
 		.procname	= "ipfrag_time",
@@ -752,7 +755,10 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &net->ipv4.frags.high_thresh;
+		table[0].extra1 = &net->ipv4.frags.low_thresh;
+		table[0].extra2 = &init_net.ipv4.frags.high_thresh;
 		table[1].data = &net->ipv4.frags.low_thresh;
+		table[1].extra2 = &net->ipv4.frags.high_thresh;
 		table[2].data = &net->ipv4.frags.timeout;
 
 		/* Don't export sysctls to unprivileged users */
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 4d9da1e35f8c..3d4bccf6d67d 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -63,6 +63,8 @@ struct nf_ct_frag6_skb_cb
 static struct inet_frags nf_frags;
 
 #ifdef CONFIG_SYSCTL
+static int zero;
+
 static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_frag6_timeout",
@@ -76,14 +78,17 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 		.data		= &init_net.nf_frag.frags.low_thresh,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &init_net.nf_frag.frags.high_thresh
 	},
 	{
 		.procname	= "nf_conntrack_frag6_high_thresh",
 		.data		= &init_net.nf_frag.frags.high_thresh,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &init_net.nf_frag.frags.low_thresh
 	},
 	{ }
 };
@@ -102,7 +107,10 @@ static int nf_ct_frag6_sysctl_register(struct net *net)
 
 		table[0].data = &net->nf_frag.frags.timeout;
 		table[1].data = &net->nf_frag.frags.low_thresh;
+		table[1].extra2 = &net->nf_frag.frags.high_thresh;
 		table[2].data = &net->nf_frag.frags.high_thresh;
+		table[2].extra1 = &net->nf_frag.frags.low_thresh;
+		table[2].extra2 = &init_net.nf_frag.frags.high_thresh;
 	}
 
 	hdr = register_net_sysctl(net, "net/netfilter", table);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 57a9707b2032..f1709c4a289a 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -578,20 +578,25 @@ static const struct inet6_protocol frag_protocol =
 };
 
 #ifdef CONFIG_SYSCTL
+static int zero;
+
 static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
 		.procname	= "ip6frag_high_thresh",
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &init_net.ipv6.frags.low_thresh
 	},
 	{
 		.procname	= "ip6frag_low_thresh",
 		.data		= &init_net.ipv6.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &init_net.ipv6.frags.high_thresh
 	},
 	{
 		.procname	= "ip6frag_time",
@@ -628,7 +633,10 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 			goto err_alloc;
 
 		table[0].data = &net->ipv6.frags.high_thresh;
+		table[0].extra1 = &net->ipv6.frags.low_thresh;
+		table[0].extra2 = &init_net.ipv6.frags.high_thresh;
 		table[1].data = &net->ipv6.frags.low_thresh;
+		table[1].extra2 = &net->ipv6.frags.high_thresh;
 		table[2].data = &net->ipv6.frags.timeout;
 
 		/* Don't export sysctls to unprivileged users */
-- 
1.9.3
