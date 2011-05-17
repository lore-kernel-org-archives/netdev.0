From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: Tree for May 16 (net/ipv4/ping)
Date: Tue, 17 May 2011 11:54:07 +0200
Message-ID: <1305626047.2850.35.camel@edumazet-laptop>
References: <20110516151019.be338f1c.sfr@canb.auug.org.au>
	 <20110516123534.5d3a51b9.randy.dunlap@oracle.com>
	 <20110516.153844.1072050131335197211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, segoon@openwall.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110516.153844.1072050131335197211.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 mai 2011 =C3=A0 15:38 -0400, David Miller a =C3=A9crit :
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Mon, 16 May 2011 12:35:34 -0700
>=20
> > On Mon, 16 May 2011 15:10:19 +1000 Stephen Rothwell wrote:
> >=20
> >> Hi all,
> >>=20
> >> Changes since 20110513:
> >=20
> >=20
> > when CONFIG_PROC_SYSCTL is not enabled:
> >=20
> > ping.c:(.text+0x52af3): undefined reference to `inet_get_ping_group=
_range_net'
>=20
> Vasiliy, please fix this.

Vasily seems busy, here is a fix for this problem.

I tested new ping was working even if we could not set the group range
anymore.

Thanks

[PATCH net-next-2.6] net: ping: fix build error

Randy Dunlap reported following build error if CONFIG_PROC_SYSCTL is no=
t
enabled:

ping.c:(.text+0x52af3): undefined reference to
`inet_get_ping_group_range_net'

Also made inet_get_ping_group_range_table() static

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Vasiliy Kulikov <segoon@openwall.com>
---
 net/ipv4/inet_connection_sock.c |   14 ++++++++++++++
 net/ipv4/sysctl_net_ipv4.c      |   14 +-------------
 2 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 3a2ba56..e5c0729 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -23,6 +23,7 @@
 #include <net/route.h>
 #include <net/tcp_states.h>
 #include <net/xfrm.h>
+#include <net/ping.h>
=20
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] =3D "inet_csk BUG: unknown timer v=
alue\n";
@@ -52,6 +53,19 @@ void inet_get_local_port_range(int *low, int *high)
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
=20
+void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t =
*high)
+{
+	const gid_t *data =3D net->ipv4.sysctl_ping_group_range;
+	unsigned int seq;
+
+	do {
+		seq =3D read_seqbegin(&sysctl_local_ports.lock);
+
+		*low =3D data[0];
+		*high =3D data[1];
+	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+}
+
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
 {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 28e8273..dc5d2a0 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -73,19 +73,7 @@ static int ipv4_local_port_range(ctl_table *table, i=
nt write,
 }
=20
=20
-void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t =
*high)
-{
-	gid_t *data =3D net->ipv4.sysctl_ping_group_range;
-	unsigned seq;
-	do {
-		seq =3D read_seqbegin(&sysctl_local_ports.lock);
-
-		*low =3D data[0];
-		*high =3D data[1];
-	} while (read_seqretry(&sysctl_local_ports.lock, seq));
-}
-
-void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *l=
ow, gid_t *high)
+static void inet_get_ping_group_range_table(struct ctl_table *table, g=
id_t *low, gid_t *high)
 {
 	gid_t *data =3D table->data;
 	unsigned seq;
