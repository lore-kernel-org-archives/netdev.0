From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Wed, 12 Jul 2017 17:46:40 +0800
Message-ID: <16d18af6-f578-ef8a-a52e-46ec975e59e0@huawei.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
 <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdqoRR8XLG1o3ygUZTqEBQ4dgNaneZ-n1OSNC1AiswO_g@mail.gmail.com>
 <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "mark.rutland@arm.com" <mark.rutland@arm.com>,
 "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
 "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "ashok.raj@intel.com" <ashok.raj@intel.com>,
 "helgaas@kernel.org" <helgaas@kernel.org>,
 "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 Ganesh GR <ganeshgr@chelsio.com>, "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
 "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
 Michael Werner <werner@chelsio.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "amira@mellanox.com" <amira@mellanox.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "David.L
To: Casey Leedom <leedom@chelsio.com>, Alexander Duyck
 <alexander.duyck@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>
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



On 2017/7/11 8:01, Casey Leedom wrote:
> 
> Hey Alexander,
> 
>   Okay, I understand your point regarding the "most likely scenario" being
> TLPs directed upstream to the Root Complex.  But I'd still like to make sure
> that we have an agreed upon API/methodology for doing Peer-to-Peer with
> Relaxed Ordering and no Relaxed Ordering to the Root Complex.  I don't see
> how the proposed APIs can be used in that fashion.
>  
>   Right now the proposed change for cxgb4 is for it to test its own PCIe
> Capability Device Control[Relaxed Ordering Enable] in order to use that
> information to program the Chelsio Hardware to emit/not emit upstream TLPs
> with the Relaxed Ordering Attribute set.  But if we're going to have the
> mixed mode situation I describe, the PCIe Capability Device Control[Relaxed
> Ordering Enable] will have to be set which means that we'll be programming
> the Chelsio Hardware to send upstream TLPs with Relaxed Ordering Enable to
> the Root Complex which is what we were trying to avoid in the first place ...
> 
>   [[ And, as I noted on Friday evening, the currect cxgb4 Driver hardwires
>      the Relaxed Ordering Enable on early dureing device probe, so that
>      would minimally need to be addressed even if we decide that we don't
>      ever want to support mixed mode Relaxed Ordering. ]]
> 
>   We need some method of telling the Chelsio Driver that it should/shouldn't
> use Relaxed Ordering with TLPs directed at the Root Complex.  And the same
> is true for a Peer PCIe Device.
> 
>   It may be that we should approach this from the completely opposite
> direction and instead of having quirks which identify problematic devices,
> have quirks which identify devices which would benefit from the use of
> Relaxed Ordering (if the sending device supports that).  That is, assume the
> using Relaxed Ordering shouldn't be done unless the target device says "I
> love Relaxed Ordering TLPs" ...  In such a world, an NVMe or a Graphics
> device might declare love of Relaxed Ordering and the same for a SPARC Root
> Complex (I think that was your example).
> 
>   By the way, the sole example of Data Corruption with Relaxed Ordering is
> the AMD A1100 ARM SoC and AMD appears to have given up on that almost as
> soon as it was released.  So what we're left with currently is a performance
> problem on modern Intel CPUs ...  (And hopefully we'll get a Technical
> Publication on that issue fairly soon.)
> 
> Casey
> 

Hi Casey:

After the long discuss, I think If the PCIe Capability Device Control[Relaxed Ordering
Enable] to be cleared when the platform's RC has some problematic for RO didn't break
anything in your driver, I think you could choose to check the
(!pci_dev_should_disable_relaxed_ordering(root)) in the code to to enable
ROOT_NO_RELAXED_ORDERING for your adapter, and enable the PCIe Capability Device Control
[Relaxed Ordering Enable] bit when you need it, I think we don't have much gap here.
And we could leave the pear-to-pear situation to be fixed later.

Thanks
Ding

> .
> 
