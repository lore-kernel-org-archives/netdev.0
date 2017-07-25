From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH net-next] TLP: Don't reschedule PTO when there's one outstanding TLP retransmission.
Date: Tue, 25 Jul 2017 16:35:35 +0800
Message-ID: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <weiyongjun1@huawei.com>, <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:10261 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdGYIgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 04:36:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is one TLP probe went out(TLP use the write_queue_tail packet
as TLP probe, we assume this first TLP probe named A), and this TLP
probe was not acked by receive side.

Then the transmit side sent the next two packetes out(named B,C), but
unfortunately these two packets are also not acked by receive side.

And then there is one data packet with ack_seq A arrive, in tcp_ack() 
will call tcp_schedule_loss_probe() to rearm PTO, the handler 
tcp_send_loss_probe() pass if(tp->tlp_high_seq)(because there is 
one outstanding TLP named A,tp->tlp_high_seq is not zero),
so the new TLP probe can't be went out and need to rearm the RTO
timer(timeout is relative to the transmit time of the write queue head).

After this, another data packet with ack_seq A is received,
if the tlp_time_stamp is after rto_time_stamp, it will reset the
TLP timeout with delta value, which is before previous RTO timeout, 
so PTO is rearm and previous RTO is cleared. This TLP probe also can't 
be sent out because of tp->tlp_high_seq != 0, so there is no way(or need 
very long time)to retransmit the packet because of TLP A is lost.

This fix is not to pass the if(tp->tlp_high_seq) in tcp_schedule_loss_probe()
when TLP PTO is after RTO, It is no need to reschedule PTO when there
is one outstanding TLP retransmission, so if the TLP A is lost then RTO can
retransmit that packet, and tp->tlp_high_seq will be set to 0. After this TLP
will go to the normal work process.

Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 net/ipv4/tcp_output.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 886d874..0c8da1c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2423,6 +2423,10 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	tlp_time_stamp = tcp_jiffies32 + timeout;
 	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
 	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
+		/*It is no need to reschedule PTO when there is one outstanding TLP retransmission*/
+		if (tp->tlp_high_seq) {
+			return false;
+		}
 		s32 delta = rto_time_stamp - tcp_jiffies32;
 		if (delta > 0)
 			timeout = delta;
-- 
2.5.0
