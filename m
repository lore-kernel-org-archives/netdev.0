From: Steffen Sledz <sledz@dresearch.de>
Subject: [PATCH resent] tcp: ioctl type SIOCOUTQNSD returns amount of data not sent
Date: Fri,  4 Mar 2011 09:48:17 +0100
Message-ID: <1299228497-21246-1-git-send-email-sledz@dresearch.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Mario Schuknecht <m.schuknecht@dresearch.de>,
	Steffen Sledz <sledz@dresearch.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mario Schuknecht <m.schuknecht@dresearch.de>

In contrast to SIOCOUTQ which returns the amount of data sent
but not yet acknowledged plus data not yet sent this patch only
returns the data not sent.

For various methods of live streaming bitrate control it may
be helpful to know how much data are in the tcp outqueue are
not sent yet.

Signed-off-by: Mario Schuknecht <m.schuknecht@dresearch.de>
Signed-off-by: Steffen Sledz <sledz@dresearch.de>
---
 include/asm-generic/ioctls.h |    1 +
 include/linux/sockios.h      |    1 +
 net/ipv4/tcp.c               |    9 +++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/ioctls.h b/include/asm-generic/ioctls.h
index 199975f..ef2be0b 100644
--- a/include/asm-generic/ioctls.h
+++ b/include/asm-generic/ioctls.h
@@ -74,6 +74,7 @@
 #define TCSETXW		0x5435
 #define TIOCSIG		_IOW('T', 0x36, int)  /* pty: generate signal */
 #define TIOCVHANGUP	0x5437
+#define TIOCOUTQNSD	0x5438
 
 #define FIONCLEX	0x5450
 #define FIOCLEX		0x5451
diff --git a/include/linux/sockios.h b/include/linux/sockios.h
index 241f179..4c5ca47 100644
--- a/include/linux/sockios.h
+++ b/include/linux/sockios.h
@@ -23,6 +23,7 @@
 /* Linux-specific socket ioctls */
 #define SIOCINQ		FIONREAD
 #define SIOCOUTQ	TIOCOUTQ
+#define SIOCOUTQNSD	TIOCOUTQNSD
 
 /* Routing table calls. */
 #define SIOCADDRT	0x890B		/* add routing table entry	*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a17a5a7..b22d450 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -505,6 +505,15 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		else
 			answ = tp->write_seq - tp->snd_una;
 		break;
+	case SIOCOUTQNSD:
+		if (sk->sk_state == TCP_LISTEN)
+			return -EINVAL;
+
+		if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))
+			answ = 0;
+		else
+			answ = tp->write_seq - tp->snd_nxt;
+		break;
 	default:
 		return -ENOIOCTLCMD;
 	}
-- 
1.7.1
