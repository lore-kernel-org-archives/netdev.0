From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 2/2] tc: flower: Allow *_mac options to accept a mask
Date: Fri, 16 Dec 2016 14:54:37 +0100
Message-ID: <1481896477-13497-3-git-send-email-simon.horman@netronome.com>
References: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36870 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934934AbcLPODd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 09:03:33 -0500
Received: by mail-wm0-f47.google.com with SMTP id t79so36176070wmt.0
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 06:03:32 -0800 (PST)
In-Reply-To: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* The argument to src_mac and dst_mac may now take an optional mask
  to limit the scope of matching.
* This address is is documented as a LLADDR in keeping with ip-link(8).
* The formats accepted match those already output when dumping flower
  filters from the kernel.

Example of use of LLADDR with and without a mask:

tc qdisc add dev eth0 ingress
tc filter add dev eth0 protocol ip parent ffff: flower indev eth0 \
	src_mac 52:54:01:00:00:00/ff:ff:00:00:00:01 action drop
tc filter add dev eth0 protocol ip parent ffff: flower indev eth0 \
	src_mac 52:54:00:00:00:00/23 action drop
tc filter add dev eth0 protocol ip parent ffff: flower indev eth0 \
	src_mac 52:54:00:00:00:00 action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 13 +++++++++----
 tc/f_flower.c        | 43 ++++++++++++++++++++++++++++++++++++-------
 2 files changed, 45 insertions(+), 11 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index a383b6584dc6..31c7d3b32f9b 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -22,7 +22,7 @@ flower \- flow based traffic control filter
 .BR skip_sw " | " skip_hw
 .R " | { "
 .BR dst_mac " | " src_mac " } "
-.IR mac_address " | "
+.IR MASKED_LLADDR " | "
 .B vlan_id
 .IR VID " | "
 .B vlan_prio
@@ -74,10 +74,15 @@ filter, or TC offload is not enabled for the interface, operation will fail.
 .BI skip_hw
 Do not process filter by hardware.
 .TP
-.BI dst_mac " mac_address"
+.BI dst_mac " MASKED_LLADDR"
 .TQ
-.BI src_mac " mac_address"
-Match on source or destination MAC address.
+.BI src_mac " MASKED_LLADDR"
+Match on source or destination MAC address.  A mask may be optionally
+provided to limit the bits of the address which are matched. A mask is
+provided by following the address with a slash and then the mask. It may be
+provided in LLADDR format, in which case it is a bitwise mask, or as a
+number of high bits to match. If the mask is missing then a match on all
+bits is assumed.
 .TP
 .BI vlan_id " VID"
 Match on vlan tag id.
diff --git a/tc/f_flower.c b/tc/f_flower.c
index cdf74344f78f..6d9a3b70afed 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -45,8 +45,8 @@ static void explain(void)
 		"                       vlan_id VID |\n"
 		"                       vlan_prio PRIORITY |\n"
 		"                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n"
-		"                       dst_mac MAC-ADDR |\n"
-		"                       src_mac MAC-ADDR |\n"
+		"                       dst_mac MASKED-LLADDR |\n"
+		"                       src_mac MASKED-LLADDR |\n"
 		"                       ip_proto [tcp | udp | sctp | icmp | icmpv6 | IP-PROTO ] |\n"
 		"                       dst_ip PREFIX |\n"
 		"                       src_ip PREFIX |\n"
@@ -58,6 +58,7 @@ static void explain(void)
 		"                       enc_src_ip PREFIX |\n"
 		"                       enc_key_id [ KEY-ID ] }\n"
 		"       FILTERID := X:Y:Z\n"
+		"       MASKED_LLADDR := { LLADDR | LLADDR/MASK | LLADDR/BITS }\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
 		"\n"
 		"NOTE: CLASSID, IP-PROTO are parsed as hexadecimal input.\n"
@@ -68,16 +69,44 @@ static void explain(void)
 static int flower_parse_eth_addr(char *str, int addr_type, int mask_type,
 				 struct nlmsghdr *n)
 {
-	int ret;
-	char addr[ETH_ALEN];
+	int ret, err = -1;
+	char addr[ETH_ALEN], *slash;
+
+	slash = strchr(str, '/');
+	if (slash)
+		*slash = '\0';
 
 	ret = ll_addr_a2n(addr, sizeof(addr), str);
 	if (ret < 0)
-		return -1;
+		goto err;
 	addattr_l(n, MAX_MSG, addr_type, addr, sizeof(addr));
-	memset(addr, 0xff, ETH_ALEN);
+
+	if (slash) {
+		unsigned bits;
+
+		if (!get_unsigned(&bits, slash + 1, 10)) {
+			uint64_t mask;
+
+			/* Extra 16 bit shift to push mac address into
+			 * high bits of uint64_t
+			 */
+			mask = htonll(0xffffffffffffULL << (16 + 48 - bits));
+			memcpy(addr, &mask, ETH_ALEN);
+		} else {
+			ret = ll_addr_a2n(addr, sizeof(addr), slash + 1);
+			if (ret < 0)
+				goto err;
+		}
+	} else {
+		memset(addr, 0xff, ETH_ALEN);
+	}
 	addattr_l(n, MAX_MSG, mask_type, addr, sizeof(addr));
-	return 0;
+
+	err = 0;
+err:
+	if (slash)
+		*slash = '/';
+	return err;
 }
 
 static int flower_parse_vlan_eth_type(char *str, __be16 eth_type, int type,
-- 
2.7.0.rc3.207.g0ac5344
