From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [RESEND 2/3] /proc/net/if_inet6 may drop some data
Date: Wed, 10 Sep 2003 11:53:53 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910.115353.05248507.yoshfuji@linux-ipv6.org>
References: <20030904004638.1d4b001d.davem@redhat.com>
	<Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
	<20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
In-Reply-To: <20030906.160458.39800982.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030906.160458.39800982.yoshfuji@linux-ipv6.org> (at Sat, 06 Sep 2003 16:04:58 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> [2/3] /proc/net/if_inet6 may drop some data
:
> Note 0: These confilct with SEQ_START_TOKEN patches; 
>         I'll regenerate if SEQ_START_TOKEN accepted.

Index: linux-2.6/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.53
diff -u -r1.53 addrconf.c
--- linux-2.6/net/ipv6/addrconf.c	9 Sep 2003 23:24:51 -0000	1.53
+++ linux-2.6/net/ipv6/addrconf.c	10 Sep 2003 01:00:49 -0000
@@ -2149,59 +2149,65 @@
 	int bucket;
 };
 
-static inline struct inet6_ifaddr *if6_get_bucket(struct seq_file *seq, loff_t *pos)
+static struct inet6_ifaddr *if6_get_first(struct seq_file *seq)
 {
-	int i;
 	struct inet6_ifaddr *ifa = NULL;
-	loff_t l = *pos;
 	struct if6_iter_state *state = seq->private;
 
-	for (; state->bucket < IN6_ADDR_HSIZE; ++state->bucket)
-		for (i = 0, ifa = inet6_addr_lst[state->bucket]; ifa; ++i, ifa=ifa->lst_next) {
-			if (l--)
-				continue;
-			*pos = i;
-			goto out;
-		}
-out:
+	for (state->bucket = 0; state->bucket < IN6_ADDR_HSIZE; ++state->bucket) {
+		ifa = inet6_addr_lst[state->bucket];
+		if (ifa)
+			break;
+	}
+	return ifa;
+}
+
+static struct inet6_ifaddr *if6_get_next(struct seq_file *seq, struct inet6_ifaddr *ifa)
+{
+	struct if6_iter_state *state = seq->private;
+
+	ifa = ifa->lst_next;
+try_again:
+	if (!ifa && ++state->bucket < IN6_ADDR_HSIZE) {
+		ifa = inet6_addr_lst[state->bucket];
+		goto try_again;
+	}
 	return ifa;
 }
 
+static struct inet6_ifaddr *if6_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct inet6_ifaddr *ifa = if6_get_first(seq);
+
+	if (ifa)
+		while(pos && (ifa = if6_get_next(seq, ifa)) != NULL)
+			--pos;
+	return pos ? NULL : ifa;
+}
+
 static void *if6_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock_bh(&addrconf_hash_lock);
-	return *pos ? if6_get_bucket(seq, pos) : SEQ_START_TOKEN;
+	return if6_get_idx(seq, *pos);
 }
 
 static void *if6_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct inet6_ifaddr *ifa;
-	struct if6_iter_state *state;
-
-	if (v == SEQ_START_TOKEN) {
-		ifa = if6_get_bucket(seq, pos);
-		goto out;
-	}
-
-	state = seq->private;
-
-	ifa = v;
-	ifa = ifa->lst_next;
-	if (ifa)
-		goto out;
-
-	if (++state->bucket >= IN6_ADDR_HSIZE)
-		goto out;
 
-	*pos = 0;
-	ifa = if6_get_bucket(seq, pos);
-out:
+	ifa = if6_get_next(seq, v);
 	++*pos;
 	return ifa;
 }
 
-static inline void if6_iface_seq_show(struct seq_file *seq, struct inet6_ifaddr *ifp)
+static void if6_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock_bh(&addrconf_hash_lock);
+}
+
+static int if6_seq_show(struct seq_file *seq, void *v)
 {
+	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *)v;
 	seq_printf(seq,
 		   "%04x%04x%04x%04x%04x%04x%04x%04x %02x %02x %02x %02x %8s\n",
 		   NIP6(ifp->addr),
@@ -2210,20 +2216,7 @@
 		   ifp->scope,
 		   ifp->flags,
 		   ifp->idev->dev->name);
-}
-
-static int if6_seq_show(struct seq_file *seq, void *v)
-{
-	if (v == SEQ_START_TOKEN)
-		return 0;
-	else
-		if6_iface_seq_show(seq, v);
 	return 0;
-}
-
-static void if6_seq_stop(struct seq_file *seq, void *v)
-{
-	read_unlock_bh(&addrconf_hash_lock);
 }
 
 static struct seq_operations if6_seq_ops = {


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
