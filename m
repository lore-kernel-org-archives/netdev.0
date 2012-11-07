From: Julius Werner <jwerner@chromium.org>
Subject: [PATCH] tcp: Avoid infinite loop on recvmsg bug
Date: Wed,  7 Nov 2012 11:33:11 -0800
Message-ID: <1352316791-16491-1-git-send-email-jwerner@chromium.org>
References: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Jones <davej@redhat.com>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Julius Werner <jwerner@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp_recvmsg contains a sanity check that WARNs when there is a gap
between the socket's copied_seq and the first buffer in the
sk_receive_queue. In theory, the TCP stack makes sure that This Should
Never Happen (TM)... however, practice shows that there are still a few
bug reports from it out there (and one in my inbox).

Unfortunately, when it does happen for whatever reason, the situation
is not handled very well: the kernel logs a warning and breaks out of
the loop that walks the receive queue. It proceeds to find nothing else
to do on the socket and hits sk_wait_data, which cannot block because
the receive queue is not empty. As no data was read, the outer while
loop repeats (logging the same warning again) ad infinitum until the
system's syslog exhausts all available hard drive capacity.

This patch addresses that issue by closing the socket outright and
throwing EBADFD to userspace (which seems most appropriate to me at this
point). As the underlying bug condition is "impossible" and therefore by
definition unrecoverable, this is the only sensible action other than a
full panic.

Signed-off-by: Julius Werner <jwerner@chromium.org>
---
 net/ipv4/tcp.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 197c000..d612308 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1628,7 +1628,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				 "recvmsg bug: copied %X seq %X rcvnxt %X fl %X\n",
 				 *seq, TCP_SKB_CB(skb)->seq, tp->rcv_nxt,
 				 flags))
-				break;
+				goto selfdestruct;
 
 			offset = *seq - TCP_SKB_CB(skb)->seq;
 			if (tcp_hdr(skb)->syn)
@@ -1936,6 +1936,11 @@ recv_urg:
 recv_sndq:
 	err = tcp_peek_sndq(sk, msg, len);
 	goto out;
+
+selfdestruct:
+	err = -EBADFD;
+	tcp_done(sk);
+	goto out;
 }
 EXPORT_SYMBOL(tcp_recvmsg);
 
-- 
1.7.8.6
