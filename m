From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 19 May 2015 13:50:42 +0200
Message-ID: <20150519135042.61cfa672@nial.brq.redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
	<20150217090242.GA20254@redhat.com>
	<54E31F24.1060705@redhat.com>
	<20150217123212.GA6362@redhat.com>
	<CAG7+5M1N53tXU72W1i937xZHxc7+sF=JhA6+QWmcarNnApbgiw@mail.gmail.com>
	<20150218042739.GA22891@redhat.com>
	<CABYiri8WnRHz3M4JE_EJxbgpRQxNbsY653LNWGOjDLLgdYx-+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Eric Northup <digitaleric@google.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	KVM <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Andrey Korolyov <andrey@xdel.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35031 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188AbbESLur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 07:50:47 -0400
In-Reply-To: <CABYiri8WnRHz3M4JE_EJxbgpRQxNbsY653LNWGOjDLLgdYx-+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 May 2015 19:22:34 +0300
Andrey Korolyov <andrey@xdel.ru> wrote:

> On Wed, Feb 18, 2015 at 7:27 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Tue, Feb 17, 2015 at 04:53:45PM -0800, Eric Northup wrote:
> >> On Tue, Feb 17, 2015 at 4:32 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >> > On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
> >> >>
> >> >>
> >> >> On 17/02/2015 10:02, Michael S. Tsirkin wrote:
> >> >> > > Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> >> >> > > to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> >> >> > >
> >> >> > > Signed-off-by: Igor Mammedov <imammedo@redhat.com>
> >> >> >
> >> >> > This scares me a bit: each region is 32byte, we are talking
> >> >> > a 16K allocation that userspace can trigger.
> >> >>
> >> >> What's bad with a 16K allocation?
> >> >
> >> > It fails when memory is fragmented.
> >> >
> >> >> > How does kvm handle this issue?
> >> >>
> >> >> It doesn't.
> >> >>
> >> >> Paolo
> >> >
> >> > I'm guessing kvm doesn't do memory scans on data path,
> >> > vhost does.
> >> >
> >> > qemu is just doing things that kernel didn't expect it to need.
> >> >
> >> > Instead, I suggest reducing number of GPA<->HVA mappings:
> >> >
> >> > you have GPA 1,5,7
> >> > map them at HVA 11,15,17
> >> > then you can have 1 slot: 1->11
> >> >
> >> > To avoid libc reusing the memory holes, reserve them with MAP_NORESERVE
> >> > or something like this.
> >>
> >> This works beautifully when host virtual address bits are more
> >> plentiful than guest physical address bits.  Not all architectures
> >> have that property, though.
> >
> > AFAIK this is pretty much a requirement for both kvm and vhost,
> > as we require each guest page to also be mapped in qemu memory.
> >
> >> > We can discuss smarter lookup algorithms but I'd rather
> >> > userspace didn't do things that we then have to
> >> > work around in kernel.
> >> >
> >> >
> >> > --
> >> > MST
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> Hello,
> 
> any chance of getting the proposed patch in the mainline? Though it
> seems that most users will not suffer from relatively slot number
> ceiling (they can decrease slot 'granularity' for larger VMs and
> vice-versa), fine slot size, 256M or even 128M, with the large number
> of slots can be useful for a certain kind of tasks for an
> orchestration systems. I`ve made a backport series of all seemingly
> interesting memslot-related improvements to a 3.10 branch, is it worth
> to be tested with straighforward patch like one from above, with
> simulated fragmentation of allocations in host?

I'm almost done with approach suggested by Paolo,
i.e. replace linear search with faster/scalable lookup alg.
Hope to post it soon.

> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
