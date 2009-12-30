From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Wed, 30 Dec 2009 02:23:20 -0500
Message-ID: <4B3AFFE8.3060409@majjas.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com>
 <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com>
 <20091223230102.4bb0100e.akpm@linux-foundation.org>
 <4B34E847.8010809@majjas.com> <20091225152200.1cf11dfe@nehalam>
 <4B3581C7.8000702@majjas.com> <20091226095723.7ac82b18@nehalam>
 <4B367409.5060202@majjas.com> <4B379378.4000102@majjas.com>
 <20091227102238.0df149f9@nehalam> <4B37B7E2.5070307@majjas.com>
 <20091229093023.3ad24786@nehalam> <4B3A5048.9090700@majjas.com>
 <20091229114938.1f4d1c5c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752353AbZL3HYI@vger.kernel.org>
In-reply-to: <20091229114938.1f4d1c5c@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok - I called dump_txring from sky2_net_intr:
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2725,8 +2791,10 @@ static void sky2_watchdog(unsigned long arg)
  /* Hardware/software error handling */
  static void sky2_err_intr(struct sky2_hw *hw, u32 status)
  {
-       if (net_ratelimit())
+       if (net_ratelimit()) {
                 dev_warn(&hw->pdev->dev, "error interrupt 
status=%#x\n", status);
+               dump_txring(hw, 0);
+       }

         if (status & Y2_IS_HW_ERR)
                 sky2_hw_intr(hw);

And got this:
Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x40000008
Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0x40000008
Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 done=29
Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=28...30 report=29 done=29
Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
Dec 30 02:17:23 mail kernel: sky2 0000:06:00.0: error interrupt status=0x8
Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 done=31
Dec 30 02:17:23 mail kernel: sky2 Tx ring pending=30...32 report=30 done=31

On 12/29/2009 02:49 PM, Stephen Hemminger wrote:
> This patch will dump more info in case of hardware error.
>
> --- a/drivers/net/sky2.c	2009-12-29 11:30:06.441137685 -0800
> +++ b/drivers/net/sky2.c	2009-12-29 11:46:37.389262922 -0800
> @@ -2629,12 +2625,71 @@ static void sky2_hw_error(struct sky2_hw
>   	}
>   }
>
> +static void dump_txring(struct sky2_hw *hw, unsigned port)
> +{
> +	struct sky2_port *sky2 = netdev_priv(hw->dev[port]);
> +	int sop = 1;
> +	unsigned idx;
> +
> +	printk(KERN_INFO PFX "Tx ring pending=%u...%u report=%d done=%d\n",
> +		   sky2->tx_cons, sky2->tx_prod,
> +		   sky2_read16(hw, port == 0 ? STAT_TXA1_RIDX : STAT_TXA2_RIDX),
> +		   sky2_read16(hw, Q_ADDR(txqaddr[port], Q_DONE)));
> +
> +	/* Dump contents of tx ring */
> +	for (idx = sky2->tx_next;
> +	     idx != sky2->tx_prod&&  idx<  sky2->tx_ring_size;
> +	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
> +		const struct sky2_tx_le *le = sky2->tx_le + idx;
> +		u32 a = le32_to_cpu(le->addr);
> +
> +		if (sop)
> +			printk(KERN_DEBUG "%u:", idx);
> +		sop = 0;
> +
> +		switch(le->opcode&  ~HW_OWNER) {
> +		case OP_ADDR64:
> +			printk(" %#x:", a);
> +			break;
> +		case OP_LRGLEN:
> +			printk(" mtu=%d", a);
> +			break;
> +		case OP_VLAN:
> +			printk(" vlan=%d", be16_to_cpu(le->length));
> +			break;
> +		case OP_TCPLISW:
> +			printk(" csum=%#x", a);
> +			break;
> +		case OP_LARGESEND:
> +			printk(" tso=%#x(%d)", a, le16_to_cpu(le->length));
> +			break;
> +		case OP_PACKET:
> +			printk(" %#x(%d)", a, le16_to_cpu(le->length));
> +			break;
> +		case OP_BUFFER:
> +			printk(" frag=%#x(%d)", a, le16_to_cpu(le->length));
> +			break;
> +		default:
> +			printk(" op=%#x,%#x(%d)", le->opcode, a,
> +			       le16_to_cpu(le->length));
> +		}
> +
> +		if (le->ctrl&  EOP) {
> +			printk("\n");
> +			sop = 1;
> +		}
> +	}
> +}
> +
>   static void sky2_hw_intr(struct sky2_hw *hw)
>   {
>   	struct pci_dev *pdev = hw->pdev;
>   	u32 status = sky2_read32(hw, B0_HWE_ISRC);
>   	u32 hwmsk = sky2_read32(hw, B0_HWE_IMSK);
>
> +	printk(KERN_DEBUG PFX "hardware interrupt status %#x\n", status);
> +	dump_txring(hw, 0);
> +
>   	status&= hwmsk;
>
>   	if (status&  Y2_IS_TIST_OV)
>
>    
