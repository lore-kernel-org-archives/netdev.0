From: Tejun Heo <tj@kernel.org>
Subject: [PATCH net-next] cgroup: fix sock_cgroup_data initialization on
 earlier compilers
Date: Wed, 9 Dec 2015 12:30:46 -0500
Message-ID: <20151209173046.GO30240@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alaa Hleihel <alaa@dev.mellanox.co.il>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:32907 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbbLIRas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 12:30:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_cgroup_data is a struct containing an anonymous union.
sock_cgroup_set_prioidx() and sock_cgroup_set_classid() were
initializing a field inside the anonymous union as follows.

 struct sock_ccgroup_data skcd_buf =3D { .val =3D VAL };

While this is fine on more recent compilers, gcc-4.4.7 triggers the
following errors.

 include/linux/cgroup-defs.h: In function =E2=80=98sock_cgroup_set_prio=
idx=E2=80=99:
 include/linux/cgroup-defs.h:619: error: unknown field =E2=80=98val=E2=80=
=99 specified in initializer
 include/linux/cgroup-defs.h:619: warning: missing braces around initia=
lizer
 include/linux/cgroup-defs.h:619: warning: (near initialization for =E2=
=80=98skcd_buf.<anonymous>=E2=80=99)

This is because .val belongs to the anonymous union nested inside the
struct but the initializer is missing the nesting.  Fix it by adding
an extra pair of braces.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Alaa Hleihel <alaa@dev.mellanox.co.il>
=46ixes: bd1060a1d671 ("sock, cgroup: add sock->sk_cgroup")
---
 include/linux/cgroup-defs.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -616,7 +616,7 @@ static inline u32 sock_cgroup_classid(st
 static inline void sock_cgroup_set_prioidx(struct sock_cgroup_data *sk=
cd,
 					   u16 prioidx)
 {
-	struct sock_cgroup_data skcd_buf =3D { .val =3D READ_ONCE(skcd->val) =
};
+	struct sock_cgroup_data skcd_buf =3D {{ .val =3D READ_ONCE(skcd->val)=
 }};
=20
 	if (sock_cgroup_prioidx(&skcd_buf) =3D=3D prioidx)
 		return;
@@ -633,7 +633,7 @@ static inline void sock_cgroup_set_prioi
 static inline void sock_cgroup_set_classid(struct sock_cgroup_data *sk=
cd,
 					   u32 classid)
 {
-	struct sock_cgroup_data skcd_buf =3D { .val =3D READ_ONCE(skcd->val) =
};
+	struct sock_cgroup_data skcd_buf =3D {{ .val =3D READ_ONCE(skcd->val)=
 }};
=20
 	if (sock_cgroup_classid(&skcd_buf) =3D=3D classid)
 		return;
