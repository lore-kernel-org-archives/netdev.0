From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: phy: micrel: support !CONFIG_HAVE_CLK
Date: Fri, 8 May 2015 16:32:18 +0200
Message-ID: <20150508143218.GH1942@localhost>
References: <1430132450-4496-1-git-send-email-niklass@axis.com>
 <CAOMZO5Dg9FkGkSS7mygv3OdfdF4jOK_nbTvx8eUTGD+EMmRs0g@mail.gmail.com>
 <55475872.8020004@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Estevam <festevam@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"johan@kernel.org" <johan@kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55475872.8020004@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 01:30:58PM +0200, Niklas Cassel wrote:
> On 04/27/2015 07:59 PM, Fabio Estevam wrote:
> > On Mon, Apr 27, 2015 at 8:00 AM, Niklas Cassel <niklas.cassel@axis.com> wrote:
> > 
> >> Since NULL is a valid clock, we shouldn't use
> >> IS_ERR_OR_NULL.
> > 
> > Yes, but this code is not using IS_ERR_OR_NULL.
> > 
> > It seems that you are not describing the problem you are trying to solve.
> > 
> > What is the exact issue you are seeing?
> > 
> >>         clk = devm_clk_get(&phydev->dev, "rmii-ref");
> > 
> > You need to provide the 'rmii-ref' in your board file or dts.
> > 
> > Are you doing this?
> > 
> 
> I'm sorry, my commit message didn't really describe the problem properly.
> 
> When you compile your kernel without the clk.h API (CONFIG_HAVE_CLK),
> devm_clk_get returns NULL (which also happens to be a valid clock in the clk.h API).
> So it's not a matter of DT or board-files. This is on a mips platform without DT support.
> 
> I simply want the drivers/net/phy/micrel.c driver to also work without CONFIG_HAVE_CLK,
> like it did before commit
> 
> 63f44b2bfccdd98193bbd602747f780c0fae0f02
> net: phy: micrel: add generic clock-mode-select support
> 
> Now I get an error every time I boot with "Clock rate out of range: 0",
> since clk_get_rate returns 0 when compiling with !CONFIG_HAVE_CLK.

You should include this information in the commit message when you
send the next version of the patch (and remember to include the patch
revision in the subject, that is, PATCH v3).

As this is a regression that prevents the device from being probed
(mention this in the commit message as well) we should address this
promptly.

Add a Fixes and CC-stable tag as well as the offending commit went into 3.18.

> It is confusing that devm_clk_get returns a valid clock in the clk.h API (NULL),
> when compiling with !CONFIG_HAVE_CLK, but according to Russell King in:
> 
> http://lkml.kernel.org/r/20150207172949.GE8656@n2100.arm.linux.org.uk
> 
> this was intentional. (explained in the lkml mail above.)
> 
> In the same mail Russell King also suggests how a driver can support both
> !CONFIG_HAVE_CLK and CONFIG_HAVE_CLK.
> 
> This is the suggestion I followed when writing my patch.

I'm actually leaning towards using !IS_ERR_OR_NULL as you did in your
first patch and to add a comment explaining why it's there (rather than
skipping the ref_clk configuration if the clock rate is 0).

The rmii-ref clock is already optional and is only used to set one
configuration bit when present. We should of course continue to support
board-file configuration as well.

Thanks,
Johan
