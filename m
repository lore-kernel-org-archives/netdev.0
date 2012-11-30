From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/5] smsc95xx: fix smsc_crc return type
Date: Fri, 30 Nov 2012 07:59:59 -0800
Message-ID: <1354291199.11903.22.camel@joe-AO722>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
	 <1354290952-27109-5-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41368 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754053Ab2K3QAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 11:00:00 -0500
In-Reply-To: <1354290952-27109-5-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 15:55 +0000, Steve Glendinning wrote:
> This patch fixes a bug introduced in bbd9f9e which could prevent
> some wakeups from working correctly if multiple wol options were
> selected.
> 
> This helper function calculates a 16-bit crc and shifts it into
> either the high or low 16 bits of a u32 so the caller can or it
> directly into place.  The function previously had a u16 return
> type so would always have returned zero when filter was odd.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> Reported-by: Bjorn Mork <bjorn@mork.no>
> Cc: Joe Perches <joe@perches.com>
> ---
>  drivers/net/usb/smsc95xx.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 064df1a..b9eb490 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1074,9 +1074,10 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
>  	}
>  }
>  
> -static u16 smsc_crc(const u8 *buffer, size_t len, int filter)
> +static u32 smsc_crc(const u8 *buffer, size_t len, int filter)
>  {
> -	return bitrev16(crc16(0xFFFF, buffer, len)) << ((filter % 2) * 16);
> +	u32 crc = bitrev16(crc16(0xFFFF, buffer, len));
> +	return crc << ((filter % 2) * 16);
>  }
>  
>  static int smsc95xx_enable_phy_wakeup_interrupts(struct usbnet *dev, u16 mask)

Having filter as an argument to this function really
just confuses things.

The shift should be done when the result is or'd onto the
control variable.
