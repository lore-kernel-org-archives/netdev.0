From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 1/2] airo: fix IW_AUTH_ALG_OPEN_SYSTEM
Date: Tue, 1 Sep 2015 00:12:49 +0200
Message-ID: <201509010012.49729.linux@rainbow-software.org>
References: <1441048794-31237-1-git-send-email-linux@rainbow-software.org> <1441053894.2718.54.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-1b.atlantis.sk ([80.94.52.26]:45940 "EHLO
	smtp-1b.atlantis.sk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbbHaWNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 18:13:00 -0400
In-Reply-To: <1441053894.2718.54.camel@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Monday 31 August 2015 22:44:54 Dan Williams wrote:
> On Mon, 2015-08-31 at 21:19 +0200, Ondrej Zary wrote:
> > Handle IW_AUTH_ALG_OPEN_SYSTEM in set_auth.
> > This allows wpa_supplicant (and thus NetworkManager) to work with open
> > APs.
> >
> > Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> > ---
> >  drivers/net/wireless/airo.c |    7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
> > index d0c97c2..2066a1f 100644
> > --- a/drivers/net/wireless/airo.c
> > +++ b/drivers/net/wireless/airo.c
> > @@ -6670,10 +6670,9 @@ static int airo_set_auth(struct net_device *dev,
> >  		break;
> >
> >  	case IW_AUTH_80211_AUTH_ALG: {
> > -			/* FIXME: What about AUTH_OPEN?  This API seems to
> > -			 * disallow setting our auth to AUTH_OPEN.
> > -			 */
> > -			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> > +			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> > +				local->config.authType = AUTH_OPEN;
> > +			} else if (param->value & IW_AUTH_ALG_SHARED_KEY) {
> >  				local->config.authType = AUTH_SHAREDKEY;
> >  			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
> >  				local->config.authType = AUTH_ENCRYPT;
>
> NAK; there are two problems with this patch.  First, there's already an
> if test for OPEN_SYSTEM which sets authType to AUTH_ENCRYPT.  Second,
> AUTH_OPEN means to disable encryption entirely.  The decision being made
> here is whether to use Shared Key or Open authentication, not whether
> encryption is being used or not.  Thus this patch would appear to break
> most WEP APs?
>
> Airo really wants to know the auth type *and* whether encryption will
> actually be used at the same time, and we don't have that information
> here.  I guess the only thing you can do here is call get_wep_key() for
> all the indexes and see if any keys are set, and if any keys are set,
> use AUTH_ENCRYPT.  If get_wep_key() returns -1 for all 4 indexes, use
> AUTH_OPEN.  But you have to make sure that this all gets protected by
> local->wep_capable and that you're not checking indexes above
> ai->max_wep_idx.  Yay airo!

Sorry, I got confused (and it worked with WEP with a test AP, although there's
no open system/shared key setting in the firmware).

Reading the wpa_supplicant code, it uses IW_AUTH_ALG_OPEN_SYSTEM for WEP open
system and also as a default value - which gets used when encryption is
disabled:
static int wpa_driver_wext_set_auth_alg(void *priv, int auth_alg)
{
        struct wpa_driver_wext_data *drv = priv;
        int algs = 0, res;

        if (auth_alg & WPA_AUTH_ALG_OPEN)
                algs |= IW_AUTH_ALG_OPEN_SYSTEM;
        if (auth_alg & WPA_AUTH_ALG_SHARED)
                algs |= IW_AUTH_ALG_SHARED_KEY;
        if (auth_alg & WPA_AUTH_ALG_LEAP)
                algs |= IW_AUTH_ALG_LEAP;
        if (algs == 0) {
                /* at least one algorithm should be set */
                algs = IW_AUTH_ALG_OPEN_SYSTEM;
        }

        res = wpa_driver_wext_set_auth_param(drv, IW_AUTH_80211_AUTH_ALG,
                                             algs);
        drv->auth_alg_fallback = res == -2;
        return res;
}


However, when SIOCSIWAUTH fails with EOPNOTSUPP, it tries SIOCSIWENCODE. This
patch seems to work too with my AP:

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d0c97c2..2610fe3 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -6670,14 +6670,17 @@ static int airo_set_auth(struct net_device *dev,
 		break;
 
 	case IW_AUTH_80211_AUTH_ALG: {
-			/* FIXME: What about AUTH_OPEN?  This API seems to
-			 * disallow setting our auth to AUTH_OPEN.
+			/*
+			 * IW_AUTH_ALG_OPEN_SYSTEM is ambiguous here for WEP as
+			 * wpa_supplicant uses it for both no encryption and
+			 * WEP open system. So we return -EOPNOTSUPP and
+			 * wpa_supplicant will use SIOCSIWENCODE instead.
 			 */
-			if (param->value & IW_AUTH_ALG_SHARED_KEY) {
+			if (param->value & IW_AUTH_ALG_OPEN_SYSTEM)
+				return -EOPNOTSUPP;
+			if (param->value & IW_AUTH_ALG_SHARED_KEY)
 				local->config.authType = AUTH_SHAREDKEY;
-			} else if (param->value & IW_AUTH_ALG_OPEN_SYSTEM) {
-				local->config.authType = AUTH_ENCRYPT;
-			} else
+			else
 				return -EINVAL;
 
 			/* Commit the changes to flags if needed */



-- 
Ondrej Zary
