From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Mon, 31 Aug 2015 15:44:54 -0500
Message-ID: <1441053894.2718.54.camel@redhat.com>
References: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-08-31 at 21:19 +0200, Ondrej Zary wrote:
> Handle IW_AUTH_ALG_OPEN_SYSTEM in set_auth.
> This allows wpa_supplicant (and thus NetworkManager) to work with open APs.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> ---
>  drivers/net/wireless/airo.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index d0c97c2..2066a1f 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -6670,10 +6670,9 @@ static int airo_set_auth(struct net_device *dev,
>  		break;
>  
>  	case IW_AUTH_80211_AUTH_ALG: {
> -			/* FIXME: What about AUTH_OPEN?  This API seems to
> -			 * disallow setting our auth to AUTH_OPEN.
> -			 */
> -			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> +			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> +				local->config.authType = AUTH_OPEN;
> +			} else if (param->value & IW_AUTH_ALG_SHARED_KEY) {
>  				local->config.authType = AUTH_SHAREDKEY;
>  			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
>  				local->config.authType = AUTH_ENCRYPT;

NAK; there are two problems with this patch.  First, there's already an
if test for OPEN_SYSTEM which sets authType to AUTH_ENCRYPT.  Second,
AUTH_OPEN means to disable encryption entirely.  The decision being made
here is whether to use Shared Key or Open authentication, not whether
encryption is being used or not.  Thus this patch would appear to break
most WEP APs?

Airo really wants to know the auth type *and* whether encryption will
actually be used at the same time, and we don't have that information
here.  I guess the only thing you can do here is call get_wep_key() for
all the indexes and see if any keys are set, and if any keys are set,
use AUTH_ENCRYPT.  If get_wep_key() returns -1 for all 4 indexes, use
AUTH_OPEN.  But you have to make sure that this all gets protected by
local->wep_capable and that you're not checking indexes above
ai->max_wep_idx.  Yay airo!

Dan
