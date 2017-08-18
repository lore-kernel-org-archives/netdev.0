From: =?UTF-8?q?St=C3=A9phan=20Gorget?= <sgorget@fb.com>
Subject: [PATCH net-next] tcp: export drops counter to /proc/net/tcp{,6}
Date: Fri, 18 Aug 2017 03:21:35 -0700
Message-ID: <20170818102135.266832-1-sgorget@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?q?St=C3=A9phan=20Gorget?= <sgorget@fb.com>,
        Jeethu Rao <jeethu@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Eric Dumazet <edumazet@google.com>, <kernel-team@fb.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Those counters are exported for raw and udp but not for tcp, though they
are incremented.

An example where it is useful is chasing listen overflow. Listen overflow
are counted as a global counter in LINUX_MIB_LISTENOVERFLOWS accessible
in /proc/net/netstat but there is no way to find related drops in the
information exported for tcp. With this patch it will make possible to
correlate growth of LINUX_MIB_LISTENOVERFLOWS with growth of drops for
a tcp socket.

This patch does it for /proc/net/tcp and /proc/net/tcp6, the drops
counter is being incremented in function like tcp_listendrop() which
would help surface error cases like listen overflow and track them to
the correct socket.

That work has been done for raw sockets (/proc/net/raw and
/proc/net/raw6) by Wang Chen in commit 33c732c36169
("[IPV4]: Add raw drops counter.") and commit a92aa318b4b3
("[IPV6]: Add raw6 drops counter.") and by Eric Dumazet for udp ones
(/proc/net/udp and /proc/net/udp6) in commit cb61cb9b8b5e
("udp: sk_drops handling").

Signed-off-by: St=C3=A9phan Gorget <sgorget@fb.com>
Signed-off-by: Jeethu Rao <jeethu@fb.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: kernel-team@fb.com
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 Documentation/networking/proc_net_tcp.txt | 30 ++++++++++++++++---------=
-----
 net/ipv4/tcp_ipv4.c                       |  5 +++--
 net/ipv6/tcp_ipv6.c                       |  7 ++++---
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/Documentation/networking/proc_net_tcp.txt b/Documentation/ne=
tworking/proc_net_tcp.txt
index 4a79209..38bda94 100644
--- a/Documentation/networking/proc_net_tcp.txt
+++ b/Documentation/networking/proc_net_tcp.txt
@@ -24,20 +24,22 @@ up into 3 parts because of the length of the line):
       |        |----------------------> receive-queue
       |-------------------------------> transmit-queue
=20
-   1000        0 54165785 4 cd1e6040 25 4 27 3 -1
-    |          |    |     |    |     |  | |  | |--> slow start size thre=
shold,=20
-    |          |    |     |    |     |  | |  |      or -1 if the thresho=
ld
-    |          |    |     |    |     |  | |  |      is >=3D 0xFFFF
-    |          |    |     |    |     |  | |  |----> sending congestion w=
indow
-    |          |    |     |    |     |  | |-------> (ack.quick<<1)|ack.p=
ingpong
-    |          |    |     |    |     |  |---------> Predicted tick of so=
ft clock
-    |          |    |     |    |     |              (delayed ACK control=
 data)
-    |          |    |     |    |     |------------> retransmit timeout
-    |          |    |     |    |------------------> location of socket i=
n memory
-    |          |    |     |-----------------------> socket reference cou=
nt
-    |          |    |-----------------------------> inode
-    |          |----------------------------------> unanswered 0-window =
probes
-    |---------------------------------------------> uid
+   1000        0 54165785 4 cd1e6040 25 4 27 3 -1 0
+    |          |    |     |    |     |  | |  | |  |--> number of drops
+    |          |    |     |    |     |  | |  | |-----> slow start size
+    |          |    |     |    |     |  | |  |         threshold, or -1 =
if the
+    |          |    |     |    |     |  | |  |         threshold is >=3D=
 0xFFFF
+    |          |    |     |    |     |  | |  |-------> sending congestio=
n window
+    |          |    |     |    |     |  | |----------> (ack.quick<<1) |
+    |          |    |     |    |     |  |               ack.pingpong
+    |          |    |     |    |     |  |------------> Predicted tick of=
 soft clock
+    |          |    |     |    |     |                 (delayed ACK cont=
rol data)
+    |          |    |     |    |     |---------------> retransmit timeou=
t
+    |          |    |     |    |---------------------> location of socke=
t in memory
+    |          |    |     |--------------------------> socket reference =
count
+    |          |    |--------------------------------> inode
+    |          |-------------------------------------> unanswered 0-wind=
ow probes
+    |------------------------------------------------> uid
=20
 timer_active:
   0  no timer is pending
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5af8b80..173e20a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2255,7 +2255,7 @@ static void get_tcp4_sock(struct sock *sk, struct s=
eq_file *f, int i)
 		rx_queue =3D max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
=20
 	seq_printf(f, "%4d: %08X:%04X %08X:%04X %02X %08X:%08X %02X:%08lX "
-			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d",
+			"%08X %5u %8d %lu %d %pK %lu %lu %u %u %d %d",
 		i, src, srcp, dest, destp, state,
 		tp->write_seq - tp->snd_una,
 		rx_queue,
@@ -2272,7 +2272,8 @@ static void get_tcp4_sock(struct sock *sk, struct s=
eq_file *f, int i)
 		tp->snd_cwnd,
 		state =3D=3D TCP_LISTEN ?
 		    fastopenq->max_qlen :
-		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh));
+		    (tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh),
+		state =3D=3D TCP_LISTEN ? atomic_read(&sk->sk_drops) : 0);
 }
=20
 static void get_timewait4_sock(const struct inet_timewait_sock *tw,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d79a1af..1cd296a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1795,8 +1795,8 @@ static void get_tcp6_sock(struct seq_file *seq, str=
uct sock *sp, int i)
 		rx_queue =3D max_t(int, tp->rcv_nxt - tp->copied_seq, 0);
=20
 	seq_printf(seq,
-		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X "
-		   "%02X %08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %lu %lu %u %u %d=
\n",
+		   "%4d: %08X%08X%08X%08X:%04X %08X%08X%08X%08X:%04X %02X "
+		   "%08X:%08X %02X:%08lX %08X %5u %8d %lu %d %pK %lu %lu %u %u %d %d\n=
",
 		   i,
 		   src->s6_addr32[0], src->s6_addr32[1],
 		   src->s6_addr32[2], src->s6_addr32[3], srcp,
@@ -1818,7 +1818,8 @@ static void get_tcp6_sock(struct seq_file *seq, str=
uct sock *sp, int i)
 		   tp->snd_cwnd,
 		   state =3D=3D TCP_LISTEN ?
 			fastopenq->max_qlen :
-			(tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh)
+			(tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh),
+		   state =3D=3D TCP_LISTEN ? atomic_read(&sp->sk_drops) : 0
 		   );
 }
=20
--=20
2.9.5
