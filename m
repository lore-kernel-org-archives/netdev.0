From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide error
Date: Wed, 4 May 2011 13:04:56 -0700
Message-ID: <20110504130456.425dee68@nehalam>
References: <20110504113351.4643a0c9@nehalam>
	<16668.1304537481@localhost>
	<20110504123738.7bb4d1ee@nehalam>
	<20110504.124053.260068550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, rdunlap@xenotime.net, lkml@techboom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Injong Rhee <injongrhee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110504.124053.260068550.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP Cubic keeps a metric that estimates the amount of delayed
acknowledgements to use in adjusting the window. If an abnormally
large number of packets are acknowledged at once, then the update
could wrap and reach zero. This kind of ACK could only
happen when there was a large window and huge number of
ACK's were lost.

This patch limits the value of delayed ack ratio. The choice of 32
is just a conservative value since normally it should be range of 
1 to 4 packets.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against 2.6.39-rc5+


--- a/net/ipv4/tcp_cubic.c	2011-05-04 11:58:49.666027155 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-05-04 12:52:34.716767304 -0700
@@ -93,6 +93,7 @@ struct bictcp {
 	u32	ack_cnt;	/* number of acks */
 	u32	tcp_cwnd;	/* estimated tcp cwnd */
 #define ACK_RATIO_SHIFT	4
+#define ACK_RATIO_LIMIT (32u << ACK_RATIO_SHIFT)
 	u16	delayed_ack;	/* estimate the ratio of Packets/ACKs << 4 */
 	u8	sample_cnt;	/* number of samples to decide curr_rtt */
 	u8	found;		/* the exit point is found? */
@@ -398,8 +399,12 @@ static void bictcp_acked(struct sock *sk
 	u32 delay;
 
 	if (icsk->icsk_ca_state == TCP_CA_Open) {
-		cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
-		ca->delayed_ack += cnt;
+		u32 ratio = ca->delayed_ack;
+
+		ratio -= ca->delayed_ack >> ACK_RATIO_SHIFT;
+		ratio += cnt;
+
+		ca->delayed_ack = min(ratio, ACK_RATIO_LIMIT);
 	}
 
 	/* Some calls are for duplicates without timetamps */
