From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 7 Jul 2017 17:47:21 -0700
Message-ID: <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@a
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 7, 2017 at 5:30 PM, Casey Leedom <leedom@chelsio.com> wrote:
>   By the way, it ~seems~ like the patch set confuses the idea of the PCIe=
 Capability Device Control[Relaxed Ordering Enable] with the device's abili=
ty to handle incoming TLPs with the Relaxed Ordering Attribute set.  These =
are completely different things.  The PCIe Capability Device Control[Relaxe=
d Ordering Enable] solely governs the ability of the device to _send_ TLPs =
with the Relaxed Ordering Attribute set.  It has nothing whatsoever to do w=
ith the handling of incoming TLPs with the Relaxed Ordering Attribute set. =
 In fact, there is any standard way to disable receipt processing of such T=
LPs.  That's kind of the whole point of the majority of the patch.  If ther=
e was a separate "Ignore Incoming Relaxed Ordering Attributes" then we'd mo=
stly just have a quirk which would set that for problematic devices.
>
>   Worse yet, if I'm reading the patch right, it _is_ turning off the PCIe=
 Capability Device Control[Relaxed Ordering Enable] for the devices that we=
've identified with problematic receive handling.  Not only does this not s=
olve the problem that we've been talking about, it actually almost certainl=
y introduces a huge Graphics Performance Bug.  The Relaxed Ordering Attribu=
te was originally developed for Graphics Device support in order to downloa=
d textures, etc. to a graphics devices as fast as possible and only ensure =
ordering at points where needed.  For instance, as far as I know, the Intel=
 Root Complexes that we've been talking about have no issues whatsoever in =
generating downstream TLPs with the Relaxed Ordering Attribute set.  By tur=
ning off the PCIe Capability Device Control[Relaxed Ordering Enable] on the=
se Root Complexes, this patch prevents the generation of downstream TLPs wi=
th the Relaxed Ordering Attribute set targeted at devices like graphics ada=
pters.
>
> Casey

The patches should be disabling the relaxed ordering on upstream
facing ports that would be sending requests to the root complex. So if
the root complex cannot handle receiving a message with relaxed
ordering enabled we should be clearing the relaxed ordering bit in the
PCIe configuration on those device that could send TLPs to that root
complex. By doing that the devices hosted on that root complex cannot
generate requests that contain relaxed ordering TLPs.

I'll have to do some double checking of the patches, but I thought we
were only clearing the relaxed ordering bits on the devices that would
be sending requests to the root complex, not the downstream ports of
the root complex itself. As such we should be able to generate relaxed
ordering TLPs from the root complex, but the devices hosted on the bus
shouldn't be able to generate relaxed ordering TLPs. The bit in the
configuration space controls the ability to generate content, not the
ability to receive it so clearing the bit on the device should be the
correct behavior for this.

As far as your suggestions for the cxgb4 patch it has the same problem
it originally had. We want to disable the relaxed ordering bit on the
device since the device should not be generating relaxed ordering
requests. This is why I was trying to get your input on this as I know
you have a peer-to-peer configuration that you wanted to support. What
we need to do is identify what platforms cannot support relaxed
ordering to the root complex and prevent that from happening which is
why we clear the relaxed ordering bit on the device. In that setup we
need to have a good way to identify when this has occurred and instead
setup a side channel type configuration where we then re-enable
relaxed ordering, but only allow for sending directly to the peer and
not the root complex.

- Alex
