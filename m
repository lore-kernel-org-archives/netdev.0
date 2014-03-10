From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 51/52] net/core/flow.c: Fix CPU hotplug callback
 registration
Date: Tue, 11 Mar 2014 02:12:51 +0530
Message-ID: <20140310204250.10746.61946.stgit@srivatsabhat.in.ibm.com>
References: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, tj@kernel.org, walken@google.com,
	ego@linux.vnet.ibm.com, linux@arm.linux.org.uk,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-pm@vger.kernel.org, linuxppc-dev@ozlabs.org,
	srivatsa.bhat@linux.vnet.ibm.com,
	Li RongQing <roy.qing.li@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Metcalf <cmetcalf@tilera.com>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: paulus@samba.org, oleg@redhat.com, mingo@kernel.org,
	rjw@rjwysocki.net, rusty@rustcorp.com.au, peterz@infradead.org,
	tglx@linutronix.de, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310203312.10746.310.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subsystems that want to register CPU hotplug callbacks, as well as perform
initialization for the CPUs that are already online, often do it as shown
below:

	get_online_cpus();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	register_cpu_notifier(&foobar_cpu_notifier);

	put_online_cpus();

This is wrong, since it is prone to ABBA deadlocks involving the
cpu_add_remove_lock and the cpu_hotplug.lock (when running concurrently
with CPU hotplug operations).

Instead, the correct and race-free way of performing the callback
registration is:

	cpu_notifier_register_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_notifier_register_done();


Fix the code in net/core/flow.c by using this latter form of callback
registration.

Cc: Li RongQing <roy.qing.li@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: netdev@vger.kernel.org
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/flow.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index dfa602c..9a2151f 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -456,6 +456,8 @@ static int __init flow_cache_init(struct flow_cache *fc)
 	if (!fc->percpu)
 		return -ENOMEM;
 
+	cpu_notifier_register_begin();
+
 	for_each_online_cpu(i) {
 		if (flow_cache_cpu_prepare(fc, i))
 			goto err;
@@ -463,7 +465,9 @@ static int __init flow_cache_init(struct flow_cache *fc)
 	fc->hotcpu_notifier = (struct notifier_block){
 		.notifier_call = flow_cache_cpu,
 	};
-	register_hotcpu_notifier(&fc->hotcpu_notifier);
+	__register_hotcpu_notifier(&fc->hotcpu_notifier);
+
+	cpu_notifier_register_done();
 
 	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
 		    (unsigned long) fc);
@@ -479,6 +483,8 @@ err:
 		fcp->hash_table = NULL;
 	}
 
+	cpu_notifier_register_done();
+
 	free_percpu(fc->percpu);
 	fc->percpu = NULL;
 
