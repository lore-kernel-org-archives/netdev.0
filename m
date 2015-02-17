From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH] vhost: support upto 509 memory regions
Date: Tue, 17 Feb 2015 15:44:52 +0100
Message-ID: <20150217154452.6f62dd77@nial.brq.redhat.com>
References: <1423842599-5174-1-git-send-email-imammedo@redhat.com>
	<20150217090242.GA20254@redhat.com>
	<54E31F24.1060705@redhat.com>
	<20150217123212.GA6362@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150217123212.GA6362@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2015 13:32:12 +0100
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Tue, Feb 17, 2015 at 11:59:48AM +0100, Paolo Bonzini wrote:
> > 
> > 
> > On 17/02/2015 10:02, Michael S. Tsirkin wrote:
> > > > Increasing VHOST_MEMORY_MAX_NREGIONS from 65 to 509
> > > > to match KVM_USER_MEM_SLOTS fixes issue for vhost-net.
> > > > 
> > > > Signed-off-by: Igor Mammedov <imammedo@redhat.com>
> > >
> > > This scares me a bit: each region is 32byte, we are talking
> > > a 16K allocation that userspace can trigger.
> > 
> > What's bad with a 16K allocation?
> 
> It fails when memory is fragmented.
> 
> > > How does kvm handle this issue?
> > 
> > It doesn't.
> > 
> > Paolo
> 
> I'm guessing kvm doesn't do memory scans on data path,
> vhost does.
> 
> qemu is just doing things that kernel didn't expect it to need.
> 
> Instead, I suggest reducing number of GPA<->HVA mappings:
> 
> you have GPA 1,5,7
> map them at HVA 11,15,17
> then you can have 1 slot: 1->11
> 
> To avoid libc reusing the memory holes, reserve them with MAP_NORESERVE
> or something like this.
Lets suppose that we add API to reserve whole memory hotplug region
with MAP_NORESERVE and passed it as memslot to KVM.

Then what will happen to guest accessing not really mapped region?
This memslot will also be passed to vhost as region, is it really ok?
I don't know what else it might break.

As alternative:
we can filter out hotplugged memory and vhost will continue to work with
only initial memory.
So question is id we have to tell vhost about hotplugged memory?

> 
> We can discuss smarter lookup algorithms but I'd rather
> userspace didn't do things that we then have to
> work around in kernel.
> 
> 
