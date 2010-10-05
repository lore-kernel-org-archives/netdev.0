From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Tue, 5 Oct 2010 21:01:17 +0800
Message-ID: <20101005130117.GK5170@cr0.nay.redhat.com>
References: <1286025469.2582.1806.camel@edumazet-laptop>
 <20101004085913.GR14068@sgi.com>
 <1286183058.18293.26.camel@edumazet-laptop>
 <20101004093439.GG5189@cr0.nay.redhat.com>
 <1286187030.18293.33.camel@edumazet-laptop>
 <20101004103545.GJ5189@cr0.nay.redhat.com>
 <1286188701.18293.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:58543 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728Ab0JEM4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 08:56:54 -0400
Content-Disposition: inline
In-Reply-To: <1286188701.18293.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 12:38:21PM +0200, Eric Dumazet wrote:
>Le lundi 04 octobre 2010 =C3=A0 18:35 +0800, Am=C3=A9rico Wang a =C3=A9=
crit :
>
>> Your patch does fix the problem, but seems not a good solution,
>> we should skip all min/max checking if ->extra(1|2) is NULL,
>> instead of checking it every time within the loop.
>
>Please do submit a patch, we'll see if you come to a better solution,
>with no added code size (this is slow path, I dont care for checking i=
t
>'every time winthin the loop')
>
>

I have one, but just did compile test. :)
I will test it tomorrow.

NOT-Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f88552c..345a193 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2448,86 +2448,119 @@ int proc_dointvec_minmax(struct ctl_table *tab=
le, int write,
 				do_proc_dointvec_minmax_conv, &param);
 }
=20
-static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *t=
able, int write,
-				     void __user *buffer,
+static int __doulongvec_minmax_read(void *data, void __user *buffer,
 				     size_t *lenp, loff_t *ppos,
 				     unsigned long convmul,
 				     unsigned long convdiv)
 {
-	unsigned long *i, *min, *max;
-	int vleft, first =3D 1, err =3D 0;
-	unsigned long page =3D 0;
-	size_t left;
-	char *kbuf;
+	unsigned long *i =3D (unsigned long *) data;
+	int err =3D 0;
+	bool first =3D true;
+	size_t left =3D *lenp;
=20
-	if (!data || !table->maxlen || !*lenp || (*ppos && !write)) {
-		*lenp =3D 0;
-		return 0;
+	for (; left; i++, first=3Dfalse) {
+		unsigned long val;
+
+		val =3D convdiv * (*i) / convmul;
+		if (!first)
+			err =3D proc_put_char(&buffer, &left, '\t');
+		err =3D proc_put_long(&buffer, &left, val, false);
+		if (err)
+			break;
 	}
=20
-	i =3D (unsigned long *) data;
-	min =3D (unsigned long *) table->extra1;
-	max =3D (unsigned long *) table->extra2;
-	vleft =3D table->maxlen / sizeof(unsigned long);
-	left =3D *lenp;
+	if (!first && left && !err)
+		err =3D proc_put_char(&buffer, &left, '\n');
=20
-	if (write) {
-		if (left > PAGE_SIZE - 1)
-			left =3D PAGE_SIZE - 1;
-		page =3D __get_free_page(GFP_TEMPORARY);
-		kbuf =3D (char *) page;
-		if (!kbuf)
-			return -ENOMEM;
-		if (copy_from_user(kbuf, buffer, left)) {
-			err =3D -EFAULT;
-			goto free;
-		}
-		kbuf[left] =3D 0;
+	*lenp -=3D left;
+	*ppos +=3D *lenp;
+	return err;
+}
+
+static int __doulongvec_minmax_write(void *data, void __user *buffer,
+				     size_t *lenp, loff_t *ppos, int vleft,
+				     unsigned long min, unsigned long max)
+{
+	char *kbuf;
+	size_t left =3D *lenp;
+	unsigned long page =3D 0;
+	unsigned long *i =3D (unsigned long *) data;
+	int err =3D 0;
+	bool first =3D true;
+
+	if (left > PAGE_SIZE - 1)
+		left =3D PAGE_SIZE - 1;
+	page =3D __get_free_page(GFP_TEMPORARY);
+	kbuf =3D (char *) page;
+	if (!kbuf)
+		return -ENOMEM;
+	if (copy_from_user(kbuf, buffer, left)) {
+		err =3D -EFAULT;
+		goto free;
 	}
+	kbuf[left] =3D 0;
=20
-	for (; left && vleft--; i++, min++, max++, first=3D0) {
+	for (; left && vleft--; i++, min++, max++, first=3Dfalse) {
 		unsigned long val;
+		bool neg;
=20
-		if (write) {
-			bool neg;
-
-			left -=3D proc_skip_spaces(&kbuf);
+		left -=3D proc_skip_spaces(&kbuf);
=20
-			err =3D proc_get_long(&kbuf, &left, &val, &neg,
-					     proc_wspace_sep,
-					     sizeof(proc_wspace_sep), NULL);
-			if (err)
-				break;
-			if (neg)
-				continue;
-			if ((min && val < *min) || (max && val > *max))
-				continue;
-			*i =3D val;
-		} else {
-			val =3D convdiv * (*i) / convmul;
-			if (!first)
-				err =3D proc_put_char(&buffer, &left, '\t');
-			err =3D proc_put_long(&buffer, &left, val, false);
-			if (err)
-				break;
-		}
+		err =3D proc_get_long(&kbuf, &left, &val, &neg,
+				     proc_wspace_sep,
+				     sizeof(proc_wspace_sep), NULL);
+		if (err)
+			break;
+		if (neg)
+			continue;
+		if (val < min || val > max)
+			continue;
+		*i =3D val;
 	}
=20
-	if (!write && !first && left && !err)
-		err =3D proc_put_char(&buffer, &left, '\n');
-	if (write && !err)
+	if (!err)
 		left -=3D proc_skip_spaces(&kbuf);
 free:
-	if (write) {
-		free_page(page);
-		if (first)
-			return err ? : -EINVAL;
-	}
+	free_page(page);
+	if (first)
+		return err ? : -EINVAL;
+
 	*lenp -=3D left;
 	*ppos +=3D *lenp;
 	return err;
 }
=20
+static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *t=
able, int write,
+				     void __user *buffer,
+				     size_t *lenp, loff_t *ppos,
+				     unsigned long convmul,
+				     unsigned long convdiv)
+{
+	if (!data || !table->maxlen || !*lenp || (*ppos && !write)) {
+		*lenp =3D 0;
+		return 0;
+	}
+
+	if (write) {
+		unsigned long min, max;
+		int vleft;
+
+		vleft =3D table->maxlen / sizeof(unsigned long);
+		if (table->extra1)
+			min =3D *(unsigned long *) table->extra1;
+		else
+			min =3D 0;
+		if (table->extra2)
+			max =3D *(unsigned long *) table->extra2;
+		else
+			max =3D ULONG_MAX;
+		return __doulongvec_minmax_write(data, buffer, lenp,
+						  ppos, vleft, min, max);
+	} else
+		return __doulongvec_minmax_read(data, buffer, lenp,
+						 ppos, convmul, convdiv);
+}
+
 static int do_proc_doulongvec_minmax(struct ctl_table *table, int writ=
e,
 				     void __user *buffer,
 				     size_t *lenp, loff_t *ppos,
