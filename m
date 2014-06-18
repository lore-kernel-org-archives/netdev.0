From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer
 size
Date: Wed, 18 Jun 2014 15:41:04 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1406181534510.1519@gmail.com>
References: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-213642212-1403098865=:1519"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403094084-13588-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-213642212-1403098865=:1519
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

I think this is good, even if I admit I am starting to feel pretty 
unconfortable with this situation where a firmware is using an unknown 
combination of two protocols, not respecting both AT spec and CDC WDM one.
That may explain why the device refuses some commands sometimes, such as
at+clac
.

I hope I'll be able to come back at this driver some day and try to figure out 
something more.
I can not promise anything - but I would like to modify cdc-wdm as per our last 
discussion (and I might ask you to point me to the right message from Oliver 
again).
Regarding the buffer size - I do not know if there is a way to obtain it. Might 
USB sniffing help in this, to see if we are receiving the data in some 
unexpected location?
I am asking myself how this thing is implemented in Windows Huawei drivers: 
just out of curiosity.
i can tell also - i experienced some crash with E3251 where I had to close and 
re-open the seiral port, but this usually happened after simple
AT
commands, and it seemd a problem with minicom, but it was only an impression, 
not confirmed by anything, so it can very easily wrong. I like to play and try 
to understand.

So - I acknoledge the patch.
Please can you CC Oliver so that he knows?


Acked-By: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

On Wed, 18 Jun 2014, Bjørn Mork wrote:

==Date: Wed, 18 Jun 2014 14:21:24
==From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
==To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
==Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
==    Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Subject: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer size
==
==Messages from the modem exceeding 256 bytes cause communication
==failure.
==
==The WDM protocol is strictly "read on demand", meaning that we only
==poll for unread data after receiving a notification from the modem.
==Since we have no way to know how much data the modem has to send,
==we must make sure that the buffer we provide is "big enough".
==Message truncation does not work. Truncated messages are left unread
==until the modem has another message to send.  Which often won't
==happen until the userspace application has given up waiting for the
==final part of the last message, and therefore sends another command.
==
==With a proper CDC WDM function there is a descriptor telling us
==which buffer size the modem uses. But with this vendor specific
==implementation there is no known way to calculate the exact "big
==enough" number.  It is an unknown property of the modem firmware.
==Experience has shown that 256 is too small.  The discussion of
==this failure ended up concluding that 512 might be too small as
==well. So 1024 seems like a reasonable value for now.
==
==Fixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver")
==Cc: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
==Reported-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
==Signed-off-by: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
==---
==
==The problem is a showstopper for anyone hitting it, so I believe this
==fix should go into all maintained stable kernels with this driver.
==That is anything based on v3.13 or newer.
==
==Thanks,
==Bjørn
==
==
== drivers/net/usb/huawei_cdc_ncm.c | 7 ++++---
== 1 file changed, 4 insertions(+), 3 deletions(-)
==
==diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawei_cdc_ncm.c
==index f9822bc75425..5d95a13dbe2a 100644
==--- a/drivers/net/usb/huawei_cdc_ncm.c
==+++ b/drivers/net/usb/huawei_cdc_ncm.c
==@@ -84,12 +84,13 @@ static int huawei_cdc_ncm_bind(struct usbnet *usbnet_dev,
== 	ctx = drvstate->ctx;
== 
== 	if (usbnet_dev->status)
==-		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
==-		 * decimal (0x100)"
==+		/* The wMaxCommand buffer must be big enough to hold
==+		 * any message from the modem. Experience has shown
==+		 * that some replies are more than 256 bytes long
== 		 */
== 		subdriver = usb_cdc_wdm_register(ctx->control,
== 						 &usbnet_dev->status->desc,
==-						 256, /* wMaxCommand */
==+						 1024, /* wMaxCommand */
== 						 huawei_cdc_ncm_wdm_manage_power);
== 	if (IS_ERR(subdriver)) {
== 		ret = PTR_ERR(subdriver);
==-- 
==2.0.0
==
==
--8323328-213642212-1403098865=:1519--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
