From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] x86: get more exact nr_irqs
Date: Mon, 04 Jan 2010 12:05:08 -0800
Message-ID: <m1skald4az.fsf@fess.ebiederm.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	<4B398ECD.1080506@kernel.org>
	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	<4B415E73.1050801@kernel.org> <4B41918D.3000605@kernel.org>
	<m1fx6lizc3.fsf@fess.ebiederm.org>
	<86802c441001041103s5abd6d3ai4e6ccbfc68323f3c@mail.gmail.com>
	<m1bph9he9m.fsf@fess.ebiederm.org> <4B4241E2.1020008@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yinghai@kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753817Ab0ADUFS@vger.kernel.org>
In-Reply-To: <4B4241E2.1020008@zytor.com> (H. Peter Anvin's message of "Mon\, 04 Jan 2010 11\:30\:42 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 01/04/2010 11:16 AM, Eric W. Biederman wrote:
>> 
>> If we care about memory use efficiency let's replace irq_desc_ptrs
>> with a rbtree or a radix_tree.  Something that moves the memory use
>> penalty onto those machines that have a lot of irqs.
>> 
>
> rbtree doesn't make much sense for something that is addressed by index,
> and doesn't need to answer questions of the form "give me the highest
> member <= X".  A hash table or radix tree makes sense, depending on the
> expected sparseness of the index.

Not counting irqs for msi's I think we are looking 36% to 25% fill.  Maybe
a little lower.  The sparseness is much higher if we count the number of
irqs that we might/use allocate as we do today.

Short of driver hotplug msis should be allocated densely, unless we start
reserving all possible 4K msi-x vectors.

For each ioapic we allocate 16 gsis, and only maybe four of them are
connected to actual pci slots.

This is essentially a slow path operation, so as long as we are not
too expensive we can use any data structure we want.  In kernel hash
tables don't grow well so I don't think a hash table is a good choice,
and a hash table is essentially what we have now.

The truth is we don't know how many irqs we will have until msi
supporting drivers claim all of theirs.

I think a radix-tree would likely be the least intrusive choice as it
does not imply any changes to the data structure indexed.

Eric
