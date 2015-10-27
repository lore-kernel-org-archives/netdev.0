From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [PATCH] ixgbe: Wait for 1ms, not 1us, after RST
Date: Tue, 27 Oct 2015 17:03:34 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF22286646913C0CCF@ORSMSX110.amr.corp.intel.com>
References: <1445904971-9442-1-git-send-email-dan.streetman@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dan Streetman <ddstreet@ieee.org>
To: "dan.streetman@canonical.com" <dan.streetman@canonical.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445904971-9442-1-git-send-email-dan.streetman@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: dan.streetman@canonical.com
> [mailto:dan.streetman@canonical.com]
> Sent: Monday, October 26, 2015 5:16 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore,
> Donald C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> Dan Streetman; Dan Streetman
> Subject: [PATCH] ixgbe: Wait for 1ms, not 1us, after RST
> 
> From: Dan Streetman <dan.streetman@canonical.com>
> 
> The driver currently waits 1us after issuing a RST, but the spec requires it to
> wait 1ms.
> 
> Signed-off-by: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> index 4e75843..147bc65 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
> @@ -113,7 +113,12 @@ mac_reset_top:
> 
>  	/* Poll for reset bit to self-clear indicating reset is complete */
>  	for (i = 0; i < 10; i++) {
> -		udelay(1);
> +		/* sec 8.2.4.1.1 :
> +		 * programmers must wait approximately 1 ms after setting
> before
> +		 * attempting to check if the bit has cleared or to access
> (read
> +		 * or write) any other device register.
> +		 */
> +		mdelay(1);
>  		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
>  		if (!(ctrl & IXGBE_CTRL_RST_MASK))
>  			break;
> --
> 2.5.0

While the Data Sheet does mention that this should take ~ 1ms, we are in a busy wait state so it probably isn't that big of a deal to check more frequently for our exit condition.  That said there are plenty of other delays later on in the reset path so keeping the udelay really isn't speeding things up much. :)

Also normally it isn't a good idea to reference a section number in the data sheet as they do seem to change with updates.  We are most likely a bit more safe here as it is one of the first of a list of register descriptions' and thus less like to move. 
