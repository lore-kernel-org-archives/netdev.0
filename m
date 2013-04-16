From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: socket: move ktime2ts to ktime header api
Date: Tue, 16 Apr 2013 13:29:10 +0200
Message-ID: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, willemb@google.com, hawk@diku.dk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab3DPL3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 07:29:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ktime2ts is a small helper function that is only used in
net/socket.c. Move this helper into the ktime API as a small inline
function, so that i) it's maintained together with ktime routines,
and ii) also other files can make use of it. The function is named
ktime_to_timespec_cond() and placed into the generic part of ktime,
since we internally make use of ktime_to_timespec(). ktime_to_timespec()
itself does not check the ktime variable for zero, hence, we name
this function ktime_to_timespec_cond() for only a conditional
conversion, and adapt its users to it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 ktime_to_timespec_cond() will be used in the 2nd patch as well.

 include/linux/ktime.h | 18 ++++++++++++++++++
 net/socket.c          | 20 ++++----------------
 2 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/include/linux/ktime.h b/include/linux/ktime.h
index e83512f..68ceba0 100644
--- a/include/linux/ktime.h
+++ b/include/linux/ktime.h
@@ -330,6 +330,24 @@ static inline ktime_t ktime_sub_us(const ktime_t kt, const u64 usec)
 
 extern ktime_t ktime_add_safe(const ktime_t lhs, const ktime_t rhs);
 
+/**
+ * ktime_to_timespec_cond - convert a ktime_t variable to timespec
+ *			    format only if the variable contains data
+ * @kt:		the ktime_t variable to convert
+ * @ts:		the timespec variable to store the result in
+ *
+ * Returns true if there was a successful conversion, false if kt was 0.
+ */
+static inline bool ktime_to_timespec_cond(const ktime_t kt, struct timespec *ts)
+{
+	if (kt.tv64) {
+		*ts = ktime_to_timespec(kt);
+		return true;
+	} else {
+		return false;
+	}
+}
+
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
diff --git a/net/socket.c b/net/socket.c
index 36883fe..280283f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -681,16 +681,6 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
-static int ktime2ts(ktime_t kt, struct timespec *ts)
-{
-	if (kt.tv64) {
-		*ts = ktime_to_timespec(kt);
-		return 1;
-	} else {
-		return 0;
-	}
-}
-
 /*
  * called from sock_recv_timestamp() if sock_flag(sk, SOCK_RCVTSTAMP)
  */
@@ -723,17 +713,15 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 
 	memset(ts, 0, sizeof(ts));
-	if (skb->tstamp.tv64 &&
-	    sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE)) {
-		skb_get_timestampns(skb, ts + 0);
+	if (sock_flag(sk, SOCK_TIMESTAMPING_SOFTWARE) &&
+	    ktime_to_timespec_cond(skb->tstamp, ts + 0))
 		empty = 0;
-	}
 	if (shhwtstamps) {
 		if (sock_flag(sk, SOCK_TIMESTAMPING_SYS_HARDWARE) &&
-		    ktime2ts(shhwtstamps->syststamp, ts + 1))
+		    ktime_to_timespec_cond(shhwtstamps->syststamp, ts + 1))
 			empty = 0;
 		if (sock_flag(sk, SOCK_TIMESTAMPING_RAW_HARDWARE) &&
-		    ktime2ts(shhwtstamps->hwtstamp, ts + 2))
+		    ktime_to_timespec_cond(shhwtstamps->hwtstamp, ts + 2))
 			empty = 0;
 	}
 	if (!empty)
-- 
1.7.11.7
