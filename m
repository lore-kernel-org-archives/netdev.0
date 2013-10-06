From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] static_key: WARN on usage before jump_label_init was called
Date: Sun, 6 Oct 2013 20:29:19 +0200
Message-ID: <20131006182919.GD9295@order.stressinduktion.org>
References: <1381015258-7667-1-git-send-email-hannes@stressinduktion.org> <1381015258-7667-4-git-send-email-hannes@stressinduktion.org> <20131005200558.3be2f841@gandalf.local.home> <20131006001247.GB25076@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Jason Baron <jbaron@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <edumazet@google.com>,
	"andi @ firstfloor. org David S. Miller" <davem@davemloft.net>,
	x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131006001247.GB25076@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 06, 2013 at 02:12:47AM +0200, Hannes Frederic Sowa wrote:
> On Sat, Oct 05, 2013 at 08:05:58PM -0400, Steven Rostedt wrote:
> > >  	if (type == JUMP_LABEL_ENABLE) {
> > > -		/*
> > > -		 * We are enabling this jump label. If it is not a nop
> > > -		 * then something must have gone wrong.
> > > -		 */
> > > -		if (unlikely(memcmp((void *)entry->code, ideal_nop, 5) != 0))
> > > -			bug_at((void *)entry->code, __LINE__);
> > > +		if (init) {
> > > +			/*
> > > +			 * Jump label is enabled for the first time.
> > > +			 * So we expect a default_nop...
> > > +			 */
> > > +			if (unlikely(memcmp((void *)entry->code, default_nop, 5)
> > > +				     != 0))
> > > +				bug_at((void *)entry->code, __LINE__);
> > > +		} else {
> > > +			/*
> > > +			 * ...otherwise expect an ideal_nop. Otherwise
> > > +			 * something went horribly wrong.
> > > +			 */
> > > +			if (unlikely(memcmp((void *)entry->code, ideal_nop, 5)
> > > +				     != 0))
> > > +				bug_at((void *)entry->code, __LINE__);
> > > +		}
> > 
> > I don't know if I like this change. This is similar to a bug we had
> > with the Xen folks, where they didn't realize that jump labels are not
> > suppose to be used (or set) before jump_label_init() is called.
> > 
> > I'll have to take a deeper look at this on Monday.
> 
> Yes, I understand and saw the commit to call jump_label_init
> earlier. Maybe the default could be to insert illegal instructions by
> default if we try to replace them with nops or branches afterwards anyway.

This would not help, but maybe someting like this patch.  Andi Kleen
also recently posted something similar, I cleaned it up a bit.

[PATCH] static_key: WARN on usage before jump_label_init was called

Based on a patch from Andi Kleen.

Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/jump_label.h           | 11 +++++++++++
 include/linux/jump_label_ratelimit.h |  2 ++
 kernel/jump_label.c                  |  5 +++++
 lib/Makefile                         |  2 +-
 lib/jump_label_initialized.c         |  6 ++++++
 5 files changed, 25 insertions(+), 1 deletion(-)
 create mode 100644 lib/jump_label_initialized.c

diff --git a/include/linux/jump_label.h b/include/linux/jump_label.h
index a507907..ed3a4bd 100644
--- a/include/linux/jump_label.h
+++ b/include/linux/jump_label.h
@@ -48,6 +48,14 @@
 
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <linux/bug.h>
+
+extern bool static_key_initialized; 
+
+#define STATIC_KEY_CHECK_USE() do {						\
+	WARN(!static_key_initialized, "%s used before call to jump_label_init", \
+	     __func__);								\
+} while (0)
 
 #if defined(CC_HAVE_ASM_GOTO) && defined(CONFIG_JUMP_LABEL)
 
@@ -128,6 +136,7 @@ struct static_key {
 
 static __always_inline void jump_label_init(void)
 {
+	static_key_initialized = true;
 }
 
 static __always_inline bool static_key_false(struct static_key *key)
@@ -146,11 +155,13 @@ static __always_inline bool static_key_true(struct static_key *key)
 
 static inline void static_key_slow_inc(struct static_key *key)
 {
+	STATIC_KEY_CHECK_USE();
 	atomic_inc(&key->enabled);
 }
 
 static inline void static_key_slow_dec(struct static_key *key)
 {
+	STATIC_KEY_CHECK_USE();
 	atomic_dec(&key->enabled);
 }
 
diff --git a/include/linux/jump_label_ratelimit.h b/include/linux/jump_label_ratelimit.h
index 1137883..089f70f 100644
--- a/include/linux/jump_label_ratelimit.h
+++ b/include/linux/jump_label_ratelimit.h
@@ -23,12 +23,14 @@ struct static_key_deferred {
 };
 static inline void static_key_slow_dec_deferred(struct static_key_deferred *key)
 {
+	STATIC_KEY_CHECK_USE();
 	static_key_slow_dec(&key->key);
 }
 static inline void
 jump_label_rate_limit(struct static_key_deferred *key,
 		unsigned long rl)
 {
+	STATIC_KEY_CHECK_USE();
 }
 #endif	/* HAVE_JUMP_LABEL */
 #endif	/* _LINUX_JUMP_LABEL_RATELIMIT_H */
diff --git a/kernel/jump_label.c b/kernel/jump_label.c
index 297a924..9019f15 100644
--- a/kernel/jump_label.c
+++ b/kernel/jump_label.c
@@ -58,6 +58,7 @@ static void jump_label_update(struct static_key *key, int enable);
 
 void static_key_slow_inc(struct static_key *key)
 {
+	STATIC_KEY_CHECK_USE();
 	if (atomic_inc_not_zero(&key->enabled))
 		return;
 
@@ -103,12 +104,14 @@ static void jump_label_update_timeout(struct work_struct *work)
 
 void static_key_slow_dec(struct static_key *key)
 {
+	STATIC_KEY_CHECK_USE();
 	__static_key_slow_dec(key, 0, NULL);
 }
 EXPORT_SYMBOL_GPL(static_key_slow_dec);
 
 void static_key_slow_dec_deferred(struct static_key_deferred *key)
 {
+	STATIC_KEY_CHECK_USE();
 	__static_key_slow_dec(&key->key, key->timeout, &key->work);
 }
 EXPORT_SYMBOL_GPL(static_key_slow_dec_deferred);
@@ -116,6 +119,7 @@ EXPORT_SYMBOL_GPL(static_key_slow_dec_deferred);
 void jump_label_rate_limit(struct static_key_deferred *key,
 		unsigned long rl)
 {
+	STATIC_KEY_CHECK_USE();
 	key->timeout = rl;
 	INIT_DELAYED_WORK(&key->work, jump_label_update_timeout);
 }
@@ -212,6 +216,7 @@ void __init jump_label_init(void)
 		key->next = NULL;
 #endif
 	}
+	static_key_initialized = true;
 	jump_label_unlock();
 }
 
diff --git a/lib/Makefile b/lib/Makefile
index f3bb2cb..7f48ddc 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu_ida.o
+	 percpu_ida.o jump_label_initialized.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += kstrtox.o
diff --git a/lib/jump_label_initialized.c b/lib/jump_label_initialized.c
new file mode 100644
index 0000000..a668a40
--- /dev/null
+++ b/lib/jump_label_initialized.c
@@ -0,0 +1,6 @@
+#include <linux/types.h>
+#include <linux/cache.h>
+
+bool static_key_initialized __read_mostly = false;
+EXPORT_SYMBOL_GPL(static_key_initialized);
+
-- 
1.8.3.1
