From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH v2 6/7] PCI: Make sure VF's driver get attached after
 PF's
Date: Mon, 20 May 2013 09:37:26 -0700
Message-ID: <519A5146.4020606@intel.com>
References: <1368586102-17661-1-git-send-email-yinghai@kernel.org> <20130515091248.00002fe3@unknown> <CAJZOPZ+L1QJdHePd_x9RAoqZKyJAKHo+hA8T1UZoe8=ozT98RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gregory.v.rose@intel.com>,
	Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yan Burman <yanb@mellanox.com>,
	Sathya Perla <Sathya.Perla@emulex.com>, netdev@vger.kernel.org
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZ+L1QJdHePd_x9RAoqZKyJAKHo+hA8T1UZoe8=ozT98RA@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/20/2013 05:28 AM, Or Gerlitz wrote:
> On Wed, May 15, 2013 at 7:12 PM, Greg Rose <gregory.v.rose@intel.com> wrote:
>
>
>> I'm really not a fan of this.  Seems to me the tail is wagging the dog
>> here.  Fix the driver to work without a PF driver being present.
> Greg, Alex,
>
> As I wrote over the V1 thread, currently we can't go and patch mlx4 to
> use the sysfs API nor defer the call from within our probe function to
> enable sriov since  this requires some firmware change to allow
> enabling SRIOV after some  resources are initialized/provisioned.
> Hence the patch suggested here or any other patch we can agree on
> which will make sure that VF probing is done only once the PF is ready
> is preferred, I think.

I guess I am not understanding.  Are you saying you have to enable
SR-IOV, then allocate some resources, and then wait for firmware to
complete, and then load VFs?  Is it not possible to do whatever it is
you need to do in firmware first, and then enable SR-IOV?

Would it be possible for the VFs to detect this state?  If so you could
probably work around it by either delaying probe as Ben suggested with
EPROBE_DEFER, or by using something such as the igbvf/ixgbevf approach
which will treat the lack of a PF and resources as a link down condition
until the PF and resources become available.

> I wasn't sure to totally follow on the argument that things need to
> work when the PF is absent in the sense there's no driver instance
> around over which the PF is probed, if you can explain little better,
> that would help.
>
> Or.

The problem I was referring to was the case where the PF is loaded, the
VFs are then assigned to guests, and then someone attempts to unload the
PF driver.  The problem in that case is that disabling SR-IOV will cause
all of the guests with assigned VFs to crash so the solution is to leave
the VFs loaded when the PF is unloaded or we would have to block PF
driver unload.  As such the Intel VFs have to deal with a PF that can be
unloaded while they are present.

If you take a look at the code for the igb/igbvf drivers it is a bit
easier to tell what is going on in terms of how we handle the unloaded
PF state.  Basically what happens is that the mailbox we use goes dead
so we just report link down until we can get the PF to come back on the
other end of the mailbox.

Thanks,

Alex
