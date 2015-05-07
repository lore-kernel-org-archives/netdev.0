From: Derrick Pallas <pallas@meraki.com>
Subject: [PATCH] tcp: expose listen socket backlog via SIOCGBACKLOG
Date: Wed,  6 May 2015 19:21:15 -0700
Message-ID: <1430965275-50606-1-git-send-email-pallas@meraki.com>
Cc: Derrick Pallas <pallas@meraki.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:58152 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751292AbbEGC1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 22:27:35 -0400
Received: by pdbnk13 with SMTP id nk13so27236571pdb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 19:27:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This IOCTL exposes the current backlog for a listen socket.  This value can
be useful in userland, e.g. in an overloaded transparent proxy that would
rather push new connections into bypass than have then hang waiting for
accept.  Knowing the current backlog allows this process to make that
decision and then begin intercepting connections again once the backlog
falls to a reasonable level.

Signed-off-by: Derrick Pallas <pallas@meraki.com>
---
 include/net/sock.h           | 5 +++++
 include/uapi/linux/sockios.h | 1 +
 net/ipv4/tcp.c               | 8 ++++++++
 3 files changed, 14 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898e..7597671 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -772,6 +772,11 @@ static inline void sk_acceptq_added(struct sock *sk)
 	sk->sk_ack_backlog++;
 }
 
+static inline int sk_acceptq_backlog(struct sock *sk)
+{
+	return sk->sk_ack_backlog;
+}
+
 static inline bool sk_acceptq_is_full(const struct sock *sk)
 {
 	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index e888b1a..9320493 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -84,6 +84,7 @@
 #define SIOCWANDEV	0x894A		/* get/set netdev parameters	*/
 
 #define SIOCOUTQNSD	0x894B		/* output queue size (not sent only) */
+#define SIOCGBACKLOG	0x894C		/* get listen socket backlog length */
 
 /* ARP cache control calls. */
 		    /*  0x8950 - 0x8952  * obsolete calls, don't re-use */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8c5cd9e..1aa509d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -591,6 +591,14 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		else
 			answ = tp->write_seq - tp->snd_nxt;
 		break;
+
+	case SIOCGBACKLOG:
+		if (sk->sk_state != TCP_LISTEN)
+			return -EINVAL;
+
+		answ = sk_acceptq_backlog(sk);
+		break;
+
 	default:
 		return -ENOIOCTLCMD;
 	}
-- 
1.9.1
