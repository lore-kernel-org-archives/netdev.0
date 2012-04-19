From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 6/6] tcp: Repair connection-time negotiated parameters
Date: Thu, 19 Apr 2012 17:41:57 +0400
Message-ID: <4F901625.1090008@parallels.com>
References: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21226 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab2DSNmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:42:05 -0400
In-Reply-To: <4F901572.4040009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are options, which are set up on a socket while performing
TCP handshake. Need to resurrect them on a socket while repairing.
A new sockoption accepts a buffer and parses it. The buffer should
be CODE:VALUE sequence of bytes, where CODE is standard option
code and VALUE is the respective value.

Only 4 options should be handled on repaired socket.

To read 3 out of 4 of these options the TCP_INFO sockoption can be
used. An ability to get the last one (the mss_clamp) was added by
the previous patch.

Now the restore. Three of these options -- timestamp_ok, mss_clamp
and snd_wscale -- are just restored on a coket.

The sack_ok flags has 2 issues. First, whether or not to do sacks
at all. This flag is just read and set back. No other sack  info is
saved or restored, since according to the standart and the code
dropping all sack-ed segments is OK, the sender will resubmit them
again, so after the repair we will probably experience a pause in
connection. Next, the fack bit. It's just set back on a socket if
the respective sysctl is set. No collected stats about packets flow
is preserved. As far as I see (plz, correct me if I'm wrong) the
fack-based congestion algorithm survives dropping all of the stats
and repairs itself eventually, probably losing the performance for
that period.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/tcp.h |    1 +
 net/ipv4/tcp.c      |   71 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e90e6a..9865936 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -109,6 +109,7 @@ enum {
 #define TCP_REPAIR		19	/* TCP sock is under repair right now */
 #define TCP_REPAIR_QUEUE	20
 #define TCP_QUEUE_SEQ		21
+#define TCP_REPAIR_OPTIONS	22
 
 enum {
 	TCP_NO_QUEUE,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b4e690d..3ce3bd0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2218,6 +2218,68 @@ static inline int tcp_can_repair_sock(struct sock *sk)
 		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
 }
 
+static int tcp_repair_options_est(struct tcp_sock *tp, char __user *optbuf, unsigned int len)
+{
+	/*
+	 * Options are stored in CODE:VALUE form where CODE is 8bit and VALUE
+	 * fits the respective TCPOLEN_ size
+	 */
+
+	while (len > 0) {
+		u8 opcode;
+
+		if (get_user(opcode, optbuf))
+			return -EFAULT;
+
+		optbuf++;
+		len--;
+
+		switch (opcode) {
+		case TCPOPT_MSS: {
+			u16 in_mss;
+
+			if (len < sizeof(in_mss))
+				return -ENODATA;
+			if (get_user(in_mss, optbuf))
+				return -EFAULT;
+
+			tp->rx_opt.mss_clamp = in_mss;
+
+			optbuf += sizeof(in_mss);
+			len -= sizeof(in_mss);
+			break;
+		}
+		case TCPOPT_WINDOW: {
+			u8 wscale;
+
+			if (len < sizeof(wscale))
+				return -ENODATA;
+			if (get_user(wscale, optbuf))
+				return -EFAULT;
+
+			if (wscale > 14)
+				return -EFBIG;
+
+			tp->rx_opt.snd_wscale = wscale;
+
+			optbuf += sizeof(wscale);
+			len -= sizeof(wscale);
+			break;
+		}
+		case TCPOPT_SACK_PERM:
+			tp->rx_opt.sack_ok |= TCP_SACK_SEEN;
+			if (sysctl_tcp_fack)
+				tcp_enable_fack(tp);
+			break;
+		case TCPOPT_TIMESTAMP:
+			tp->rx_opt.tstamp_ok = 1;
+			break;
+		}
+	}
+
+	return 0;
+}
+
 /*
  *	Socket option code for TCP.
  */
@@ -2426,6 +2488,15 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 			err = -EINVAL;
 		break;
 
+	case TCP_REPAIR_OPTIONS:
+		if (!tp->repair)
+			err = -EINVAL;
+		else if (sk->sk_state == TCP_ESTABLISHED)
+			err = tcp_repair_options_est(tp, optval, optlen);
+		else
+			err = -EPERM;
+		break;
+
 	case TCP_CORK:
 		/* When set indicates to always queue non-full frames.
 		 * Later the user clears this option and we transmit
-- 
1.5.5.6
