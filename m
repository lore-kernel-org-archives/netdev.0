From: subashab@codeaurora.org
Subject: [PATCH net-next] inet: Always increment refcount in
 inet_twsk_schedule
Date: Sun, 19 Jul 2015 03:31:44 -0000
Message-ID: <d6222bf87f44ca3adf3988202bd31a3c.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58827 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbbGSDbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 23:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing an issue with the reference count of time wait sockets which
leads to freeing of active timer object. This occurs in some data stress
test setups, so I am unable to determine the exact step when it occured.
However, I logged the refcount and was able to find out the code path
which leads to this problem.

//Initialize time wait socket and setup timer
inet_twsk_alloc() tw_refcnt = 0
__inet_twsk_hashdance() tw_refcnt = 3
inet_twsk_schedule() tw_refcnt = 4
inet_twsk_put() tw_refcnt = 3

//Receive packet 1 in timewait state
tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 3 (no change)
TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 2

//Receive packet 2 in timewait state
tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 2 (no change)
TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 1

//Receive packet 3 in timewait state
tcp_timewait_state_process() -> inet_twsk_schedule tw_refcnt = 1 (no change)
TCP: tcp_v4_timewait_ack() -> inet_twsk_put() tw_refcnt = 0

After this step, the time wait socket is destroyed along with the active
timer object. This leads to a warning being printed which eventually leads
to a crash.

ODEBUG: free active (active state 0) object type: timer_list hint:
tw_timer_handler+0x0/0x68

It appears that inet_twsk_schedule needs to increment the reference count
unconditionally, otherwise the socket will be destroyed since reference
count will be decremented each time an ack is sent out as a response for
an incoming packet.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv4/inet_timewait_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index cbeb022..99c349a 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -246,9 +246,9 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
const int timeo)

 	tw->tw_kill = timeo <= 4*HZ;
 	if (!mod_timer_pinned(&tw->tw_timer, jiffies + timeo)) {
-		atomic_inc(&tw->tw_refcnt);
 		atomic_inc(&tw->tw_dr->tw_count);
 	}
+	atomic_inc(&tw->tw_refcnt);
 }
 EXPORT_SYMBOL_GPL(inet_twsk_schedule);

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
