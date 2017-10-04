From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] PCI: Check/Set ARI capability before
 setting numVFs
Date: Wed, 4 Oct 2017 16:29:14 -0700
Message-ID: <CAKgT0UfL6sASMFfUbN7qkJxAMEU9BwJgMJeFmHRZsk1fhVYzZQ@mail.gmail.com>
References: <20171004155258.35634-1-anthony.l.nguyen@intel.com> <20171004230114.GO25517@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>
To: Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004230114.GO25517@bhelgaas-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 4, 2017 at 4:01 PM, Bjorn Helgaas <helgaas@kernel.org> wrote:
> On Wed, Oct 04, 2017 at 08:52:58AM -0700, Tony Nguyen wrote:
>> This fixes a bug that can occur if an AER error is encountered while SRIOV
>> devices are present.
>>
>> This issue was seen by doing the following. Inject an AER error to a device
>> that has SRIOV devices.  After the device has recovered, remove the driver.
>> Reload the driver and enable SRIOV which causes the following crash to
>> occur:
>>
>> kernel BUG at drivers/pci/iov.c:157!
>> invalid opcode: 0000 [#1] SMP
>> CPU: 36 PID: 2295 Comm: bash Not tainted 4.14.0-rc1+ #74
>> Hardware name: Supermicro X9DAi/X9DAi, BIOS 3.0a 04/29/2014
>> task: ffff9fa41cd45a00 task.stack: ffffb4b2036e8000
>> RIP: 0010:pci_iov_add_virtfn+0x2eb/0x350
>> RSP: 0018:ffffb4b2036ebcb8 EFLAGS: 00010286
>> RAX: 00000000fffffff0 RBX: ffff9fa42c1c8800 RCX: ffff9fa421ce2388
>> RDX: 00000000df900000 RSI: ffff9fa8214fb388 RDI: 00000000df903fff
>> RBP: ffffb4b2036ebd18 R08: ffff9fa421ce23b8 R09: ffffb4b2036ebc2c
>> R10: ffff9fa42c1a5548 R11: 000000000000058e R12: ffff9fa8214fb000
>> R13: ffff9fa42c1a5000 R14: ffff9fa8214fb388 R15: 0000000000000000
>> FS:  00007f60724b6700(0000) GS:ffff9fa82f300000(0000)
>> knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000559eca8b0f40 CR3: 0000000864146000 CR4: 00000000001606e0
>> Call Trace:
>>  pci_enable_sriov+0x353/0x440
>>  ixgbe_pci_sriov_configure+0xd5/0x1f0 [ixgbe]
>>  sriov_numvfs_store+0xf7/0x170
>>  dev_attr_store+0x18/0x30
>>  sysfs_kf_write+0x37/0x40
>>  kernfs_fop_write+0x120/0x1b0
>>  __vfs_write+0x37/0x170
>>  ? __alloc_fd+0x3f/0x170
>>  ? set_close_on_exec+0x30/0x70
>>  vfs_write+0xb5/0x1a0
>>  SyS_write+0x55/0xc0
>>  entry_SYSCALL_64_fastpath+0x1a/0xa5
>> RIP: 0033:0x7f6071bafc20
>> RSP: 002b:00007ffe7d42ba48 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
>> RAX: ffffffffffffffda RBX: 0000559eca8b0f30 RCX: 00007f6071bafc20
>> RDX: 0000000000000002 RSI: 0000559eca961f60 RDI: 0000000000000001
>> RBP: 00007f6071e78ae0 R08: 00007f6071e7a740 R09: 00007f60724b6700
>> R10: 0000000000000073 R11: 0000000000000246 R12: 0000000000000000
>> R13: 0000000000000000 R14: 0000000000000000 R15: 0000559eca892170
>> RIP: pci_iov_add_virtfn+0x2eb/0x350 RSP: ffffb4b2036ebcb8
>>
>> The occurs since during AER recovery the ARI Capable Hierarchy bit,
>> which can affect the values for First VF Offset and VF Stride, is not set
>> until after pci_iov_set_numvfs() is called.
>
> Can you elaborate on where exactly this happens?  The only place we
> explicitly set PCI_SRIOV_CTRL_ARI is in sriov_init(), which is only
> called at enumeration-time.  So I'm guessing you're talking about this
> path:
>
>   ixgbe_io_slot_reset
>     pci_restore_state
>       pci_restore_iov_state
>         sriov_restore_state
>           pci_iov_set_numvfs
>
> where we don't set PCI_SRIOV_CTRL_ARI at all.  The fact that you say
> PCI_SRIOV_CTRL_ARI isn't set until *after* pci_iov_set_numvfs() is
> called suggests that it is being set *somewhere*, but I don't know
> where.

The ARI bit is initialized in sriov_init, stored in iov->ctrl, and
restored in sriov_restore_state, but it occurs in the line after the
call to pci_iov_set_numvfs.

The problem is you don't want to write the full iov->ctrl value until
after you have reset the the number of VFs since it will set VFE so
pulling out and configuring the ARI value separately is needed.

>> This can cause the iov
>> structure to be populated with values that are incorrect if the bit is
>> later set.   Check and set this bit, if needed, before calling
>> pci_iov_set_numvfs() so that the values being populated properly take
>> the ARI bit into account.
>>
>> CC: Alexander Duyck <alexander.h.duyck@intel.com>
>> CC: Emil Tantilov <emil.s.tantilov@intel.com>
>> Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
>> ---
>>  drivers/pci/iov.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/pci/iov.c b/drivers/pci/iov.c
>> index 7492a65..a8896c7 100644
>> --- a/drivers/pci/iov.c
>> +++ b/drivers/pci/iov.c
>> @@ -497,6 +497,10 @@ static void sriov_restore_state(struct pci_dev *dev)
>>       if (ctrl & PCI_SRIOV_CTRL_VFE)
>>               return;
>>
>> +     if ((iov->ctrl & PCI_SRIOV_CTRL_ARI) && !(ctrl & PCI_SRIOV_CTRL_ARI))
>> +             pci_write_config_word(dev, iov->pos + PCI_SRIOV_CTRL,
>> +                                   ctrl | PCI_SRIOV_CTRL_ARI);
>> +
>>       for (i = PCI_IOV_RESOURCES; i <= PCI_IOV_RESOURCE_END; i++)
>>               pci_update_resource(dev, i);
>>
>> --
>> 2.9.5
>>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
