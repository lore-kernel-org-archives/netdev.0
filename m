From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH net RESEND] PCI: fix oops when try to find Root Port for a
 PCI device
Date: Thu, 17 Aug 2017 14:59:27 +1000
Message-ID: <87inhmssb4.fsf@concordia.ellerman.id.au>
References: <1502810688-12420-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: Ding Tianhong <dingtianhong@huawei.com>, leedom@chelsio.com,
 ashok.raj@intel.com, bhelgaas@google.com, helgaas@kernel.org,
 werner@chelsio.com, ganeshgr@chelsio.com, asit.k.mallick@intel.com,
 patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
 l.stach@pengutronix.de, amira@mellanox.com, gabriele.paoloni@huawei.com,
 David.Laight@aculab.com, jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
 will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
 davem@davemloft.net, alexander.duyck@gmail.com, eric.dumazet@gmail.com,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
 linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com,
 linuxppc-dev@lists.ozlabs.org <linuxppc-dev@lists.ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1502810688-12420-1-git-send-email-dingtianhong@huawei.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

Ding Tianhong <dingtianhong@huawei.com> writes:

> Eric report a oops when booting the system after applying
> the commit a99b646afa8a ("PCI: Disable PCIe Relaxed..."):

I'm seeing a similar oops on powerpc:

[    0.177242] pci_bus 0015:70: root bus resource [bus 70-ff]
[    0.178012] Unable to handle kernel paging request for data at address 0x00000050
[    0.178017] Faulting instruction address: 0xc0000000005f84b4
[    0.178022] Oops: Kernel access of bad area, sig: 11 [#1]
[    0.178024] SMP NR_CPUS=2048 
[    0.178025] NUMA 
[    0.178028] pSeries
[    0.178031] Modules linked in:
[    0.178036] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W       4.13.0-rc4-gcc-6.3.1-00167-ga99b646afa8a #407
[    0.178040] task: c0000003f7400000 task.stack: c0000003f7480000
[    0.178043] NIP: c0000000005f84b4 LR: c0000000005f5ccc CTR: 0000000000000000
[    0.178046] REGS: c0000003f74836d0 TRAP: 0380   Tainted: G        W        (4.13.0-rc4-gcc-6.3.1-00167-ga99b646afa8a)
[    0.178050] MSR: 8000000002009033 <SF,VEC,EE,ME,IR,DR,RI,LE>
[    0.178057]   CR: 48000842  XER: 2000000f
[    0.178061] CFAR: c0000000005f840c SOFTE: 1 
[    0.178061] GPR00: c0000000005f5cb4 c0000003f7483950 c000000000fa0000 0000000000000000 
[    0.178061] GPR04: 0000000000000001 0000000000000028 c0000003f7483820 f000000000ff6360 
[    0.178061] GPR08: 00000003fe2f0000 0000000000000000 c0000003f5759000 0000000002001001 
[    0.178061] GPR12: 0000000000000010 c00000000fd80000 c00000000000db08 0000000000000000 
[    0.178061] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
[    0.178061] GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
[    0.178061] GPR24: 0000000000000000 c000000000c5f680 c0000003f756b678 c0000003f5759000 
[    0.178061] GPR28: 0000000000000030 c0000003f756b098 c0000003f5759000 c0000003f756b000 
[    0.178110] NIP [c0000000005f84b4] pci_find_pcie_root_port+0xb4/0xd0
[    0.178114] LR [c0000000005f5ccc] pci_device_add+0x32c/0x470
[    0.178117] Call Trace:
[    0.178120] [c0000003f7483950] [c0000000005f5cb4] pci_device_add+0x314/0x470 (unreliable)
[    0.178126] [c0000003f74839f0] [c00000000005b85c] of_create_pci_dev+0x35c/0x400
[    0.178130] [c0000003f7483ab0] [c00000000005ba14] __of_scan_bus+0x114/0x1e0
[    0.178135] [c0000003f7483b20] [c000000000059a9c] pcibios_scan_phb+0x23c/0x270
[    0.178140] [c0000003f7483bc0] [c000000000d8057c] pcibios_init+0x84/0xdc
[    0.178144] [c0000003f7483c40] [c00000000000d680] do_one_initcall+0x60/0x1c0
[    0.178149] [c0000003f7483d00] [c000000000d74454] kernel_init_freeable+0x2c4/0x3a0
[    0.178153] [c0000003f7483dc0] [c00000000000db24] kernel_init+0x24/0x150
[    0.178158] [c0000003f7483e30] [c00000000000bc28] ret_from_kernel_thread+0x5c/0xb4

...


And the patch below fixes it. Thanks.

cheers

> ====================== cut here =============================
>
> It looks like the pci_find_pcie_root_port() was trying to
> find the Root Port for the PCI device which is the Root
> Port already, it will return NULL and trigger the problem,
> so check the highest_pcie_bridge to fix thie problem.
>
> Fixes: a99b646afa8a ("PCI: Disable PCIe Relaxed Ordering if unsupported")
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/pci/pci.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index af0cc34..7e2022f 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -522,7 +522,8 @@ struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>  		bridge = pci_upstream_bridge(bridge);
>  	}
>  
> -	if (pci_pcie_type(highest_pcie_bridge) != PCI_EXP_TYPE_ROOT_PORT)
> +	if (highest_pcie_bridge &&
> +	    pci_pcie_type(highest_pcie_bridge) != PCI_EXP_TYPE_ROOT_PORT)
>  		return NULL;
>  
>  	return highest_pcie_bridge;
> -- 
> 1.8.3.1
