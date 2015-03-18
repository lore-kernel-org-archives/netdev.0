From: Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>
Subject: Re: [PATCH] net: ethernet: pcnet32: Setup the SRAM and UFLO on Am79C97{3,5}
Date: Wed, 18 Mar 2015 12:48:03 -0700
Message-ID: <5509D673.1010006@imgtec.com>
References: <1426690073-8013-1-git-send-email-markos.chandras@imgtec.com> <eewj4d62moo4u25sersnbe2u.1426700072540@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: IMG - MIPS Linux Kernel developers
	<IMG-MIPSLinuxKerneldevelopers@imgtec.com>, <pcnet32@frontier.com>,
	LKML <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Markos Chandras <Markos.Chandras@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <eewj4d62moo4u25sersnbe2u.1426700072540@email.android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Confirmed - your fix solves TX problem in kernel.

- Leonid.

On 03/18/2015 10:34 AM, Leonid Yegoshin wrote:
> Thank you, Markos!
>
> It seems like one Samurai problem may be solved by your work -
> right now I experience TX problem while I use NFS root.
>
> Will test today.
>
> - Leonid.
>
>
> Markos Chandras <Markos.Chandras@imgtec.com> wrote:
>
>
> On a MIPS Malta board, tons of fifo underflow errors have been observed
> when using u-boot as bootloader instead of YAMON. The reason for that
> is that YAMON used to set the pcnet device to SRAM mode but u-boot does
> not. As a result, the default Tx threshold (64 bytes) is now too small to
> keep the fifo relatively used and it can result to Tx fifo underflow errors.
> As a result of which, it's best to setup the SRAM on supported controllers
> so we can always use the UFLO bit.
>
> Cc: <netdev@vger.kernel.org>
> Cc: <stable@vger.kernel.org>
> Cc: <linux-kernel@vger.kernel.org>
> Cc: Don Fry <pcnet32@frontier.com>
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
> ---
>   drivers/net/ethernet/amd/pcnet32.c | 32 ++++++++++++++++++++++++++++++--
>   1 file changed, 30 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
> index 11d6e6561df1..e474eb947f1a 100644
> --- a/drivers/net/ethernet/amd/pcnet32.c
> +++ b/drivers/net/ethernet/amd/pcnet32.c
> @@ -1543,7 +1543,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>   {
>          struct pcnet32_private *lp;
>          int i, media;
> -       int fdx, mii, fset, dxsuflo;
> +       int fdx, mii, fset, dxsuflo, sram;
>          int chip_version;
>          char *chipname;
>          struct net_device *dev;
> @@ -1580,7 +1580,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>          }
>
>          /* initialize variables */
> -       fdx = mii = fset = dxsuflo = 0;
> +       fdx = mii = fset = dxsuflo = sram = 0;
>          chip_version = (chip_version >> 12) & 0xffff;
>
>          switch (chip_version) {
> @@ -1613,6 +1613,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>                  chipname = "PCnet/FAST III 79C973";     /* PCI */
>                  fdx = 1;
>                  mii = 1;
> +               sram = 1;
>                  break;
>          case 0x2626:
>                  chipname = "PCnet/Home 79C978"; /* PCI */
> @@ -1636,6 +1637,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>                  chipname = "PCnet/FAST III 79C975";     /* PCI */
>                  fdx = 1;
>                  mii = 1;
> +               sram = 1;
>                  break;
>          case 0x2628:
>                  chipname = "PCnet/PRO 79C976";
> @@ -1664,6 +1666,32 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
>                  dxsuflo = 1;
>          }
>
> +       /*
> +        * The Am79C973/Am79C975 controllers come with 12K of SRAM
> +        * which we can use for the Tx/Rx buffers but most importantly,
> +        * the use of SRAM allow us to use the BCR18:NOUFLO bit to avoid
> +        * Tx fifo underflows.
> +        */
> +       if (sram) {
> +               /*
> +                * The SRAM is being configured in two steps. First we
> +                * set the SRAM size in the BCR25:SRAM_SIZE bits. According
> +                * to the datasheet, each bit corresponds to a 512-byte
> +                * page so we can have at most 24 pages.
> +                * The SRAM_SIZE corresponds holds the value of the upper
> +                * 8 bits of the 16-bit SRAM size. The low 8-bits start at
> +                * 0x00 and end at 0xff. So the address range is from
> +                * 0x0000 up to 0x17ff. Therefore, the SRAM_SIZE is set to 0x17.
> +                * The next step is to set the BCR24:SRAM_BND
> +                * midway through so the Tx and Rx buffers can share the SRAM
> +                * equally.
> +                */
> +               a->write_bcr(ioaddr, 25, 0x17);
> +               a->write_bcr(ioaddr, 26, 0xc);
> +               /* And finally enable the NOUFLO bit */
> +               a->write_bcr(ioaddr, 18, a->read_bcr(ioaddr, 18) | (1 << 11));
> +       }
> +
>          dev = alloc_etherdev(sizeof(*lp));
>          if (!dev) {
>                  ret = -ENOMEM;
> --
> 2.3.3
>
