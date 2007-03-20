From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 15:08:19 -0800
Message-ID: <46006963.1020401@vmware.com>
References: <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <46000C7E.4070001@goop.org> <20070320224324.GL10459@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:35833 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932318AbXCTXIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:08:20 -0400
In-Reply-To: <20070320224324.GL10459@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> I don't know that you need an xchg there. If you're still on the same
> CPU, it should all be nice and causal even across an interrupt handler.
> So it could be:
>
>    pda.intr_mask = 0; /* intr_pending can't get set after this */
>   

Why not?  Oh, I see.  intr_mask is inverted form of EFLAGS_IF.

>    if (unlikely(pda.intr_pending)) {
>       pda.intr_pending = 0;
>       asm("sti");
>    }
>
> (This would actually need a C barrier, but I'll ignore that as this'd
> end up being asm...)
>
> But other interesting things could happen. If we never did a real CLI
> and we get preempted and switched to another CPU between clearing
> intr_mask and checking intr_pending, we get a little confused. 
>   

I think Jeremy's idea was to have interrupt handlers leave interrupts 
disabled on exit if pda.intr_mask was set.  In which case, they would 
bypass all work and we could never get preempted.  I don't think leaving 
hardware interrupts disabled for such a long time is good though.

> But perhaps that doesn't matter because we'd by definition have no
> pending interrupts on either processor?
>
> Is it expensive to do an STI if interrupts are already enabled?
>   

Yes.

Zach
