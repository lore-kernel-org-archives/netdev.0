From: behanw@converseincode.com
Subject: [PATCH] net: inetfilter: LLVMLinux: vlais-netfilter
Date: Thu,  6 Mar 2014 11:56:08 -0800
Message-ID: <1394135768-27621-1-git-send-email-behanw@converseincode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	dwmw2@infradead.org, pageexec@freemail.hu,
	Mark Charlebois <charlebm@gmail.com>,
	Behan Webster <behanw@converseincode.com>,
	=?UTF-8?q?Vin=C3=ADcius=20Tinti?= <viniciustinti@gmail.com>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
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

Author: Mark Charlebois <charlebm@gmail.com>
Signed-off-by: Mark Charlebois <charlebm@gmail.com>
Signed-off-by: Behan Webster <behanw@converseincode.com>
Signed-off-by: Vin=C3=ADcius Tinti <viniciustinti@gmail.com>
---
 net/netfilter/xt_repldata.h | 34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_repldata.h b/net/netfilter/xt_repldata.h
index 6efe4e5..c138fea 100644
--- a/net/netfilter/xt_repldata.h
+++ b/net/netfilter/xt_repldata.h
@@ -5,29 +5,51 @@
  * they serve as the hanging-off data accessed through repl.data[].
  */
=20
+#define padbytes(offset, type) ((-offset) & (__alignof__(type)-1))
+
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
+		char data[0]; \
+	} *tbl; \
+	struct type##_standard *entries; \
+	struct type##_error *term; \
+	size_t entries_offset =3D padbytes(sizeof(tbl->repl), *entries); \
+	size_t entries_end =3D entries_offset + nhooks * sizeof(*entries); \
+	size_t term_offset =3D entries_end \
+		+ padbytes(sizeof(tbl->repl) + entries_end, *term); \
+	size_t term_end =3D term_offset + sizeof(*term); \
+	size_t data_sz =3D term_end \
+		+ padbytes(sizeof(tbl->repl) + term_end, tbl->repl); \
+	size_t tbl_sz =3D sizeof(tbl->repl) + data_sz; \
+	tbl =3D kzalloc(tbl_sz, GFP_KERNEL); \
 	if (tbl =3D=3D NULL) \
 		return NULL; \
+	entries =3D (struct type##_standard *)&tbl->data[entries_offset]; \
+	term =3D (struct type##_error *)&tbl->data[term_offset]; \
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
 		tbl->repl.hook_entry[hooknum] =3D bytes; \
 		tbl->repl.underflow[hooknum]  =3D bytes; \
-		tbl->entries[i++] =3D (struct type##_standard) \
+		entries[i++] =3D (struct type##_standard) \
 			typ2##_STANDARD_INIT(NF_ACCEPT); \
 		bytes +=3D sizeof(struct type##_standard); \
 	} \
--=20
1.8.3.2

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
