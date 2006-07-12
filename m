From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in wireless	statistics
Date: Tue, 11 Jul 2006 23:03:59 -0500
Message-ID: <44B474AF.6010907@lwfinger.net>
References: <44B3CC25.7060305@lwfinger.net> <1152646370.27683.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:14049 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932403AbWGLEEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:04:00 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1152646370.27683.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> 
> NAK... remember, range->max_qual.level must be _0_ if you're in dBm,

I do not think this is right. From the comments in include/linux/wireless.h:

         /* Quality of link & SNR stuff */
         /* Quality range (link, level, noise)
          * If the quality is absolute, it will be in the range [0 ; max_qual],
          * if the quality is dBm, it will be in the range [max_qual ; 0].
          * Don't forget that we use 8 bit arithmetics... */

My interpretation of this is that if 0 < max_qual < 128, the quantity is absolute. Conversely, if 
-129 < max_qual < 0, the quantity is in dBm. This is in fact what I see, both from the KDE applets 
and the various wireless extension tools.

> since 0 is the actual maximum, and your level values are negative since
> they are in dBm.
> 
> If KDE network applets display the wrong value when max_qual.level == 0,
> then they are wrong and need to be fixed.

They display correctly; however, choosing 0 rather than -100 expands the scale to the point that my 
noise values of -65 dBm display as rather high values. Despite the 8-bit arithmetic, I think it 
creates a scale from 0 to -255 dBm. My choice of parameters expands the scale by limiting the lower 
value to -100 dBm.

> If you actually want RSSI, then you set max_qual.level to the upper
> limit of your RSSI, and the RSSI is assumed to go from 0 ->
> max_qual.level.  AFAIK, the patch you had earlier is using dBm, _not_
> RSSI, so max_qual.level = 0 is correct.

As I explained earlier, the RSSI value returned by the firmware has been processed by the driver 
into a quantity that varies between -10 and -65 as the receiver is moved from very close to very far 
from the AP, which looks like strength in dBm. This is what is stored in stats.rssi. As this seems 
to be confusing, I will rewrite the driver code so that this value is returned in stats.signal with 
the RSSI value preserved in stats.rssi. The quality output will be derived from stats.rssi, and the 
level output will come from stats.signal. These two quantities have a correlation of -1 so there is 
no new information, but that might change in the future.

Larry
