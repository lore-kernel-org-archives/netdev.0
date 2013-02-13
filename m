From: Rusty Russell <rusty@rustcorp.com.au>
Subject: RE: [PATCH vringh 2/2] caif_virtio: Introduce caif over virtio
Date: Wed, 13 Feb 2013 20:46:22 +1030
Message-ID: <87ehgklds9.fsf@rustcorp.com.au>
References: <1360494273-27889-1-git-send-email-sjur.brandeland@stericsson.com>
	<1360494273-27889-3-git-send-email-sjur.brandeland@stericsson.com>
	<87vc9zfic8.fsf@rustcorp.com.au>
	<81C3A93C17462B4BBD7E272753C105792458EDD161@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vikram ARV <vikram.arv@stericsson.com>,
	Dmitry TARNYAGIN <dmitry.tarnyagin@stericsson.com>,
	"sjur@brendeland.net" <sjur@brendeland.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Erwan YVIN <erwan.yvin@stericsson.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ido Yariv <ido@wizery.com>
To: Sjur BRENDELAND <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>, Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <81C3A93C17462B4BBD7E272753C105792458EDD161@EXDCVYMBSTM005.EQ1STM.local>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sjur BRENDELAND <sjur.brandeland@stericsson.com> writes:
> Hi Rusty,
>
>> From: Rusty Russell [mailto:rusty@rustcorp.com.au]
>> sjur.brandeland@stericsson.com writes:
>> > +struct cfv_napi_context {
>> > +	struct vringh_kiov riov;
>> > +	unsigned short head;
>> > +};
>> 
>> Usually we use an int, and -1.  I imagine it'll take no more space,
>> due to padding.
>
> I'm passing a pointer to "head" to vringh_getdesc_kern() directly, are you
> suggesting to change the head argument in  vringh_getdesc_kern()
> to a int pointer as well then?

No, that's OK in that case.

>> > +static inline void ctx_prep_iov(struct cfv_napi_context *ctx)
>> > +{
>> > +	if (ctx->riov.allocated) {
>> > +		kfree(ctx->riov.iov);
>> > +		ctx->riov.iov = NULL;
>> > +		ctx->riov.allocated = false;
>> > +	}
>> > +	ctx->riov.iov = NULL;
>> > +	ctx->riov.i = 0;
>> > +	ctx->riov.max = 0;
>> > +}
>> 
>> Hmm, we should probably make sure you don't have to do this: that if
>> allocated once, you can simply reuse it by setting i = 0.
>
> Yes, I had problems getting the alloc/free of iov right. This is
> perhaps the least intuitively part of the API. I maybe it's just me, but
> I think some more helper functions and support from vringh in this
> area would be great.

Yes, I've neatened my git tree, an in particular added a commit which
covers this explicitly, and one for the -EPROTO when we get unexpected
r/w bufs.  I've appended them below.

>> (This requires some care in the error handling paths, so we don't
>> free it from under you)...
>> 
>> And you probably want to free this up in cfv_remove() instead?
>
> OK, I'll look into this when you have a some more code ready...

Pushed (rebase!) to my git tree now.  You can also see what I've done to
vhost, though there's more to come on that front.

vringh: Allow reuse of vringh_iov/vringh_kiov.

We allocate a larger iov if we need to, but it's better if the caller
can simply hand it back for reuse, rather than freeing it every time.

We also want to interate without mangling the iov (useful for vhost).

