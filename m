From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: bpf: arm: make hole-faulting more robust
Date: Fri, 19 Sep 2014 01:20:18 +0200
Message-ID: <541B68B2.80905@redhat.com>
References: <1411081023-17874-1-git-send-email-dborkman@redhat.com> <20140918231154.GH5182@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbaIRXVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 19:21:05 -0400
In-Reply-To: <20140918231154.GH5182@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 01:11 AM, Russell King - ARM Linux wrote:
> On Fri, Sep 19, 2014 at 12:57:03AM +0200, Daniel Borkmann wrote:
>> Will Deacon pointed out, that the currently used opcode for filling holes,
>> that is 0xe7ffffff, seems not robust enough ...
>
> If you're after a single 32-bit word which will fault if executed in
> ARM or Thumb mode, and you only want it to raise an undefined
> instruction exception (iow, you're not using it as a breakpoint or
> similar), then may I suggest the poison value I chose for the vectors
> page, designed to trap userspace branches to locations in there?
>
> 0xe7fddef1
>
>> Similarly, ptrace, kprobes, kgdb, bug and uprobes make use of such instruction
>> as well to trap. Given mentioned section from the specification, we can find
>> such a universe as (where 'x' denotes 'don't care'):
>>
>>    ARM:    xxxx 0111 1111 xxxx xxxx xxxx 1111 xxxx
>>    Thumb:  1101 1110 xxxx xxxx
>
> You'll notice that the value conforms to the ARM undefined instruction
> space.  You'll also notice that the low 16 bits correspond to the
> Thumb case.  The only question is, what is 0xe7fd as a Thumb instruction...
>
> 00000000 <a>:
>     0:   def1                            ; <UNDEFINED> instruction: 0xdef1
>     2:   e7fd            b.n     0 <a>
>
> So, if either 0 or 2 gets branched to, we end up at the Thumb UDF
> instruction.  (Sorry, my binutils doesn't know about UDF.)

Yes, that should keep the code even simpler! Will try that out tomorrow
and respin the patch.

Thanks Russell!
