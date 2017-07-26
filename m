From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH V2 net-next] TLP: Don't reschedule PTO when there's one outstanding TLP retransmission
Date: Wed, 26 Jul 2017 17:44:45 +0800
Message-ID: <1501062285-9648-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <ncardwell@google.com>, <ycheng@google.com>, <nanditad@google.com>,
        <weiyongjun1@huawei.com>, <chenweilong@huawei.com>,
        <wangkefeng.wang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:10352 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdGZJt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 05:49:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is one TLP probe went out(TLP use the write_queue_tail packet
as TLP probe, we assume this first TLP probe named A), and this TLP
probe was not acked by receive side.

Then the transmit side sent the next two packetes out(named B,C), but
unfortunately these two packets are also not acked by receive side.

And then there is one data packet with ack_seq A arrive
at transmit side, in tcp_ack() will call tcp_schedule_loss_probe()
to rearm PTO, the handler tcp_send_loss_probe() is to check
if(tp->tlp_high_seq) then go to rearm_timer(because there is
one outstanding TLP named A),
so the new TLP probe can't be sent out and it needs to rearm the RTO
timer(timeout is relative to the transmit time of the write queue head).

After that, there is another data packet with ack_seq A is received,
if the tlp_time_stamp is greater than rto_time_stamp, it will reset the
TLP timeout, which is before previous RTO timeout, so PTO is rearm and previous
RTO is cleared. Because there is no retransmission packet was sent or
no TLP sack receive, tp->tlp_high_seq can't be reset to zero and the next
TLP probe also can't be sent out, so there is no way(or very long time)
to retransmit the lost packet.

This fix is to check(tp->tlp_high_seq) in tcp_schedule_loss_probe()
when TLP PTO is after RTO, It is not needed to reschedule PTO when there
is one outstanding TLP retransmission, so if the TLP A is lost RTO can
retransmit lost packet, then tp->tlp_high_seq will be set to 0, and TLP
will go to the normal work process.

v1->v2
	refine some words of code and patch comments.
	
Signed-off-by: Mao Wenan <maowenan@huawei.com>
---
 net/ipv4/tcp_output.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 886d874..f85c7ef 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2423,6 +2423,12 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	tlp_time_stamp = tcp_jiffies32 + timeout;
 	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
 	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
+		/* It is not needed to reschedule PTO when there 
+		 * is one outstanding TLP retransmission. 
+		 */
+		if (tp->tlp_high_seq) {
+			return false;
+		}
 		s32 delta = rto_time_stamp - tcp_jiffies32;
 		if (delta > 0)
 			timeout = delta;
-- 
2.5.0
