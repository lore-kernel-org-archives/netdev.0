From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Mon, 27 Nov 2006 16:49:20 +0100
Message-ID: <200611271649.21385.mb@bu3sch.de>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net> <1164535408.21459.3.camel@johannes.berg> <4569C2D0.8080406@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Stefano Brivio <st3@riseup.net>,
	John Linville <linville@tuxdriver.com>,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:31662
	"EHLO vs166246.vserver.de") by vger.kernel.org with ESMTP
	id S1758335AbWK0Pv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 10:51:58 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4569C2D0.8080406@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 26 November 2006 17:37, Daniel Drake wrote:
> Johannes Berg wrote:
> > The problem is that queue disabling isn't refcounted so that a scan that
> > collides with bcm43xx having disabled the queue for calibration might
> > re-enable the queue while bcm43xx is still calibrating.
> 
> I agree with that part. However the other reason for the patch (transmit 
> queue needed for active scanning) is bogus, and the patch introduces a 
> problem where session frames may be transmitted during scanning (using 
> TX queue control avoids that problem).
> 
> > Clearly, this doesn't fully fix the problem because softmac will try to
> > transmit frames during the calibration. Hence, a proper fix would be to
> > not remove the calls to netif_tx_disable but make them go through
> > softmac (ieee80211_tx_disable) to make sure that softmac doesn't try to
> > scan while the queues are disabled, which would fix the aforementioned
> > problem of softmac enabling the queue while the driver needs it disabled
> > for free.
> 
> Stack-level refcounted TX control like this would also be beneficial for 
> zd1211rw, currently we have a semi-ugly implementation inside the driver.
> 
> > Also, for bcm43xx this isn't a problem since the firmware (optionally
> > but we use that afaik) takes care of not transmitting frames that are
> > tagged for a different channel than currently tuned to.
> 
> zd1211 has no such functionality :(
> 
> Michael Buesch wrote:
> > Softmac ignoring
> > this queue-disabled flag is just yet another bug.
> 
> Agreed, but this one isn't going to be fixed any time soon. This was the 
> first point I raised against softmac during early zd1211rw development a 
> long while back.
> 
> I agree with the objectives of this patch but the way I see it is that 
> it trades one bug for another. A proper solution, as suggested by 

Yeah, it trades one fat big bug against a very minor one.
AND!! Currently it's possible to transmit frames while scanning, too.
Don't forget that. Today we have both bugs. With this patch we have only
one left. The only "issue" is that today the "transmit packet while
scanning" bug is less likely to trigger. But it's still possible (because
of disabling not being refcounted).

> Johannes (refcounted stack-level TX control) would not be hard to 
> implement and would solve the bug without introducing another.

So, please do so.
But please apply this one regardless of what you do. ;)
It fixes a nasty kind of bug. With this trivial to fix bug
in the tree I won't look at periodic work "bugs" anymore, that
are reported now and then, because I really thing they are all
caused by this hidden bug.
I also saw a real life bugreport of the asserion in the DMA code
triggering. I didn't know back than how that was possible to happen,
but now I know.

Besides that, what's the problem with some bogus frames being transmitted
throughout the short period of scanning? I don't really see how that
can hurt anyone (besides consuming minor bandwidth).

I already said it in the past. We _have_ to trade one bug for the other
in softmac, because it's buggy by design. And it really doesn't make sense
to fix them all. Well, actually it does. Because fixing all these bugs
would mean replacing softmac by d80211. There's no real other way. ;)

-- 
Greetings Michael.
