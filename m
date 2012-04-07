From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] net/ipv6/exthdrs.c et al: Optional strict PadN option checking
Date: Sat,  7 Apr 2012 12:44:27 +0200
Message-ID: <1333795467-3643-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	atrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added strict checking of PadN, which can be used to increase header
size and thus push the protocol header into the 2nd fragment.

PadN is used to align the options within the Hop-by-Hop or
Destination Options header to 64-bit boundaries. The maximum valid
size is thus 7 bytes.
RFC 4942 recommends to actively check the "payload" itself and
ensure that it contains only zeroes.

See also RFC 4942 section 2.1.9.5.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 Documentation/networking/ip-sysctl.txt |    7 +++++++
 include/net/ipv6.h                     |    4 ++++
 net/ipv6/Kconfig                       |   14 ++++++++++++++
 net/ipv6/exthdrs.c                     |   22 ++++++++++++++++++++++
 net/ipv6/sysctl_net_ipv6.c             |    7 +++++++
 5 files changed, 54 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ad3e80e..abaa1cf 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1007,6 +1007,13 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+padn_strict - BOOLEAN
+	Perform strict checking of PadN.
+		TRUE: enable strict PadN checking
+		FALSE: disable strict PadN checking
+
+	Default: FALSE
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e4170a2..1458915 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -115,6 +115,10 @@ struct frag_hdr {
 extern int sysctl_mld_max_msf;
 extern struct ctl_path net_ipv6_ctl_path[];
 
+#if defined(CONFIG_IPV6_PADN_STRICT)
+extern int sysctl_padn_strict;
+#endif
+
 #define _DEVINC(net, statname, modifier, idev, field)			\
 ({									\
 	struct inet6_dev *_idev = (idev);				\
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 36d7437..a10a684 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -250,4 +250,18 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_PADN_STRICT
+	bool "IPv6: Strict PadN processing"
+	---help---
+	  This enables strict processing of PadN (See RFC 4942, Section
+	  2.1.9.5). Any packet with PadN exceeding the length of 7 is
+	  dropped, as well as with packets with non-zero PadN payload.
+
+	  By default the kernel does not perform these checks.
+	  To enable them, use the following command:
+
+	    echo 1 >/proc/sys/net/ipv6/padn_strict
+
+	  If unsure, say N.
+
 endif # IPV6
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index c486b8e..e04d4ff 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -49,6 +49,10 @@
 
 #include <asm/uaccess.h>
 
+#if defined(CONFIG_IPV6_PADN_STRICT)
+int sysctl_padn_strict;
+#endif
+
 int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
 {
 	const unsigned char *nh = skb_network_header(skb);
@@ -160,7 +164,25 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 			break;
 
 		case IPV6_TLV_PADN:
+#if defined(CONFIG_IPV6_PADN_STRICT)
+			if (sysctl_padn_strict) {
+				int i;
+				/* RFC 2460 states that the purpose of PadN is
+				   to align the containing header to multiples
+				   of 8. 7 is therefore the highest valid value.
+				   See also RFC 4942, Section 2.1.9.5.*/
+				if (optlen > 7)
+					goto bad;
+				/* RFC 4942 recommends receiving hosts to
+				   actively check PadN payload to contain
+				   only zeroes. */
+				for (i = 2; i < optlen; i++) {
+					if (nh[off + i] != 0)
+						goto bad;
+				}
+			}
 			break;
+#endif
 
 		default: /* Other TLV code so scan list */
 			if (optlen > len)
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 166a57c..c7f07f9 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -48,6 +48,13 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "padn_strict",
+		.data		= &sysctl_padn_strict,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
-- 
1.7.9.5
