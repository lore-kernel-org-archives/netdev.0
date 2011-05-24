From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Tue, 24 May 2011 09:04:41 +0200
Message-ID: <1306220681.2638.40.camel@edumazet-laptop>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
	 <20110524.011330.1077020828173889583.davem@davemloft.net>
	 <1306217837.2638.36.camel@edumazet-laptop>
	 <1306218793.2298.10.camel@Joe-Laptop>  <20110524065715.GB12816@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, a.p.zijlstra@chello.nl,
	eparis@parisplace.org, eugeneteo@kernel.org, jmorris@namei.org,
	kees.cook@canonical.com, tgraf@infradead.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34290 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450Ab1EXHEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:04:46 -0400
Received: by wya21 with SMTP id 21so4734877wya.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 00:04:45 -0700 (PDT)
In-Reply-To: <20110524065715.GB12816@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 mai 2011 =C3=A0 08:57 +0200, Ingo Molnar a =C3=A9crit :
> * Joe Perches <joe@perches.com> wrote:
>=20
> > Maybe for clarity it'd be better to use a switch/case
> > or something like:
> >=20
> > 	if (kptr_restrict =3D=3D 0)
> > 		return ptr;
> > 	if (ptr_restrict =3D=3D 1 &&
> > 	    has_capability_noaudit(current, CAP_SYSLOG))
> > 		return ptr;
> > 	return NULL;
>=20
> While not breaking that line really - so something like:
>=20
> 	if (kptr_restrict =3D=3D 0)
> 		return ptr;
>=20
> 	if (kptr_restrict =3D=3D 1 && has_capability_noaudit(current, CAP_SY=
SLOG))
> 		return ptr;
>=20
> 	return NULL;
>=20
> Thanks,
>=20
> 	Ingo

Here we are, thanks.

[PATCH v2] inet_diag: hide socket pointers

Provide a mayber_hide_ptr() helper and use it in inet_diag to not
disclose kernel pointers to user, with following kptr_restrict logic :

kptr_restrict =3D 0 : kernel pointers are not mangled
kptr_restrict =3D 1 : if the current user does not have CAP_SYSLOG,
		    kernel pointers are replaced by 0
kptr_restrict =3D 2 : kernel pointers are replaced by 0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: kerneldoc and cleanup (Joe & Ingo feedback)

 include/linux/printk.h |    1 +
 lib/vsprintf.c         |   25 +++++++++++++++++++++----
 net/ipv4/inet_diag.c   |    6 ++++--
 3 files changed, 26 insertions(+), 6 deletions(-)

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
index 1d659d7..db1a193 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -798,6 +798,26 @@ char *uuid_string(char *buf, char *end, const u8 *=
addr,
 }
=20
 int kptr_restrict __read_mostly;
+/**
+ * maybe_hide_ptr - Eventually nullify a kernel pointer given to user
+ * @ptr: kernel pointer
+ *
+ * kptr_restrict =3D 0 : kernel pointer not changed
+ * kptr_restrict =3D 1 : if the current user does not have CAP_SYSLOG,
+ *		       kernel pointer is replaced by 0
+ * kptr_restrict =3D 2 : kernel pointer is replaced by 0 for all users=
=2E
+ */
+void *maybe_hide_ptr(void *ptr)
+{
+	if (!kptr_restrict)
+		return ptr;
+
+	if (kptr_restrict =3D=3D 1 && has_capability_noaudit(current, CAP_SYS=
LOG))
+		return ptr;
+
+	return NULL;
+}
+EXPORT_SYMBOL(maybe_hide_ptr);
=20
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
@@ -911,10 +931,7 @@ char *pointer(const char *fmt, char *buf, char *en=
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


