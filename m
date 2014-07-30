From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH net-next] pktgen: add ttl option for pktgen
Date: Wed, 30 Jul 2014 16:21:26 +0800
Message-ID: <1406708486-23427-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: <rdunlap@infradead.org>, <davem@davemloft.net>,
	<minipli@googlemail.com>, <brouer@redhat.com>,
	<steffen.klassert@secunet.com>, <fan.du@windriver.com>,
	<dborkman@redhat.com>, <fengguang.wu@intel.com>, <tgraf@suug.ch>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it is useful to add ttl option for pktgen, for example
if a some ISP want to test its network quality, it could set 
ttl so that the tested links get the packet while end users won't
get it. 

Also, add a blank line after declarations in pktgen.c

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
---
 Documentation/networking/pktgen.txt |    2 +-
 net/core/pktgen.c                   |   24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networking/pktgen.txt
index 0dffc6e..abad388 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -180,7 +180,7 @@ Examples:
  pgset "vlan_id 9999"     > 4095 remove vlan and svlan tags
  pgset "svlan 9999"       > 4095 remove svlan tag
 
-
+ pgset "ttl xx"           set former IPv4 TTL field (default 32)
  pgset "tos XX"           set former IPv4 TOS field (e.g. "tos 28" for AF11 no ECN, default 00)
  pgset "traffic_class XX" set former IPv6 TRAFFIC CLASS (e.g. "traffic_class B8" for EF no ECN, default 00)
 
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849dd..54cb750 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -318,6 +318,8 @@ struct pktgen_dev {
 	__u16 udp_dst_min;	/* inclusive, dest UDP port */
 	__u16 udp_dst_max;	/* exclusive, dest UDP port */
 
+	__u8 ttl;            /* time to live */
+
 	/* DSCP + ECN */
 	__u8 tos;            /* six MSB of (former) IPv4 TOS
 				are for dscp codepoint */
@@ -606,6 +608,8 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 			   pkt_dev->svlan_id, pkt_dev->svlan_p,
 			   pkt_dev->svlan_cfi);
 
+	seq_printf(seq, "     ttl: 0x%02x\n", pkt_dev->ttl);
+
 	if (pkt_dev->tos)
 		seq_printf(seq, "     tos: 0x%02x\n", pkt_dev->tos);
 
@@ -1667,8 +1671,26 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 
+	if (!strcmp(name, "ttl")) {
+		__u32 tmp_value = 0;
+
+		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		if (len == 2) {
+			pkt_dev->ttl = tmp_value;
+			sprintf(pg_result, "OK: ttl=0x%02x", pkt_dev->ttl);
+		} else {
+			sprintf(pg_result, "ERROR: tos must be 00-ff");
+		}
+		return count;
+	}
+
 	if (!strcmp(name, "tos")) {
 		__u32 tmp_value = 0;
+
 		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
 		if (len < 0)
 			return len;
@@ -1685,6 +1707,7 @@ static ssize_t pktgen_if_write(struct file *file,
 
 	if (!strcmp(name, "traffic_class")) {
 		__u32 tmp_value = 0;
+
 		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
 		if (len < 0)
 			return len;
@@ -3558,6 +3581,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->udp_src_max = 9;
 	pkt_dev->udp_dst_min = 9;
 	pkt_dev->udp_dst_max = 9;
+	pkt_dev->ttl = 32;
 	pkt_dev->vlan_p = 0;
 	pkt_dev->vlan_cfi = 0;
 	pkt_dev->vlan_id = 0xffff;
-- 
1.7.1

