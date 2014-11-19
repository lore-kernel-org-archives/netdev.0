From: Jon Maxwell <jmaxwell37@gmail.com>
Subject: [PATCH net] tcp: fix connect() invalid -EADDRNOTAVAIL error
Date: Wed, 19 Nov 2014 17:37:40 +1100
Message-ID: <1416379060-15685-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmaxwell@redhat.com,
	Jon Maxwell <jmaxwell37@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The connect() routine returns -EADDRNOTAVAIL without doing a 4=20
tuple check when the hash buckets were previously allocated by=20
bind() and all local ports are used.

The bind() routine creates the local port hash buckets in=20
inet_csk_get_port(). Depending on the socket options it sets=20
tb->fastreuse and tb->fastreuseport to 0 or 1 in the bucket.

However the __inet_hash_connect() routine initializes the hash=20
buckets differently and sets these to -1. The end result is=20
that connect() calling into __inet_hash_connect() will=20
subsequently ignore the check_established() routine if, here

__inet_hash_connect()
=2E
=2E
if (tb->fastreuse >=3D 0 ||=E2=86=A9
    tb->fastreuseport >=3D 0)=E2=86=A9
    goto next_port;

and cycle through all local ports until it returns -EADDRNOTAVAIL.=20
The 4 tuple check is in check_established() so connect() can fail=20
unnecessarily.

Prerequisites for this to happen:
1) The local tcp port range must be exhausted.
2) A process must have called bind() followed by connect() for all=20
local ports.
3) A different process calls connect() only which returns -EADDRNOTAVAI=
L.=20
4) The system more than 1 interface configured.

If a system has 2 IP Addresses and all local tcp ports are in use
for connection from IP Address (1). Connecting to the same ports=20
via IP Address (2) should work based on the 4 tuple rule. But it=20
fails under this condition.=20

To fix this make __inet_hash_connect() honour inet_csk_get_port()'s
tb->fastreuse* variables.

Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
---
 net/ipv4/inet_hashtables.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 9111a4e..b39e89e 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -513,8 +513,8 @@ int __inet_hash_connect(struct inet_timewait_death_=
row *death_row,
 			inet_bind_bucket_for_each(tb, &head->chain) {
 				if (net_eq(ib_net(tb), net) &&
 				    tb->port =3D=3D port) {
-					if (tb->fastreuse >=3D 0 ||
-					    tb->fastreuseport >=3D 0)
+					if (tb->fastreuse > 0 ||
+					    tb->fastreuseport > 0)
 						goto next_port;
 					WARN_ON(hlist_empty(&tb->owners));
 					if (!check_established(death_row, sk,
@@ -530,8 +530,6 @@ int __inet_hash_connect(struct inet_timewait_death_=
row *death_row,
 				spin_unlock(&head->lock);
 				break;
 			}
-			tb->fastreuse =3D -1;
-			tb->fastreuseport =3D -1;
 			goto ok;
=20
 		next_port:
--=20
1.8.3.1
