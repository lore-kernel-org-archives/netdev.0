From: Matt Evans <matt@ozlabs.org>
Subject: Re: [PATCH net-next 2/2] PPC: net: bpf_jit_comp: add VLAN instructions for BPF JIT
Date: Sat, 17 Nov 2012 00:06:03 +0000
Message-ID: <45EBCE3A-FE92-4A8D-B5D8-DED4E30DF419@ozlabs.org>
References: <20121108214137.GB29696@thinkbox>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, benh@kernel.crashing.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dxchgb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40428 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753780Ab2KQAGO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 19:06:14 -0500
In-Reply-To: <20121108214137.GB29696@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 08/11/2012, at 9:41 PM, Daniel Borkmann wrote:

> This patch is a follow-up for patch "net: filter: add vlan tag access"
> to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> Cc: Matt Evans <matt@ozlabs.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> Disclaimer: uncompiled and untested, since I don't have a PPC machine,
> but it should (hopefully) integrate cleanly; impl. after PPC instruction
> reference.

And for this too,

Acked-by: Matt Evans <matt@ozlabs.org>

Sorry for the delay in reviewing this!

Thanks,


Matt


> 
> arch/powerpc/net/bpf_jit_comp.c |   14 ++++++++++++++
> 1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
> index b9434de..e834f1e 100644
> --- a/arch/powerpc/net/bpf_jit_comp.c
> +++ b/arch/powerpc/net/bpf_jit_comp.c
> @@ -13,6 +13,8 @@
> #include <asm/cacheflush.h>
> #include <linux/netdevice.h>
> #include <linux/filter.h>
> +#include <linux/if_vlan.h>
> +
> #include "bpf_jit.h"
> 
> #ifndef __BIG_ENDIAN
> @@ -89,6 +91,8 @@ static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
> 	case BPF_S_ANC_IFINDEX:
> 	case BPF_S_ANC_MARK:
> 	case BPF_S_ANC_RXHASH:
> +	case BPF_S_ANC_VLAN_TAG:
> +	case BPF_S_ANC_VLAN_TAG_PRESENT:
> 	case BPF_S_ANC_CPU:
> 	case BPF_S_ANC_QUEUE:
> 	case BPF_S_LD_W_ABS:
> @@ -382,6 +386,16 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
> 			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
> 							  rxhash));
> 			break;
> +		case BPF_S_ANC_VLAN_TAG:
> +		case BPF_S_ANC_VLAN_TAG_PRESENT:
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
> +			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
> +							  vlan_tci));
> +			if (filter[i].code == BPF_S_ANC_VLAN_TAG)
> +				PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
> +			else
> +				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
> +			break;
> 		case BPF_S_ANC_QUEUE:
> 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
> 						  queue_mapping) != 2);
