From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] cs89x0_platform : Use ioread16/iowrite16 instead of inw/outw
Date: Mon, 30 Apr 2012 14:19:26 +0000
Message-ID: <201204301419.27119.arnd@arndb.de>
References: <1335779839-30420-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:51574 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534Ab2D3OTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 10:19:44 -0400
In-Reply-To: <1335779839-30420-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 30 April 2012, Jaccon Bastiaansen wrote:
> The use of the inw/outw functions by the cs89x0 platform driver
> results in NULL pointer references.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> ---
>  drivers/net/ethernet/cirrus/cs89x0.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)

It's actually broken on most platforms already, and the #ifdef is
about to go away since IXP2xxx is getting removed in v3.5.

> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
> index b9406cb..95737e9 100644
> --- a/drivers/net/ethernet/cirrus/cs89x0.c
> +++ b/drivers/net/ethernet/cirrus/cs89x0.c
> @@ -369,6 +369,18 @@ writeword(unsigned long base_addr, int portno, u16 value)
>  {
>         __raw_writel(value, base_addr + (portno << 1));
>  }
> +#elif defined(CONFIG_CS89x0_PLATFORM)
> +static u16
> +readword(unsigned long base_addr, int portno)
> +{
> +       return ioread16(base_addr + portno);
> +}
> +
> +static void
> +writeword(unsigned long base_addr, int portno, u16 value)
> +{
> +       iowrite16(value, base_addr + portno);
> +}
>  #else
>  static u16
>  readword(unsigned long base_addr, int portno)

I think the best solution would be to always using ioread32/iowrite32
in the #else path, and change the ISA code to do an ioport_map
for the base address, passing around the virtual address as an __iomem
pointer.

	Arnd
