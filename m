From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inetpeer: kill inet_putpeer race
Date: Mon, 11 Jul 2011 14:49:52 +0200
Message-ID: <1310388592.26049.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53576 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757115Ab1GKMuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 08:50:04 -0400
Received: by wyg8 with SMTP id 8so2551626wyg.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 05:50:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently can free inetpeer entries too early :

[  782.636674] WARNING: kmemcheck: Caught 32-bit read from uninitialized memory (f130f44c)
[  782.636677] 1f7b13c100000000000000000000000002000000000000000000000000000000
[  782.636686]  i i i i u u u u i i i i u u u u i i i i u u u u u u u u u u u u
[  782.636694]                          ^
[  782.636696] 
[  782.636698] Pid: 4638, comm: ssh Not tainted 3.0.0-rc5+ #270 Hewlett-Packard HP Compaq 6005 Pro SFF PC/3047h
[  782.636702] EIP: 0060:[<c13fefbb>] EFLAGS: 00010286 CPU: 0
[  782.636707] EIP is at inet_getpeer+0x25b/0x5a0
[  782.636709] EAX: 00000002 EBX: 00010080 ECX: f130f3c0 EDX: f0209d30
[  782.636711] ESI: 0000bc87 EDI: 0000ea60 EBP: f0209ddc ESP: c173134c
[  782.636712]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  782.636714] CR0: 8005003b CR2: f0beca80 CR3: 30246000 CR4: 000006d0
[  782.636716] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  782.636717] DR6: ffff4ff0 DR7: 00000400
[  782.636718]  [<c13fbf76>] rt_set_nexthop.clone.45+0x56/0x220
[  782.636722]  [<c13fc449>] __ip_route_output_key+0x309/0x860
[  782.636724]  [<c141dc54>] tcp_v4_connect+0x124/0x450
[  782.636728]  [<c142ce43>] inet_stream_connect+0xa3/0x270
[  782.636731]  [<c13a8da1>] sys_connect+0xa1/0xb0
[  782.636733]  [<c13a99dd>] sys_socketcall+0x25d/0x2a0
[  782.636736]  [<c149deb8>] sysenter_do_call+0x12/0x28
[  782.636738]  [<ffffffff>] 0xffffffff

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index dafbf2c..90c5f0d 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -373,11 +373,14 @@ static int inet_peer_gc(struct inet_peer_base *base,
 	while (stackptr > stack) {
 		stackptr--;
 		p = rcu_deref_locked(**stackptr, base);
-		delta = (__u32)jiffies - p->dtime;
-		if (atomic_read(&p->refcnt) == 0 && delta >= ttl &&
-		    atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
-			p->gc_next = gchead;
-			gchead = p;
+		if (atomic_read(&p->refcnt) == 0) {
+			smp_rmb();
+			delta = (__u32)jiffies - p->dtime;
+			if (delta >= ttl &&
+			    atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
+				p->gc_next = gchead;
+				gchead = p;
+			}
 		}
 	}
 	while ((p = gchead) != NULL) {
@@ -456,6 +459,7 @@ EXPORT_SYMBOL_GPL(inet_getpeer);
 void inet_putpeer(struct inet_peer *p)
 {
 	p->dtime = (__u32)jiffies;
+	smp_mb__before_atomic_dec();
 	atomic_dec(&p->refcnt);
 }
 EXPORT_SYMBOL_GPL(inet_putpeer);


