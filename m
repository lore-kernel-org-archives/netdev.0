From: Anton Arapov <aarapov@redhat.com>
Subject: [PATCH] ip: justification for local port range robustness
Date: Thu, 18 Oct 2007 16:27:37 +0200
Message-ID: <m3odewh50m.fsf@bandura.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762541AbXJRO1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 10:27:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

Hi!

  There is a justifying patch for Stephen's patches. Stephen's patches
disallows using a port range of one single port and brakes the meaning
of the 'remaining' variable, in some places it has different meaning.
My patch gives back the sense of 'remaining' variable. It should mean how
many ports are remaining and nothing else. Also my patch allows using
a single port.

  I sure we must be able to use mentioned port range, this does not
restricted by documentation and does not brake current behavior.

usefull links:
Patches posted by Stephen Hemminger
  http://marc.info/?l=3Dlinux-netdev&m=3D119206106218187&w=3D2
  http://marc.info/?l=3Dlinux-netdev&m=3D119206109918235&w=3D2

Andrew Morton's comment
  http://marc.info/?l=3Dlinux-kernel&m=3D119248225007737&w=3D2

=3D=3D Patch:

Justification of the Stephen Hemminger's patches, commit numbers
  06393009000779b00a558fd2f280882cc7dc2008
  227b60f5102cda4e4ab792b526a59c8cb20cd9f8

  1. Allows using a port range of one single port.
  2. Gives back sense of 'remaining' variable.

Signed-off-by: Anton Arapov <aarapov@redhat.com>
=2D--

 drivers/infiniband/core/cma.c   |    5 +++--
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/inet_hashtables.c      |    2 +-
 net/ipv4/sysctl_net_ipv4.c      |    4 ++--
 net/ipv4/udp.c                  |    5 +++--
 net/ipv6/inet6_hashtables.c     |    2 +-
 6 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 93644f8..d08fb30 100644
=2D-- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2797,11 +2797,12 @@ static void cma_remove_one(struct ib_device *device)
=20
 static int cma_init(void)
 {
=2D	int ret, low, high;
+	int ret, low, high, remaining;
=20
 	get_random_bytes(&next_port, sizeof next_port);
 	inet_get_local_port_range(&low, &high);
=2D	next_port =3D ((unsigned int) next_port % (high - low)) + low;
+	remaining =3D (high - low) + 1;
+	next_port =3D ((unsigned int) next_port % remaining) + low;
=20
 	cma_wq =3D create_singlethread_workqueue("rdma_cm");
 	if (!cma_wq)
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_soc=
k.c
index 3cef128..8fb6ca2 100644
=2D-- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -93,7 +93,7 @@ int inet_csk_get_port(struct inet_hashinfo *hashinfo,
 		int remaining, rover, low, high;
=20
 		inet_get_local_port_range(&low, &high);
=2D		remaining =3D high - low;
+		remaining =3D (high - low) + 1;
 		rover =3D net_random() % remaining + low;
=20
 		do {
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index fac6398..16eecc7 100644
=2D-- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -286,7 +286,7 @@ int inet_hash_connect(struct inet_timewait_death_row *d=
eath_row,
 		struct inet_timewait_sock *tw =3D NULL;
=20
 		inet_get_local_port_range(&low, &high);
=2D		remaining =3D high - low;
+		remaining =3D (high - low) + 1;
=20
 		local_bh_disable();
 		for (i =3D 1; i <=3D remaining; i++) {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c98ef16..ec353cf 100644
=2D-- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -122,7 +122,7 @@ static int ipv4_local_port_range(ctl_table *table, int =
write, struct file *filp,
 	ret =3D proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
=20
 	if (write && ret =3D=3D 0) {
=2D		if (range[1] <=3D range[0])
+		if (range[1] < range[0])
 			ret =3D -EINVAL;
 		else
 			set_local_port_range(range);
@@ -150,7 +150,7 @@ static int ipv4_sysctl_local_port_range(ctl_table *tabl=
e, int __user *name,
=20
 	ret =3D sysctl_intvec(&tmp, name, nlen, oldval, oldlenp, newval, newlen);
 	if (ret =3D=3D 0 && newval && newlen) {
=2D		if (range[1] <=3D range[0])
+		if (range[1] < range[0])
 			ret =3D -EINVAL;
 		else
 			set_local_port_range(range);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cb9fc58..35d2b0e 100644
=2D-- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -147,13 +147,14 @@ int __udp_lib_get_port(struct sock *sk, unsigned shor=
t snum,
 	write_lock_bh(&udp_hash_lock);
=20
 	if (!snum) {
=2D		int i, low, high;
+		int i, low, high, remaining;
 		unsigned rover, best, best_size_so_far;
=20
 		inet_get_local_port_range(&low, &high);
+		remaining =3D (high - low) + 1;
=20
 		best_size_so_far =3D UINT_MAX;
=2D		best =3D rover =3D net_random() % (high - low) + low;
+		best =3D rover =3D net_random() % remaining + low;
=20
 		/* 1st pass: look for empty (or shortest) hash chain */
 		for (i =3D 0; i < UDP_HTABLE_SIZE; i++) {
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 1c2c276..d6f1026 100644
=2D-- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -261,7 +261,7 @@ int inet6_hash_connect(struct inet_timewait_death_row *=
death_row,
 		struct inet_timewait_sock *tw =3D NULL;
=20
 		inet_get_local_port_range(&low, &high);
=2D		remaining =3D high - low;
+		remaining =3D (high - low) + 1;
=20
 		local_bh_disable();
 		for (i =3D 1; i <=3D remaining; i++) {

=2D-=20
Anton Arapov, <aarapov@redhat.com>
GPG Key ID: 0x6FA8C812

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFHF21cVub9yW+oyBIRAux7AJ9plxykqEPVyZztXfBu9QhMWWgQpgCePeNG
jE3fyPV5LnJS1Dn7r83y/sQ=
=gbnH
-----END PGP SIGNATURE-----
--=-=-=--
