From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu
 wireless IC
Date: Mon, 31 Oct 2016 20:01:54 -0700
Message-ID: <1477969314.23018.24.camel@perches.com>
References: <20161031183522.GA13315@cube> <wrfj1sywrz2f.fsf@redhat.com>
         <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: John Heenan <john@zgus.com>, Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0020.hostedemail.com ([216.40.44.20]:56022 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S965298AbcKADCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 23:02:03 -0400
In-Reply-To: <CAAye0QNtcb28q1HY-xAr=bQ0s_nEQuv1TM+Ax5i99Eds7xOb=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 08:15 +1000, John Heenan wrote:
> > On 1 November 2016 at 07:25, Jes Sorensen <Jes.Sorensen@redhat.com> wrote:
> > > > John Heenan <john@zgus.com> writes:
> > > The rtl8723bu wireless IC shows evidence of a more agressive approach to
> > > power saving, powering down its RF side when there is no wireless
> > > interfacing but leaving USB interfacing intact. This makes the wireless
> > > IC more suitable for use in devices which need to keep their power use
> > > as low as practical, such as tablets and Surface Pro type devices.
> > > 
> > > In effect this means that a full initialisation must be performed
> > > whenever a wireless interface is brought up. It also means that
> > > interpretations of power status from general wireless registers should
> > > not be relied on to influence an init sequence.
> > > 
> > > The patch works by forcing a fuller initialisation and forcing it to
> > > occur more often in code paths (such as occurs during a low level
> > > authentication that initiates wireless interfacing).
> > > 
> > > The initialisation sequence is now more consistent with code based
> > > directly on vendor code. For example while the vendor derived code
> > > interprets a register as indcating a particular powered state, it does
> > > not use this information to influence its init sequence.
> > > 
> > > The rtl8723bu device has a unique USB VID and PID. This is taken
> > > advantage of for the patch to ensure only rtl8723bu devices are affected
> > > by this patch.
> > > 
> > > With this patch wpa_supplicant reliably and consistently connects with
> > > an AP. Before a workaround such as executing rmmod and modprobe before
> > > each call to wpa_supplicant worked with some distributions.
> > > 
> > > > > > Signed-off-by: John Heenan <john@zgus.com>
> > > ---
> > >  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  | 24 ++++++++++++++++++----
> > >  1 file changed, 20 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> > > index 04141e5..f36e674 100644
> > > --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> > > +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> > > @@ -79,6 +79,8 @@ MODULE_PARM_DESC(dma_agg_pages, "Set DMA aggregation pages (range 1-127, 0 to di
> > >  #define RTL8XXXU_TX_URB_LOW_WATER    25
> > >  #define RTL8XXXU_TX_URB_HIGH_WATER   32
> > > 
> > > +#define USB_PRODUCT_ID_RTL8723BU 0xb720
> > > +
> > 
> > Absolutely not! You have no guarantee that this is the only id used for
> > 8723bu devices, and adding a #define for each is not going to happen.
> 
> Thanks for you reply.
> 
> I have no problem with that. However the patch does get the point
> across in a minimalist and efficient way of what the issues are.
> 
> Currently there is no property available to determine the information required.
> 
> > 
> > >  static int rtl8xxxu_submit_rx_urb(struct rtl8xxxu_priv *priv,
> > >                                 struct rtl8xxxu_rx_urb *rx_urb);
> > > 
> > > @@ -3892,6 +3894,7 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
> > >       u8 val8;
> > >       u16 val16;
> > >       u32 val32;
> > > +  struct usb_device_descriptor *udesc = &priv->udev->descriptor;
> > 
> > Indentaiton
> 
> OK. Missed that one.
> 
> > 
> > >       /* Check if MAC is already powered on */
> > >       val8 = rtl8xxxu_read8(priv, REG_CR);
> > > @@ -3900,7 +3903,9 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
> > >        * Fix 92DU-VC S3 hang with the reason is that secondary mac is not
> > >        * initialized. First MAC returns 0xea, second MAC returns 0x00
> > >        */
> > > -     if (val8 == 0xea)
> > > +     if (val8 == 0xea
> > > +                     || (udesc->idVendor == USB_VENDOR_ID_REALTEK
> > > +                     &&  udesc->idProduct == USB_PRODUCT_ID_RTL8723BU))
> > >               macpower = false;
> > >       else
> > >               macpower = true;
> > 
> > Please respect proper kernel coding style!
> 
> I don't know what you mean. Your code has real tabs. My code has real
> tabs. The kernel style goes on about tabs being 8 spaces. So do you
> want: real tabs or real spaces?
> 
> You said no lines over 80 columns long. This is what i have done.

Typical kernel style would be:

	if (val == 0xea ||
	    (udesc->idVendor == USB_VENDOR_ID_REALTEK &&
	     udesc->idProduct == USB_PRODUCT_ID_RTL8723BU))
		macpower = false;
	else
		macpower = true;

ie: logical continuations at EOL and indentation aligned to parentheses
    using as many leading tabs as possible, then spaces where necessary

or maybe:

	macpower = !(val == 0xea ||
		     (idesc->idVendor == USB_VENDOR_ID_REALTEK &&
		      udesc->idProduct == USB_PRODUCT_ID_RTL8723BU));

but the first one seems easier to read.

> > > @@ -6080,9 +6093,12 @@ static int rtl8xxxu_probe(struct usb_interface *interface,
> > >               goto exit;
> > >       }
> > > 
> > > -     ret = rtl8xxxu_init_device(hw);
> > > -     if (ret)
> > > +     if(!(id->idVendor == USB_VENDOR_ID_REALTEK
> > > +                     && id->idProduct == USB_PRODUCT_ID_RTL8723BU)) {
> > > +             ret = rtl8xxxu_init_device(hw);
> > > +             if (ret)
> > >               goto exit;
> > > +     }
> > 
> > Again, this coding style abuse will never go into this driver,
> 
> As above, what abuse? I am not being facetious. Just puzzled.

Same logical continuation and indentation alignment.

>  Again have a nice day!

That's pleasant of you but Jen's rarely seems pleasant in return via
email.  I trust he's more personable over a beer though.  Perhaps one
day we'll all have one together.
