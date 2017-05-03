From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/16] netfilter: xt_socket: Fix broken IPv6 handling
Date: Wed,  3 May 2017 11:32:04 +0200
Message-ID: <1493803931-2837-10-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45692 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752983AbdECJcf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 05:32:35 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2BDC71C4FE3
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1A985FF124
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:26 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 066A4FF2D3
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:24 +0200 (CEST)
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tirsek <peter@tirsek.com>

Commit 834184b1f3a4 ("netfilter: defrag: only register defrag
functionality if needed") used the outdated XT_SOCKET_HAVE_IPV6 macro
which was removed earlier in commit 8db4c5be88f6 ("netfilter: move
socket lookup infrastructure to nf_socket_ipv{4,6}.c"). With that macro
never being defined, the xt_socket match emits an "Unknown family 10"
warning when used with IPv6:

WARNING: CPU: 0 PID: 1377 at net/netfilter/xt_socket.c:160 socket_mt_enable_defrag+0x47/0x50 [xt_socket]
Unknown family 10
Modules linked in: xt_socket nf_socket_ipv4 nf_socket_ipv6 nf_defrag_ipv4 [...]
CPU: 0 PID: 1377 Comm: ip6tables-resto Not tainted 4.10.10 #1
Hardware name: [...]
Call Trace:
? __warn+0xe7/0x100
? socket_mt_enable_defrag+0x47/0x50 [xt_socket]
? socket_mt_enable_defrag+0x47/0x50 [xt_socket]
? warn_slowpath_fmt+0x39/0x40
? socket_mt_enable_defrag+0x47/0x50 [xt_socket]
? socket_mt_v2_check+0x12/0x40 [xt_socket]
? xt_check_match+0x6b/0x1a0 [x_tables]
? xt_find_match+0x93/0xd0 [x_tables]
? xt_request_find_match+0x20/0x80 [x_tables]
? translate_table+0x48e/0x870 [ip6_tables]
? translate_table+0x577/0x870 [ip6_tables]
? walk_component+0x3a/0x200
? kmalloc_order+0x1d/0x50
? do_ip6t_set_ctl+0x181/0x490 [ip6_tables]
? filename_lookup+0xa5/0x120
? nf_setsockopt+0x3a/0x60
? ipv6_setsockopt+0xb0/0xc0
? sock_common_setsockopt+0x23/0x30
? SyS_socketcall+0x41d/0x630
? vfs_read+0xfa/0x120
? do_fast_syscall_32+0x7a/0x110
? entry_SYSENTER_32+0x47/0x71

This patch brings the conditional back in line with how the rest of the
file handles IPv6.

Fixes: 834184b1f3a4 ("netfilter: defrag: only register defrag functionality if needed")
Signed-off-by: Peter Tirsek <peter@tirsek.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 770bbec878f1..e75ef39669c5 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -152,7 +152,7 @@ static int socket_mt_enable_defrag(struct net *net, int family)
 	switch (family) {
 	case NFPROTO_IPV4:
 		return nf_defrag_ipv4_enable(net);
-#ifdef XT_SOCKET_HAVE_IPV6
+#if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
 		return nf_defrag_ipv6_enable(net);
 #endif
-- 
2.1.4
