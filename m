From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Sat, 8 Jul 2017 02:04:56 +0000
Message-ID: <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>,<CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        "Michael Werner" <werner@chelsio.com>,
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
        "will.deacon@arm.com" <will.deacon
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Okay, thanks for the note Alexander.	I'll have to look more closely at
the patch on Monday and try it out on one of the targeted systems to verify
the semantics you describe.

  However, that said, there is no way to tell a priori where a device will
send TLPs.  To simply assume that all TLPs will be directed towards the Roo=
t
Complex is a big assumption.  Only the device and the code controlling it
know where the TLPs will be directed.  That's why there are changes require=
d
in the cxgb4 driver.  For instance, the code in
drivers/net/ethernet/chelsio./cxgb4/sge.c: t4_sge_alloc_rxq() knows that
it's allocating Free List Buffers in Host Memory and that the RX Queues tha=
t
it's allocating in the Hardware will eventually send Ingress Data to those
Free List Buffers.  (And similarly for the Free List Buffer Pointer Queue
with respect to DMA Reads from the host.)  In that routine we explicitly
configure the Hardware to use/not-use the Relaxed Ordering Attribute via th=
e
FW_IQ_CMD_FL0FETCHRO and FW_IQ_CMD_FL0DATARO flags.  Basically we're
conditionally setting them based on the desirability of sending Relaxed
Ordering TLPs to the Root Complex.  (And we would perform the same kind of
check for an nVME application ... which brings us to ...)

  And what would be the code using these patch APIs to set up a Peer-to-Pee=
r
nVME-style application?	 In that case we'd need the Chelsio adapter's PCIe
Capability Device Control[Relaxed Ordering Enable] set for the nVME
application ... and we would avoid programming the Chelsio Hardware to use
Relaxed Ordering for TLPs directed at the Root Complex.	 Thus we would be i=
n
a position where some TLPs being emitted by the device to Peer devices woul=
d
have Relaxed Ordering set and some directed at the Root Complex would not.
And the only way for that to work is if the source device's Device
Control[Relaxed Ordering Enable] is set ...

  Finally, setting aside my disagreements with the patch, we still have the
code in the cxgb4 driver which explicitly turns on its own Device
Control[Relaxed Ordering Enable] in cxgb4_main.c:
enable_pcie_relaxed_ordering().  So the patch is something of a loop if all
we're doing is testing our own Relaxed Ordering Enable state ...
=20
Casey
