From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] pci: Avoid reentrant calls to work_on_cpu
Date: Wed, 12 Jun 2013 10:58:38 -0700
Message-ID: <51B8B6CE.4010701@intel.com>
References: <20130514221748.6180.30597.stgit@ahduyck-cp1.jf.intel.com> <CAE9FiQVrtM2kcRd_z+mciq8HFnaTu73Jezef+wnnmsFP_q5=TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQVrtM2kcRd_z+mciq8HFnaTu73Jezef+wnnmsFP_q5=TQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/14/2013 07:50 PM, Yinghai Lu wrote:
> On Tue, May 14, 2013 at 3:26 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> This change is meant to fix a deadlock seen when pci_enable_sriov was
>> called from within a driver's probe routine.  The issue was that
>> work_on_cpu calls flush_work which attempts to flush a work queue for a
>> cpu that we are currently working in.  In order to avoid the reentrant
>> path we just skip the call to work_on_cpu in the case that the device
>> node matches our current node.
>>
>> Reported-by: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>> This patch is meant to address the issue pointed out in an earlier patch
>> sent by Yinghai Lu titled:
>>   [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
> Yes, that help. my v2 patch will not need to device schecdule and
> device_initicall to wait
> first work_on_cpu is done.
>
> Tested-by: Yinghai Lu <yinghai@kernel.org>

So what ever happened with this patch?  It doesn't look like it was
applied anywhere.  Was there some objection to it?  If so I can update
and resubmit if necessary.

Thanks,

Alex


>
>>  drivers/pci/pci-driver.c |   14 +++++++++-----
>>  1 files changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
>> index 79277fb..caeb1c0 100644
>> --- a/drivers/pci/pci-driver.c
>> +++ b/drivers/pci/pci-driver.c
>> @@ -277,12 +277,16 @@ static int pci_call_probe(struct pci_driver *drv, struct pci_dev *dev,
>>         int error, node;
>>         struct drv_dev_and_id ddi = { drv, dev, id };
>>
>> -       /* Execute driver initialization on node where the device's
>> -          bus is attached to.  This way the driver likely allocates
>> -          its local memory on the right node without any need to
>> -          change it. */
>> +       /*
>> +        * Execute driver initialization on the node where the device's
>> +        * bus is attached.  This way the driver likely allocates
>> +        * its local memory on the right node without any need to
>> +        * change it.  If the node is the current node just call
>> +        * local_pci_probe and avoid the possibility of reentrant
>> +        * calls to work_on_cpu.
>> +        */
>>         node = dev_to_node(&dev->dev);
>> -       if (node >= 0) {
>> +       if ((node >= 0) && (node != numa_node_id())) {
>>                 int cpu;
>>
>>                 get_online_cpus();
>>
