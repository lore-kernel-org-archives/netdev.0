From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fix double release of mutex
Date: Thu, 11 Dec 2008 21:24:43 -0800
Message-ID: <9929d2390812112124r3632d551we7c95237c23d9137@mail.gmail.com>
References: <20081212052025.3298.151.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	linux-kernel@vger.kernel.org,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:12605 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbYLLFYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:24:45 -0500
In-Reply-To: <20081212052025.3298.151.stgit@lost.foo-projects.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 9:20 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> During a reset, releasing the swflag after it failed to be acquired would
> cause a double unlock of the mutex.  Instead, test whether acquisition of
> the swflag was successful and if not, do not release the swflag.  The reset
> must still be done to bring the device to a quiescent state.
>
> This resolves [BUG 12200] BUG: bad unlock balance detected! e1000e
> http://bugzilla.kernel.org/show_bug.cgi?id=12200
>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
>  drivers/net/e1000e/ich8lan.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
> index 523b971..d115a6d 100644
> --- a/drivers/net/e1000e/ich8lan.c
> +++ b/drivers/net/e1000e/ich8lan.c
> @@ -1893,12 +1893,17 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
>                ctrl |= E1000_CTRL_PHY_RST;
>        }
>        ret_val = e1000_acquire_swflag_ich8lan(hw);
> +       /* Whether or not the swflag was acquired, we need to reset the part */
>        hw_dbg(hw, "Issuing a global reset to ich8lan");
>        ew32(CTRL, (ctrl | E1000_CTRL_RST));
>        msleep(20);
>
> -       /* release the swflag because it is not reset by hardware reset */
> -       e1000_release_swflag_ich8lan(hw);
> +       if (!ret_val) {
> +               /* release the swflag because it is not reset by
> +                * hardware reset
> +                */
> +               e1000_release_swflag_ich8lan(hw);
> +       }
>
>        ret_val = e1000e_get_auto_rd_done(hw);
>        if (ret_val) {
>
> --
>

I meant to put [RESPIN] in the title, but I did not.  So here is the respin.

-- 
Cheers,
Jeff
