From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2 net-next] ipv[4|6]: correct dropwatch false positive in local_deliver_finish
Date: Fri,  1 Mar 2013 12:44:08 -0500
Message-ID: <1362159848-8530-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	William Reich <reich@ulticom.com>, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56540 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab3CARoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 12:44:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I had a report recently of a user trying to use dropwatch to localise some frame
loss, and they were getting false positives.  Turned out they were using a user
space SCTP stack that used raw sockets to grab frames.  When we don't have a
registered protocol for a given packet, we record it as a drop, even if a raw
socket receieves the frame.  We should only record the drop in the event a raw
socket doesnt exist to receive the frames

Tested by the reported successfully

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Reported-by: William Reich <reich@ulticom.com>
Tested-by: William Reich <reich@ulticom.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: William Reich <reich@ulticom.com>
CC: eric.dumazet@gmail.com
---
 net/ipv4/ip_input.c  | 6 ++++--
 net/ipv6/ip6_input.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 87abd3e..2bdf802 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -228,9 +228,11 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 					icmp_send(skb, ICMP_DEST_UNREACH,
 						  ICMP_PROT_UNREACH, 0);
 				}
-			} else
+				kfree_skb(skb);
+			} else {
 				IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
-			kfree_skb(skb);
+				consume_skb(skb);
+			}
 		}
 	}
  out:
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 5b10414..b1876e5 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -241,9 +241,11 @@ resubmit:
 				icmpv6_send(skb, ICMPV6_PARAMPROB,
 					    ICMPV6_UNK_NEXTHDR, nhoff);
 			}
-		} else
+			kfree_skb(skb);
+		} else {
 			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
-		kfree_skb(skb);
+			consume_skb(skb);
+		}
 	}
 	rcu_read_unlock();
 	return 0;
-- 
1.7.11.7
