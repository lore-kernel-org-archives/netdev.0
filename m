From: Koen De Schepper <koen0607@gmail.com>
Subject: [PATCH net-next] DCTCP drop compatibility
Date: Tue, 14 Feb 2017 18:05:48 +0100
Message-ID: <1487091948-7492-1-git-send-email-koen.de_schepper@nokia-bell-labs.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>,
        Glenn Judd <glenn.judd@morganstanley.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Andrew Shewmaker <agshew@gmail.com>,
        Lawrence Brakmo <brakmo@fb.com>,
        Koen De Schepper <koen.de_schepper@nokia-bell-labs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34686 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755113AbdBNRGH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:06:07 -0500
Received: by mail-it0-f65.google.com with SMTP id r141so5944144ita.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 09:06:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Makes DCTCP respond to drop. Additional Reno-like
 response is added when a packet gets lost. The
 clamp_alpha_on_loss implementation was not working.
 The parameter was renamed into dctcp_drop_compatible
 to express the expected result, not the implementation
 mechanism.

 If the dctcp_drop_compatible parameter is enabled, and in
 this RTT at least one loss occurred, the window is reduced
 additionally by half. The motivation is that packet
 loss is an indicator of extreme congestion. In practice,
 this turned out to be both beneficial for overloaded
 datacenter ECN-configured queues, and classic configured
 drop queues (non-ECN) where it supports coexistence with
 classic TCPs such as Cubic and Reno.

 On a PI2 or PIE AQM bottleneck without ECN support in the
 AQM, following drop probabilities are measured for 4
 competing flows of the same congestion control:

   TCP  |    Drop    |  Link   |   RTT    |    Drop
   CC   | compatible |  speed  | base+AQM | probability
 =======|============|=========|==========|============
  CUBIC |      -     |  40Mbps |  7+20ms  |    0.21%
  RENO  |      -     |         |          |    0.19%
  DCTCP |      1     |         |          |    0.22%
  DCTCP |      0     |         |          |   25.8%
 -------|------------|---------|----------|------------
  CUBIC |      -     | 100Mbps |  7+20ms  |    0.03%
  RENO  |      -     |         |          |    0.02%
  DCTCP |      1     |         |          |    0.04%
  DCTCP |      0     |         |          |   23.3%
 -------|------------|---------|----------|------------
  CUBIC |      -     | 800Mbps |   1+1ms  |    0.04%
  RENO  |      -     |         |          |    0.05%
  DCTCP |      1     |         |          |    0.06%
  DCTCP |      0     |         |          |   18.7%

 These results show that DCTCP drives drop based queues
 to high levels of loss when dctcp_drop_compatible=0,
 and becomes compatible with Cubic and Reno when
 dctcp_drop_compatible=1.

 The parameter is default on, to protect network paths
 that do not support ECN. DCTCP in MS-Windows is similarly
 drop compatible by default. 

---
 net/ipv4/tcp_dctcp.c | 79 +++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 62 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 5f5e593..d1cf111 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -67,10 +67,10 @@ static unsigned int dctcp_alpha_on_init __read_mostly = DCTCP_MAX_ALPHA;
 module_param(dctcp_alpha_on_init, uint, 0644);
 MODULE_PARM_DESC(dctcp_alpha_on_init, "parameter for initial alpha value");
 
-static unsigned int dctcp_clamp_alpha_on_loss __read_mostly;
-module_param(dctcp_clamp_alpha_on_loss, uint, 0644);
-MODULE_PARM_DESC(dctcp_clamp_alpha_on_loss,
-		 "parameter for clamping alpha on loss");
+static unsigned int dctcp_drop_compatible __read_mostly = 1;
+module_param(dctcp_drop_compatible, uint, 0644);
+MODULE_PARM_DESC(dctcp_drop_compatible,
+		 "parameter for classic drop compatibility on loss");
 
 static struct tcp_congestion_ops dctcp_reno;
 
@@ -231,21 +231,62 @@ static void dctcp_update_alpha(struct sock *sk, u32 flags)
 	}
 }
 
