From: "Steve Wise" <swise@opengridcomputing.com>
Subject: [PATCH v2 4/7] AMSO1100 Memory Management.
Date: Wed, 07 Jun 2006 15:06:55 -0500
Message-ID: <20060607200655.9259.90768.stgit@stevo-desktop>
References: <20060607200646.9259.24588.stgit@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com,
	mshefty@ichips.intel.com
In-Reply-To: <20060607200646.9259.24588.stgit@stevo-desktop>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org


Review Changes:

- sizeof -> sizeof()
---

 drivers/infiniband/hw/amso1100/c2_alloc.c |  256 ++++++++++++++++++++
 drivers/infiniband/hw/amso1100/c2_mm.c    |  378 +++++++++++++++++++++++=
++++++
 2 files changed, 634 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_alloc.c b/drivers/infiniba=
nd/hw/amso1100/c2_alloc.c
new file mode 100644
index 0000000..e496eb7
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2_alloc.c
@@ -0,0 +1,256 @@
+/*
+ * Copyright (c) 2004 Topspin Communications.  All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/bitmap.h>
+
+#include "c2.h"
+
+/* Trivial bitmap-based allocator */
+u32 c2_alloc(struct c2_alloc *alloc)
+{
+	u32 obj;
+
+	spin_lock(&alloc->lock);
+	obj =3D find_next_zero_bit(alloc->table, alloc->max, alloc->last);
+	if (obj >=3D alloc->max)
+		obj =3D find_first_zero_bit(alloc->table, alloc->max);
+	if (obj >=3D 0) {
+	    alloc->last =3D obj+1;
+	    if (alloc->last > alloc->max)
+		    alloc->last =3D 0;
+	}
+	spin_unlock(&alloc->lock);
+
+	return obj;
+}
+
+void c2_free(struct c2_alloc *alloc, u32 obj)
+{
+	spin_lock(&alloc->lock);
+	clear_bit(obj, alloc->table);
+	spin_unlock(&alloc->lock);
+}
+
+int c2_alloc_init(struct c2_alloc *alloc, u32 num, u32 reserved)
+{
+	int i;
+
+	alloc->last =3D 0;
+	alloc->max =3D num;
+	spin_lock_init(&alloc->lock);
+	alloc->table =3D kmalloc(BITS_TO_LONGS(num) * sizeof(long), GFP_KERNEL)=
;
+	if (!alloc->table)
+		return -ENOMEM;
+
+	bitmap_zero(alloc->table, num);
+	for (i =3D 0; i < reserved; ++i)
+		set_bit(i, alloc->table);
+
+	return 0;
+}
+
+void c2_alloc_cleanup(struct c2_alloc *alloc)
+{
+	kfree(alloc->table);
+}
+
+/*
+ * Array of pointers with lazy allocation of leaf pages.  Callers of
+ * _get, _set and _clear methods must use a lock or otherwise
+ * serialize access to the array.
+ */
+
+void *c2_array_get(struct c2_array *array, int index)
+{
+	int p =3D (index * sizeof(void *)) >> PAGE_SHIFT;
+
+	if (array->page_list[p].page) {
+		int i =3D index & (PAGE_SIZE / sizeof(void *) - 1);
+		return array->page_list[p].page[i];
+	} else
+		return NULL;
+}
+
+int c2_array_set(struct c2_array *array, int index, void *value)
+{
+	int p =3D (index * sizeof(void *)) >> PAGE_SHIFT;
+
+	/* Allocate with GFP_ATOMIC because we'll be called with locks held. */
+	if (!array->page_list[p].page)
+		array->page_list[p].page =3D
+		    (void **) get_zeroed_page(GFP_ATOMIC);
+
+	if (!array->page_list[p].page)
+		return -ENOMEM;
+
+	array->page_list[p].page[index & (PAGE_SIZE / sizeof(void *) - 1)] =3D
+	    value;
+	++array->page_list[p].used;
+
+	return 0;
+}
+
+void c2_array_clear(struct c2_array *array, int index)
+{
+	int p =3D (index * sizeof(void *)) >> PAGE_SHIFT;
+
+	if (--array->page_list[p].used =3D=3D 0) {
+		free_page((unsigned long) array->page_list[p].page);
+		array->page_list[p].page =3D NULL;
+	}
+
+	if (array->page_list[p].used < 0)
+		pr_debug("Array %p index %d page %d with ref count %d < 0\n",
+			 array, index, p, array->page_list[p].used);
+}
+
+int c2_array_init(struct c2_array *array, int nent)
+{
+	int npage =3D (nent * sizeof(void *) + PAGE_SIZE - 1) / PAGE_SIZE;
+	int i;
+
+	array->page_list =3D
+	    kmalloc(npage * sizeof(*array->page_list), GFP_KERNEL);
+	if (!array->page_list)
+		return -ENOMEM;
+
+	for (i =3D 0; i < npage; ++i) {
+		array->page_list[i].page =3D NULL;
+		array->page_list[i].used =3D 0;
+	}
+
+	return 0;
+}
+
+void c2_array_cleanup(struct c2_array *array, int nent)
+{
+	int i;
+
+	for (i =3D 0; i < (nent * sizeof(void *) + PAGE_SIZE - 1) / PAGE_SIZE;
+	     ++i)
+		free_page((unsigned long) array->page_list[i].page);
+
+	kfree(array->page_list);
+}
+
+static int c2_alloc_mqsp_chunk(gfp_t gfp_mask, struct sp_chunk **head)
+{
+	int i;
+	struct sp_chunk *new_head;
+
+	new_head =3D (struct sp_chunk *) __get_free_page(gfp_mask | GFP_DMA);
+	if (new_head =3D=3D NULL)
+		return -ENOMEM;
+
+	new_head->next =3D NULL;
+	new_head->head =3D 0;
+	new_head->gfp_mask =3D gfp_mask;
+
+	/* build list where each index is the next free slot */
+	for (i =3D 0;
+	     i < (PAGE_SIZE - sizeof(struct sp_chunk) -=20
+		  sizeof(u16)) / sizeof(u16) - 1;=20
+	     i++) {
+		new_head->shared_ptr[i] =3D i + 1;
+	}
+	/* terminate list */
+	new_head->shared_ptr[i] =3D 0xFFFF;
+
+	*head =3D new_head;
+	return 0;
+}
+
+int c2_init_mqsp_pool(gfp_t gfp_mask, struct sp_chunk **root)
+{
+	return c2_alloc_mqsp_chunk(gfp_mask, root);
+}
+
+void c2_free_mqsp_pool(struct sp_chunk *root)
+{
+	struct sp_chunk *next;
+
+	while (root) {
+		next =3D root->next;
+		__free_page((struct page *) root);
+		root =3D next;
+	}
+}
+
+u16 *c2_alloc_mqsp(struct sp_chunk *head)
+{
+	u16 mqsp;
+
+	while (head) {
+		mqsp =3D head->head;
+		if (mqsp !=3D 0xFFFF) {
+			head->head =3D head->shared_ptr[mqsp];
+			break;
+		} else if (head->next =3D=3D NULL) {
+			if (c2_alloc_mqsp_chunk(head->gfp_mask, &head->next)=3D=3D0) {
+				head =3D head->next;
+				mqsp =3D head->head;
+				head->head =3D head->shared_ptr[mqsp];
+				break;
+			} else
+				return NULL;
+		} else
+			head =3D head->next;
+	}
+	if (head)
+		return &(head->shared_ptr[mqsp]);
+	return NULL;
+}
+
+void c2_free_mqsp(u16 * mqsp)
+{
+	struct sp_chunk *head;
+	u16 idx;
+
+	/* The chunk containing this ptr begins at the page boundary */
+	head =3D (struct sp_chunk *) ((unsigned long) mqsp & PAGE_MASK);
+
+	/* Link head to new mqsp */
+	*mqsp =3D head->head;
+
+	/* Compute the shared_ptr index */
+	idx =3D ((unsigned long) mqsp & ~PAGE_MASK) >> 1;
+	idx -=3D (unsigned long) &(((struct sp_chunk *) 0)->shared_ptr[0]) >> 1=
;
+
+	/* Point this index at the head */
+	head->shared_ptr[idx] =3D head->head;
+
+	/* Point head at this index */
+	head->head =3D idx;
+}
diff --git a/drivers/infiniband/hw/amso1100/c2_mm.c b/drivers/infiniband/=
hw/amso1100/c2_mm.c
new file mode 100644
index 0000000..13c8122
--- /dev/null
+++ b/drivers/infiniband/hw/amso1100/c2_mm.c
@@ -0,0 +1,378 @@
+/*
+ * Copyright (c) 2005 Ammasso, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include "c2.h"
+#include "c2_vq.h"
+
+#define PBL_VIRT 1
+#define PBL_PHYS 2
+
+/*
+ * Send all the PBL messages to convey the remainder of the PBL
+ * Wait for the adapter's reply on the last one.
+ * This is indicated by setting the MEM_PBL_COMPLETE in the flags.
+ *
+ * NOTE:  vq_req is _not_ freed by this function.  The VQ Host
+ *	  Reply buffer _is_ freed by this function.
+ */
+static int
+send_pbl_messages(struct c2_dev *c2dev, u32 stag_index,
+		  unsigned long va, u32 pbl_depth,
+		  struct c2_vq_req *vq_req, int pbl_type)
+{
+	u32 pbe_count;		/* amt that fits in a PBL msg */
+	u32 count;		/* amt in this PBL MSG. */
+	struct c2wr_nsmr_pbl_req *wr;	/* PBL WR ptr */
+	struct c2wr_nsmr_pbl_rep *reply;	/* reply ptr */
+ 	int err, pbl_virt, pbl_index, i;
+
+	switch (pbl_type) {
+	case PBL_VIRT:
+		pbl_virt =3D 1;
+		break;
+	case PBL_PHYS:
+		pbl_virt =3D 0;
+		break;
+	default:
+		return -EINVAL;
+		break;
+	}
+
+	pbe_count =3D (c2dev->req_vq.msg_size -
+		     sizeof(struct c2wr_nsmr_pbl_req)) / sizeof(u64);
+	wr =3D kmalloc(c2dev->req_vq.msg_size, GFP_KERNEL);
+	if (!wr) {
+		return -ENOMEM;
+	}
+	c2_wr_set_id(wr, CCWR_NSMR_PBL);
+
+	/*
+	 * Only the last PBL message will generate a reply from the verbs,=20
+	 * so we set the context to 0 indicating there is no kernel verbs
+	 * handler blocked awaiting this reply.
+	 */
+	wr->hdr.context =3D 0;
+	wr->rnic_handle =3D c2dev->adapter_handle;
+	wr->stag_index =3D stag_index;	/* already swapped */
+	wr->flags =3D 0;
+	pbl_index =3D 0;
+	while (pbl_depth) {
+		count =3D min(pbe_count, pbl_depth);
+		wr->addrs_length =3D cpu_to_be32(count);
+
+		/*
+		 *  If this is the last message, then reference the
+		 *  vq request struct cuz we're gonna wait for a reply.
+		 *  also make this PBL msg as the last one.
+		 */
+		if (count =3D=3D pbl_depth) {
+			/*
+			 * reference the request struct.  dereferenced in the=20
+			 * int handler.
+			 */
+			vq_req_get(c2dev, vq_req);
+			wr->flags =3D cpu_to_be32(MEM_PBL_COMPLETE);
+
+			/*
+			 * This is the last PBL message.
+			 * Set the context to our VQ Request Object so we can
+			 * wait for the reply.
+			 */
+			wr->hdr.context =3D (unsigned long) vq_req;
+		}
+
+		/*
+		 * If pbl_virt is set then va is a virtual address=20
+		 * that describes a virtually contiguous memory
+		 * allocation. The wr needs the start of each virtual page
+		 * to be converted to the corresponding physical address
+		 * of the page. If pbl_virt is not set then va is an array
+		 * of physical addresses and there is no conversion to do.
+		 * Just fill in the wr with what is in the array. =20
+		 */
+		for (i =3D 0; i < count; i++) {
+			if (pbl_virt) {
+				/* XXX */
+				//wr->paddrs[i] =3D=20
+				//	cpu_to_be64(user_virt_to_phys(va));
+				va +=3D PAGE_SIZE;
+			} else {
+ 				wr->paddrs[i] =3D=20
+				    cpu_to_be64(((u64 *)va)[pbl_index + i]);
+			}
+		}
+
+		/*
+		 * Send WR to adapter
+		 */
+		err =3D vq_send_wr(c2dev, (union c2wr *) wr);
+		if (err) {
+			if (count <=3D pbe_count) {
+				vq_req_put(c2dev, vq_req);
+			}
+			goto bail0;
+		}
+		pbl_depth -=3D count;
+		pbl_index +=3D count;
+	}
+
+	/*
+	 *  Now wait for the reply...
+	 */
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err) {
+		goto bail0;
+	}
+
+	/*
+	 * Process reply=20
+	 */
+	reply =3D (struct c2wr_nsmr_pbl_rep *) (unsigned long) vq_req->reply_ms=
g;
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	err =3D c2_errno(reply);
+
+	vq_repbuf_free(c2dev, reply);
+      bail0:
+	kfree(wr);
+	return err;
+}
+
+#define C2_PBL_MAX_DEPTH 131072
+int
+c2_nsmr_register_phys_kern(struct c2_dev *c2dev, u64 *addr_list,=20
+ 			   int page_size, int pbl_depth, u32 length,=20
+ 			   u32 offset, u64 *va, enum c2_acf acf,=20
+			   struct c2_mr *mr)
+{
+	struct c2_vq_req *vq_req;
+	struct c2wr_nsmr_register_req *wr;
+	struct c2wr_nsmr_register_rep *reply;
+	u16 flags;
+	int i, pbe_count, count;
+	int err;
+
+	if (!va || !length || !addr_list || !pbl_depth)
+		return -EINTR;
+
+	/*
+	 * Verify PBL depth is within rnic max
+	 */
+	if (pbl_depth > C2_PBL_MAX_DEPTH) {
+		return -EINTR;
+	}
+
+	/*
+	 * allocate verbs request object
+	 */
+	vq_req =3D vq_req_alloc(c2dev);
+	if (!vq_req)
+		return -ENOMEM;
+
+	wr =3D kmalloc(c2dev->req_vq.msg_size, GFP_KERNEL);
+	if (!wr) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	/*
+	 * build the WR
+	 */
+	c2_wr_set_id(wr, CCWR_NSMR_REGISTER);
+	wr->hdr.context =3D (unsigned long) vq_req;
+	wr->rnic_handle =3D c2dev->adapter_handle;
+
+	flags =3D (acf | MEM_VA_BASED | MEM_REMOTE);
+
+	/*
+	 * compute how many pbes can fit in the message
+	 */
+	pbe_count =3D (c2dev->req_vq.msg_size -
+		     sizeof(struct c2wr_nsmr_register_req)) / sizeof(u64);
+
+	if (pbl_depth <=3D pbe_count) {
+		flags |=3D MEM_PBL_COMPLETE;
+	}
+	wr->flags =3D cpu_to_be16(flags);
+	wr->stag_key =3D 0;	//stag_key;
+	wr->va =3D cpu_to_be64(*va);
+	wr->pd_id =3D mr->pd->pd_id;
+	wr->pbe_size =3D cpu_to_be32(page_size);
+	wr->length =3D cpu_to_be32(length);
+	wr->pbl_depth =3D cpu_to_be32(pbl_depth);
+	wr->fbo =3D cpu_to_be32(offset);
+	count =3D min(pbl_depth, pbe_count);
+	wr->addrs_length =3D cpu_to_be32(count);
+
+	/*
+	 * fill out the PBL for this message
+	 */
+	for (i =3D 0; i < count; i++) {
+		wr->paddrs[i] =3D cpu_to_be64(addr_list[i]);
+	}
+
+	/*
+	 * regerence the request struct=20
+	 */
+	vq_req_get(c2dev, vq_req);
+
+	/*
+	 * send the WR to the adapter
+	 */
+	err =3D vq_send_wr(c2dev, (union c2wr *) wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail1;
+	}
+
+	/*
+	 * wait for reply from adapter
+	 */
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err) {
+		goto bail1;
+	}
+
+	/*
+	 * process reply
+	 */
+	reply =3D
+	    (struct c2wr_nsmr_register_rep *) (unsigned long) (vq_req->reply_ms=
g);
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail1;
+	}
+	if ((err =3D c2_errno(reply))) {
+		goto bail2;
+	}
+	//*p_pb_entries =3D be32_to_cpu(reply->pbl_depth);
+	mr->ibmr.lkey =3D mr->ibmr.rkey =3D be32_to_cpu(reply->stag_index);
+	vq_repbuf_free(c2dev, reply);
+
+	/*
+	 * if there are still more PBEs we need to send them to
+	 * the adapter and wait for a reply on the final one.
+	 * reuse vq_req for this purpose.
+	 */
+	pbl_depth -=3D count;
+	if (pbl_depth) {
+
+		vq_req->reply_msg =3D (unsigned long) NULL;
+		atomic_set(&vq_req->reply_ready, 0);
+		err =3D send_pbl_messages(c2dev,
+					cpu_to_be32(mr->ibmr.lkey),
+					(unsigned long) &addr_list[i],
+					pbl_depth, vq_req, PBL_PHYS);
+		if (err) {
+			goto bail1;
+		}
+	}
+
+	vq_req_free(c2dev, vq_req);
+	kfree(wr);
+
+	return err;
+
+      bail2:
+	vq_repbuf_free(c2dev, reply);
+      bail1:
+	kfree(wr);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
+
+int c2_stag_dealloc(struct c2_dev *c2dev, u32 stag_index)
+{
+	struct c2_vq_req *vq_req;	/* verbs request object */
+	struct c2wr_stag_dealloc_req wr;	/* work request */
+	struct c2wr_stag_dealloc_rep *reply;	/* WR reply  */
+	int err;
+
+
+	/*
+	 * allocate verbs request object
+	 */
+	vq_req =3D vq_req_alloc(c2dev);
+	if (!vq_req) {
+		return -ENOMEM;
+	}
+
+	/*=20
+	 * Build the WR
+	 */
+	c2_wr_set_id(&wr, CCWR_STAG_DEALLOC);
+	wr.hdr.context =3D (u64) (unsigned long) vq_req;
+	wr.rnic_handle =3D c2dev->adapter_handle;
+	wr.stag_index =3D cpu_to_be32(stag_index);
+
+	/*
+	 * reference the request struct.  dereferenced in the int handler.
+	 */
+	vq_req_get(c2dev, vq_req);
+
+	/*
+	 * Send WR to adapter
+	 */
+	err =3D vq_send_wr(c2dev, (union c2wr *) & wr);
+	if (err) {
+		vq_req_put(c2dev, vq_req);
+		goto bail0;
+	}
+
+	/*
+	 * Wait for reply from adapter
+	 */
+	err =3D vq_wait_for_reply(c2dev, vq_req);
+	if (err) {
+		goto bail0;
+	}
+
+	/*
+	 * Process reply=20
+	 */
+	reply =3D (struct c2wr_stag_dealloc_rep *) (unsigned long) vq_req->repl=
y_msg;
+	if (!reply) {
+		err =3D -ENOMEM;
+		goto bail0;
+	}
+
+	err =3D c2_errno(reply);
+
+	vq_repbuf_free(c2dev, reply);
+      bail0:
+	vq_req_free(c2dev, vq_req);
+	return err;
+}
