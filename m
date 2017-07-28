From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net] tcp: avoid bogus gcc-7 array-bounds warning
Date: Fri, 28 Jul 2017 16:41:37 +0200
Message-ID: <20170728144153.2024234-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using CONFIG_UBSAN_SANITIZE_ALL, the TCP code produces a
false-positive warning:

net/ipv4/tcp_output.c: In function 'tcp_connect':
net/ipv4/tcp_output.c:2207:40: error: array subscript is below array bounds [-Werror=array-bounds]
   tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
                                        ^~
net/ipv4/tcp_output.c:2207:40: error: array subscript is below array bounds [-Werror=array-bounds]
   tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~

I have opened a gcc bug for this, but distros have already shipped
compilers with this problem, and it's not clear yet whether there is
a way for gcc to avoid the warning. As the problem is related to the
bitfield access, this introduces a temporary variable to store the old
enum value.

I did not notice this warning earlier, since UBSAN is disabled when
building with COMPILE_TEST, and that was always turned on in both
allmodconfig and randconfig tests.

Link: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81601
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/ipv4/tcp_output.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 886d874775df..bb901297a369 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2202,9 +2202,10 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 static void tcp_chrono_set(struct tcp_sock *tp, const enum tcp_chrono new)
 {
 	const u32 now = tcp_jiffies32;
+	enum tcp_chrono old = tp->chrono_type;
 
-	if (tp->chrono_type > TCP_CHRONO_UNSPEC)
-		tp->chrono_stat[tp->chrono_type - 1] += now - tp->chrono_start;
+	if (old > TCP_CHRONO_UNSPEC)
+		tp->chrono_stat[old - 1] += now - tp->chrono_start;
 	tp->chrono_start = now;
 	tp->chrono_type = new;
 }
-- 
2.9.0
