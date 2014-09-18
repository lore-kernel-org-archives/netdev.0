From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next] net: bpf: arm: make hole-faulting more robust
Date: Fri, 19 Sep 2014 00:11:54 +0100
Message-ID: <20140918231154.GH5182@n2100.arm.linux.org.uk>
References: <1411081023-17874-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Will Deacon <will.deacon@arm.com>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:33872 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750895AbaIRXMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 19:12:03 -0400
Content-Disposition: inline
In-Reply-To: <1411081023-17874-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 12:57:03AM +0200, Daniel Borkmann wrote:
> Will Deacon pointed out, that the currently used opcode for filling holes,
> that is 0xe7ffffff, seems not robust enough ...

If you're after a single 32-bit word which will fault if executed in
ARM or Thumb mode, and you only want it to raise an undefined
instruction exception (iow, you're not using it as a breakpoint or
similar), then may I suggest the poison value I chose for the vectors
page, designed to trap userspace branches to locations in there?

0xe7fddef1

> Similarly, ptrace, kprobes, kgdb, bug and uprobes make use of such instruction
> as well to trap. Given mentioned section from the specification, we can find
> such a universe as (where 'x' denotes 'don't care'):
> 
>   ARM:    xxxx 0111 1111 xxxx xxxx xxxx 1111 xxxx
>   Thumb:  1101 1110 xxxx xxxx

You'll notice that the value conforms to the ARM undefined instruction
space.  You'll also notice that the low 16 bits correspond to the
Thumb case.  The only question is, what is 0xe7fd as a Thumb instruction...

00000000 <a>:
   0:   def1                            ; <UNDEFINED> instruction: 0xdef1
   2:   e7fd            b.n     0 <a>

So, if either 0 or 2 gets branched to, we end up at the Thumb UDF
instruction.  (Sorry, my binutils doesn't know about UDF.)

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
