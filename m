From: Michael Turquette <mturquette@baylibre.com>
Subject: Re: [PATCH RFC 3/3] ARM64: dts: meson-gxbb: use the new meson8b DWMAC glue
Date: Wed, 13 Jul 2016 14:01:14 -0700
Message-ID: <146844367410.73491.117379762912178421@resonance>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
 <20160625165013.15917-4-martin.blumenstingl@googlemail.com>
 <20160627092448.GA3275@localhost>
 <CAFBinCB6i2-ZUDupAXUZkQO9y93rtCvguD_avdY=Ze72wxQKpw@mail.gmail.com>
 <CAFBinCBcv+4MHe9sFeGLRRRvb7hjX4=XYOtxN_rO1yzVFZisaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-amlogic@lists.infradead.org, mark.rutland@arm.com,
	khilman@baylibre.com, robh+dt@kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
	"Carlo Caione" <carlo@caione.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33866 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923AbcGMVBY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 17:01:24 -0400
Received: by mail-pa0-f44.google.com with SMTP id fi15so21034097pac.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 14:01:23 -0700 (PDT)
In-Reply-To: <CAFBinCBcv+4MHe9sFeGLRRRvb7hjX4=XYOtxN_rO1yzVFZisaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

Quoting Martin Blumenstingl (2016-06-27 04:33:49)
> On Mon, Jun 27, 2016 at 12:44 PM, Martin Blumenstingl
> <martin.blumenstingl@googlemail.com> wrote:
> > On Mon, Jun 27, 2016 at 11:24 AM, Carlo Caione <carlo@caione.org> wrote:
> >> A syscon is a region containing a set of miscellaneous registers used
> >> for several reasons by several devices [1]. It this case there is really
> >> no need to define a new syscon node since those two registers are only
> >> used by your driver.
> > I can easily change it back if that's the way to go.
> > Before I do that: could you please confirm that "mp2_clk_out" (which
> > is controlled by PRG_ETH0/offset 0x0 bits 7-9) is not something which
> > has to be available through the common clk framework?
> there was just an IRC discussion with Carlo on this topic:
> We tried to find whether PRG_ETH0 is used to actually configure
> "mp2_clk_out". Carlo brought up that it could also be the case that
> the ethernet block simply needs to be informed about the rate of the
> mp2_clk_out (which is *probably* the "mpll2" clock).
> 
> I'm adding Michael Turquette to this mail, maybe you can comment on this topic.
> 
> If it turns out that the etthernet block just has to know about the
> clock rate then we have two tasks:
> 1. identify why the mpll2 rate returns 0 on my GXBB device

This is in progress, but turns out it doesn't matter for Ethernet. Bit 4
in PRG_ETHERNET_ADDR0 control a mux clock inside of the Ethernet
controller.

A value of 0x0 selects fclk_div2 and a value of 0x1 selects mp2_clk_out.
The bootloader programs in sets the mux to zero, or fclk_div2 as the
input clock (which runs at 1GHz).

> 2. change my patch so the new DWMAC glue gets a reference to the mpll2
> clock and then use "clk_get_rate(mpll2) / (250 * 1000000)" to
> configure the PRG_ETH0_MP2_CLK bits.

Hmm, I'm not sure about that part. Bits 7-9 is a divider that further
divides the clock signal selected by bit 4. This is set to 0x4, which
means we divide the 1GHz fclk_div2 down to 250MHz, which seems to be the
expected value coming out of this divider.

I haven't looked further to see if there is a further programmable
divider to divide 250MHz down to 50MHz, or (more likely) there is simply
a fixed-factor divide-by-5 that results in the 50MHz rate consumed by
the PHY.

Modeling this all in the mmc driver makes sense. So we would have:

struct clk_mux clk_m250_sel ->
	struct clk_divider clk_m250_div ->
		struct clk_fixed_factor enet_phy_clk

I don't know what the name should be for that last one, I just chose
enet_phy_clk since it illustrates the point. The updated docs suggest
that clk_m250_{sel,div} might be reasonable names for the mux and
divider.

Kevin and I just got this info from AmLogic earlier today. The next rev
of documentation should correct these register definitions.

Regards,
Mike
