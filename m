From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Mon, 31 Aug 2015 19:04:43 -0500
Message-ID: <1441065883.2718.76.camel@redhat.com>
References: <1441048794-31237-1-git-send-email-linux@rainbow-software.org>
	 <1441053894.2718.54.camel@redhat.com>
	 <201509010012.49729.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201509010012.49729.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-09-01 at 00:12 +0200, Ondrej Zary wrote:
> 
> On Monday 31 August 2015 22:44:54 Dan Williams wrote:
> > On Mon, 2015-08-31 at 21:19 +0200, Ondrej Zary wrote:
> > > Handle IW_AUTH_ALG_OPEN_SYSTEM in set_auth.
> > > This allows wpa_supplicant (and thus NetworkManager) to work with open
> > > APs.
> > >
> > > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > > ---
> > >  drivers/net/wireless/airo.c |    7 +++----
> > >  1 file changed, 3 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> > > index d0c97c2..2066a1f 100644
> > > --- a/drivers/net/wireless/airo.c
> > > +++ b/drivers/net/wireless/airo.c
> > > @@ -6670,10 +6670,9 @@ static int airo_set_auth(struct net_device *dev,
> > >  		break;
> > >
> > >  	case IW_AUTH_80211_AUTH_ALG: {
> > > -			/* FIXME: What about AUTH_OPEN?  This API seems to
> > > -			 * disallow setting our auth to AUTH_OPEN.
> > > -			 */
> > > -			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> > > +			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> > > +				local->config.authType = AUTH_OPEN;
> > > +			} else if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> > >  				local->config.authType = AUTH_SHAREDKEY;
> > >  			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> > >  				local->config.authType = AUTH_ENCRYPT;
> >
> > NAK; there are two problems with this patch.  First, there's already an
> > if test for OPEN_SYSTEM which sets authType to AUTH_ENCRYPT.  Second,
> > AUTH_OPEN means to disable encryption entirely.  The decision being made
> > here is whether to use Shared Key or Open authentication, not whether
> > encryption is being used or not.  Thus this patch would appear to break
> > most WEP APs?
> >
> > Airo really wants to know the auth type *and* whether encryption will
> > actually be used at the same time, and we don't have that information
> > here.  I guess the only thing you can do here is call get_wep_key() for
> > all the indexes and see if any keys are set, and if any keys are set,
> > use AUTH_ENCRYPT.  If get_wep_key() returns -1 for all 4 indexes, use
> > AUTH_OPEN.  But you have to make sure that this all gets protected by
> > local->wep_capable and that you're not checking indexes above
> > ai->max_wep_idx.  Yay airo!
> 
> Sorry, I got confused (and it worked with WEP with a test AP, although there's
> no open system/shared key setting in the firmware).
> 
> Reading the wpa_supplicant code, it uses IW_AUTH_ALG_OPEN_SYSTEM for WEP open
> system and also as a default value - which gets used when encryption is
> disabled:

I think you're still confusing the relationship between Open System and
WEP in the code and comments here.  802.11 always uses an "auth method"
regardless of whether encryption is used or not.  There are 3 possible
settings here:

Auth    Encryption
------------------
OPEN    NONE
OPEN    WEP
SHARED  WEP

The problem here is that:

1) the WEXT SIWAUTH call only sets authentication, but says nothing
about encryption

2) that airo is currently structured such that it wants both auth &
encryption specified at the same time.  It tracks the states in the
table above with the authType variable, but at the point of SIWAUTH
there is no information about whether the requested mode is OPEN+NONE or
OPEN+WEP.

The patches might work for some cases, but they are ignoring others
where clients might send WEXT calls in different order.  WEXT doesn't
specify any kind of ordering, which is one reason it's been deprecated
and replaced with nl80211.  So in your case, the supplicant does [IWAUTH
+ IWENCODE] but that's just how the supplicant decided to implement it.
If some other client does a perfectly legal [IWENCODE + IWAUTH] then
your original patch will turn off WEP, when the client wanted OPEN +
WEP.

