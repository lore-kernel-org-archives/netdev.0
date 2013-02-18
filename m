From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v6 17/46] clockevents: Use get/put_online_cpus_atomic() in
 clockevents_notify()
Date: Mon, 18 Feb 2013 18:10:42 +0530
Message-ID: <20130218124042.26245.92242.stgit@srivatsabhat.in.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
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
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpu idle code invokes clockevents_notify() during idle state transitions
and the cpu offline code invokes it during the CPU_DYING phase. There
seems to be a race-condition between the two, where the clockevents_lock
never gets released, ending in a lockup. This can be fixed by synchronizing
clockevents_notify() with CPU offline, by wrapping its contents within
get/put_online_cpus_atomic().

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/time/clockevents.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/time/clockevents.c b/kernel/time/clockevents.c
index 30b6de0..ca340fd 100644
--- a/kernel/time/clockevents.c
+++ b/kernel/time/clockevents.c
@@ -17,6 +17,7 @@
 #include <linux/module.h>
 #include <linux/notifier.h>
 #include <linux/smp.h>
+#include <linux/cpu.h>
 
 #include "tick-internal.h"
 
@@ -431,6 +432,7 @@ void clockevents_notify(unsigned long reason, void *arg)
 	unsigned long flags;
 	int cpu;
 
+	get_online_cpus_atomic();
 	raw_spin_lock_irqsave(&clockevents_lock, flags);
 	clockevents_do_notify(reason, arg);
 
@@ -459,6 +461,7 @@ void clockevents_notify(unsigned long reason, void *arg)
 		break;
 	}
 	raw_spin_unlock_irqrestore(&clockevents_lock, flags);
+	put_online_cpus_atomic();
 }
 EXPORT_SYMBOL_GPL(clockevents_notify);
 #endif
