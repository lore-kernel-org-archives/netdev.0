From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: smallish review of acx1xx-wireless-driver.patch
Date: Fri, 20 Oct 2006 06:37:04 +0400
Message-ID: <20061020023704.GC5342@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Denis Vlasenko <vda@ilport.com.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:57907 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1946839AbWJTChC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 22:37:02 -0400
Received: by ug-out-1314.google.com with SMTP id o38so647069ugd
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 19:37:01 -0700 (PDT)
To: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Main griefs:
a) home-grown lock debugger (what can it do what lockdep can't?)
b) lack of endian annotations.
c) driver fallbacks to USA regulatory domain if it can't find valid one
   from the list. My gut feeling is that this can bring an unattentive Linux
   user to police on bad day.

lesser griefs are scattered over the rest of email.
-----------------------------------------------------
+/* Locking: */
+/* very talkative */
+/* #define PARANOID_LOCKING 1 */
+/* normal (use when bug-free) */
+#define DO_LOCKING 1
+/* else locking is disabled! */

	lock debugging.

+#define CLEAR_BIT(val, mask) ((val) &= ~(mask))
+#define SET_BIT(val, mask) ((val) |= (mask))

	silly macros and even misused in code like

		CLEAR_BIT(feat.feature_options, cpu_to_le32(feature_options));

	Please, open code.

+/* These functions *must* be inline or they will break horribly on SPARC, due
+ * to its weird semantics for save/restore flags */
+
+#if defined(PARANOID_LOCKING) /* Lock debugging */
+
+void acx_lock_debug(acx_device_t *adev, const char* where);
+void acx_unlock_debug(acx_device_t *adev, const char* where);
+void acx_down_debug(acx_device_t *adev, const char* where);
+void acx_up_debug(acx_device_t *adev, const char* where);
+void acx_lock_unhold(void);
+void acx_sem_unhold(void);
+
+static inline void
+acx_lock_helper(acx_device_t *adev, unsigned long *fp, const char* where)
+{
+	acx_lock_debug(adev, where);
+	spin_lock_irqsave(&adev->lock, *fp);
+}
+static inline void
+acx_unlock_helper(acx_device_t *adev, unsigned long *fp, const char* where)
+{
+	acx_unlock_debug(adev, where);
+	spin_unlock_irqrestore(&adev->lock, *fp);
+}
+static inline void
+acx_down_helper(acx_device_t *adev, const char* where)
+{
+	acx_down_debug(adev, where);
+}
+static inline void
+acx_up_helper(acx_device_t *adev, const char* where)
+{
+	acx_up_debug(adev, where);
+}
+#define acx_lock(adev, flags)	acx_lock_helper(adev, &(flags), __FILE__ ":" STRING(__LINE__))
+#define acx_unlock(adev, flags)	acx_unlock_helper(adev, &(flags), __FILE__ ":" STRING(__LINE__))
+#define acx_sem_lock(adev)	acx_down_helper(adev, __FILE__ ":" STRING(__LINE__))
+#define acx_sem_unlock(adev)	acx_up_helper(adev, __FILE__ ":" STRING(__LINE__))
+
+#elif defined(DO_LOCKING)
+
+#define acx_lock(adev, flags)	spin_lock_irqsave(&adev->lock, flags)
+#define acx_unlock(adev, flags)	spin_unlock_irqrestore(&adev->lock, flags)
+#define acx_sem_lock(adev)	down(&adev->sem)
+#define acx_sem_unlock(adev)	up(&adev->sem)
+#define acx_lock_unhold()	((void)0)
+#define acx_sem_unhold()	((void)0)
+
+#else /* no locking! :( */
+
+#define acx_lock(adev, flags)	((void)0)
+#define acx_unlock(adev, flags)	((void)0)
+#define acx_sem_lock(adev)	((void)0)
+#define acx_sem_unlock(adev)	((void)0)
+#define acx_lock_unhold()	((void)0)
+#define acx_sem_unhold()	((void)0)
+
+#endif

