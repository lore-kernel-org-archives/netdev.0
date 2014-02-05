From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 50/51] net/core/flow.c: Fix CPU hotplug callback registration
Date: Thu, 06 Feb 2014 03:43:46 +0530
Message-ID: <20140205221345.19080.20784.stgit@srivatsabhat.in.ibm.com>
References: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, paulmck@linux.vnet.ibm.com, tj@kernel.org,
	walken@google.com, ego@linux.vnet.ibm.com, linux@arm.linux.org.uk,
	linux-kernel@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com,
	"David S. Miller" <davem@davemloft.net>,
	Li RongQing <roy.qing.li@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Metcalf <cmetcalf@tilera.com>, netdev@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: paulus@samba.org, oleg@redhat.com, rusty@rustcorp.com.au,
	peterz@infradead.org, tglx@linutronix.de, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140205220251.19080.92336.stgit@srivatsabhat.in.ibm.com>
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

	cpu_maps_update_begin();

	for_each_online_cpu(cpu)
		init_cpu(cpu);

	/* Note the use of the double underscored version of the API */
	__register_cpu_notifier(&foobar_cpu_notifier);

	cpu_maps_update_done();


Fix the code in net/core/flow.c by using this latter form of callback
registration.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Li RongQing <roy.qing.li@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/flow.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index dfa602c..0f2c995 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -456,6 +456,8 @@ static int __init flow_cache_init(struct flow_cache *fc)
 	if (!fc->percpu)
 		return -ENOMEM;
 
+	cpu_maps_update_begin();
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
+	cpu_maps_update_done();
 
 	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
 		    (unsigned long) fc);
@@ -479,6 +483,8 @@ err:
 		fcp->hash_table = NULL;
 	}
 
+	cpu_maps_update_done();
+
 	free_percpu(fc->percpu);
 	fc->percpu = NULL;
 
