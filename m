From: Brice Goglin <brice@myri.com>
Subject: Re: [patch 2/2] myri10ge - Write the firmware in 256-bytes chunks
Date: Fri, 21 Jul 2006 22:42:30 -0400
Message-ID: <44C19096.40204@myri.com>
References: <44C12D14.7050509@myri.com> <44C12FD9.3050001@myri.com> <200607212211.21043.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.208.38.107] ([216.208.38.107]:3978 "EHLO OTTLS.pngxnet.com")
	by vger.kernel.org with ESMTP id S1751129AbWGVCnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 22:43:46 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607212211.21043.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Friday 21 July 2006 21:49, Brice Goglin wrote:
>   
>> +		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET + i,
>> +				  fw->data + i,
>> +				  min(256U, (unsigned)(fw->size - i)));
>> +		mb();
>> +		readb(mgp->sram);
>> +		mb();
>>     
>
> Why two mb() here?
> I would say actually none is needed.
> The readb fully synchronizes the previous writes on bus level
> (and so on CPU level, too)

At least on i386 and x86-64, readb does not pass an explicit memory
barrier to the processor. We use a "weak-ordering" write-combining
mapping, so the previous PIO-write accesses and the readb are not
automatically serialized. So in absence of the first mb(), and because
"WC" read can definitely pass "WC" write, the readb (whose purpose is to
guarantee the previous write is finished) could actually be complete
long before those have even started (especially because WC buffers can
stay in the processor a long time before being flushed in absence of
synchronization instructions).

The second mb() is indeed probably superfluous and could be removed. The
WC semantics are not weak enough to allow WC writes to pass WC read
(given it was only one instruction in init code, we did the lazy thing).

Brice



