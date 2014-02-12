From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net 1/3] kref: add kref_sub_return
Date: Wed, 12 Feb 2014 18:38:21 +0200
Message-ID: <1392222846-26699-2-git-send-email-mst@redhat.com>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, Joern Engel <joern@logfs.org>,
	Anatol Pomozov <anatol.pomozov@gmail.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	qinchuanyu@huawei.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1392222846-26699-1-git-send-email-mst@redhat.com>
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

It is sometimes useful to get the value of the reference count after
decrement.
For example, vhost wants to execute some periodic cleanup operations
once number of references drops below a specific value, before it
reaches zero (for efficiency).

Add an API to do this atomically and efficiently using
atomic_sub_return.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Greg, could you ack this API extension please?
I think it is cleanest to merge this through -net together
with the first user.

 include/linux/kref.h | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/kref.h b/include/linux/kref.h
index 484604d..cb20550 100644
--- a/include/linux/kref.h
+++ b/include/linux/kref.h
@@ -61,7 +61,7 @@ static inline void kref_get(struct kref *kref)
  *
  * Subtract @count from the refcount, and if 0, call release().
  * Return 1 if the object was removed, otherwise return 0.  Beware, if this
- * function returns 0, you still can not count on the kref from remaining in
+ * function returns 0, you still can not count on the kref remaining in
  * memory.  Only use the return value if you want to see if the kref is now
  * gone, not present.
  */
@@ -78,6 +78,38 @@ static inline int kref_sub(struct kref *kref, unsigned int count,
 }
 
 /**
+ * kref_sub_return - subtract a number of refcounts for object.
+ * @kref: object.
+ * @count: Number of recounts to subtract.
+ * @release: pointer to the function that will clean up the object when the
+ *	     last reference to the object is released.
+ *	     This pointer is required, and it is not acceptable to pass kfree
+ *	     in as this function.  If the caller does pass kfree to this
+ *	     function, you will be publicly mocked mercilessly by the kref
+ *	     maintainer, and anyone else who happens to notice it.  You have
+ *	     been warned.
+ *
+ * Subtract @count from the refcount, and if 0, call release().
+ * Return the new refcount.  Beware, if this function returns > N, you still
+ * can not count on there being at least N other references, and in
+ * particular, on the kref remaining in memory.
+ * Only use the return value if you want to see if there are at most,
+ * not at least, N other references to kref,
+ */
+static inline int kref_sub_return(struct kref *kref, unsigned int count,
+				  void (*release)(struct kref *kref))
+{
+	int r;
+
+	WARN_ON(release == NULL);
+
+	r = atomic_sub_return((int) count, &kref->refcount);
+	if (!r)
+		release(kref);
+	return r;
+}
+
+/**
  * kref_put - decrement refcount for object.
  * @kref: object.
  * @release: pointer to the function that will clean up the object when the
-- 
MST
