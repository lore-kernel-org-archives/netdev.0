From: Qasim Javed <qasimj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: Use correct originator sequence number in a Path
	Reply
Date: Fri, 25 May 2012 00:02:15 -0500
Message-ID: <1337922135-27846-1-git-send-email-qasimj@gmail.com>
Reply-To: devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ravip-DNmUmOh1Rg72fBVCVOL8/A@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Return-path: <devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://lists.open80211s.org/cgi-bin/mailman/options/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open80211s.org/pipermail/devel>
List-Post: <mailto:devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open80211s.org/cgi-bin/mailman/listinfo/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Errors-To: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I have been doing some experiments using the 802.11s functionality in the mac80211 stack. Today I stumbled across something which I believe is a critical bug in the usage of originator sequence number for a Path Reply message upon the reception of a Path Request message.

Consider the following topology:

                    +---+
                    | S |
                    +---+
                  /      \
                 /        \
            +---+          +---+
            | A |          | B |
            +---+          +---+
                 \         /
                  \       /
                    +---+
                    | D |
                    +---+

Node S is the source node and D the destination. Clearly there are two possible paths from S to D namely S->A->D and S->B->D. When S wants to communicate with D, it will broadcast a Path Request (PREQ) where the originator will be S and target will be D. On receiving the PREQ, both A and B will broadcast it further to D. Let us assume that aggregate value of the metric for path D->B->S denoted by cost(DBS) is greater than cost(DAS). Notice that according to HWMP operation, when the PREQ is propagating from S to D, the cost on the "reverse" path is aggregated, that is why I used cost(DB) + cost(BS) for cost(DBS) and did not consider cost(SBD). Suppose also that smaller the metric the better it is which is the case for the default airtime link metric used by the 802.11s stack.

Let us suppose that the PREQ which passes through B arrives first at D and as mentioned earlier has a larger (worse) value than the soon to be received PREQ through the intermediate hop A. When D receives a PREQ from B, since it has not received any other PREQ, it generates a Path Reply (PREP). More specifically, the function hwmp_preq_frame_process generates the PREP. The PREQ contains originator and target sequence numbers which are used to avoid loops and ascertain the freshness of route information. On receiving a PREQ at D, the above mentioned function checks whether dot11MeshHWMPnetDiameterTraversalTime have elapsed since the last sequence number update (stored in ifmsh->last_sn_update). So suppose this is true when the first PREQ via B is received at D. So, in this case the originat
 or sequence number in PREP is incremented (that is becomes one more than the target sequence number in the PREQ).

Let us look at an example at this point. Suppose, the the originator sequence number in the PREQ is 1 and the target sequence number is 2. When this PREQ is received at D via B, and considering that dot11MeshHWMPnetDiameterTraversalTime have passed since the last sequence number update, we will increment the target sequence number which now becomes 3. Now for the PREP, the originator sequence number of PREQ, 1 in this case, becomes the target sequence number of PREP and the target sequence number of the PREQ (which has been updated and its value is 3) becomes the originator sequence number of the PREP.

As this PREQ which was received at D via B has a larger metric, we know that when the PREQ from S is received via A, it will have a lower (better) metric, hence we will also generate a PREP for that PREQ. Suppose the second PREQ via A is received at D within dot11MeshHWMPnetDiameterTraversalTime (currently 50ms). This is a reasonable assumption since the PREQ is broadcast by S and further broadcast by A and B in some order. There is very less likelihood that the time difference between the PREQ from A and B would be greater than 50ms since this is a lot of time in 802.11 speak where the nodes are contending for the channel on the order of hundreds of microseconds (typically). In short, it is very likely (confirmed through experiments) that this difference is less than 50ms.

So, when the PREQ from S arrives a D via A, since most likely this event happens within 50ms if the PREQ via B, the target sequence number will not be updated. Therefore, the originator sequence number stays at 1 and the target sequence number remains 2. It is very important to note that the code in hwmp_preq_frame_process just "swaps" the originator and target sequence numbers for use in the PREP. More specifically as mentioned earlier, the second PREP will have an originator sequence number of 2 and a target sequence number of 1.

At this point, we have two PREPs in flight, one via B and one via A.

PREP via B: originator sequence number = 3, target sequence number = 1
PREP via A: originator sequence number = 2, target sequence number = 1

The net effect is that when these PREPs reach S, irrespective of the order in which they arrive, the PREP via A will be ignored! This is very wrong since the reason we sent the PREP via A in the first place was that it had a better metric (albeit on the reverse path).

I have not tested the patch yet. This is more of a heads up email to let everyone.

Signed-off-by: Qasim Javed <qasimj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/mesh_hwmp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 70ac7d1..a13b593 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -543,6 +543,8 @@ static void hwmp_preq_frame_process(struct ieee80211_sub_if_data *sdata,
 		    time_before(jiffies, ifmsh->last_sn_update)) {
 			target_sn = ++ifmsh->sn;
 			ifmsh->last_sn_update = jiffies;
+		} else {
+			target_sn = ifmsh->sn;
 		}
 	} else {
 		rcu_read_lock();
-- 
1.7.1
