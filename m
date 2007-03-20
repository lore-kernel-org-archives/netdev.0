From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 18:00:35 -0800
Message-ID: <45FF4043.4000805@vmware.com>
References: <20070316.023331.59468179.davem@davemloft.net>	 <45FB005D.9060809@goop.org>	 <1174127638.8897.75.camel@localhost.localdomain>	 <20070318.003309.71088169.davem@davemloft.net>	 <20070318120814.GA45869@muc.de>	 <1174272469.11680.23.camel@localhost.localdomain>	 <m1648xxf93.fsf@ebiederm.dsl.xmission.com>	 <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andi Kleen <ak@muc.de>, David Miller <davem@davemloft.net>,
	jeremy@goop.org, mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	anthony@codemonkey.ws, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:47566 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966064AbXCTCAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 22:00:37 -0400
In-Reply-To: <1174348905.11680.54.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> On Mon, 2007-03-19 at 11:38 -0700, Linus Torvalds wrote:
>   
>> On Mon, 19 Mar 2007, Eric W. Biederman wrote:
>>     
>>> True.  You can use all of the call clobbered registers.
>>>       
>> Quite often, the biggest single win of inlining is not so much the code 
>> size (although if done right, that will be smaller too), but the fact that 
>> inlining DOES NOT CLOBBER AS MANY REGISTERS!
>>     

For VMI, the default clobber was "cc", and you need a way to allow at 
least that, because saving and restoring flags is too expensive on x86.

> Thanks Linus.
>
> *This* was the reason that the current hand-coded calls only clobber %
> eax.  It was a compromise between native (no clobbers) and others (might
> need a reg).
>   

I still don't think this was a good trade.  The primary motivation for 
clobbering %eax was that Xen wanted a free register to use for computing 
the offset into the shared data in the case of SMP preemptible kernels.  
Xen no longer needs such a register, they can use the PDA offset 
instead.  And it does hurt native performance by unconditionally 
stealing a register in the four most commonly invoked paravirt-ops code 
sequences.

> Now, since we decided to allow paravirt_ops operations to be normal C
> (ie. the patching is optional and done late), we actually push and pop %
> ecx and %edx.  This makes the call site 10 bytes long, which is a nice
> size for patching anyway (enough for a movl $0, <addr>, a-la lguest's
> cli, or movw $0, %gs:<addr> if we supported SMP).
>   

You can do it in 11 bytes with no clobbers and normal C semantics by 
linking to a direct address instead of calling to an indirect, but then 
you need some gross fixup technology in paravirt_patch:

if (call_addr == (void*)native_sti) {
  ...
}

I think we should probably try to do it in 12 bytes.  Freeing eax to the 
inline caller is likely to make up the 2 bytes of space more we have to nop.

One thing I always tried to get in VMI was to encapsulate the actual 
code which went through the business of computing arguments that were 
not even used in the native case.  Unfortunately, that seems impossible 
in the current design, but I don't think it is an issue because I don't 
think there is actually a way to express:

SWITCHABLE_CODE_BLOCK_BEGIN {
   /* arbitrary C code for native */
} SWITCHABLE_CODE_BLOCK_ALTERNATIVE {
   /* arbitrary C code for something else */
}

Dave's linker suggestion is probably the best for things like that.

Zach
