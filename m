From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 17:41:07 +0100
Message-ID: <1384188067.14334.45.camel@jlt4.sipsolutions.net>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	 <1384160932.14334.6.camel@jlt4.sipsolutions.net>
	 <CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	 <1384184624.14334.31.camel@jlt4.sipsolutions.net>
	 <CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	 (sfid-20131111_172306_225045_4D26036E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Felipe Contreras <felipe.contreras@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:36720 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173Ab3KKQlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:41:14 -0500
In-Reply-To: <CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com> (sfid-20131111_172306_225045_4D26036E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 10:23 -0600, Felipe Contreras wrote:

> The driver is not receiving it at all. I already debugged this:
> 
> http://article.gmane.org/gmane.linux.kernel.wireless.general/115429

Hmm, ok. I pretty much didn't read that thread since some others were
jumping in.

> However, I noticed that once in a very long time, sometimes it does
> receive the corrupted frame and the association continues, and the
> driver code detects it's a corrupted beacon frame.

So how does it treat the corruption?

> > The firmware still
> > shouldn't be filtering anything since it doesn't really look at the
> > beacon information (or maybe it filters based on the DS IE? I'm not
> > entirely sure)
> 
> That's what I thought, but I don't see it at all (only in monitor
> mode, and in ad-hoc).

Yes, that part is odd - that's really the root cause.

I didn't quickly find in the threads what device and firmware you were
using, mind identifying it (again)?

> Nope, it keeps trying forever.
> 
> Oct 13 14:33:15 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
> Oct 13 14:33:15 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
> Oct 13 14:33:15 nysa kernel: wlan0: authenticated
> Oct 13 14:33:15 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
> Oct 13 14:33:18 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
> Oct 13 14:33:18 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
> Oct 13 14:33:18 nysa kernel: wlan0: authenticated
> Oct 13 14:33:18 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
> Oct 13 14:33:22 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
> Oct 13 14:33:22 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
> Oct 13 14:33:22 nysa kernel: wlan0: authenticated
> Oct 13 14:33:22 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
> ...

I see the same behaviour - but it's the supplicant's doing, it is indeed
getting the event that the AP connection failed (timed out):

wlan0: Event ASSOC_TIMED_OUT (15) received


> > This isn't really true like I said above - the kernel can only drop the
> > association, if userspace *insists* then it will try again and again.
> 
> But it's not doing this:
> 
>   ieee80211_destroy_assoc_data(sdata, false);
>   cfg80211_assoc_timeout(sdata->dev, bss);
> 
> Which is what causes the association to stop for me.
> 
> So where exactly in the code is the association being "dropped"?

This does get called in my setup.

> I would rather fix the problem at the two levels, so even if the
> firmware passes the corrupt frames correctly, the driver would still
> somewhat work when there's no beacon frames at all.

Like I said before - trying to work with an AP without beacons at all is
really bad, we shouldn't be doing it. We might not properly react to
radar events, and other things, for example.

johannes
