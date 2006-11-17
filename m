From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 19:13:10 -0600
Message-ID: <455D0CA6.3030604@lwfinger.net>
References: <455B63EC.8070704@madrabbit.org> <455BFC47.3020006@madrabbit.org>
	<455CAB2F.1060709@lwfinger.net> <200611162016.42095.mb@bu3sch.de>
	<455CBDD7.6000507@madrabbit.org> <455CE8FB.2000803@lwfinger.net>
	<ae017dc00611161526v6bcbddc2ve2c7e10963d25c3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
In-Reply-To: <ae017dc00611161526v6bcbddc2ve2c7e10963d25c3b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Ray Lee wrote:
> First off, thanks for all your help.
> 
> Second off,
> 
> On 11/16/06, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
>> Ray Lee wrote:
>> >
>> > If I could figure out a way to make it repeatable, I'd happily do a 
>> blind
>> > bisect.
> [...]
>> > I'm open to suggestions on how to make the problem trigger more than 
>> once
>> > every two days...
>>
>> I don't know what might be causing the lock problems. I'm more 
>> concerned with the NETDEV WATCHDOG
>> timeouts. AFAIK, you are the only one still reporting this error. On 
>> my system, I get an occasional
>> MAC suspend failure, sometimes followed by an BCM43xx_IRQ_XMIT_ERROR.
> 
> Last time I had trouble with 2.6.18-rcX, I wasn't the only one, just
> the only one reporting it. Can you tell me why reverting the likely
> culprit isn't an option? rc6 is out, and Linus is really pushing to
> finalize 2.6.19 here soon.
> 
>>  From what I read in your post, the timeouts happen a lot more often 
>> than once every two days. Once
>> we get those fixed, then we can concentrate on the locking.
> 
> It's becoming clear that I wasn't so clear :-). No, it doesn't happen
> more than once every two (three, now) days. I'm saying that it's only
> happened twice, as once the first timeout message starts, the timeouts
> don't stop short of a reboot.
> 
> Or, in other words, it happened occasionally under 2.6.19-rc3, but
> fixed itself. Under 2.6.19-rc5, it's happened less frequently (maybe),
> but once it starts, it goes on solid until I reboot the computer.
> Until I reboot, the laptop is fully unusable as things start hanging
> on the rtnl_lock (X, apparently).
> 
> Please see http://madrabbit.org/~ray/messages.gz for the
> /var/log/messages to understand what I mean by that. (Though, that was
> captured before I'd rebuilt the module with debugging, unfortunately.
> Regardless, it may help clarify what I mean here.)
> 
> So all the NETDEV WATCHDOG timeouts other than the first (of each of
> the two events) appear to be bogus, or side effects of rtnl_lock being
> held after the first time, and not clearing out.
> 
> <thinks...> Maybe I've got the culprit backward here. Perhaps
> something else in my system is locking on rtnl_lock, and bcm43xx can't
> acquire it? Could the NETDEV WATCHDOG timeouts be a side effect of
> someone acquiring and not releasing the rtnl_lock()? Is that possible?
> (ie, would it cause the effect I'm seeing?)

It certainly could. Please remove the new line in the hunk below for 
drivers/net/wireless/bcm43xx/bcm43xx_main.c:

@@ -3569,6 +3586,7 @@ int bcm43xx_select_wireless_core(struct
         bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
         bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
         bcm43xx_security_init(bcm);
+       drain_txstatus_queue(bcm);
         ieee80211softmac_start(bcm->net_dev);

This will effectively remove _ALL_ bcm43xx patches between 2.6.19-rc3 and -rc6. If the rtnl_locks 
still occur, bcm43xx is not causing them. The other patches are not involved for your system.

Larry
