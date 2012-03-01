From: Jason Wessel <jason.wessel@windriver.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Thu, 1 Mar 2012 16:24:18 -0600
Message-ID: <4F4FF712.2030400@windriver.com>
References: <1191723499.1820816.1330635848166.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrei Warkentin <andreiw@vmware.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>, kgdb-bugreport@lists.sourceforge.net
To: Andrei Warkentin <awarkentin@vmware.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <1191723499.1820816.1330635848166.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 03/01/2012 03:04 PM, Andrei Warkentin wrote:
> ----- Original Message -----
>> From: "Andrei Warkentin" <awarkentin@vmware.com>
>> To: "Jason Wessel" <jason.wessel@windriver.com>
>> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
>> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>, "Andrei Warkentin"
>> <andrey.warkentin@gmail.com>
>> Sent: Tuesday, February 28, 2012 12:43:52 PM
>> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
>>
>>> All that netpoll_poll() did was to call netpoll_poll_dev().  I have
>>> not yet looked at the differences between kgdboe and the netkdb
>>> code
>>> you proposed but I would have suspected it also falls victim to the
>>> ethernet preemption problem which prevented kgdboe from ever being
>>> considered for a mainline merge.  Certainly there are ways to fix
>>> this
>>> problem but most involved changes to scheduling, core net code, or
>>> substantial driver specific changes.
>>>
>> I see, I read up on the issues w.r.t. preemption. Could this be
>> worked
>> around by modifiying affected drivers to bypass locking if they are
>> used in KDB context? Make some accessor netdev-specific lock/unlocks
>> that won't do anything if running in KDB context.
>>
>>
> By the way, is there a good way to repro the preemption case? Hopefully this doesn't
> involve some crazy hardware...


I have several cases which will usually hang the machine fairly quickly, but they all involve using gdb and a target using SMP.  Most often it is as simple as this:

* Use an SMP system with with at least 2 cores
* Start two threads rapidly running some processes
     while [ 1 ] ; do date > /dev/null ; done &
     while [ 1 ] ; do date > /dev/null ; done &
* Connect with gdb to kgdb and set a breakpoint at do_fork
   Now do "c"
   Now do "c 1000"

Generally the system will hang long before you get 1000 breakpoints hit and it will be a condition where there is a lock needed to create an skb, or the ethernet driver is preempted or some part of the network stack is preempted (or holding a lock) on the non master cpu.

There is another condition that is hard to catch that involves a task migrating from one cpu to the next, but we'll stick to the simple test case I described above for now.

I did have a question, because it seems you were using qemu / kvm.   I have a number of test cases that use kvm, but the netkkgdb does not seem to work with the nc.  My question is how am I supposed to actually use the netkgdb?

Here is what I observe on the target system:

insmod netkgdb.ko netkgdb=@/,@10.0.2.2/
echo g > /proc/sysrq-trigger

On my host system:
nc.traditional -l -u -p 7777

I will type help, and then the netkgdb is toast.  It doesn't seem to respond anymore.

Jason.

------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
