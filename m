From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 2/2] openvswitch: fix a sparse warning
Date: Mon,  6 Oct 2014 13:22:51 -0700
Message-ID: <1412626971-30271-2-git-send-email-azhou@nicira.com>
References: <1412626971-30271-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:45934 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751011AbaJFU25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 16:28:57 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so5921175pad.29
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 13:28:56 -0700 (PDT)
In-Reply-To: <1412626971-30271-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a sparse warning introduced by commit:
f5796684069e0c71c65bce6a6d4766114aec1396 (openvswitch: Add support for
Geneve tunneling.) caught by kbuild test robot:

reproduce:
  # apt-get install sparse
  #   git checkout f5796684069e0c71c65bce6a6d4766114aec1396
  #     make ARCH=x86_64 allmodconfig
  #       make C=1 CF=-D__CHECK_ENDIAN__
  #
  #
  #       sparse warnings: (new ones prefixed by >>)
  #
  #       >> net/openvswitch/vport-geneve.c:109:15: sparse: incorrect type in assignment (different base types)
  #          net/openvswitch/vport-geneve.c:109:15:    expected restricted __be16 [usertype] sport
  #             net/openvswitch/vport-geneve.c:109:15:    got int
  #             >> net/openvswitch/vport-geneve.c:110:56: sparse: incorrect type in argument 3 (different base types)
  #                net/openvswitch/vport-geneve.c:110:56:    expected unsigned short [unsigned] [usertype] value
  #                   net/openvswitch/vport-geneve.c:110:56:    got restricted __be16 [usertype] sport

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/vport-geneve.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 5572d48..910b3ef 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -104,10 +104,9 @@ static int geneve_get_options(const struct vport *vport,
 			      struct sk_buff *skb)
 {
 	struct geneve_port *geneve_port = geneve_vport(vport);
-	__be16 sport;
+	struct inet_sock *sk = inet_sk(geneve_port->gs->sock->sk);
 
-	sport = ntohs(inet_sk(geneve_port->gs->sock->sk)->inet_sport);
-	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, sport))
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(sk->inet_sport)))
 		return -EMSGSIZE;
 	return 0;
 }
-- 
1.7.9.5
