From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sysctl: reduce ram usage by 40 %
Date: Tue, 03 Nov 2009 08:01:24 +0100
Message-ID: <4AEFD544.6040602@gmail.com>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com> <4AEFCA49.4020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36074 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbZKCHB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 02:01:27 -0500
In-Reply-To: <4AEFCA49.4020305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :

> Its curious because in my tests the biggest problems come from
> kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
> in following attempt to create 20.000 devices
>=20
> (disable hotplug before trying this, and ipv6 too !)
> modprobe dummy numdummies=3D20000
>=20
> I believe we should address __register_sysctl_paths() scalability
> problems too.
>=20
> I dont know what is the 'sentinel' we allocate after each struct ctl_=
table
> But I suspect we could reduce size requirement of the 'sentinel' to i=
nclude
> only needed fields for the sentinel (and move them at start of ctl_ta=
ble)
>=20

Here is the patch to reduce ram usage of sysctl :

[PATCH] sysctl: reduce ram usage by 40 %

We currently reserve space for a so called sentinel, a full struct ctl_=
table
for each ctl_table. We can cheat a bit since only needed fields of a se=
ntinel
are ctl_name and procname. Add a new structure (struct ctl_table_sentin=
el)
that includes a full ctl_table and only required part of a sentinel.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/sysctl.h |   13 ++++++++++++-
 kernel/sysctl.c        |   19 ++++++++++---------
 2 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 1e4743e..6a1b1d5 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1050,8 +1050,10 @@ extern ctl_handler sysctl_ms_jiffies;
 /* A sysctl table is an array of struct ctl_table: */
 struct ctl_table=20
 {
-	int ctl_name;			/* Binary ID */
+	/* ctl_name and procname must be first fields (check sentinel) */
+	int	   ctl_name;		/* Binary ID */
 	const char *procname;		/* Text ID for /proc/sys, or zero */
+
 	void *data;
 	int maxlen;
 	mode_t mode;
@@ -1063,6 +1065,15 @@ struct ctl_table
 	void *extra2;
 };
=20
+/* ctl_table_sentinel : a ctl_table followed by a sentinel
+ * (null ctl & procname)
+ */
+struct ctl_table_sentinel {
+	struct ctl_table table;
+	int		 ctl_name;
+	const char	 *procname;
+};
+
 struct ctl_table_root {
 	struct list_head root_list;
 	struct ctl_table_set default_set;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 0d949c5..5d29dd8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2063,7 +2063,8 @@ struct ctl_table_header *__register_sysctl_paths(
 	const struct ctl_path *path, struct ctl_table *table)
 {
 	struct ctl_table_header *header;
-	struct ctl_table *new, **prevp;
+	struct ctl_table_sentinel *new;
+	struct ctl_table **prevp;
 	unsigned int n, npath;
 	struct ctl_table_set *set;
=20
@@ -2080,24 +2081,24 @@ struct ctl_table_header *__register_sysctl_path=
s(
 	 * worry about freeing additional memory in unregister_sysctl_table.
 	 */
 	header =3D kzalloc(sizeof(struct ctl_table_header) +
-			 (2 * npath * sizeof(struct ctl_table)), GFP_KERNEL);
+			 (npath * sizeof(struct ctl_table_sentinel)), GFP_KERNEL);
 	if (!header)
 		return NULL;
=20
-	new =3D (struct ctl_table *) (header + 1);
+	new =3D (struct ctl_table_sentinel *) (header + 1);
=20
 	/* Now connect the dots */
 	prevp =3D &header->ctl_table;
 	for (n =3D 0; n < npath; ++n, ++path) {
 		/* Copy the procname */
-		new->procname =3D path->procname;
-		new->ctl_name =3D path->ctl_name;
-		new->mode     =3D 0555;
+		new->table.procname =3D path->procname;
+		new->table.ctl_name =3D path->ctl_name;
+		new->table.mode     =3D 0555;
=20
-		*prevp =3D new;
-		prevp =3D &new->child;
+		*prevp =3D &new->table;
+		prevp =3D &new->table.child;
=20
-		new +=3D 2;
+		new++;
 	}
 	*prevp =3D table;
 	header->ctl_table_arg =3D table;
