From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v4 6/7] openvswitch: more accurate checksumming in queue_userspace_packet()
Date: Thu, 20 Apr 2017 15:38:12 +0200
Message-ID: <08b128001903268801d5406ee821f4365dbb987b.1492692976.git.dcaratti@redhat.com>
References: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33886 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S942869AbdDTNje (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 09:39:34 -0400
In-Reply-To: <CALx6S36rem=OuN_At6qYA=se5cpuYM1N2R8efoaszvo8b8Tz5A@mail.gmail.com>
In-Reply-To: <cover.1492692976.git.dcaratti@redhat.com>
References: <cover.1492692976.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if skb carries an SCTP packet and ip_summed is CHECKSUM_PARTIAL, it needs
CRC32c in place of Internet Checksum: use skb_csum_hwoffload_help to avoid
corrupting such packets while queueing them towards userspace.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/openvswitch/datapath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7b17da9..9ddc9f8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -453,7 +453,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 
 	/* Complete checksum if needed */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    (err = skb_checksum_help(skb)))
+	    (err = skb_csum_hwoffload_help(skb, 0)))
 		goto out;
 
 	/* Older versions of OVS user space enforce alignment of the last
-- 
2.7.4
