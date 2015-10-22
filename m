From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Qemu-devel] [RFC Patch 06/12] IXGBEVF: Add self emulation layer
Date: Thu, 22 Oct 2015 08:50:00 -0700
Message-ID: <562905A8.5010200@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-7-git-send-email-tianyu.lan@intel.com>
 <5627FC6B.8060004@gmail.com> <20151022154802-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20151022154802-mutt-send-email-mst@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2015 05:50 AM, Michael S. Tsirkin wrote:
> On Wed, Oct 21, 2015 at 01:58:19PM -0700, Alexander Duyck wrote:
>> On 10/21/2015 09:37 AM, Lan Tianyu wrote:
>>> In order to restore VF function after migration, add self emulation layer
>>> to record regs' values during accessing regs.
>>>
>>> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
>>> ---
>>>   drivers/net/ethernet/intel/ixgbevf/Makefile        |  3 ++-
>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  2 +-
>>>   .../net/ethernet/intel/ixgbevf/self-emulation.c    | 26 ++++++++++++++++++++++
>>>   drivers/net/ethernet/intel/ixgbevf/vf.h            |  5 ++++-
>>>   4 files changed, 33 insertions(+), 3 deletions(-)
>>>   create mode 100644 drivers/net/ethernet/intel/ixgbevf/self-emulation.c
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/Makefile b/drivers/net/ethernet/intel/ixgbevf/Makefile
>>> index 4ce4c97..841c884 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/Makefile
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/Makefile
>>> @@ -31,7 +31,8 @@
>>>   obj-$(CONFIG_IXGBEVF) += ixgbevf.o
>>> -ixgbevf-objs := vf.o \
>>> +ixgbevf-objs := self-emulation.o \
>>> +		vf.o \
>>>                   mbx.o \
>>>                   ethtool.o \
>>>                   ixgbevf_main.o
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> index a16d267..4446916 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> @@ -156,7 +156,7 @@ u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg)
>>>   	if (IXGBE_REMOVED(reg_addr))
>>>   		return IXGBE_FAILED_READ_REG;
>>> -	value = readl(reg_addr + reg);
>>> +	value = ixgbe_self_emul_readl(reg_addr, reg);
>>>   	if (unlikely(value == IXGBE_FAILED_READ_REG))
>>>   		ixgbevf_check_remove(hw, reg);
>>>   	return value;
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/self-emulation.c b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
>>> new file mode 100644
>>> index 0000000..d74b2da
>>> --- /dev/null
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
>>> @@ -0,0 +1,26 @@
>>> +#include <linux/netdevice.h>
>>> +#include <linux/pci.h>
>>> +#include <linux/delay.h>
>>> +#include <linux/interrupt.h>
>>> +#include <net/arp.h>
>>> +
>>> +#include "vf.h"
>>> +#include "ixgbevf.h"
>>> +
>>> +static u32 hw_regs[0x4000];
>>> +
>>> +u32 ixgbe_self_emul_readl(volatile void __iomem *base, u32 addr)
>>> +{
>>> +	u32 tmp;
>>> +
>>> +	tmp = readl(base + addr);
>>> +	hw_regs[(unsigned long)addr] = tmp;
>>> +
>>> +	return tmp;
>>> +}
>>> +
>>> +void ixgbe_self_emul_writel(u32 val, volatile void __iomem *base, u32  addr)
>>> +{
>>> +	hw_regs[(unsigned long)addr] = val;
>>> +	writel(val, (volatile void __iomem *)(base + addr));
>>> +}
>> So I see what you are doing, however I don't think this adds much value.
>> Many of the key registers for the device are not simple Read/Write
>> registers.  Most of them are things like write 1 to clear or some other sort
>> of value where writing doesn't set the bit but has some other side effect.
>> Just take a look through the Datasheet at registers such as the VFCTRL,
>> VFMAILBOX, or most of the interrupt registers.  The fact is simply storing
>> the values off doesn't give you any real idea of what the state of things
>> are.
> It doesn't, but I guess the point is to isolate the migration-related logic
> in the recovery code.
>
> An alternative would be to have some smart logic all over the place to
> only store what's required - that would be much more intrusive.

After reviewing all of the patches yesterday I would say that almost all 
the values being stored aren't needed.  They can be restored from the 
settings of the driver itself anyway.  Copying the values out don't make 
much sense here since there are already enough caches for almost all of 
this data.

- Alex
