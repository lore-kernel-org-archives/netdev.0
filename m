From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 5/9] net: introduce new macro net_get_random_once
Date: Sat, 19 Oct 2013 21:48:55 +0200
Message-ID: <1382212139-20301-6-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Jason Baron <jbaron@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_get_random_once is a new macro which handles the initialization
of secret keys. It is possible to call it in the fast path. Only the
initialization depends on the spinlock and is rather slow. Otherwise
it should get used just before the key is used to delay the entropy
extration as late as possible to get better randomness. It returns true
if the key got initialized.

The usage of static_keys for net_get_random_once is a bit uncommon so
it needs some further explanation why this actually works:

=== In the simple non-HAVE_JUMP_LABEL case we actually have ===
no constrains to use static_key_(true|false) on keys initialized with
STATIC_KEY_INIT_(FALSE|TRUE). So this path just expands in favor of
the likely case that the initialization is already done. The key is
initialized like this:

___done_key = { .enabled = ATOMIC_INIT(0) }

The check

                if (!static_key_true(&___done_key))                     \

expands into (pseudo code)

                if (!likely(___done_key > 0))

, so we take the fast path as soon as ___done_key is increased from the
helper function.

=== If HAVE_JUMP_LABELs are available this depends ===
on patching of jumps into the prepared NOPs, which is done in
jump_label_init at boot-up time (from start_kernel). It is forbidden
and dangerous to use net_get_random_once in functions which are called
before that!

At compilation time NOPs are generated at the call sites of
net_get_random_once. E.g. net/ipv6/inet6_hashtable.c:inet6_ehashfn (we
need to call net_get_random_once two times in inet6_ehashfn, so two NOPs):

      71:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
      76:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)

Both will be patched to the actual jumps to the end of the function to
call __net_get_random_once at boot time as explained above.

arch_static_branch is optimized and inlined for false as return value and
actually also returns false in case the NOP is placed in the instruction
stream. So in the fast case we get a "return false". But because we
initialize ___done_key with (enabled != (entries & 1)) this call-site
will get patched up at boot thus returning true. The final check looks
like this:

                if (!static_key_true(&___done_key))                     \
                        ___ret = __net_get_random_once(buf,             \

expands to

                if (!!static_key_false(&___done_key))                     \
                        ___ret = __net_get_random_once(buf,             \

So we get true at boot time and as soon as static_key_slow_inc is called
on the key it will invert the logic and return false for the fast path.
static_key_slow_inc will change the branch because it got initialized
with .enabled == 0. After static_key_slow_inc is called on the key the
branch is replaced with a nop again.

=== Misc: ===
The helper defers the increment into a workqueue so we don't
have problems calling this code from atomic sections. A seperate boolean
(___done) guards the case where we enter net_get_random_once again before
the increment happend.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Jason Baron <jbaron@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I tested this patchset with !CC_HAVE_ASM_GOTO and with CC_HAVE_ASM_GOTO
on x86_64.

I quickly reviewed that all architectures which implement HAVE_JUMP_LABEL
also patch all branch sites on boot-up. But this needs further review
as this is a security sensitive patch series.

Thank you!

 include/linux/net.h | 25 +++++++++++++++++++++++++
 net/core/utils.c    | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index ca9ec85..a489705 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -239,6 +239,31 @@ do {								\
 #define net_random()		prandom_u32()
 #define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
+bool __net_get_random_once(void *buf, int nbytes, bool *done,
+			   struct static_key *done_key);
+
+#ifdef HAVE_JUMP_LABEL
+#define ___NET_RANDOM_STATIC_KEY_INIT ((struct static_key) \
+		{ .enabled = ATOMIC_INIT(0), .entries = (void *)1 })
+#else /* !HAVE_JUMP_LABEL */
+#define ___NET_RANDOM_STATIC_KEY_INIT STATIC_KEY_INIT_FALSE
+#endif /* HAVE_JUMP_LABEL */
+
+/* BE CAREFUL: this function is not interrupt safe */
+#define net_get_random_once(buf, nbytes)				\
+	({								\
+		bool ___ret = false;					\
+		static bool ___done = false;				\
+		static struct static_key ___done_key =			\
+			___NET_RANDOM_STATIC_KEY_INIT;			\
+		if (!static_key_true(&___done_key))			\
+			___ret = __net_get_random_once(buf,		\
+						       nbytes,		\
+						       &___done,	\
+						       &___done_key);	\
+		___ret;							\
+	})
+
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
 		   size_t num, size_t len);
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
diff --git a/net/core/utils.c b/net/core/utils.c
index aa88e23..bf09371 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -338,3 +338,51 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 				  csum_unfold(*sum)));
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
+
+struct __net_random_once_work {
+	struct work_struct work;
+	struct static_key *key;
+};
+
+static void __net_random_once_deferred(struct work_struct *w)
+{
+	struct __net_random_once_work *work =
+		container_of(w, struct __net_random_once_work, work);
+	if (!static_key_enabled(work->key))
+		static_key_slow_inc(work->key);
+	kfree(work);
+}
+
+static void __net_random_once_disable_jump(struct static_key *key)
+{
+	struct __net_random_once_work *w;
+
+	w = kmalloc(sizeof(*w), GFP_ATOMIC);
+	if (!w)
+		return;
+
+	INIT_WORK(&w->work, __net_random_once_deferred);
+	w->key = key;
+	schedule_work(&w->work);
+}
+
+bool __net_get_random_once(void *buf, int nbytes, bool *done,
+			   struct static_key *done_key)
+{
+	static DEFINE_SPINLOCK(lock);
+
+	spin_lock_bh(&lock);
+	if (*done) {
+		spin_unlock_bh(&lock);
+		return false;
+	}
+
+	get_random_bytes(buf, nbytes);
+	*done = true;
+	spin_unlock_bh(&lock);
+
+	__net_random_once_disable_jump(done_key);
+
+	return true;
+}
+EXPORT_SYMBOL(__net_get_random_once);
-- 
1.8.3.1
