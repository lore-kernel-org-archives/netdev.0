From: Kaigai Kohei <kaigai@ak.jp.nec.com>
Subject: Re: Re: A common layer for Accounting packages
Date: Mon, 28 Feb 2005 10:59:06 +0900
Message-ID: <42227AEA.6050002@ak.jp.nec.com>
References: <42168D9E.1010900@sgi.com> <20050218171610.757ba9c9.akpm@osdl.org> <421993A2.4020308@ak.jp.nec.com> <421B955A.9060000@sgi.com> <421C2B99.2040600@ak.jp.nec.com> <421CEC38.7010008@sgi.com> <421EB299.4010906@ak.jp.nec.com> <20050224212839.7953167c.akpm@osdl.org> <20050227094949.GA22439@logos.cnet> <4221E548.4000008@ak.jp.nec.com> <20050227140355.GA23055@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, davem@redhat.com, jlan@sgi.com,
	lse-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
In-Reply-To: <20050227140355.GA23055@logos.cnet>
Sender: lse-tech-admin@lists.sourceforge.net
Errors-To: lse-tech-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:lse-tech@lists.sourceforge.net>
List-Help: <mailto:lse-tech-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/lse-tech>,
	<mailto:lse-tech-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=lse-tech>
List-Id: netdev.vger.kernel.org

Hello,

Marcelo Tosatti wrote:
 > Yep, the netlink people should be able to help - they known what would be
 > required for not sending messages in case there is no listener registered.
 >
 > Maybe its already possible? I have never used netlink myself.

If we notify the fork/exec/exit-events to user-space directly as you said,
I don't think some hackings on netlink is necessary.
For example, such packets is sent only when /proc/sys/.../process_grouping is set,
and user-side daemon set this value, and unset when daemon will exit.
It's not necessary to take too seriously.

 >>And, why can't netlink packets send always?
 >>If there are fork/exec/exit hooks, and they call CSA or other
 >>process-grouping modules,
 >>then those modules will decide whether packets for interaction with the
 >>daemon should be
 >>sent or not.
 >
 >
 > The netlink data will be sent to userspace at fork/exec/exit hooks - one wants
 > to avoid that if there are no listeners, so setups which dont want to run the
 > accounting daemon dont pay the cost of building and sending the information
 > through netlink.
 >
 > Thats what Andrew asked for if I understand correctly.

Does it mean "netlink packets shouled be sent to userspace unconditionally." ?
I have advocated steadfastly that fork/exec/exit hooks is necessary to support
process-grouping and to account per process-grouping.
It intend to be decided whether packets should be sent or not by hooked functions,
in my understanding.
Is it also one of the implementations whether using netlink-socket or not ?


 >>In most considerable case, CSA's kernel-loadable-module using such hooks
 >>will not be loaded
 >>when no accounting daemon is running. Adversely, this module must be loaded
 >>when accounting
 >>daemon needs CSA's netlink packets.
 >>Thus, it is only necessary to refer flag valiable and to execute
 >>conditional-jump
 >>when no-accounting daemon is running.
 >
 >
 > That would be one hack, although it is uglier than the pure netlink
 > selection.

No, I can't agree this opinion.
It means netlink-packets will be sent unconditionally when fork/exec/exit occur.
Nobady can decide which packet is sent user-space, I think.

In addition, the definition of process grouping is lightweight in many cases.
For example, CpuSet can define own process-group by one increment-operation.

I think it's not impossible to implement it in userspace, but it's not reasonable.
An implementation as a kernel loadable module is reasonable and enough tiny.


 >>In my estimation, we must pay additional cost for an increment-operation,
 >>an decrement-op,
 >>an comparison-op and an conditional jump-op. It's enough lightweight, I
 >>think.
 >>
 >>For example:
 >>If CSA's module isn't loaded, 'privates_for_grouping' will be empty.
 >>
 >>inline int on_fork_hook(task_struct *parent, task_struct *newtask){
 >>  rcu_read_lock();
 >>  if( !list_empty(&parent->privates_for_grouping) ){
 >>    ..<Calling to any process grouping module>..;
 >>  }
 >>  rcu_read_unlock();
 >>}
 >
 >
 > Andrew has been talking about sending data over netlink to implement the
 > accounting at userspace, so this piece of code is out of the game, no?

Indeed, I'm not opposed to implement the accounting in userspace and
using netlink-socket for kernel-daemon communication. But definition
of process-grouping based on any grouping policy should be done
in kernel space at reasonability viewpoint.

Thanks.
-- 
Linux Promotion Center, NEC
KaiGai Kohei <kaigai@ak.jp.nec.com>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