Hence we track the number allocated and the number used separately, as
well as the offset within the current iov element, and add helpers to
init/cleanup and reuse.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index 55f3805..eb19948 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -73,21 +73,22 @@ static inline ssize_t vringh_iov_xfer(struct vringh_kiov *iov,
 {
 	int err, done = 0;
 
-	while (len && iov->i < iov->max) {
+	while (len && iov->i < iov->used) {
 		size_t partlen;
 
-		partlen = min(iov->iov[iov->i].iov_len, len);
-		err = xfer(iov->iov[iov->i].iov_base, ptr, partlen);
+		partlen = min(iov->iov[iov->i].iov_len - iov->off, len);
+		err = xfer(iov->iov[iov->i].iov_base + iov->off, ptr, partlen);
 		if (err)
 			return err;
 		done += partlen;
 		len -= partlen;
 		ptr += partlen;
-		iov->iov[iov->i].iov_base += partlen;
-		iov->iov[iov->i].iov_len -= partlen;
+		iov->off += partlen;
 
-		if (iov->iov[iov->i].iov_len == 0)
+		if (iov->off == iov->iov[iov->i].iov_len) {
+			iov->off = 0;
 			iov->i++;
+		}
 	}
 	return done;
 }
@@ -167,24 +168,25 @@ static int move_to_indirect(int *up_next, u16 *i, void *addr,
 static int resize_iovec(struct vringh_kiov *iov, gfp_t gfp)
 {
 	struct kvec *new;
-	unsigned int new_num = iov->max * 2;
+	unsigned int flag, new_num = (iov->max_num & ~VRINGH_IOV_ALLOCATED) * 2;
 
 	if (new_num < 8)
 		new_num = 8;
 
-	if (iov->allocated)
+	flag = (iov->max_num & VRINGH_IOV_ALLOCATED);
+	if (flag)
 		new = krealloc(iov->iov, new_num * sizeof(struct iovec), gfp);
 	else {
 		new = kmalloc(new_num * sizeof(struct iovec), gfp);
 		if (new) {
 			memcpy(new, iov->iov, iov->i * sizeof(struct iovec));
-			iov->allocated = true;
+			flag = VRINGH_IOV_ALLOCATED;
 		}
 	}
 	if (!new)
 		return -ENOMEM;
 	iov->iov = new;
-	iov->max = new_num;
+	iov->max_num = (new_num | flag);
 	return 0;
 }
 
@@ -257,6 +259,8 @@ __vringh_iov(struct vringh *vrh, u16 i,
 	up_next = -1;
 
 	riov->i = wiov->i = 0;
+	riov->used = wiov->used = 0;
+
 	for (;;) {
 		void *addr;
 		struct vringh_kiov *iov;
@@ -319,15 +323,15 @@ __vringh_iov(struct vringh *vrh, u16 i,
 		}
 		addr = (void *)(unsigned long)(desc.addr + range.offset);
 
-		if (unlikely(iov->i == iov->max)) {
+		if (unlikely(iov->used == (iov->max_num & ~VRINGH_IOV_ALLOCATED))) {
 			err = resize_iovec(iov, gfp);
 			if (err)
 				goto fail;
 		}
 
-		iov->iov[iov->i].iov_base = addr;
-		iov->iov[iov->i].iov_len = len;
-		iov->i++;
+		iov->iov[iov->used].iov_base = addr;
+		iov->iov[iov->used].iov_len = len;
+		iov->used++;
 
 		if (unlikely(len != desc.len)) {
 			desc.len -= len;
@@ -354,17 +358,9 @@ __vringh_iov(struct vringh *vrh, u16 i,
 		}
 	}
 
-	/* Reset for fresh iteration. */
-	riov->max = riov->i;
-	wiov->max = wiov->i;
-	riov->i = wiov->i = 0;
 	return 0;
 
 fail:
-	if (riov->allocated)
-		kfree(riov->iov);
-	if (wiov->allocated)
-		kfree(wiov->iov);
 	return err;
 }
 
@@ -612,8 +608,7 @@ EXPORT_SYMBOL(vringh_init_user);
  * *head will be vrh->vring.num.  You may be able to ignore an invalid
  * descriptor, but there's not much you can do with an invalid ring.
  *
- * If it returns 1, riov->allocated and wiov->allocated indicate if you
- * have to kfree riov->iov and wiov->iov respectively.
+ * Note that you may need to clean up riov and wiov, even on error!
  */
 int vringh_getdesc_user(struct vringh *vrh,
 			struct vringh_iov *riov,
@@ -639,10 +634,10 @@ int vringh_getdesc_user(struct vringh *vrh,
 		     offsetof(struct vringh_iov, iov));
 	BUILD_BUG_ON(offsetof(struct vringh_kiov, i) !=
 		     offsetof(struct vringh_iov, i));
-	BUILD_BUG_ON(offsetof(struct vringh_kiov, max) !=
-		     offsetof(struct vringh_iov, max));
-	BUILD_BUG_ON(offsetof(struct vringh_kiov, allocated) !=
-		     offsetof(struct vringh_iov, allocated));
+	BUILD_BUG_ON(offsetof(struct vringh_kiov, used) !=
+		     offsetof(struct vringh_iov, used));
+	BUILD_BUG_ON(offsetof(struct vringh_kiov, max_num) !=
+		     offsetof(struct vringh_iov, max_num));
 	BUILD_BUG_ON(sizeof(struct iovec) != sizeof(struct kvec));
 	BUILD_BUG_ON(offsetof(struct iovec, iov_base) !=
 		     offsetof(struct kvec, iov_base));
@@ -867,8 +862,12 @@ EXPORT_SYMBOL(vringh_init_kern);
  *
  * Returns 0 if there was no descriptor, 1 if there was, or -errno.
  *
- * If it returns 1, riov->allocated and wiov->allocated indicate if you
- * have to kfree riov->iov and wiov->iov respectively.
+ * Note that on error return, you can tell the difference between an
+ * invalid ring and a single invalid descriptor: in the former case,
+ * *head will be vrh->vring.num.  You may be able to ignore an invalid
+ * descriptor, but there's not much you can do with an invalid ring.
+ *
+ * Note that you may need to clean up riov and wiov, even on error!
  */
 int vringh_getdesc_kern(struct vringh *vrh,
 			struct vringh_kiov *riov,
diff --git a/include/linux/vringh.h b/include/linux/vringh.h
index d78e89e..ab41185 100644
--- a/include/linux/vringh.h
+++ b/include/linux/vringh.h
@@ -25,6 +25,7 @@
 #define _LINUX_VRINGH_H
 #include <uapi/linux/virtio_ring.h>
 #include <linux/uio.h>
+#include <linux/slab.h>
 #include <asm/barrier.h>
 
 /* virtio_ring with information needed for host access. */
@@ -60,17 +61,20 @@ struct vringh_range {
 /* All the information about an iovec. */
 struct vringh_iov {
 	struct iovec *iov;
-	unsigned i, max;
-	bool allocated;
+	size_t off; /* Within iov[i] */
+	unsigned i, used, max_num;
 };
 
 /* All the information about a kvec. */
 struct vringh_kiov {
 	struct kvec *iov;
-	unsigned i, max;
-	bool allocated;
+	size_t off; /* Within iov[i] */
+	unsigned i, used, max_num;
 };
 
+/* Flag on max_num to indicate we're kmalloced. */
+#define VRINGH_IOV_ALLOCATED 0x8000000
+
 /* Helpers for userspace vrings. */
 int vringh_init_user(struct vringh *vrh, u32 features,
 		     unsigned int num, bool weak_barriers,
@@ -78,6 +82,29 @@ int vringh_init_user(struct vringh *vrh, u32 features,
 		     struct vring_avail __user *avail,
 		     struct vring_used __user *used);
 
+static inline void vringh_iov_init(struct vringh_iov *iov,
+				   struct iovec *iovec, unsigned num)
+{
+	iov->used = iov->i = 0;
+	iov->off = 0;
+	iov->max_num = num;
+	iov->iov = iovec;
+}
+
+static inline void vringh_iov_reset(struct vringh_iov *iov)
+{
+	iov->off = 0;
+	iov->i = 0;
+}
+
+static inline void vringh_iov_cleanup(struct vringh_iov *iov)
+{
+	if (iov->max_num & VRINGH_IOV_ALLOCATED)
+		kfree(iov->iov);
+	iov->max_num = iov->used = iov->i = iov->off = 0;
+	iov->iov = NULL;
+}
+
 /* Convert a descriptor into iovecs. */
 int vringh_getdesc_user(struct vringh *vrh,
 			struct vringh_iov *riov,
@@ -115,6 +142,29 @@ int vringh_init_kern(struct vringh *vrh, u32 features,
 		     struct vring_avail *avail,
 		     struct vring_used *used);
 
+static inline void vringh_kiov_init(struct vringh_kiov *kiov,
+				    struct kvec *kvec, unsigned num)
+{
+	kiov->used = kiov->i = 0;
+	kiov->off = 0;
+	kiov->max_num = num;
+	kiov->iov = kvec;
+}
+
+static inline void vringh_kiov_reset(struct vringh_kiov *kiov)
+{
+	kiov->off = 0;
+	kiov->i = 0;
+}
+
+static inline void vringh_kiov_cleanup(struct vringh_kiov *kiov)
+{
+	if (kiov->max_num & VRINGH_IOV_ALLOCATED)
+		kfree(kiov->iov);
+	kiov->max_num = kiov->used = kiov->i = kiov->off = 0;
+	kiov->iov = NULL;
+}
+
 int vringh_getdesc_kern(struct vringh *vrh,
 			struct vringh_kiov *riov,
 			struct vringh_kiov *wiov,

vringh: allow NULL riov and wiov to vringh_getdesc_user()

There are numerous cases where we don't expect any writable (or
readable) descriptors, so handle that in common code rather than
making the caller check.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index ec50cd9..6b37974 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -257,8 +257,13 @@ __vringh_iov(struct vringh *vrh, u16 i,
 	desc_max = vrh->vring.num;
 	up_next = -1;
 
-	riov->i = wiov->i = 0;
-	riov->used = wiov->used = 0;
+	if (riov)
+		riov->i = riov->used = 0;
+	else if (wiov)
+		wiov->i = wiov->used = 0;
+	else
+		/* You must want something! */
+		BUG();
 
 	for (;;) {
 		void *addr;
@@ -305,7 +310,7 @@ __vringh_iov(struct vringh *vrh, u16 i,
 			iov = wiov;
 		else {
 			iov = riov;
-			if (unlikely(wiov->i)) {
+			if (unlikely(wiov && wiov->i)) {
 				vringh_bad("Readable desc %p after writable",
 					   &descs[i]);
 				err = -EINVAL;
@@ -313,6 +318,13 @@ __vringh_iov(struct vringh *vrh, u16 i,
 			}
 		}
 
+		if (!iov) {
+			vringh_bad("Unexpected %s desc",
+				   !wiov ? "writable" : "readable");
+			err = -EPROTO;
+			goto fail;
+		}
+
 	again:
 		/* Make sure it's OK, and get offset. */
 		len = desc.len;
@@ -595,8 +607,8 @@ EXPORT_SYMBOL(vringh_init_user);
 /**
  * vringh_getdesc_user - get next available descriptor from userspace ring.
  * @vrh: the userspace vring.
- * @riov: where to put the readable descriptors.
- * @wiov: where to put the writable descriptors.
+ * @riov: where to put the readable descriptors (or NULL)
+ * @wiov: where to put the writable descriptors (or NULL)
  * @getrange: function to call to check ranges.
  * @head: head index we received, for passing to vringh_complete_user().
  *
@@ -854,8 +866,8 @@ EXPORT_SYMBOL(vringh_init_kern);
 /**
  * vringh_getdesc_kern - get next available descriptor from kernelspace ring.
  * @vrh: the kernelspace vring.
- * @riov: where to put the readable descriptors.
- * @wiov: where to put the writable descriptors.
+ * @riov: where to put the readable descriptors (or NULL)
+ * @wiov: where to put the writable descriptors (or NULL)
  * @head: head index we received, for passing to vringh_complete_kern().
  * @gfp: flags for allocating larger riov/wiov.
  *
