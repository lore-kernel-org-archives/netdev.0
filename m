From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Fri, 09 Sep 2011 07:06:17 +0200
Message-ID: <1315544777.5410.19.camel@edumazet-laptop>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop>  <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <1315430766.2532.1.camel@edumazet-laptop>
	 <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35973 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab1IIFG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 01:06:26 -0400
Received: by wyh22 with SMTP id 22so1248566wyh.19
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 22:06:25 -0700 (PDT)
In-Reply-To: <1315473888.2301.21.camel@schen9-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 septembre 2011 =C3=A0 02:24 -0700, Tim Chen a =C3=A9crit :

> Looking forward to the patch.  This should improve the scalability of
> af_unix.

Here it is, based on top on previous one [af_unix: Fix use-after-free
crashes]

Thanks

[PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default

Since commit 7361c36c5224 (af_unix: Allow credentials to work across
user and pid namespaces) af_unix performance dropped a lot.

This is because we now take a reference on pid and cred in each write()=
,
and release them in read(), usually done from another process,
eventually from another cpu. This triggers false sharing.

# Events: 154K cycles
#
# Overhead  Command       Shared Object                               S=
ymbol
# ........  .......  ..................  ..............................=
=2E....
#
    10.40%  hackbench  [kernel.kallsyms]   [k] put_pid
     8.60%  hackbench  [kernel.kallsyms]   [k] unix_stream_recvmsg
     7.87%  hackbench  [kernel.kallsyms]   [k] unix_stream_sendmsg
     6.11%  hackbench  [kernel.kallsyms]   [k] do_raw_spin_lock
     4.95%  hackbench  [kernel.kallsyms]   [k] unix_scm_to_skb
     4.87%  hackbench  [kernel.kallsyms]   [k] pid_nr_ns
     4.34%  hackbench  [kernel.kallsyms]   [k] cred_to_ucred
     2.39%  hackbench  [kernel.kallsyms]   [k] unix_destruct_scm
     2.24%  hackbench  [kernel.kallsyms]   [k] sub_preempt_count
     1.75%  hackbench  [kernel.kallsyms]   [k] fget_light
     1.51%  hackbench  [kernel.kallsyms]   [k] __mutex_lock_interruptib=
le_slowpath
     1.42%  hackbench  [kernel.kallsyms]   [k] sock_alloc_send_pskb


This patch includes SCM_CREDENTIALS information in a af_unix message/sk=
b
only if requested by the sender, [man 7 unix for details how to include
ancillary data using sendmsg() system call]

Note: This might break buggy applications that expected SCM_CREDENTIAL
from an unaware write() system call.

Performance boost in hackbench : more than 50% gain on a 16 thread
machine (2 quad-core cpus, 2 threads per core)

hackbench 20 thread 2000

4.224 sec instead of 9.102 sec


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/scm.h        |   11 +----------
 net/core/scm.c           |   10 ++++++----
 net/netlink/af_netlink.c |    5 ++---
 net/unix/af_unix.c       |    9 +++++----
 4 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 2a5b42f..74c8fdc 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -45,14 +45,6 @@ static __inline__ void unix_get_peersec_dgram(struct=
 socket *sock, struct scm_co
 { }
 #endif /* CONFIG_SECURITY_NETWORK */
=20
-static __inline__ void scm_set_cred(struct scm_cookie *scm,
-				    struct pid *pid, const struct cred *cred)
-{
-	scm->pid  =3D get_pid(pid);
-	scm->cred =3D get_cred(cred);
-	cred_to_ucred(pid, cred, &scm->creds);
-}
-
 static __inline__ void scm_set_cred_noref(struct scm_cookie *scm,
 				    struct pid *pid, const struct cred *cred)
 {
@@ -81,8 +73,7 @@ static __inline__ void scm_destroy(struct scm_cookie =
*scm)
 static __inline__ int scm_send(struct socket *sock, struct msghdr *msg=
,
 			       struct scm_cookie *scm)
 {
-	scm_set_cred(scm, task_tgid(current), current_cred());
-	scm->fp =3D NULL;
+	memset(scm, 0, sizeof(*scm));
 	unix_get_peersec_dgram(sock, scm);
 	if (msg->msg_controllen <=3D 0)
 		return 0;
diff --git a/net/core/scm.c b/net/core/scm.c
index 811b53f..ff52ad0 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -173,7 +173,7 @@ int __scm_send(struct socket *sock, struct msghdr *=
msg, struct scm_cookie *p)
 			if (err)
 				goto error;
=20
-			if (pid_vnr(p->pid) !=3D p->creds.pid) {
+			if (!p->pid || pid_vnr(p->pid) !=3D p->creds.pid) {
 				struct pid *pid;
 				err =3D -ESRCH;
 				pid =3D find_get_pid(p->creds.pid);
@@ -183,8 +183,9 @@ int __scm_send(struct socket *sock, struct msghdr *=
msg, struct scm_cookie *p)
 				p->pid =3D pid;
 			}
=20
-			if ((p->cred->euid !=3D p->creds.uid) ||
-				(p->cred->egid !=3D p->creds.gid)) {
+			if (!p->cred ||
+			    (p->cred->euid !=3D p->creds.uid) ||
+			    (p->cred->egid !=3D p->creds.gid)) {
 				struct cred *cred;
 				err =3D -ENOMEM;
 				cred =3D prepare_creds();
@@ -193,7 +194,8 @@ int __scm_send(struct socket *sock, struct msghdr *=
msg, struct scm_cookie *p)
=20
 				cred->uid =3D cred->euid =3D p->creds.uid;
 				cred->gid =3D cred->egid =3D p->creds.gid;
-				put_cred(p->cred);
+				if (p->cred)
+					put_cred(p->cred);
 				p->cred =3D cred;
 			}
 			break;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4330db9..1201b6d 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1324,10 +1324,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, =
struct socket *sock,
 	if (msg->msg_flags&MSG_OOB)
 		return -EOPNOTSUPP;
=20
-	if (NULL =3D=3D siocb->scm) {
+	if (NULL =3D=3D siocb->scm)
 		siocb->scm =3D &scm;
-		memset(&scm, 0, sizeof(scm));
-	}
+
 	err =3D scm_send(sock, msg, siocb->scm);
 	if (err < 0)
 		return err;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c8a08ba..4c77385 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1383,12 +1383,13 @@ static int unix_scm_to_skb(struct scm_cookie *s=
cm, struct sk_buff *skb,
 {
 	int err =3D 0;
=20
+	UNIXCB(skb).pid  =3D scm->pid;
+	UNIXCB(skb).cred =3D scm->cred;
 	if (!steal_refs) {
-		UNIXCB(skb).pid  =3D get_pid(scm->pid);
-		UNIXCB(skb).cred =3D get_cred(scm->cred);
+		get_pid(scm->pid);
+		if (scm->cred)
+			get_cred(scm->cred);
 	} else {
-		UNIXCB(skb).pid  =3D scm->pid;
-		UNIXCB(skb).cred =3D scm->cred;
 		scm->pid =3D NULL;
 		scm->cred =3D NULL;
 	}
