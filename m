From: Daniel Drake <dsd@gentoo.org>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
 btw)
Date: Sun, 24 Sep 2006 11:34:16 -0400
Message-ID: <4516A578.2030105@gentoo.org>
References: <1159065798.5924.8.camel@localhost.localdomain> <200609241005.02024.mb@bu3sch.de> <1159085579.5924.25.camel@localhost.localdomain> <200609241043.49772.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:14475 "EHLO
	smtp151.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1750987AbWIXPeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 11:34:13 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609241043.49772.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Well. Works For Me (tm).
> If there is some bug for you in current mainline, it needs to
> be fixed. But I can't fix something I am not able to reproduce and
> don't know what happens.

Take a look at the logs in Ben's original mail. I've seen this a lot 
myself and am fairly sure that the problem is softmac's handling of a 
SIWESSID *immediately* followed by a SIWAP call. This is what 
wpa_supplicant does, and the timing screws us over.

You can see in the logs that the driver starts authenticating after the 
first ioctl comes in, but then starts scanning (in preparation for 
authentication, again) as soon as the 2nd call comes in immediately 
after. As the device is busy scanning other channels it misses the 
authentication response, and this goes round in circles.

Now, Jose recently bolted on a few more lock-like flags onto the whole 
auth+assoc procedure, which has certainly helped, but the races do still 
exist, and I don't think that approach is practical: there are simply 
too many points in the sequence where softmac could be 'interrupted' by 
another ESSID/AP call.

But, I'd be absolutely delighted if I'm missing something and you can 
fix it :)

Daniel

