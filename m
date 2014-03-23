From: behanw@converseincode.com
Subject: [PATCH v4] net: netfilter: LLVMLinux: vlais-netfilter
Date: Sat, 22 Mar 2014 23:55:44 -0700
Message-ID: <1395557744-25248-1-git-send-email-behanw@converseincode.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6E0F8D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dwmw2@infradead.org,
	pageexec@freemail.hu, Mark Charlebois <charlebm@gmail.com>,
	Behan Webster <behanw@converseincode.com>,
	=?UTF-8?q?Vin=C3=ADcius=20Tinti?= <viniciustinti@gmail.com>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E0F8D@AcuExch.aculab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Mark Charlebois <charlebm@gmail.com>

Replaced non-standard C use of Variable Length Arrays In Structs (VLAIS=
) in
xt_repldata.h with a C99 compliant flexible array member and then calcu=
lated
offsets to the other struct members. These other members aren't referen=
ced by
name in this code, however this patch maintains the same memory layout =
and
padding as was previously accomplished using VLAIS.

Had the original structure been ordered differently, with the entries V=
LA at
the end, then it could have been a flexible member, and this patch woul=
d have
been a lot simpler. However since the data stored in this structure is
ultimately exported to userspace, the order of this structure can't be =
changed.

This patch makes no attempt to change the existing behavior, merely the=
 way in
which the current layout is accomplished using standard C99 constructs.=
 As such
the code can now be compiled with either gcc or clang.

This version of the patch removes the trailing alignment that the VLAIS
structure would allocate in order to simplify the patch.

Author: Mark Charlebois <charlebm@gmail.com>
Signed-off-by: Mark Charlebois <charlebm@gmail.com>
Signed-off-by: Behan Webster <behanw@converseincode.com>
Signed-off-by: Vin=C3=ADcius Tinti <viniciustinti@gmail.com>
---
 net/netfilter/xt_repldata.h | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
index 6efe4e5..8fd3241 100644
--- a/net/netfilter/xt_repldata.h
+++ b/net/netfilter/xt_repldata.h
@@ -5,23 +5,35 @@
  * they serve as the hanging-off data accessed through repl.data[].
  */
=20
+/* tbl has the following structure equivalent, but is C99 compliant:
+ * struct {
+ *	struct type##_replace repl;
+ *	struct type##_standard entries[nhooks];
+ *	struct type##_error term;
+ * } *tbl;
+ */
+
 #define xt_alloc_initial_table(type, typ2) ({ \
 	unsigned int hook_mask =3D info->valid_hooks; \
 	unsigned int nhooks =3D hweight32(hook_mask); \
 	unsigned int bytes =3D 0, hooknum =3D 0, i =3D 0; \
 	struct { \
 		struct type##_replace repl; \
-		struct type##_standard entries[nhooks]; \
-		struct type##_error term; \
-	} *tbl =3D kzalloc(sizeof(*tbl), GFP_KERNEL); \
+		struct type##_standard entries[]; \
+	} *tbl; \
+	struct type##_error *term; \
+	size_t term_offset =3D (offsetof(typeof(*tbl), entries[nhooks]) + \
+		__alignof__(*term) - 1) & ~(__alignof__(*term) - 1); \
+	tbl =3D kzalloc(term_offset + sizeof(*term), GFP_KERNEL); \
 	if (tbl =3D=3D NULL) \
 		return NULL; \
+	term =3D (struct type##_error *)&(((char *)tbl)[term_offset]); \
 	strncpy(tbl->repl.name, info->name, sizeof(tbl->repl.name)); \
-	tbl->term =3D (struct type##_error)typ2##_ERROR_INIT;  \
+	*term =3D (struct type##_error)typ2##_ERROR_INIT;  \
 	tbl->repl.valid_hooks =3D hook_mask; \
 	tbl->repl.num_entries =3D nhooks + 1; \
 	tbl->repl.size =3D nhooks * sizeof(struct type##_standard) + \
-	                 sizeof(struct type##_error); \
+			 sizeof(struct type##_error); \
 	for (; hook_mask !=3D 0; hook_mask >>=3D 1, ++hooknum) { \
 		if (!(hook_mask & 1)) \
 			continue; \
--=20
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
