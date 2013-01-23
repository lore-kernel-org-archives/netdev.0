From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] [RFC] tcp: add ability to set a timestamp offset (v2)
Date: Wed, 23 Jan 2013 19:01:52 +0400
Message-ID: <1358953314-12979-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a TCP socket will get live-migrated from one box to another the
timestamps (which are typically ON) will get screwed up -- the new
kernel will generate TS values that has nothing to do with what they
were on dump. The solution is to yet again fix the kernel and put a
"timestamp offset" on a socket.

v2: We can't adjust tcp_time_stamp only for output packets, because
echoed timestamp values will also no longer have a meaningful
relationship to tcp_time_stamp. That violates assumptions made in
several places in the code, which assumes that we can compare echoed
timestamp values to tcp_time_stamp; //Neal Cardwell

This version is a "bit more" radical. It makes tcp_time_stamp dependent
on tcp_sock. The idea of this patch is in the next two lines:

-#define tcp_time_stamp         ((__u32)(jiffies))
+#define tcp_time_stamp(tp)     ((__u32)(jiffies) + tp->tsoffset)

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>

Andrey Vagin (2):
  tcp: make tcp_timestamp dependent on tcp_sock
  tcp: add ability to set a timestamp offset (v2)

 include/linux/tcp.h      |  2 ++
 include/net/tcp.h        | 15 +++++++++-----
 include/uapi/linux/tcp.h |  1 +
 net/ipv4/syncookies.c    |  4 ++--
 net/ipv4/tcp.c           |  9 +++++++-
 net/ipv4/tcp_bic.c       | 10 ++++-----
 net/ipv4/tcp_cubic.c     | 14 ++++++-------
 net/ipv4/tcp_htcp.c      |  2 +-
 net/ipv4/tcp_input.c     | 53 +++++++++++++++++++++++++-----------------------
 net/ipv4/tcp_ipv4.c      | 19 +++++++++--------
 net/ipv4/tcp_lp.c        | 10 ++++-----
 net/ipv4/tcp_metrics.c   |  2 +-
 net/ipv4/tcp_output.c    | 35 +++++++++++++++++---------------
 net/ipv4/tcp_timer.c     |  9 ++++----
 net/ipv4/tcp_westwood.c  |  8 +++++---
 net/ipv6/tcp_ipv6.c      | 22 ++++++++++++--------
 16 files changed, 123 insertions(+), 92 deletions(-)

--
1.7.11.7
