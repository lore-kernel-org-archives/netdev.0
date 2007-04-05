From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Thu, 5 Apr 2007 11:30:33 +0200
Message-ID: <20070405093033.GC25448@elte.hu>
References: <4613BC6B.1070708@codemonkey.ws> <4613BF07.50606@qumranet.com>
	<4613C993.9020405@codemonkey.ws> <4613CC01.1090500@qumranet.com>
	<4613CDB2.4000903@codemonkey.ws>
	<4613D001.3040606@qumranet.com> <20070404200112.GA6070@elte.hu>
	<4614098F.2030307@us.ibm.com> <20070404212103.GA19026@elte.hu>
	<1175728768.12230.593.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1175728768.12230.593.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


* Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org> wrote:

> It's easier to write a kernel-space network driver, but it's not 
> obviously the right thing to do until we can show that an efficient 
> packet-level userspace interface isn't possible.  I don't think that's 
> been done, and it would be interesting to try.

yes, i agree in theory, but IMO this is largely beside the point. What 
matters most for developing a project is _the quality of the codebase_. 
That attracts developers, developers improve the code, which then 
attracts users, which attracts more developers, etc., etc. As long as 
the quality of the codebase is maintained, this is a self-sustaining 
process. You've seen that happen with Linux. [ And of course, the 
crutial step #0 is: a sane, open-minded maintainer with good taste ;-) ]

qemu's code quality is not really suitable for that basic OSS model, in 
my opinion. It has been a mostly one-man show for a long time with 
various hostile forks, bin-only kernel module and other actions that 
easily poison an OSS project.

the result is not surprising: important portions of qemu have grown into 
a hard to hack, hard to maintain codebase with poor code quality, with 
gems like:

 #ifdef _WIN32
 void CALLBACK host_alarm_handler(UINT uTimerID, UINT uMsg,
                                  DWORD_PTR dwUser, DWORD_PTR dw1, DWORD_PTR dw2)
 #else
 static void host_alarm_handler(int host_signum)
 #endif
 {
 #if 0
 #define DISP_FREQ 1000

and that's not just some random driver - this is _the_ main central 
timer code of qemu.

so right now the only option for a clean codebase is the KVM in-kernel 
code. It's clean and sweet and integrates nicely into the rest of the 
kernel. The kernel is also obviously the final place where most 
virtualization technologies want to show up because it's the entity that 
is the closest to the guest context: we _dont_ want to _force_ network 
traffic (let alone interrupt handling) through a userspace context, only 
if the functionality of the task absolutely requires it. (but in most 
cases we'll try to come up with a maximally flexible scheme that can 
just drive things straight via the kernel. netfilter/iptables isnt in 
user-space either, partly for that reason.)

but architectural issues aside (ignoring that the kernel _is_ the best 
place to do this particular of stuff), this question is still mainly 
dominated by the basic question of code quality. I'd rather move 
something into the Linux kernel, enforce its code quality that way, and 
_then_ add whatever clean infrastructure is needed to push it back into 
user-space again (into a different codebase), than having to hack the 
monolithic 200 KLOC+ qemu codebase that is shackled with support for 
tons of arcane architectures nobody uses and tons of arcane OS variants 
that no-one cares about. Now qemu is a very important enabler and 
platform-reference-implementation for KVM to fall back to, but it's not 
the place to put crutial new code into, at least currently.

	Ingo

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