> static int wpa_driver_wext_set_auth_alg(void *priv, int auth_alg)
> {
>         struct wpa_driver_wext_data *drv = priv;
>         int algs = 0, res;
> 
>         if (auth_alg & WPA_AUTH_ALG_OPEN)
>                 algs |= IW_AUTH_ALG_OPEN_SYSTEM;
>         if (auth_alg & WPA_AUTH_ALG_SHARED)
>                 algs |= IW_AUTH_ALG_SHARED_KEY;
>         if (auth_alg & WPA_AUTH_ALG_LEAP)
>                 algs |= IW_AUTH_ALG_LEAP;
>         if (algs == 0) {
>                 /* at least one algorithm should be set */
>                 algs = IW_AUTH_ALG_OPEN_SYSTEM;
>         }
> 
>         res = wpa_driver_wext_set_auth_param(drv, IW_AUTH_80211_AUTH_ALG,
>                                              algs);
>         drv->auth_alg_fallback = res == -2;
>         return res;
> }
> 
> 
> However, when SIOCSIWAUTH fails with EOPNOTSUPP, it tries SIOCSIWENCODE. This
> patch seems to work too with my AP:
> 
> diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> index d0c97c2..2610fe3 100644
> --- a/drivers/net/wireless/airo.c
> +++ b/drivers/net/wireless/airo.c
> @@ -6670,14 +6670,17 @@ static int airo_set_auth(struct net_device *dev,
>  		break;
>  
>  	case IW_AUTH_80211_AUTH_ALG: {
> -			/* FIXME: What about AUTH_OPEN?  This API seems to
> -			 * disallow setting our auth to AUTH_OPEN.
> +			/*
> +			 * IW_AUTH_ALG_OPEN_SYSTEM is ambiguous here for WEP as
> +			 * wpa_supplicant uses it for both no encryption and
> +			 * WEP open system. So we return -EOPNOTSUPP and
> +			 * wpa_supplicant will use SIOCSIWENCODE instead.

It's not really the supplicant that's ambiguous, the supplicant is doing
stuff that makes sense.  Unfortunately the WEXT API is what is ambiguous
here.  Plus, even though wpa_supplicant is the de-facto standard, the
kernel should treat the supplicant specially and we shouldn't add hacks
for specific programs.  Let's see if a general solution can be found.

>  			 */
> -			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> +			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM)
> +				return -EOPNOTSUPP;

While it works due to wpa_supplicant behavior, it's a hack.  It's
perfectly legal to set OPEN_SYSTEM mode in SIWAUTH.  It's just that airo
is so simple in how it handles WEXT that it doesn't have enough
information to do the right thing.  What ipw2200 does is cache values in
the driver struct so it has everything it needs all the time.

So what I'm saying is that your fix here isn't really a complete fix.  A
complete fix would work for all these scenarios:

a) SIWAUTH(open), SIWENCODE(enable wep) = WEP + open system
b) SIWENCODE(enable wep), SIWAUTH(open) = WEP + open system
c) SIWAUTH(open), SIWENCODE(disable WEP) = unencrypted + open system
d) SIWENCODE(disable WEP), SIWAUTH(open) = unencrypted + open system

and that complete fix might well be caching the IW_AUTH_ALG value in  a
couple places (in the SIWAUTH handler and the SIWENCODE and SIWENCODEEXT
handlers) and also whether WEP is enabled or not, and then using both of
those values to set authType in SIWAUTH.

Dan

> +			if (param->value & IW_AUTH_ALG_SHARED_KEY)
>  				local->config.authType = AUTH_SHAREDKEY;
> -			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> -				local->config.authType = AUTH_ENCRYPT;
> -			} else
> +			else
>  				return -EINVAL;
>  
>  			/* Commit the changes to flags if needed */
> 
> 
> 
> -- 
> Ondrej Zary
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
