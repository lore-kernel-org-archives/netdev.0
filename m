From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH v3] net: phy: micrel: Fix regression in kszphy_probe
Date: Mon, 11 May 2015 15:50:40 +0200
Message-ID: <20150511135040.GD24504@localhost>
References: <1431351015-21956-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, festevam@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	johan@kernel.org, Niklas Cassel <niklass@axis.com>,
	stable <stable@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431351015-21956-1-git-send-email-niklass@axis.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 11, 2015 at 03:30:15PM +0200, Niklas Cassel wrote:
> Don't do clock-mode-select if clk == NULL,
> since when building without CONFIG_HAVE_CLK,
> clk_get returns NULL and clk_get_rate returns 0.
> 
> Doing clock-mode-select in this cause causes kszphy_probe to
> return -EINVAL and thus prevents the device from being probed.
> 
> The original code (before regression) would return 0
> when building without CONFIG_HAVE_CLK.
> 
> Cc: stable <stable@vger.kernel.org> # 3.19+
> Fixes: 63f44b2bfccd ("net: phy: micrel: add generic clock-mode-select
> support")

You're blaming the wrong commit here -- the regression was introduced by
1fadee0c3645 ("net/phy: micrel: Add clock support for KSZ8021/KSZ8031")
and then the commit you mention made even more devices fail without
CONFIG_HAVE_CLK.

Thought I mentioned this commit explicitly in my last mail but see now
that I only wrote that the offending commit went into 3.18 (i.e. not
3.19).

> Signed-off-by: Niklas Cassel <niklass@axis.com>
> ---
>  drivers/net/phy/micrel.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 1190fd8..f6a34e3 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -548,7 +548,11 @@ static int kszphy_probe(struct phy_device *phydev)
>  	}
>  
>  	clk = devm_clk_get(&phydev->dev, "rmii-ref");
> -	if (!IS_ERR(clk)) {
> +	/* Don't check rate if clk == NULL, since when CONFIG_HAVE_CLK is not
> +	 * set, clk_get returns NULL and clk_get_rate returns 0.  Doing so
> +	 * would return -EINVAL and prevent the device from being probed.
> +	 */

Why not simply

	/* NOTE: clk may be NULL if building without CONFIG_HAVE_CLK */

> +	if (!IS_ERR_OR_NULL(clk)) {
>  		unsigned long rate = clk_get_rate(clk);
>  		bool rmii_ref_clk_sel_25_mhz;

Johan
