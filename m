From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap
 paravirt ops callsites to make them patchable
Date: Mon, 19 Mar 2007 12:10:08 -0700
Message-ID: <45FEE010.1050103@goop.org>
References: <20070316.023331.59468179.davem@davemloft.net>	<45FB005D.9060809@goop.org>	<1174127638.8897.75.camel@localhost.localdomain>	<20070318.003309.71088169.davem@davemloft.net>	<20070318120814.GA45869@muc.de>	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zach@vmware.com, xen-devel@lists.xensource.com, akpm@linux-foundation.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	Andi Kleen <ak@muc.de>, anthony@codemonkey.ws, mingo@elte.hu,
	torvalds@linux-foundation.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <m1648xxf93.fsf@ebiederm.dsl.xmission.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Rusty Russell <rusty@rustcorp.com.au> writes:
>
>   
>> On Sun, 2007-03-18 at 13:08 +0100, Andi Kleen wrote:
>>     
>>>> The idea is _NOT_ that you go look for references to the paravirt_ops
>>>> members structure, that would be stupid and you wouldn't be able to
>>>> use the most efficient addressing mode on a given cpu, you'd be
>>>> patching up indirect calls and crap like that.  Just say no...
>>>>         
>>> That wouldn't handle inlines though. At least some of the current
>>> paravirtops like cli/sti are critical enough to require inlining.
>>>       
>> Well, we'd patch the inline over the call if we have room.
>>
>> Magic patching would be neat, but the downsides are that (1) we can't
>> expand the patching room and (2) there's no way of attaching clobber
>> info to the call site (doing register liveness analysis is not
>> appealing).
>>     
>
> True.  You can use all of the call clobbered registers.
>   

The trouble is that there are places where we want to intercept things
like sti/cli in entry.S in a context where all the registers are in use,
so we can't generally make the assumption that caller-saved regs are
clobberable.  For any call-site in compiler-generated code we can make
that assumption, of course.

>> Now, this may not be fatal.  5 bytes is enough for all the native ops to
>> be patched inline.   For lguest this covers popf and pushf, but not cli
>> and sti (10 bytes): they'd have to be calls.
>>
>> As for clobber info, it turns out that almost all of the calls can
>> clobber %eax, which is probably enough.  We just need to mark the
>> handful of asm ones where this isn't true.
>>     
>
> I guess if the code is larger than a function call I'm failing to see
> the disadvantage in making it a direct function call.  Any modern
> processor ought to be able to predict it perfectly, and processors
> like the P4 may even optimize the call out of their L1 instruction
> cache.
>   

For current processors, I think i-cache pollution is really the only
downside to a call.  But maybe you could put multiple pv-op functions
into a cacheline if they're used in close proximity
(cli/sti/save_fl/restore_fl would all fit into a single cacheline).

> If what David is suggesting works, making all of these direct calls
> looks easy and very maintainable.   At which point patching
> instructions inline is quite possibly overkill.
>   

I spent some time looking at what it would take to get this going.  It
would probably look something like:

   1. make CONFIG_PARAVIRT select CONFIG_RELOCATABLE
   2. generate vmlinux
   3. extract relocs, and process the references to paravirt symbols
      into a table
   4. compile and link that table into the kernel again (like the ksyms
      dance)
   5. at boot time, use that table to redirect calls/references into the
      paravirt backend to the appropriate one

I think if we store the reloc references as section-relative, and the
reloc table itself is linked into its own section, then there's no need
for multipass linking to combine the reloc table into the kernel image,
since adding that table won't affect any existing reloc.

All this is doable; I'd probably end up hacking boot/compressed/relocs.c
to generate the appropriate reloc table.  My main concern is hacking the
kernel build process itself; I'm unsure of what it would actually take
to implement all this.

> Is it truly critical to inline any of these instructions?
>   

Possibly not, but I'd like to be able to say with confidence that
running a PARAVIRT kernel on bare hardware has no performance loss
compared to running a !PARAVIRT kernel.  There's the case of small
instruction sequences which have been replaced with calls (such as
sti/cli/push;popf/etc), and also the case of hooks which are noops on
native (like make_pte/pte_val, etc).  In those cases it would be nice to
patch in a replacement, either a real instruction or just nops.


    J
