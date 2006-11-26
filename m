From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] softmac: remove netif_tx_disable when scanning
Date: Sun, 26 Nov 2006 11:37:36 -0500
Message-ID: <4569C2D0.8080406@gentoo.org>
References: <4568DCEB.mailLLK1Z24PM@lwfinger.net>	
	<45691273.9090803@gentoo.org>
	<1164535408.21459.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
In-Reply-To: <1164535408.21459.3.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> The problem is that queue disabling isn't refcounted so that a scan that
> collides with bcm43xx having disabled the queue for calibration might
> re-enable the queue while bcm43xx is still calibrating.

I agree with that part. However the other reason for the patch (transmit 
queue needed for active scanning) is bogus, and the patch introduces a 
problem where session frames may be transmitted during scanning (using 
TX queue control avoids that problem).

> Clearly, this doesn't fully fix the problem because softmac will try to
> transmit frames during the calibration. Hence, a proper fix would be to
> not remove the calls to netif_tx_disable but make them go through
> softmac (ieee80211_tx_disable) to make sure that softmac doesn't try to
> scan while the queues are disabled, which would fix the aforementioned
> problem of softmac enabling the queue while the driver needs it disabled
> for free.

Stack-level refcounted TX control like this would also be beneficial for 
zd1211rw, currently we have a semi-ugly implementation inside the driver.

> Also, for bcm43xx this isn't a problem since the firmware (optionally
> but we use that afaik) takes care of not transmitting frames that are
> tagged for a different channel than currently tuned to.

zd1211 has no such functionality :(

Michael Buesch wrote:
> Softmac ignoring
> this queue-disabled flag is just yet another bug.

Agreed, but this one isn't going to be fixed any time soon. This was the 
first point I raised against softmac during early zd1211rw development a 
long while back.

I agree with the objectives of this patch but the way I see it is that 
it trades one bug for another. A proper solution, as suggested by 
Johannes (refcounted stack-level TX control) would not be hard to 
implement and would solve the bug without introducing another.

Daniel
