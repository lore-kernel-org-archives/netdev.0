From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: fix sleeping while atomic problem in sock
 mem_cgroup.
Date: Fri, 16 Dec 2011 10:31:09 +0100
Message-ID: <1324027869.2273.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324026582-5214-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org,
	cgroups@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	Randy Dunlap <rdunlap@xenotime.net>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:59596 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759876Ab1LPJbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 04:31:14 -0500
In-Reply-To: <1324026582-5214-1-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 13:09 +0400, Glauber Costa a =C3=
=A9crit :
> Since we can't scan the proto_list to initialize sock cgroups, as it
> holds a rwlock, and we also want to keep the code generic enough to
> avoid calling the initialization functions of protocols directly,
> I propose we keep the interested parties in a separate list. This lis=
t
> is protected by a mutex so we can sleep and do the necessary allocati=
ons.
>=20
> Also fixes a reference problem found by Randy Dunlap's randconfig.
>=20
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Randy Dunlap <rdunlap@xenotime.net>
> ---

Sorry to come late, but why dont we convert proto_list_lock to a mutex =
?

 net/core/sock.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5a6a906..0c67fac 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -136,7 +136,7 @@
 #include <net/tcp.h>
 #endif
=20
-static DEFINE_RWLOCK(proto_list_lock);
+static DEFINE_MUTEX(proto_list_mutex);
 static LIST_HEAD(proto_list);
=20
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
@@ -145,7 +145,7 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, st=
ruct cgroup_subsys *ss)
 	struct proto *proto;
 	int ret =3D 0;
=20
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_for_each_entry(proto, &proto_list, node) {
 		if (proto->init_cgroup) {
 			ret =3D proto->init_cgroup(cgrp, ss);
@@ -154,13 +154,13 @@ int mem_cgroup_sockets_init(struct cgroup *cgrp, =
struct cgroup_subsys *ss)
 		}
 	}
=20
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return ret;
 out:
 	list_for_each_entry_continue_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
 			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return ret;
 }
=20
@@ -168,11 +168,11 @@ void mem_cgroup_sockets_destroy(struct cgroup *cg=
rp, struct cgroup_subsys *ss)
 {
 	struct proto *proto;
=20
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_for_each_entry_reverse(proto, &proto_list, node)
 		if (proto->destroy_cgroup)
 			proto->destroy_cgroup(cgrp, ss);
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 }
 #endif
=20
@@ -2479,10 +2479,10 @@ int proto_register(struct proto *prot, int allo=
c_slab)
 		}
 	}
=20
-	write_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	list_add(&prot->node, &proto_list);
 	assign_proto_idx(prot);
-	write_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 	return 0;
=20
 out_free_timewait_sock_slab_name:
@@ -2505,10 +2505,10 @@ EXPORT_SYMBOL(proto_register);
=20
 void proto_unregister(struct proto *prot)
 {
-	write_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	release_proto_idx(prot);
 	list_del(&prot->node);
-	write_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
=20
 	if (prot->slab !=3D NULL) {
 		kmem_cache_destroy(prot->slab);
@@ -2531,9 +2531,9 @@ EXPORT_SYMBOL(proto_unregister);
=20
 #ifdef CONFIG_PROC_FS
 static void *proto_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(proto_list_lock)
+	__acquires(proto_list_mutex)
 {
-	read_lock(&proto_list_lock);
+	mutex_lock(&proto_list_mutex);
 	return seq_list_start_head(&proto_list, *pos);
 }
=20
@@ -2543,9 +2543,9 @@ static void *proto_seq_next(struct seq_file *seq,=
 void *v, loff_t *pos)
 }
=20
 static void proto_seq_stop(struct seq_file *seq, void *v)
-	__releases(proto_list_lock)
+	__releases(proto_list_mutex)
 {
-	read_unlock(&proto_list_lock);
+	mutex_unlock(&proto_list_mutex);
 }
=20
 static char proto_method_implemented(const void *method)
