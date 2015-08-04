From: Wenyu Zhang <wenyuz@vmware.com>
Subject: [PATCH net-next v2] openvswitch: Make 100 percents packets sampled when sampling rate is 1.
Date: Mon, 3 Aug 2015 21:07:35 -0700
Message-ID: <1438661255-22103-1-git-send-email-wenyuz@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <wenyuz@vmware.com>, <jgross@vmware.com>, <dev@openvswitch.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:45935 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751227AbbHDEHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 00:07:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sampling rate is 1, the sampling probability is UINT32_MAX. The packet
should be sampled even the prandom_u32() generate the number of UINT32_MAX.
And none packet need be sampled when the probability is 0.

Signed-off-by: Wenyu Zhang <wenyuz@vmware.com>
---
 net/openvswitch/actions.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index cf04c2f..c81bcf5 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -669,9 +669,11 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
+		uint32_t probability;
 		switch (nla_type(a)) {
 		case OVS_SAMPLE_ATTR_PROBABILITY:
-			if (prandom_u32() >= nla_get_u32(a))
+			probability = nla_get_u32(a);
+			if (!probability || prandom_u32() > probability)
 				return 0;
 			break;
 
-- 
1.7.9.5
