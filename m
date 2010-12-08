From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] SCTP: Fix SCTP_SET_PEER_PRIMARY_ADDR to accpet v4mapped address
Date: Wed, 08 Dec 2010 11:11:09 +0800
Message-ID: <4CFEF74D.7020704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62492 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab0LHDLl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 22:11:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP_SET_PEER_PRIMARY_ADDR does not accpet v4mapped address, using
v4mapped address in SCTP_SET_PEER_PRIMARY_ADDR socket option will
get -EADDRNOTAVAIL error if v4map is enabled. This patch try to
fix it by mapping v4mapped address to v4 address if allowed.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/socket.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6bd5543..0b9ee34 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2932,6 +2932,7 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
 	struct sctp_association	*asoc = NULL;
 	struct sctp_setpeerprim	prim;
 	struct sctp_chunk	*chunk;
+	struct sctp_af		*af;
 	int 			err;
 
 	sp = sctp_sk(sk);
@@ -2959,6 +2960,13 @@ static int sctp_setsockopt_peer_primary_addr(struct sock *sk, char __user *optva
 	if (!sctp_state(asoc, ESTABLISHED))
 		return -ENOTCONN;
 
+	af = sctp_get_af_specific(prim.sspp_addr.ss_family);
+	if (!af)
+		return -EINVAL;
+
+	if (!af->addr_valid((union sctp_addr *)&prim.sspp_addr, sp, NULL))
+		return -EADDRNOTAVAIL;
+
 	if (!sctp_assoc_lookup_laddr(asoc, (union sctp_addr *)&prim.sspp_addr))
 		return -EADDRNOTAVAIL;
 


