From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's bind address list
Date: Fri, 19 Aug 2016 19:30:22 +0800
Message-ID: <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
 <4d3c7b176bc8d5c48807ed60d83793c9d02e3757.1471605833.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36124 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751817AbcHSLch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 07:32:37 -0400
In-Reply-To: <4d3c7b176bc8d5c48807ed60d83793c9d02e3757.1471605833.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1471605833.git.lucien.xin@gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lxin@redhat.com>

sctp.local_addr_list is a global address list that is supposed to include
all the local addresses. sctp updates this list according to NETDEV_UP/
NETDEV_DOWN notifications.

However, if multiple NICs have the same address, the global list will
have duplicate addresses. Even if for one NIC, promote secondaries in
__inet_del_ifa can also lead to accumulating duplicate addresses.

When sctp binds address 'ANY' and creates a connection, it copies all
the addresses from global list into asoc's bind addr list, which makes
sctp pack the duplicate addresses into INIT/INIT_ACK packets.

This patch is to filter the duplicate addresses when copying the addrs
from global list in sctp_copy_local_addr_list and unpacking addr_param
from cookie in sctp_raw_to_bind_addrs to asoc's bind addr list.

Signed-off-by: Xin Long <lxin@redhat.com>
---
 net/sctp/bind_addr.c | 3 +++
 net/sctp/protocol.c  | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 401c607..1ebc184 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -292,6 +292,8 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
 		}
 
 		af->from_addr_param(&addr, rawaddr, htons(port), 0);
+		if (sctp_bind_addr_state(bp, &addr) != -1)
+			goto next;
 		retval = sctp_add_bind_addr(bp, &addr, sizeof(addr),
 					    SCTP_ADDR_SRC, gfp);
 		if (retval) {
@@ -300,6 +302,7 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
 			break;
 		}
 
+next:
 		len = ntohs(param->length);
 		addrs_len -= len;
 		raw_addr_list += len;
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index da5d82b..616a942 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -220,6 +220,9 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
 		     !(copy_flags & SCTP_ADDR6_PEERSUPP)))
 			continue;
 
+		if (sctp_bind_addr_state(bp, &addr->a) != -1)
+			continue;
+
 		error = sctp_add_bind_addr(bp, &addr->a, sizeof(addr->a),
 					   SCTP_ADDR_SRC, GFP_ATOMIC);
 		if (error)
-- 
2.1.0
