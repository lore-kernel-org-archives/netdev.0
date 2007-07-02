From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Mon, 02 Jul 2007 16:57:12 -0700
Message-ID: <468990D8.6040604@intel.com>
References: <4688F512.3030801@garzik.org> <20070702214238.GA7085@infradead.org> <46897611.9020207@intel.com> <200707030010.25431.mb@bu3sch.de> <46897934.5040101@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18873 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757761AbXGBX5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 19:57:14 -0400
In-Reply-To: <46897934.5040101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Michael Buesch wrote:
>> On Tuesday 03 July 2007 00:02:57 Kok, Auke wrote:
>>> well, FWIW when I started looking at adding these flags I looked in various 
>>> subsystems in the kernel and picked an implementation that suited. Guess what 
>>> pci.h has? ...:
>>>
>>> 	unsigned int msi_enabled:1;
>>> 	unsigned int msix_enabled:1;
>>>
>>> this is literally where I copied the example from
>>>
>>> I suppose I can fix those, but I really don't understand what all the fuzz is 
>>> about here. We're only conserving memory and staying far away from the real 
>> I'm not sure if these bitfields actually _do_ conserve memory.
>> Generated code gets bigger (need bitwise masks and stuff).
>> Code also needs memory. It probably only conserves memory, if the
>> structure is instanciated a lot.
> 
> Actually, that's a good point.  On several RISC architectures it 
> certainly generates bigger code.

so, even on i386 it does (17 bytes and 6 instructions to test vs. 10:3 if using 
a "bool"):

unsigned int:1:
  8048365:       0f b6 45 f8             movzbl 0xfffffff8(%ebp),%eax
  8048369:       0c 01                   or     $0x1,%al
  804836b:       88 45 f8                mov    %al,0xfffffff8(%ebp)
  804836e:       0f b6 45 f8             movzbl 0xfffffff8(%ebp),%eax
  8048372:       24 01                   and    $0x1,%al
  8048374:       84 c0                   test   %al,%al

bool:
  8048365:       c6 45 fb 01             movb   $0x1,0xfffffffb(%ebp)
  8048369:       0f b6 45 fb             movzbl 0xfffffffb(%ebp),%eax
  804836d:       84 c0                   test   %al,%al

unsigned int:
  8048365:       c7 45 f8 01 00 00 00    movl   $0x1,0xfffffff8(%ebp)
  804836c:       8b 45 f8                mov    0xfffffff8(%ebp),%eax
  804836f:       85 c0                   test   %eax,%eax

using var & flag:
  8048365:       c7 45 f8 01 00 00 00    movl   $0x1,0xfffffff8(%ebp)
  804836c:       8b 45 f8                mov    0xfffffff8(%ebp),%eax
  804836f:       25 00 04 00 00          and    $0x400,%eax
  8048374:       85 c0                   test   %eax,%eax

note that using "var & flag" is slightly larger here... 1 extra instruction and 
7 more bytes.

interesting...


but let's stay constructive here:

~/git/linux-2.6 $ grep -r 'unsigned int.*:1;' * | wc -l
748

Is anyone going to fix those? If we don't, someone will certainly again submit 
patches to add more of these bitfields, after all, some very prominent parts of 
the kernel still use them. Only recently for instance mac80211 merged like 30 of 
these.... and drivers/net, include etc.. certainly has a lot of these.

Cheers,


Auke
