From: "ravinandan arakali" <ravinandan.arakali@s2io.com>
Subject: RE: Submission for S2io 10GbE driver
Date: Thu, 19 Feb 2004 18:33:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002701c3f759$f14dbea0$8e10100a@S2IOtech.com>
References: <40347076.8030105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <leonid.grossman@s2io.com>, <netdev@oss.sgi.com>,
        <raghavendra.koushik@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>, <raghavendra.koushik@wipro.com>
In-Reply-To: <40347076.8030105@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,
For #7, the temporary variable tmp_v_addr is assigned as follows
(immediately below the code you have quoted):

nic->rx_blocks[i][j].block_virt_addr = tmp_v_addr;

In the freeSharedMem() routine, we go thru' each block of each
receive ring and free it. Following is the relevant piece of
code:
for (i = 0; i < config->RxRingNum; i++) {
     blk_cnt = nic->block_count[i];
     for (j = 0; j < blk_cnt; j++) {
          tmp_v_addr = nic->rx_blocks[i][j].block_virt_addr;
          tmp_p_addr = nic->rx_blocks[i][j].block_dma_addr;
          pci_free_consistent(nic->pdev, size, tmp_v_addr, tmp_p_addr);
     }
}

But I guess in the above piece of code, it may be a good idea to
check if nic->rx_blocks[i][j].block_virt_addr is non-NULL before
doing the pci_free_consistent().

Thanks,
Ravi

-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: Thursday, February 19, 2004 12:15 AM
To: raghavendra.koushik@wipro.com
Cc: leonid.grossman@s2io.com; netdev@oss.sgi.com;
raghavendra.koushik@s2io.com; ravinandan.arakali@s2io.com
Subject: Re: Submission for S2io 10GbE driver

raghavendra.koushik@wipro.com wrote:
> Hi Jeff,
> 
> 1. points 7 and 8, when initSharedMem returns error, I call
> freeSharedMem which should free any partially alloced memory.

For #8 quite possibly, and if so, I stand corrected.

For #7, it's a temporary variable so this would be impossible.


> 2. For point 17 and 33
> We do support IPV6 checksum offload. There is one issue though,
> our hardware only says whether the checksum is Ok or not it does
> not actually return the checksum values!
[...]
> If I say features as NETIF_F_IP_CSUM instead of NETIF_F_HW_CSUM,
> then I cannot utilize it's entire gamut of checksum offload feature
> as the offload will be limited to just TCP/UDP over IPV4.

Correct.  Your hardware cannot utilize NETIF_F_HW_CSUM.  You must be 
able to supply a valid csum from hardware, to use NETIF_F_HW_CSUM. 
Using NETIF_F_HW_CSUM as s2io does is abuse of the API, and prone to 
breakage...

For the future, it sounds like you should create a NETIF_F_IPV6_CSUM 
that works for both IPv4 and IPv6, and more closely matches your 
hardware.  We need to do this anyway, because most future cards will 
almost certainly offload IPv6 as well as IPv4.

For the present, NETIF_F_IP_CSUM is unfortunately your only choice. 
Zero-copy only occurs for sendfile(2) system call, which works fine with

NETIF_F_IP_CSUM, so no big deal.

In general, I certainly want to encourage s2io to participate in adding 
features to Linux that is needed to more fully utilize the hardware. 
Some of the proposed features might not be appropriate, but adding 
NETIF_F_IPV6_CSUM for you guys certainly seems reasonable.

	Jeff
