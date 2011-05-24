From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 08:17:17 +0200
Message-ID: <1306217837.2638.36.camel@edumazet-laptop>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
	 <20110524.011330.1077020828173889583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, mingo@elte.hu, tgraf@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37546 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab1EXGRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 02:17:23 -0400
Received: by wwa36 with SMTP id 36so6949321wwa.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 23:17:22 -0700 (PDT)
In-Reply-To: <20110524.011330.1077020828173889583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 01:13 -0400, David Miller a =C3=A9crit :
> From: akpm@linux-foundation.org
> Date: Mon, 23 May 2011 15:17:35 -0700
>=20
> > From: Dan Rosenberg <drosenberg@vsecurity.com>
> >=20
> > The %pK format specifier is designed to hide exposed kernel pointer=
s,
> > specifically via /proc interfaces.  Exposing these pointers provide=
s an
> > easy target for kernel write vulnerabilities, since they reveal the
> > locations of writable structures containing easily triggerable func=
tion
> > pointers.  The behavior of %pK depends on the kptr_restrict sysctl.
> >=20
> > If kptr_restrict is set to 0, no deviation from the standard %p beh=
avior
> > occurs.  If kptr_restrict is set to 1, the default, if the current =
user
> > (intended to be a reader via seq_printf(), etc.) does not have CAP_=
SYSLOG
> > (currently in the LSM tree), kernel pointers using %pK are printed =
as 0's.
> >  If kptr_restrict is set to 2, kernel pointers using %pK are printe=
d as
> > 0's regardless of privileges.  Replacing with 0's was chosen over t=
he
> > default "(null)", which cannot be parsed by userland %p, which expe=
cts
> > "(nil)".
> >=20
> > The supporting code for kptr_restrict and %pK are currently in the =
-mm
> > tree.  This patch converts users of %p in net/ to %pK.  Cases of pr=
inting
> > pointers to the syslog are not covered, since this would eliminate =
useful
> > information for postmortem debugging and the reading of the syslog =
is
> > already optionally protected by the dmesg_restrict sysctl.
> >=20
> > Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>=20
> Applied.

We probably need to extend this to inet_diag as well.

"ss -e" currently expose kernel pointers, like /proc files used to do
before this patch.

Thanks

[PATCH] inet_diag: hide socket pointers

Provide a mayber_hide_ptr() helper and use it in inet_diag to not
disclose kernel pointers to user, with kptr_restrict logic :

kptr_restrict =3D 0 : kernel pointers are not mangled
kptr_restrict =3D 1 : if the current user does not have CAP_SYSLOG,
kernel pointers are replaced by 0
kptr_restrict =3D 2 : kernel pointers are replaced by 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/printk.h |    1 +
 lib/vsprintf.c         |   15 +++++++++++----
 net/ipv4/inet_diag.c   |    6 ++++--
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/include/linux/printk.h b/include/linux/printk.h
index ee048e7..47c0cef 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -111,6 +111,7 @@ extern bool printk_timed_ratelimit(unsigned long *c=
aller_jiffies,
 extern int printk_delay_msec;
 extern int dmesg_restrict;
 extern int kptr_restrict;
+void *maybe_hide_ptr(void *ptr);
=20
 void log_buf_kexec_setup(void);
 #else
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 1d659d7..20d3576 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -799,6 +799,16 @@ char *uuid_string(char *buf, char *end, const u8 *=
addr,
=20
 int kptr_restrict __read_mostly;
=20
+void *maybe_hide_ptr(void *ptr)
+{
+	if (!((kptr_restrict =3D=3D 0) ||
+	      (kptr_restrict =3D=3D 1 &&
+	       has_capability_noaudit(current, CAP_SYSLOG))))
+		ptr =3D NULL;
+	return ptr;
+}
+EXPORT_SYMBOL(maybe_hide_ptr);
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -911,10 +921,7 @@ char *pointer(const char *fmt, char *buf, char *en=
d, void *ptr,
 				spec.field_width =3D 2 * sizeof(void *);
 			return string(buf, end, "pK-error", spec);
 		}
-		if (!((kptr_restrict =3D=3D 0) ||
-		      (kptr_restrict =3D=3D 1 &&
-		       has_capability_noaudit(current, CAP_SYSLOG))))
-			ptr =3D NULL;
+		ptr =3D maybe_hide_ptr(ptr);
 		break;
 	}
 	spec.flags |=3D SMALL;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6ffe94c..b5646a3 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -84,6 +84,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	struct inet_diag_meminfo  *minfo =3D NULL;
 	unsigned char	 *b =3D skb_tail_pointer(skb);
 	const struct inet_diag_handler *handler;
+	u64 ptr;
=20
 	handler =3D inet_diag_table[unlh->nlmsg_type];
 	BUG_ON(handler =3D=3D NULL);
@@ -114,8 +115,9 @@ static int inet_csk_diag_fill(struct sock *sk,
 	r->idiag_retrans =3D 0;
=20
 	r->id.idiag_if =3D sk->sk_bound_dev_if;
-	r->id.idiag_cookie[0] =3D (u32)(unsigned long)sk;
-	r->id.idiag_cookie[1] =3D (u32)(((unsigned long)sk >> 31) >> 1);
+	ptr =3D (u64)maybe_hide_ptr(sk);
+	r->id.idiag_cookie[0] =3D (u32)ptr;
+	r->id.idiag_cookie[1] =3D (u32)(ptr >> 32);
=20
 	r->id.idiag_sport =3D inet->inet_sport;
 	r->id.idiag_dport =3D inet->inet_dport;


