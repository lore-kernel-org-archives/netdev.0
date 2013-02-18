From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Mon, 18 Feb 2013 23:26:22 +0530
Message-ID: <51226B46.9080707@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com> <CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com> <5122551E.1080703@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, namhyung@kernel.org,
	tglx@linutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, oleg@redhat.com,
	vincent.guittot@linaro.org, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <5122551E.1080703@linux.vnet.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 09:51 PM, Srivatsa S. Bhat wrote:
> Hi Michel,
> 
> On 02/18/2013 09:15 PM, Michel Lespinasse wrote:
>> Hi Srivasta,
>>
>> I admit not having followed in detail the threads about the previous
>> iteration, so some of my comments may have been discussed already
>> before - apologies if that is the case.
>>
>> On Mon, Feb 18, 2013 at 8:38 PM, Srivatsa S. Bhat
>> <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>> Reader-writer locks and per-cpu counters are recursive, so they can be
>>> used in a nested fashion in the reader-path, which makes per-CPU rwlocks also
>>> recursive. Also, this design of switching the synchronization scheme ensures
>>> that you can safely nest and use these locks in a very flexible manner.
[...]
>>>  void percpu_write_lock(struct percpu_rwlock *pcpu_rwlock)
>>>  {
>>> +       unsigned int cpu;
>>> +
>>> +       /*
>>> +        * Tell all readers that a writer is becoming active, so that they
>>> +        * start switching over to the global rwlock.
>>> +        */
>>> +       for_each_possible_cpu(cpu)
>>> +               per_cpu_ptr(pcpu_rwlock->rw_state, cpu)->writer_signal = true;
>>
>> I don't see anything preventing a race with the corresponding code in
>> percpu_write_unlock() that sets writer_signal back to false. Did I
>> miss something here ? It seems to me we don't have any guarantee that
>> all writer signals will be set to true at the end of the loop...
>>
> 
> Ah, thanks for pointing that out! IIRC Oleg had pointed this issue in the last
> version, but back then, I hadn't fully understood what he meant. Your
> explanation made it clear. I'll work on fixing this.
> 

We can fix this by using the simple patch (untested) shown below.
The alternative would be to acquire the rwlock for write, update the
->writer_signal values, release the lock, wait for readers to switch,
again acquire the rwlock for write with interrupts disabled etc... which
makes it kinda messy, IMHO. So I prefer the simple version shown below.


diff --git a/lib/percpu-rwlock.c b/lib/percpu-rwlock.c
index bf95e40..64ccd3f 100644
--- a/lib/percpu-rwlock.c
+++ b/lib/percpu-rwlock.c
@@ -50,6 +50,12 @@
 	(__this_cpu_read((pcpu_rwlock)->rw_state->writer_signal))
 
 
+/*
+ * Spinlock to synchronize access to the writer's data-structures
+ * (->writer_signal) from multiple writers.
+ */
+static DEFINE_SPINLOCK(writer_side_lock);
+
 int __percpu_init_rwlock(struct percpu_rwlock *pcpu_rwlock,
 			 const char *name, struct lock_class_key *rwlock_key)
 {
@@ -191,6 +197,8 @@ void percpu_write_lock_irqsave(struct percpu_rwlock *pcpu_rwlock,
 {
 	unsigned int cpu;
 
+	spin_lock(&writer_side_lock);
+
 	/*
 	 * Tell all readers that a writer is becoming active, so that they
 	 * start switching over to the global rwlock.
@@ -252,5 +260,6 @@ void percpu_write_unlock_irqrestore(struct percpu_rwlock *pcpu_rwlock,
 		per_cpu_ptr(pcpu_rwlock->rw_state, cpu)->writer_signal = false;
 
 	write_unlock_irqrestore(&pcpu_rwlock->global_rwlock, *flags);
+	spin_unlock(&writer_side_lock);
 }

