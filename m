From: Masami Hiramatsu <mhiramat@kernel.org>
Subject: [RFC PATCH tip/master 2/3] kprobes: Allocate kretprobe instance if its free list is empty
Date: Wed, 29 Mar 2017 14:23:12 +0900
Message-ID: <149076498222.24574.679546540523044200.stgit@devbox>
References: <149076484118.24574.7083269903420611708.stgit@devbox>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alban Crequy <alban.crequy@gmail.com>,
        Alban Crequy <alban@kinvolk.io>,
        Alexei Starovoitov <ast@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Omar Sandoval <osandov@fb.com>, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        iago@kinvolk.io, michael@kinvolk.io,
        Dorau Lukasz <lukasz.dorau@intel.com>, systemtap@sourceware.org
To: Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <149076484118.24574.7083269903420611708.stgit@devbox>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try to allocate kretprobe instance by GFP_ATOMIC if kretprobe's
free list is empty. This can prevent kretprobe miss-hit on the
function which can be heavily invoked and slept inside (like
locking syscall entries.)

NOTE: This may easily cause nested kprobe call which will be
just skipped (but nmissed count is incremented), if someone
probe functions on the memory allocation path.

Signed-off-by: Masami Hiramatsu <mhiramat@kernel.org>
---
 Documentation/kprobes.txt |   25 +++++++++++++++----------
 include/linux/kprobes.h   |    2 ++
 kernel/kprobes.c          |   41 +++++++++++++++++++++++++++++------------
 3 files changed, 46 insertions(+), 22 deletions(-)

diff --git a/Documentation/kprobes.txt b/Documentation/kprobes.txt
index 1f6d45a..2de6533 100644
--- a/Documentation/kprobes.txt
+++ b/Documentation/kprobes.txt
@@ -131,11 +131,13 @@ kretprobe, then sets the saved instruction pointer to the saved return
 address, and that's where execution resumes upon return from the trap.
 
 While the probed function is executing, its return address is
-stored in an object of type kretprobe_instance.  Before calling
-register_kretprobe(), the user sets the maxactive field of the
-kretprobe struct to specify how many instances of the specified
-function can be probed simultaneously.  register_kretprobe()
-pre-allocates the indicated number of kretprobe_instance objects.
+stored in an object of type kretprobe_instance. Usually, this
+kretprobe_instance will be allocated dynamically.
+Since the dynamic allocation can cause mis-hit of other probes
+on memory allocation path, user can set maxactive field for pooling
+pre-allocated instances before calling register_kretprobe().
+This maxactive indicates how many instances of the specified
+function can be probed simultaneously.
 
 For example, if the function is non-recursive and is called with a
 spinlock held, maxactive = 1 should be enough.  If the function is
@@ -144,11 +146,14 @@ or preemption), NR_CPUS should be enough.  If maxactive <= 0, it is
 set to a default value.  If CONFIG_PREEMPT is enabled, the default
 is max(10, 2*NR_CPUS).  Otherwise, the default is NR_CPUS.
 
-It's not a disaster if you set maxactive too low; you'll just miss
-some probes.  In the kretprobe struct, the nmissed field is set to
-zero when the return probe is registered, and is incremented every
-time the probed function is entered but there is no kretprobe_instance
-object available for establishing the return probe.
+It's not a disaster if you set maxactive too low; you'll just see
+some probes on memory allocation path missed if it exists.
+
+In the kretprobe struct, the nmissed field is set to zero when the
+return probe is registered, and is incremented every time the probed
+function is entered but there is no kretprobe_instance object available
+and it fails to allocate new one, or hit the upper limit of maxactive
+(KRETPROBE_MAXACTIVE_ALLOC, currently it is 4096.)
 
 1.3.2 Kretprobe entry-handler
 
diff --git a/include/linux/kprobes.h b/include/linux/kprobes.h
index 47e4da5..8064e14 100644
--- a/include/linux/kprobes.h
+++ b/include/linux/kprobes.h
@@ -192,6 +192,8 @@ struct kretprobe {
 	struct hlist_head free_instances;
 	raw_spinlock_t lock;
 };
+/* Upper limit of maxactive for dynamic allocation */
+#define KRETPROBE_MAXACTIVE_ALLOC 4096
 
 struct kretprobe_instance {
 	struct hlist_node hlist;
diff --git a/kernel/kprobes.c b/kernel/kprobes.c
index d733479..75c5390 100644
--- a/kernel/kprobes.c
+++ b/kernel/kprobes.c
@@ -57,7 +57,6 @@
 #define KPROBE_HASH_BITS 6
 #define KPROBE_TABLE_SIZE (1 << KPROBE_HASH_BITS)
 
-
 /*
  * Some oddball architectures like 64bit powerpc have function descriptors
  * so this must be overridable.
@@ -1824,6 +1823,30 @@ void unregister_jprobes(struct jprobe **jps, int num)
 EXPORT_SYMBOL_GPL(unregister_jprobes);
 
 #ifdef CONFIG_KRETPROBES
+
+/* Try to use free instance first, if failed, try to allocate new instance */
+struct kretprobe_instance *kretprobe_alloc_instance(struct kretprobe *rp)
+{
+	struct kretprobe_instance *ri = NULL;
+	unsigned long flags = 0;
+
+	raw_spin_lock_irqsave(&rp->lock, flags);
+	if (!hlist_empty(&rp->free_instances)) {
+		ri = hlist_entry(rp->free_instances.first,
+				struct kretprobe_instance, hlist);
+		hlist_del(&ri->hlist);
+	}
+	raw_spin_unlock_irqrestore(&rp->lock, flags);
+
+	/* Populate max active instance if possible */
+	if (!ri && rp->maxactive < KRETPROBE_MAXACTIVE_ALLOC) {
+		ri = kmalloc(sizeof(*ri) + rp->data_size, GFP_ATOMIC);
+		if (ri)
+			rp->maxactive++;
+	}
+
+	return ri;
+}
 /*
  * This kprobe pre_handler is registered with every kretprobe. When probe
  * hits it will set up the return probe.
@@ -1846,14 +1869,8 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
 	}
 
 	/* TODO: consider to only swap the RA after the last pre_handler fired */
-	hash = hash_ptr(current, KPROBE_HASH_BITS);
-	raw_spin_lock_irqsave(&rp->lock, flags);
-	if (!hlist_empty(&rp->free_instances)) {
-		ri = hlist_entry(rp->free_instances.first,
-				struct kretprobe_instance, hlist);
-		hlist_del(&ri->hlist);
-		raw_spin_unlock_irqrestore(&rp->lock, flags);
-
+	ri = kretprobe_alloc_instance(rp);
+	if (ri) {
 		ri->rp = rp;
 		ri->task = current;
 
@@ -1868,13 +1885,13 @@ static int pre_handler_kretprobe(struct kprobe *p, struct pt_regs *regs)
 
 		/* XXX(hch): why is there no hlist_move_head? */
 		INIT_HLIST_NODE(&ri->hlist);
+		hash = hash_ptr(current, KPROBE_HASH_BITS);
 		kretprobe_table_lock(hash, &flags);
 		hlist_add_head(&ri->hlist, &kretprobe_inst_table[hash]);
 		kretprobe_table_unlock(hash, &flags);
-	} else {
+	} else
 		rp->nmissed++;
-		raw_spin_unlock_irqrestore(&rp->lock, flags);
-	}
+
 	return 0;
 }
 NOKPROBE_SYMBOL(pre_handler_kretprobe);

