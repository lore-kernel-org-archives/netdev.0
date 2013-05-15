From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] pci: Avoid reentrant calls to work_on_cpu
Date: Tue, 14 May 2013 18:58:03 -0700
Message-ID: <5192EBAB.7030203@gmail.com>
References: <20130514221748.6180.30597.stgit@ahduyck-cp1.jf.intel.com> <CAJZOPZL06sG__MdTzp6FF6BuB+Tv+CC_US35eHY0EDP6vQVzMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, bhelgaas@google.com,
	yinghai@kernel.org, guz.fnst@cn.fujitsu.com,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZL06sG__MdTzp6FF6BuB+Tv+CC_US35eHY0EDP6vQVzMw@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/14/2013 05:32 PM, Or Gerlitz wrote:
> On Tue, May 14, 2013 at 6:26 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>>
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
>>
>>  drivers/pci/pci-driver.c |   14 +++++++++-----
>>  1 files changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
>> index 79277fb..caeb1c0 100644
>> --- a/drivers/pci/pci-driver.c
>> +++ b/drivers/pci/pci-driver.c
>> @@ -277,12 +277,16 @@ static int pci_call_probe(struct pci_driver *drv,
>> struct pci_dev *dev,
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
> 
> 
> Alex, FWIW a similar patch was posted by Michael during the last rc
> cycles of 3.9 see
> http://marc.info/?l=linux-netdev&m=136569426119644&w=2

Did his patch ever get applied anywhere?  I don't see it in any of the
trees.

The advantage this approach has over the one in the similar patch is
that this covers a broader set of CPUs since anything on the same node
is local versus just the first CPU in a given NUMA node.

Thanks,

Alex
