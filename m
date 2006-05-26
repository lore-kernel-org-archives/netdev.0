From: Marcel Holtmann <marcel@holtmann.org>
Subject: Fix SO_ORIGINAL_DST information leak (CVE-2006-1343)
Date: Fri, 26 May 2006 13:50:46 +0200
Message-ID: <1148644246.21881.7.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YiLIIAwAaTxnzi8MHWhH"
Cc: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:469 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S932350AbWEZLvQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 07:51:16 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-YiLIIAwAaTxnzi8MHWhH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

the fix for CVE-2006-1343 (information leak) never made it upstream:

http://marc.theaimsgroup.com/?l=linux-netdev&m=114148078223594&w=2

So here it is again against the latest git repository and with the
additional line in net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c.

Regards

Marcel


--=-YiLIIAwAaTxnzi8MHWhH
Content-Disposition: attachment; filename=patch
Content-Type: text/plain; name=patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

[PATCH] Fix small information leak in SO_ORIGINAL_DST

It appears that sockaddr_in.sin_zero is not zeroed during
getsockopt(...SO_ORIGINAL_DST...) operation. This can lead
to an information leak (CVE-2006-1343).

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

---
commit 8b9b62a6bb6c5488fd094d97216787e191721a15
tree fac8f79c318f37d4cb6795e540b77be61c9d1f5d
parent 705af309505681f197f81618440954d10f120dc0
author Marcel Holtmann <marcel@holtmann.org> Fri, 26 May 2006 13:45:42 +0200
committer Marcel Holtmann <marcel@holtmann.org> Fri, 26 May 2006 13:45:42 +0200

 net/ipv4/netfilter/ip_conntrack_core.c         |    1 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
index 979a2ea..a297da7 100644
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -1318,6 +1318,7 @@ getorigdst(struct sock *sk, int optval, 
 			.tuple.dst.u.tcp.port;
 		sin.sin_addr.s_addr = ct->tuplehash[IP_CT_DIR_ORIGINAL]
 			.tuple.dst.ip;
+		memset(sin.sin_zero, 0, sizeof(sin.sin_zero));
 
 		DEBUGP("SO_ORIGINAL_DST: %u.%u.%u.%u %u\n",
 		       NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 5bc9f64..77d9744 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -348,6 +348,7 @@ getorigdst(struct sock *sk, int optval, 
 			.tuple.dst.u.tcp.port;
 		sin.sin_addr.s_addr = ct->tuplehash[IP_CT_DIR_ORIGINAL]
 			.tuple.dst.u3.ip;
+		memset(sin.sin_zero, 0, sizeof(sin.sin_zero));
 
 		DEBUGP("SO_ORIGINAL_DST: %u.%u.%u.%u %u\n",
 		       NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));

--=-YiLIIAwAaTxnzi8MHWhH--

