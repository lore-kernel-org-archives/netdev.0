From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Tue, 19 Feb 2013 02:07:45 +0800
Message-ID: <CANN689FSxOz+0Cu7EG_yKD8ZE1OpT4kyT+ybLfXSqaifodJRpw@mail.gmail.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com>
	<20130218123856.26245.46705.stgit@srivatsabhat.in.ibm.com>
	<CANN689F9S7c1M8+cEpz3tsxGF34+NTRBLvxgPUOtbvav5u+RRA@mail.gmail.com>
	<5122551E.1080703@linux.vnet.ibm.com>
	<51226B46.9080707@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <51226B46.9080707@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 19, 2013 at 1:56 AM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> On 02/18/2013 09:51 PM, Srivatsa S. Bhat wrote:
>> On 02/18/2013 09:15 PM, Michel Lespinasse wrote:
>>> I don't see anything preventing a race with the corresponding code in
>>> percpu_write_unlock() that sets writer_signal back to false. Did I
>>> miss something here ? It seems to me we don't have any guarantee that
>>> all writer signals will be set to true at the end of the loop...
>>
>> Ah, thanks for pointing that out! IIRC Oleg had pointed this issue in the last
>> version, but back then, I hadn't fully understood what he meant. Your
>> explanation made it clear. I'll work on fixing this.
>
> We can fix this by using the simple patch (untested) shown below.
> The alternative would be to acquire the rwlock for write, update the
> ->writer_signal values, release the lock, wait for readers to switch,
> again acquire the rwlock for write with interrupts disabled etc... which
> makes it kinda messy, IMHO. So I prefer the simple version shown below.

Looks good.

Another alternative would be to make writer_signal an atomic integer
instead of a bool. That way writers can increment it before locking
and decrement it while unlocking.

To reduce the number of atomic ops during writer lock/unlock, the
writer_signal could also be a global read_mostly variable (I don't see
any downsides to that compared to having it percpu - or is it because
you wanted all the fastpath state to be in one single cacheline ?)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
