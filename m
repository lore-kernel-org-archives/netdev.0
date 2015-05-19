From: Dave Jones <davej@codemonkey.org.uk>
Subject: iptables: ensure number of counters is >0 in do_replace()
Date: Tue, 19 May 2015 19:11:20 -0400
Message-ID: <20150519231120.GA1761@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After improving setsockopt() coverage in trinity, I started triggering
vmalloc failures pretty reliably from this code path:

warn_alloc_failed+0xe9/0x140
__vmalloc_node_range+0x1be/0x270
vzalloc+0x4b/0x50
__do_replace+0x52/0x260 [ip_tables]
do_ipt_set_ctl+0x15d/0x1d0 [ip_tables]
nf_setsockopt+0x65/0x90
ip_setsockopt+0x61/0xa0
raw_setsockopt+0x16/0x60
sock_common_setsockopt+0x14/0x20
SyS_setsockopt+0x71/0xd0

It turns out we don't validate that the num_counters field in the
struct we pass in from userspace is initialized.

Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index c69db7fa25ee..12a33d178614 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1262,6 +1262,9 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 	/* overflow check */
 	if (tmp.num_counters >= INT_MAX / sizeof(struct xt_counters))
 		return -ENOMEM;
+	if (tmp.num_counters == 0)
+		return -EINVAL;
+
 	tmp.name[sizeof(tmp.name)-1] = 0;
 
 	newinfo = xt_alloc_table_info(tmp.size);