+enum {
+	L_LOCK		= (ACX_DEBUG>1)*0x0001,	/* locking debug log */

	lock debugging

+#define ACX_PACKED __WLAN_ATTRIB_PACK__

	Just add __packed in kernel.h I guess.

+#define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))

	That would be already existing ARRAY_SIZE()

+/***********************************************************************
+** Constants
+*/
+#define OK	0
+#define NOT_OK	1

	That's not OK.

+#if !defined(CONFIG_ACX_PCI) && !defined(CONFIG_ACX_USB)
+#error Driver must include PCI and/or USB support. You selected neither.
+#endif

	Can it be done some via Kconfig magic? I don't know.

+/* An opaque typesafe helper type
+ *
+ * Some hardware fields are actually pointers,
+ * but they have to remain u32, since using ptr instead
+ * (8 bytes on 64bit systems!) would disrupt the fixed descriptor
+ * format the acx firmware expects in the non-user area.
+ * Since we cannot cram an 8 byte ptr into 4 bytes, we need to
+ * enforce that pointed to data remains in low memory
+ * (address value needs to fit in 4 bytes) on 64bit systems.
+ *
+ * This is easy to get wrong, thus we are using a small struct
+ * and special macros to access it. Macros will check for
+ * attempts to overflow an acx_ptr with value > 0xffffffff.
+ *
+ * Attempts to use acx_ptr without macros result in compile-time errors */
+
+typedef struct {
+	u32	v;
+} ACX_PACKED acx_ptr;
+
+#if ACX_DEBUG
+#define CHECK32(n) BUG_ON(sizeof(n)>4 && (long)(n)>0xffffff00)
+#else
+#define CHECK32(n) ((void)0)
+#endif
+
+/* acx_ptr <-> integer conversion */
+#define cpu2acx(n) ({ CHECK32(n); ((acx_ptr){ .v = cpu_to_le32(n) }); })
+#define acx2cpu(a) (le32_to_cpu(a.v))
+
+/* acx_ptr <-> pointer conversion */
+#define ptr2acx(p) ({ CHECK32(p); ((acx_ptr){ .v = cpu_to_le32((u32)(long)(p)) }); })
+#define acx2ptr(a) ((void*)le32_to_cpu(a.v))

	Duh!

+struct acx_device {
+	/* most frequent accesses first (dereferencing and cache line!) */
+
+	/*** Locking ***/
+	struct semaphore	sem;
+	spinlock_t		lock;
+#if defined(PARANOID_LOCKING) /* Lock debugging */
+	const char		*last_sem;
+	const char		*last_lock;
+	unsigned long		sem_time;
+	unsigned long		lock_time;
+#endif

+#define CHECK_SIZEOF(type,size) { \
+	extern void BUG_bad_size_for_##type(void); \
+	if (sizeof(type)!=(size)) BUG_bad_size_for_##type(); \
+}

+static inline void
+acx_struct_size_check(void)
+{
+	CHECK_SIZEOF(txdesc_t, 0x30);
+	CHECK_SIZEOF(acx100_ie_memconfigoption_t, 24);
+	CHECK_SIZEOF(acx100_ie_queueconfig_t, 0x20);
+	CHECK_SIZEOF(acx_joinbss_t, 0x30);
+	/* IEs need 4 bytes for (type,len) tuple */
+	CHECK_SIZEOF(acx111_ie_configoption_t, ACX111_IE_CONFIG_OPTIONS_LEN + 4);
+}

There is BUILD_BUG_ON(). Sample usage is:

	BUILD_BUG_ON(sizeof(txdesc_t) != 0x30);

+#ifdef MODULE_LICENSE
+MODULE_LICENSE("Dual MPL/GPL");
+#endif

	MODULE_LICENSE always exists.

+/***********************************************************************
+** Debugging support
+*/
+#ifdef PARANOID_LOCKING
+static unsigned max_lock_time;
+static unsigned max_sem_time;
+
+void
+acx_lock_unhold() { max_lock_time = 0; }
+void
+acx_sem_unhold() { max_sem_time = 0; }
+
+static inline const char*
+sanitize_str(const char *s)
+{
+	const char* t = strrchr(s, '/');
+	if (t) return t + 1;
+	return s;
+}
+
+void
+acx_lock_debug(acx_device_t *adev, const char* where)
+{
+	unsigned int count = 100*1000*1000;
+	where = sanitize_str(where);
+	while (--count) {
+		if (!spin_is_locked(&adev->lock)) break;
+		cpu_relax();
+	}
+	if (!count) {
+		printk(KERN_EMERG "LOCKUP: already taken at %s!\n", adev->last_lock);
+		BUG();
+	}
+	adev->last_lock = where;
+	rdtscl(adev->lock_time);
+}
+void
+acx_unlock_debug(acx_device_t *adev, const char* where)
+{
+#ifdef SMP
+	if (!spin_is_locked(&adev->lock)) {
+		where = sanitize_str(where);
+		printk(KERN_EMERG "STRAY UNLOCK at %s!\n", where);
+		BUG();
+	}
+#endif
+	if (acx_debug & L_LOCK) {
+		unsigned long diff;
+		rdtscl(diff);
+		diff -= adev->lock_time;
+		if (diff > max_lock_time) {
+			where = sanitize_str(where);
+			printk("max lock hold time %ld CPU ticks from %s "
+				"to %s\n", diff, adev->last_lock, where);
+			max_lock_time = diff;
+		}
+	}
+}
+void
+acx_down_debug(acx_device_t *adev, const char* where)
+{
+	int sem_count;
+	unsigned long timeout = jiffies + 5*HZ;
+
+	where = sanitize_str(where);
+
+	for (;;) {
+		sem_count = atomic_read(&adev->sem.count);
+		if (sem_count) break;
+		if (time_after(jiffies, timeout))
+			break;
+		msleep(5);
+	}
+	if (!sem_count) {
+		printk(KERN_EMERG "D STATE at %s! last sem at %s\n",
+			where, adev->last_sem);
+		dump_stack();
+	}
+	adev->last_sem = where;
+	adev->sem_time = jiffies;
+	down(&adev->sem);
+	if (acx_debug & L_LOCK) {
+		printk("%s: sem_down %d -> %d\n",
+			where, sem_count, atomic_read(&adev->sem.count));
+	}
+}
+void
+acx_up_debug(acx_device_t *adev, const char* where)
+{
+	int sem_count = atomic_read(&adev->sem.count);
+	if (sem_count) {
+		where = sanitize_str(where);
+		printk(KERN_EMERG "STRAY UP at %s! sem.count=%d\n", where, sem_count);
+		dump_stack();
+	}
+	if (acx_debug & L_LOCK) {
+		unsigned long diff = jiffies - adev->sem_time;
+		if (diff > max_sem_time) {
+			where = sanitize_str(where);
+			printk("max sem hold time %ld jiffies from %s "
+				"to %s\n", diff, adev->last_sem, where);
+			max_sem_time = diff;
+		}
+	}
+	up(&adev->sem);
+	if (acx_debug & L_LOCK) {
+		where = sanitize_str(where);
+		printk("%s: sem_up %d -> %d\n",
+			where, sem_count, atomic_read(&adev->sem.count));
+	}
+}
+#endif /* PARANOID_LOCKING */

	lock debugging

+static inline const char*
+acx_wlan_reason_str(u16 reason)
+{
+	static const char* const reason_str[] = {
+	/*  0 */	"?",
+	/*  1 */	"unspecified",
+	/*  2 */	"prev auth is not valid",
+	/*  3 */	"leaving BBS",
+	/*  4 */	"due to inactivity",
+	/*  5 */	"AP is busy",
+	/*  6 */	"got class 2 frame from non-auth'ed STA",
+	/*  7 */	"got class 3 frame from non-assoc'ed STA",
+	/*  8 */	"STA has left BSS",
+	/*  9 */	"assoc without auth is not allowed",
+	/* 10 */	"bad power setting (802.11h)",
+	/* 11 */	"bad channel (802.11i)",
+	/* 12 */	"?",
+	/* 13 */	"invalid IE",
+	/* 14 */	"MIC failure",
+	/* 15 */	"four-way handshake timeout",
+	/* 16 */	"group key handshake timeout",
+	/* 17 */	"IE is different",
+	/* 18 */	"invalid group cipher",
+	/* 19 */	"invalid pairwise cipher",
+	/* 20 */	"invalid AKMP",
+	/* 21 */	"unsupported RSN version",
+	/* 22 */	"invalid RSN IE cap",
+	/* 23 */	"802.1x failed",
+	/* 24 */	"cipher suite rejected"

If these numbers really shouldn't be reshuffled, you can write

	[ 0] = "?",
	[ 1] = "unspecified",
		...
	[24] = "cipher suite rejected",

+	if (OK != acx_s_configure(adev, &feat, ACX1xx_IE_FEATURE_CONFIG)) {

	this is really against common practice:

		if (foo != 5)

	ditto for all other places.

+void BUG_excessive_stack_usage(void);
+
+static int
+acx_l_process_mgmt_frame(acx_device_t *adev, rxbuffer_t *rxbuf)
+{
+	parsed_mgmt_req_t parsed;	/* takes ~100 bytes of stack */
+	wlan_hdr_t *hdr;
+	int adhoc, sta_scan, sta, ap;
+	int len;
+
+	if (sizeof(parsed) > 256)
+		BUG_excessive_stack_usage();

BUILD_BUG_ON

+void
+acx_s_set_sane_reg_domain(acx_device_t *adev, int do_set)
+{
+	unsigned mask;
+
+	unsigned int i;
+
+	for (i = 0; i < sizeof(acx_reg_domain_ids); i++)
+		if (acx_reg_domain_ids[i] == adev->reg_dom_id)
+			break;
+
+	if (sizeof(acx_reg_domain_ids) == i) {
+		log(L_INIT, "Invalid or unsupported regulatory domain"
+			       " 0x%02X specified, falling back to FCC (USA)!"
+			       " Please report if this sounds fishy!\n",
+				adev->reg_dom_id);

This falling back can be super dangerous. I suggest to refuse to operate
unless valid regulatory domain found.

