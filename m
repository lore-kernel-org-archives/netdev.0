From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v3] net: stmmac: add platform init/exit for
 Altera's ARM socfpga
Date: Sun, 3 Aug 2014 19:54:35 -0500
Message-ID: <CAOwfj2MqZ+s9ANv=XReq3E1mYg2gszJTuxxZj-0TQE6qQwarFw@mail.gmail.com>
References: <1406574478-19343-1-git-send-email-vbridgers2013@gmail.com>
	<CAGb2v65yyfuJvZhYKTvROOZmumPAyLNfSGSPHeJEhSKnM9ELrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Vince Bridgers <vbridger@altera.com>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:39344 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaHDAyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 20:54:36 -0400
Received: by mail-we0-f170.google.com with SMTP id w62so6947149wes.15
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2014 17:54:35 -0700 (PDT)
In-Reply-To: <CAGb2v65yyfuJvZhYKTvROOZmumPAyLNfSGSPHeJEhSKnM9ELrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ChenYu,

On Fri, Aug 1, 2014 at 11:06 AM, Chen-Yu Tsai <wens@csie.org> wrote:
> Hi,
>
> On Tue, Jul 29, 2014 at 3:07 AM, Vince Bridgers <vbridgers2013@gmail.com> wrote:
>> This patch adds platform init/exit functions and modifications to support
>> suspend/resume for the Altera Cyclone 5 SOC Ethernet controller. The platform
>> exit function puts the controller into reset using the socfpga reset
>> controller driver. The platform init function sets up the Synopsys mac by
>> first making sure the Ethernet controller is held in reset, programming the
>> phy mode through external support logic, then deasserts reset through
>> the socfpga reset manager driver.
>
> Sorry for the very late reply after the fact.
>
> Is it possible to assert/deassert the reset in the driver core
> suspend/resume functions, before the clock is enabled?

The answer to this question depends on how the Synopsys EMAC is used
in other implementations.

For the suspend - and exit, yes this is possible for the Altera SOC
implementation (but I don't know if this is the case for other EMAC
implementations). For resume - and init, this is platform specific.

For the Altera SOC implementation, the driver code must make sure the
EMAC controller logic is held in reset, set the phy mode selection
input pins to the Synopsys EMAC through a register write, then
deassert the reset. This is further complicated by making sure the
PHY's clock is active before returning from the init function so that
the DMA reset in the EMAC initialization function will be successful -
leading to the addition of phy_resume in the driver's platform
specific init function.

The patch in the platform specific portion of the driver for the
Altera socfpga supports the logic that wraps the EMAC in the Altera
SOC - note this logic could be different for other implementations and
I don't know what all of those look like. If we knew the details of
the other controller implementations then I think we could answer this
question.

>
> Since the platform hooks are called before the core resume, and after
> core suspend, doing it in the core has the same order as you have in your
> platform code. And the driver core already supports reset controls,
> deasserting them at probe time, and asserting them when removed.
>
> At the same time, phy_suspend/phy_resume could be moved into the driver
> core as well.

Only PHY resume is part of the platform specific initialization, the
reason as stated above. In the Altera SOC case, PHY resume could be
moved out of the platform specific initialization and into the driver
core if that's helpful.

>
> After that, you only need to keep is socfpga_dwmac_init() calling
> socfpga_dwmac_setup().
>
>
> I did not attempt this when I added the platform code hooks, as I did not
> have suspend capable hardware to test it on.

The contributors for the other implementations using this driver need
to let us know how this might work for them too before we make any
changes outside of the platform specific code. One suggestion might be
to start a thread requesting those details from the contributors to
the stmmac driver.

Cheers,

Vince

>
>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> ---
>> V3: respin for net-next after phy_suspend was exported by libphy
>>     per suggestion from Florian. No changes to patch from V2 -> V3.
>> V2: Address review comments - add line break before structure decl
>> ---
>>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    |   69 ++++++++++++++++++++
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    4 ++
>>  2 files changed, 73 insertions(+)
>>
> [...]
>
>
> Cheers
> ChenYu
