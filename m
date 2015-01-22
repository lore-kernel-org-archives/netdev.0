From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/2] flow_dissector: add tipc
	support
Date: Thu, 22 Jan 2015 17:10:32 +0100
Message-ID: <1421943032-29924-2-git-send-email-erik.hugne@ericsson.com>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Erik Hugne <erik.hugne@ericsson.com>

The flows are hashed on the sending node address, which allows us
to spread out the TIPC link processing to RPS enabled cores. There
is no point to include the destination address in the hash as that
will always be the same for all inbound links. We have experimented
with a 3-tuple hash over [srcnode, sport, dport], but this showed to
give slightly lower performance because of increased lock contention
when the same link was handled by multiple cores.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/core/flow_dissector.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 4508493..beb83d1 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -178,6 +178,20 @@ ipv6:
 			return false;
 		}
 	}
+	case htons(ETH_P_TIPC): {
+		struct {
+			__be32 pre[3];
+			__be32 srcnode;
+		} *hdr, _hdr;
+		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
+		if (!hdr)
+			return false;
+		flow->src = hdr->srcnode;
+		flow->dst = 0;
+		flow->n_proto = proto;
+		flow->thoff = (u16)nhoff;
+		return true;
+	}
 	case htons(ETH_P_FCOE):
 		flow->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
-- 
2.1.3


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
