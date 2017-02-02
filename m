From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add LINUX_MIB_PFMEMALLOCDROP counter
Date: Wed, 01 Feb 2017 20:47:59 -0800
Message-ID: <1486010879.13103.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Josef Bacik <jbacik@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35659 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdBBEsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 23:48:01 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so662265pge.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 20:48:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Debugging issues caused by pfmemalloc is often tedious.

Add a new SNMP counter to more easily diagnose these problems.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Josef Bacik <jbacik@fb.com>
---
 include/uapi/linux/snmp.h |    1 +
 net/core/filter.c         |    5 +++--
 net/ipv4/proc.c           |    1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index e7a31f8306903f53bc5881ae4c271f85cad2e361..3b2bed7ca9a4d92c5671e614f2bc598668805f75 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -240,6 +240,7 @@ enum
 	LINUX_MIB_SACKMERGED,
 	LINUX_MIB_SACKSHIFTFALLBACK,
 	LINUX_MIB_TCPBACKLOGDROP,
+	LINUX_MIB_PFMEMALLOCDROP,
 	LINUX_MIB_TCPMINTTLDROP, /* RFC 5082 */
 	LINUX_MIB_TCPDEFERACCEPTDROP,
 	LINUX_MIB_IPRPFILTER, /* IP Reverse Path Filter (rp_filter) */
diff --git a/net/core/filter.c b/net/core/filter.c
index 1e00737e3bc370bc6c1afaf602439c81208ea3ac..0b753cbb2536763de53d266c9b9126d63942d7e5 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -76,9 +76,10 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 	 * allow SOCK_MEMALLOC sockets to use it as this socket is
 	 * helping free memory
 	 */
-	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
+	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC)) {
+		NET_INC_STATS(sock_net(sk), LINUX_MIB_PFMEMALLOCDROP);
 		return -ENOMEM;
-
+	}
 	err = BPF_CGROUP_RUN_PROG_INET_INGRESS(sk, skb);
 	if (err)
 		return err;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index a9deeb90dd36e0a8f94596b4f563ad63925344cf..69cf49e8356d0184f774840c9dc96560f2ae2f2b 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -262,6 +262,7 @@ static const struct snmp_mib snmp4_net_list[] = {
 	SNMP_MIB_ITEM("TCPSackMerged", LINUX_MIB_SACKMERGED),
 	SNMP_MIB_ITEM("TCPSackShiftFallback", LINUX_MIB_SACKSHIFTFALLBACK),
 	SNMP_MIB_ITEM("TCPBacklogDrop", LINUX_MIB_TCPBACKLOGDROP),
+	SNMP_MIB_ITEM("PFMemallocDrop", LINUX_MIB_PFMEMALLOCDROP),
 	SNMP_MIB_ITEM("TCPMinTTLDrop", LINUX_MIB_TCPMINTTLDROP),
 	SNMP_MIB_ITEM("TCPDeferAcceptDrop", LINUX_MIB_TCPDEFERACCEPTDROP),
 	SNMP_MIB_ITEM("IPReversePathFilter", LINUX_MIB_IPRPFILTER),
