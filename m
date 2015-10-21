From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 06/12] IXGBEVF: Add self emulation layer
Date: Wed, 21 Oct 2015 13:58:19 -0700
Message-ID: <5627FC6B.8060004@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <1445445464-5056-7-git-send-email-tianyu.lan@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1445445464-5056-7-git-send-email-tianyu.lan@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2015 09:37 AM, Lan Tianyu wrote:
> In order to restore VF function after migration, add self emulation layer
> to record regs' values during accessing regs.
>
> Signed-off-by: Lan Tianyu <tianyu.lan@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbevf/Makefile        |  3 ++-
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  2 +-
>   .../net/ethernet/intel/ixgbevf/self-emulation.c    | 26 ++++++++++++++++++++++
>   drivers/net/ethernet/intel/ixgbevf/vf.h            |  5 ++++-
>   4 files changed, 33 insertions(+), 3 deletions(-)
>   create mode 100644 drivers/net/ethernet/intel/ixgbevf/self-emulation.c
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/Makefile b/drivers/net/ethernet/intel/ixgbevf/Makefile
> index 4ce4c97..841c884 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/Makefile
> +++ b/drivers/net/ethernet/intel/ixgbevf/Makefile
> @@ -31,7 +31,8 @@
>   
>   obj-$(CONFIG_IXGBEVF) += ixgbevf.o
>   
> -ixgbevf-objs := vf.o \
> +ixgbevf-objs := self-emulation.o \
> +		vf.o \
>                   mbx.o \
>                   ethtool.o \
>                   ixgbevf_main.o
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index a16d267..4446916 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -156,7 +156,7 @@ u32 ixgbevf_read_reg(struct ixgbe_hw *hw, u32 reg)
>   
>   	if (IXGBE_REMOVED(reg_addr))
>   		return IXGBE_FAILED_READ_REG;
> -	value = readl(reg_addr + reg);
> +	value = ixgbe_self_emul_readl(reg_addr, reg);
>   	if (unlikely(value == IXGBE_FAILED_READ_REG))
>   		ixgbevf_check_remove(hw, reg);
>   	return value;
> diff --git a/drivers/net/ethernet/intel/ixgbevf/self-emulation.c b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
> new file mode 100644
> index 0000000..d74b2da
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/ixgbevf/self-emulation.c
> @@ -0,0 +1,26 @@
> +#include <linux/netdevice.h>
> +#include <linux/pci.h>
> +#include <linux/delay.h>
> +#include <linux/interrupt.h>
> +#include <net/arp.h>
> +
> +#include "vf.h"
> +#include "ixgbevf.h"
> +
> +static u32 hw_regs[0x4000];
> +
> +u32 ixgbe_self_emul_readl(volatile void __iomem *base, u32 addr)
> +{
> +	u32 tmp;
> +
> +	tmp = readl(base + addr);
> +	hw_regs[(unsigned long)addr] = tmp;
> +
> +	return tmp;
> +}
> +
> +void ixgbe_self_emul_writel(u32 val, volatile void __iomem *base, u32  addr)
> +{
> +	hw_regs[(unsigned long)addr] = val;
> +	writel(val, (volatile void __iomem *)(base + addr));
> +}

So I see what you are doing, however I don't think this adds much 
value.  Many of the key registers for the device are not simple 
Read/Write registers.  Most of them are things like write 1 to clear or 
some other sort of value where writing doesn't set the bit but has some 
other side effect.  Just take a look through the Datasheet at registers 
such as the VFCTRL, VFMAILBOX, or most of the interrupt registers.  The 
fact is simply storing the values off doesn't give you any real idea of 
what the state of things are.

> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
> index d40f036..6a3f4eb 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
> @@ -39,6 +39,9 @@
>   
>   struct ixgbe_hw;
>   
> +u32 ixgbe_self_emul_readl(volatile void __iomem *base, u32 addr);
> +void ixgbe_self_emul_writel(u32 val, volatile void __iomem *base, u32  addr);
> +
>   /* iterator type for walking multicast address lists */
>   typedef u8* (*ixgbe_mc_addr_itr) (struct ixgbe_hw *hw, u8 **mc_addr_ptr,
>   				  u32 *vmdq);
> @@ -182,7 +185,7 @@ static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
>   
>   	if (IXGBE_REMOVED(reg_addr))
>   		return;
> -	writel(value, reg_addr + reg);
> +	ixgbe_self_emul_writel(value, reg_addr, reg);
>   }
>   
>   #define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
