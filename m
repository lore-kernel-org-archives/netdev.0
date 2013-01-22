From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 03/45] percpu_rwlock: Provide a way to define and init
 percpu-rwlocks at compile time
Date: Tue, 22 Jan 2013 13:03:42 +0530
Message-ID: <20130122073338.13822.94829.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:51294 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab3AVHfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 02:35:38 -0500
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Tue, 22 Jan 2013 13:03:49 +0530
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the support for defining and initializing percpu-rwlocks at compile time
for those users who would like to use percpu-rwlocks really early in the boot
process (even before dynamic per-CPU allocations can begin).

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/percpu-rwlock.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/percpu-rwlock.h b/include/linux/percpu-rwlock.h
index cd5eab5..8dec8fe 100644
--- a/include/linux/percpu-rwlock.h
+++ b/include/linux/percpu-rwlock.h
@@ -45,6 +45,24 @@ extern int __percpu_init_rwlock(struct percpu_rwlock *,
 
 extern void percpu_free_rwlock(struct percpu_rwlock *);
 
+
+#define __PERCPU_RWLOCK_INIT(name)					\
+	{								\
+		.reader_refcnt = &name##_reader_refcnt,			\
+		.writer_signal = &name##_writer_signal,			\
+		.global_rwlock = __RW_LOCK_UNLOCKED(name.global_rwlock) \
+	}
+
+#define DEFINE_PERCPU_RWLOCK(name)					\
+	static DEFINE_PER_CPU(unsigned long, name##_reader_refcnt);	\
+	static DEFINE_PER_CPU(bool, name##_writer_signal);		\
+	struct percpu_rwlock (name) = __PERCPU_RWLOCK_INIT(name);
+
+#define DEFINE_STATIC_PERCPU_RWLOCK(name)				\
+	static DEFINE_PER_CPU(unsigned long, name##_reader_refcnt);	\
+	static DEFINE_PER_CPU(bool, name##_writer_signal);		\
+	static struct percpu_rwlock(name) = __PERCPU_RWLOCK_INIT(name);
+
 #define percpu_init_rwlock(pcpu_rwlock)					\
 ({	static struct lock_class_key rwlock_key;			\
 	__percpu_init_rwlock(pcpu_rwlock, #pcpu_rwlock, &rwlock_key);	\
