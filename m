From: Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
Subject: Re: strange behaviour of MC7700 with sierra_net
Date: Thu, 28 Jul 2011 18:32:02 +0200
Message-ID: <20110728163202.GA20259@orbit.nwl.cc>
References: <20110727141246.GC29616@orbit.nwl.cc>
 <1311795643.17655.13.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311795643.17655.13.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan,

Thanks for the quick reply!

On Wed, Jul 27, 2011 at 02:40:40PM -0500, Dan Williams wrote:
> I wonder if the firmware changed and Sierra hasn't updated the driver
> yet.  I've got a usb306 which also uses sierra_net which doesn't have
> this problem.  It looks like the driver tries to sync with the firmware
> right after binding to the net interface, so that means at least a
> couple of SYNC requests have already happened by the time you start
> getting errors.  My first thought here is simply that the firmware on
> the MC7700 doesn't work like the rest of the devices that sierra_net
> expects, and for that you'd have to get Sierra to weigh in on the
> required changes :(

That's exactly the case. My printf-debugging shows that ~30 calls to
sierra_net_dosync() sycceed before it starts failing. Why the heck does
that work if I set the interface up? When doing so, the driver
immediately receives a whole bunch of restart-messages. Looks
like the number matches the number of successfully sent sync-messages.

This looks like the turned down interface is holding something back, but
looking with usbmon I see communication (this is the point when the
sync-messages start to fail):
| da9ebc40 74.842086 S Co:1:035:0 s 21 00 0000 0007 0004 4 = 00002000
| da9ebc40 74.842971 C Co:1:035:0 0 4 >
| da9ebc40 76.848151 S Co:1:035:0 s 21 00 0000 0007 0004 4 = 00002000
| da9ebc40 76.848835 C Co:1:035:0 -32 4 >

But maybe something should be done in the beginning that's done when the
interface comes up. The capture in that situation is this:
| da9ebc40 88.898257 S Co:1:035:0 s 21 00 0000 0007 0004 4 = 00002000
| da9ebc40 88.898860 C Co:1:035:0 -32 4 >
| dbe29dc0 90.548212 S Ii:1:035:8 -:64 64 <
| da9ebc40 90.548619 S Bi:1:035:9 - 8192 <
| dbe29c40 90.548632 S Bi:1:035:9 - 8192 <
| daab45c0 90.548639 S Bi:1:035:9 - 8192 <
| daac3640 90.548645 S Bi:1:035:9 - 8192 <
| da9cce40 90.548651 S Bi:1:035:9 - 8192 <
| dbe6b7c0 90.548657 S Bi:1:035:9 - 8192 <
| dab0ae40 90.548663 S Bi:1:035:9 - 8192 <
| dbe29640 90.548669 S Bi:1:035:9 - 8192 <
| dbe29340 90.548675 S Bi:1:035:9 - 8192 <
| dbe6b540 90.548681 S Bi:1:035:9 - 8192 <
| dbe6b0c0 90.548688 S Bi:1:035:9 - 8192 <
| dbe29dc0 90.550814 C Ii:1:035:8 0:64 8 = a1010000 07000000
| dbe29dc0 90.550868 S Ii:1:035:8 -:64 64 <
| daac3540 90.550980 S Ci:1:035:0 s a1 01 0000 0007 0400 1024 <
| daac3540 90.551694 C Ci:1:035:0 0 68 = 00406200 53574939 32303058 5f30332e 30302e30 322e3030 41502052 32303332
| dbe29dc0 90.558801 C Ii:1:035:8 0:64 8 = a1010000 07000000
| dbe29dc0 90.558960 S Ii:1:035:8 -:64 64 <
| daac3540 90.559054 S Ci:1:035:0 s a1 01 0000 0007 0400 1024 <
| daac3540 90.559544 C Ci:1:035:0 0 68 = 00406200 53574939 32303058 5f30332e 30302e30 322e3030 41502052 32303332
| dbe29dc0 90.566798 C Ii:1:035:8 0:64 8 = a1010000 07000000

The kernel log output of the above timeframe:
| Jul 28 17:55:36 (none) user.debug kernel: [266833.170570] usb 1-1: sierra_net_send_sync
| Jul 28 17:55:36 (none) user.info kernel: [266833.170590] sierra_net_send_sync: netif is not running
| Jul 28 17:55:36 (none) user.err kernel: [266833.171515] sierra_net 1-1:1.7: wwan0: Submit SYNC failed -32
| Jul 28 17:55:36 (none) user.err kernel: [266833.174713] sierra_net 1-1:1.7: wwan0: Send SYNC failed, status -32
| Jul 28 17:55:38 (none) user.debug kernel: [266834.823421] usb 1-1: sierra_net_status
| Jul 28 17:55:38 (none) user.debug kernel: [266834.824316] usb 1-1: sierra_net_kevent: Received status message, 0044 bytes
| Jul 28 17:55:38 (none) user.debug kernel: [266834.824475] usb 1-1: Restart reported: 0, stopping sync timer
| Jul 28 17:55:38 (none) user.debug kernel: [266834.831400] usb 1-1: sierra_net_status
| Jul 28 17:55:38 (none) user.debug kernel: [266834.832268] usb 1-1: sierra_net_kevent: Received status message, 0044 bytes
| Jul 28 17:55:38 (none) user.debug kernel: [266834.832426] usb 1-1: Restart reported: 0, stopping sync timer

> Since the MC7700 is an LTE module it's 100% likely the firmware is
> different, or at least significantly rebased, from the existing Sierra
> HSPA/EVDO parts that use sierra_net and thus I wouldn't necessarily
> expect it to work out of the box.

Well, it's obviously not that bad. Setting wwan0 up as a workaround,
everything's quite fine. Also, if I'm fast enough initialising the modem
via AT-commands before the control-tty dies, I can dial in even with
wwan0 being down, set it up and receive an address via DHCP. 

Since the MC7700 has the same USB product and vendor IDs as any other
direct-IP device (1199:68a3), Sierra may indeed have meant this device
to act identical to the other ones. Or their driver-developers are just
a little bit masochistic. ;)

Hopefully Elina Pasheva can provide some helpful insights here.

Greetings, Phil
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
