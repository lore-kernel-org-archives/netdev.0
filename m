From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver
 for QCA7000
Date: Tue, 1 Jul 2014 18:46:16 +0100
Message-ID: <20140701174616.GA10927@leverpostej>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
 <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"dave.taht@gmail.com" <dave.taht@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:54285 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758418AbaGARqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 13:46:35 -0400
Content-Disposition: inline
In-Reply-To: <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jul 01, 2014 at 05:36:49PM +0100, Stefan Wahren wrote:
> This patch adds the Ethernet over SPI driver for the
> Qualcomm QCA7000 HomePlug GreenPHY.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/qualcomm/Kconfig       |   30 +
>  drivers/net/ethernet/qualcomm/Makefile      |    6 +
>  drivers/net/ethernet/qualcomm/qca_7k.c      |  149 ++++
>  drivers/net/ethernet/qualcomm/qca_7k.h      |   72 ++
>  drivers/net/ethernet/qualcomm/qca_debug.c   |  311 +++++++++
>  drivers/net/ethernet/qualcomm/qca_debug.h   |   34 +
>  drivers/net/ethernet/qualcomm/qca_framing.c |  155 +++++
>  drivers/net/ethernet/qualcomm/qca_framing.h |  134 ++++
>  drivers/net/ethernet/qualcomm/qca_spi.c     | 1001 +++++++++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/qca_spi.h     |  114 +++
>  12 files changed, 2008 insertions(+)
>  create mode 100644 drivers/net/ethernet/qualcomm/Kconfig
>  create mode 100644 drivers/net/ethernet/qualcomm/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.h

[...]

> +       if (of_find_property(spi_device->dev.of_node,
> +               "qca,legacy-mode", NULL)) {
> +               legacy_mode = 1;
> +       }

Please use of_property_read bool for boolean properties. Here you can
have:

	legacy_mode = of_property_read_bool(spi_device->dev.of_node,
					    "qca,legacy-mode")

[...]

> +
> +       if (qcaspi_clkspeed == 0) {
> +               if (of_find_property(spi_device->dev.of_node,
> +                                       "spi-max-frequency", NULL)) {
> +                       qcaspi_clkspeed = spi_device->max_speed_hz;
> +               } else {
> +                       qcaspi_clkspeed = QCASPI_CLK_SPEED;
> +               }
> +       }

As far as I can see, of_register_spi_devices leaves
spi_device->max_speed_hz zeroed if there's no spi-max-speed property, so
here you could have:

	qcaspi_clkspeed = spi_device->max_speed_hz ?: QCASPI_CLK_SPEED;

Which avoids redundant DT parsing.

[...]

> +               memcpy(qca->net_dev->dev_addr, mac, ETH_ALEN);

I believe that it is preferred to write:

	ether_addr_copy(qca->net_dev->dev_addr, mac);

I believe checkpatch has a warning for this.

Thanks,
Mark.