-static void dctcp_state(struct sock *sk, u8 new_state)
+static void dctcp_adjust_on_loss(struct sock *sk)
 {
-	if (dctcp_clamp_alpha_on_loss && new_state == TCP_CA_Loss) {
-		struct dctcp *ca = inet_csk_ca(sk);
+	/* If the dctcp_drop_compatible extension is enabled, and
+	 * this RTT at least one loss occurred, the window is reduced
+	 * additionally by half. The motivation is that packet
+	 * loss is an indicator of extreme congestion. In practice,
+	 * this turned out to be both beneficial for overloaded
+	 * datacenter ECN-configured queues, and classic configured
+	 * drop queues (non-ECN) where it supports coexistence with
+	 * classic TCPs such as Cubic and Reno.
+	 *
+	 * On a PI2 or PIE AQM bottleneck without ECN support in the
+	 * AQM, following drop probabilities are measured for 4
+	 * competing flows of the same congestion control:
+	 *
+	 *   TCP  |    Drop    |  Link   |   RTT    |    Drop
+	 *   CC   | compatible |  speed  | base+AQM | probability
+	 * =======|============|=========|==========|============
+	 *  CUBIC |      -     |  40Mbps |  7+20ms  |    0.21%
+	 *  RENO  |      -     |         |          |    0.19%
+	 *  DCTCP |      1     |         |          |    0.22%
+	 *  DCTCP |      0     |         |          |   25.8%
+	 * -------|------------|---------|----------|------------
+	 *  CUBIC |      -     | 100Mbps |  7+20ms  |    0.03%
+	 *  RENO  |      -     |         |          |    0.02%
+	 *  DCTCP |      1     |         |          |    0.04%
+	 *  DCTCP |      0     |         |          |   23.3%
+	 * -------|------------|---------|----------|------------
+	 *  CUBIC |      -     | 800Mbps |   1+1ms  |    0.04%
+	 *  RENO  |      -     |         |          |    0.05%
+	 *  DCTCP |      1     |         |          |    0.06%
+	 *  DCTCP |      0     |         |          |   18.7%
+	 *
+	 * These results show that DCTCP drives drop based queues
+	 * to high levels of loss when dctcp_drop_compatible=0,
+	 * and becomes compatible with Cubic and Reno when
+	 * dctcp_drop_compatible=1.
+	 */
 
-		/* If this extension is enabled, we clamp dctcp_alpha to
-		 * max on packet loss; the motivation is that dctcp_alpha
-		 * is an indicator to the extend of congestion and packet
-		 * loss is an indicator of extreme congestion; setting
-		 * this in practice turned out to be beneficial, and
-		 * effectively assumes total congestion which reduces the
-		 * window by half.
-		 */
-		ca->dctcp_alpha = DCTCP_MAX_ALPHA;
-	}
+	struct dctcp *ca = inet_csk_ca(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	ca->loss_cwnd = tp->snd_cwnd;
+	tp->snd_ssthresh = max(tp->snd_cwnd >> 1U, 2U);
+}
+
+static void dctcp_state(struct sock *sk, u8 new_state)
+{
+	/* TCP_CA_LOSS is better handled via the event call back for 2 reasons:
+	 * - event is called immediately after call to ssthresh
+	 * - state is called also for MTU probe loss, which uses simple_ssthresh
+	 */
+	if (dctcp_drop_compatible &&
+	    (new_state == TCP_CA_Recovery) &&
+	    !(tcp_in_cwnd_reduction(sk)))
+		dctcp_adjust_on_loss(sk);
 }
 
 static void dctcp_update_ack_reserved(struct sock *sk, enum tcp_ca_event ev)
@@ -280,6 +321,10 @@ static void dctcp_cwnd_event(struct sock *sk, enum tcp_ca_event ev)
 	case CA_EVENT_NON_DELAYED_ACK:
 		dctcp_update_ack_reserved(sk, ev);
 		break;
+	case CA_EVENT_LOSS:
+		if (dctcp_drop_compatible)
+			dctcp_adjust_on_loss(sk);
+		break;
 	default:
 		/* Don't care for the rest. */
 		break;
-- 
2.7.4
