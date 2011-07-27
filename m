From: Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
Subject: strange behaviour of MC7700 with sierra_net
Date: Wed, 27 Jul 2011 16:12:46 +0200
Message-ID: <20110727141246.GC29616@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello everyone,

I am testing the above module on linux-2.6.39.2 which should contain the
latest changes to at least sierra_net.c. Although I am able to bring the
module up and then can get traffic through it, initialisation seems to
be a little picky.

After connecting the module via USB, I get the following final
initialisation message:
| Jul 27 14:01:15 (none) user.info kernel: [166371.982356] sierra_net 1-1:1.7: wwan0: register 'sierra_net' at usb-0000:00:08.2-1, Sierra Wireless USB-to-WWAN Modem, 4a:82:22:b9:05:07

Doing nothing (successfully), the driver starts printing errors after a
while:
| Jul 27 14:02:15 (none) user.err kernel: [166432.201461] sierra_net 1-1:1.7: wwan0: Submit SYNC failed -32
| Jul 27 14:02:15 (none) user.err kernel: [166432.201609] sierra_net 1-1:1.7: wwan0: Send SYNC failed, status -32
| Jul 27 14:02:15 (none) user.err kernel: [166432.205446] sierra_net 1-1:1.7: wwan0: Submit SYNC failed -32
| Jul 27 14:02:15 (none) user.err kernel: [166432.205590] sierra_net 1-1:1.7: wwan0: Send SYNC failed, status -32

The above messages are the first ones to appear (so there's a delay of
60 seconds in between), and they repeat each 2 seconds from then on.
Depending on how I continue at that point, results vary:

a) 'ip link set wwan0 up': setting the interface up stops the above error
   messages from being printed. This worked every time I tried.

b) Sending 'ATZ' on the control-tty: this makes the error-messages
   disappear for about 6 seconds, so two iterations of the sync-timer
   seem to succeed. When I then try to continue initialisation, I usually
   get to 'AT+C' (for AT+CPIN='1234'), then the control-tty dies (neither
   echoing of typed characters, nor feedback from the modem printed).

Trying a) from the state after b) indeed makes the error-messages go
away, but the tty stays dead until I power-cycle the module. Needless to
say, without the control-tty the module is completely useless.

My first thought was that the driver shouldn't try to SYNC while the
interface being down, but apparently sierra_net_send_sync() doesn't get
called anymore after setting the interface up.

So in order to prevent the module from dieing, I need to up the
interface before initialisation via AT-interface.

Another interesting aspect: the above error stays gone after the
interface has been upped once, even if it's brought down right
afterwards without doing anything else. OK, not completely - there needs
to be a little delay in which the interface stays up, but a tenth of a
second was enough.

What else can I do to track this problem down further? What additional
information do you need from me? Any advice is highly appreciated, of
course!

Greetings, Phil
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
