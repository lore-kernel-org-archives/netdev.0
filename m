From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 3 May 2017 04:30:24 +0000
Message-ID: <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>,
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Gabriele
 Paoloni <gabriele.paoloni@huawei.com>,
 Asit K Mallick <asit.k.mallick@intel.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 LinuxArm <linuxarm@huawei.com>, Amir Ancel <amira@mellanox.com>,
 Bjorn Helgaas <helgaas@kernel.org>, Ganesh GR <ganeshgr@chelsio.com>,
 Ding Tianhong <dingtianhong@huawei.com>,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 "leedom@gmail.com" <leedom@gmail.com>, Bob Shaw <Bob.Shaw@amd.com>, Patrick
 J Cramer <patrick.j.cramer@intel.com>, "Arjun
 V." <arjun@chelsio.com>, Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Netdev <netdev@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
 Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
 Robin Murphy <robin.murphy@arm.com>, David Miller <davem@davemlof
To: Alexander Duyck <alexander.duyck@gmail.com>, "Raj, Ashok"
 <ashok.raj@intel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

| From: Alexander Duyck <alexander.duyck@gmail.com>
| Date: Tuesday, May 2, 2017 11:10 AM
| ...
| So for example, in the case of x86 it seems like there are multiple
| root complexes that have issues, and the gains for enabling it with
| standard DMA to host memory are small. As such we may want to default
| it to off via the architecture specific PCIe code and then look at
| having "white-list" cases where we enable it for things like
| peer-to-peer accesses. In the case of SPARC we could look at
| defaulting it to on, and only "black-list" any cases where there might
| be issues since SPARC relies on this in a significant way for
| performance. In the case of ARM and other architectures it is a bit of
| a toss-up. I would say we could just default it to on for now and
| "black-list" anything that doesn't work, or we could go the other way
| like I suggested for x86. It all depends on what the ARM community
| would want to agree on for this. I would say unless it makes a
| significant difference like it does in the case of SPARC we are
| probably better off just defaulting it to off.

  Sorry, I forgot to respond to this earlier when someone was rushing me out
to a customer dinner.

  I'm unaware of any other x86 Root Complex Port that has a problem with
Relaxed Ordering other than the performance issue with the current Intel
implementation.  Ashok tells me that Intel is in the final stages of putting
together a technical notice on this issue but I don't know when that will
come out.  Hopefully that will shed much more light on the cause and actual
use of Relaxed Ordering when directed to Coherent Memory on current and past
Intel platforms.  (Note that the performance bug seems to limit us to
~75-85Gb/s DMA Write speed to Coherent Host Memory.)

  The only other Device that I currently know of which has issues with
Relaxed Ordering TLPs directed at it, is also a Root Complex Port on the new
AMD A1100 ARM SoC ("SEATTLE").  There we have an actual bug which could lead
to Data Corruption.

  But I don't know anything about other x86 Root Complex Ports having issues
with this -- we've been using it ever since commit ef306b50b from December
2010.

  Also, I'm not aware of any performance data which has been gathered on the
use of Relaxed Ordering when directed at Host Memory.  From your note, it
sounds like it's important on SPARC architectures.  But it could conceivably
be important on any architecture or Root Complex/Memory Controller
implementation.  We use it to direct Ingress Packet Data to Free List
Buffers, followed by a TLP without Relaxed Ordering directed at a Host
Memory Message Queue.  The idea here is to give the Root Complex options on
which DMA Memory Write TLPs to process in order to optimize data placement
in memory.  And with the next Ethernet speed bump to 200Gb/s this may be
even more important.

  Basically, I'd hate to come up with a solution where we write off the use
of Relaxed Ordering for DMA Writes to Host Memory.  I don't think you're
suggesting that, but there are a number of x86 Root Complex implementations
out there -- and some like the new AMD Ryzen have yet to be tested -- as
well as other architectures.

  And, as Ashok and I have both nothed, any solution we come up with needs
to cope with a heterogeneous situation where, on the same PCIe Fabric, it
may be necessesary/desireable to support Relaxed Ordering TLPs directed at
some End Nodes but not others.

Casey
