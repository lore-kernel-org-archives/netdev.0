From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Sep 2014 19:30:31 +0400
Message-ID: <541EEF17.7020806@msgid.tls.msk.ru>
References: <52BDE9DC.5040206@msgid.tls.msk.ru> <52BE9CF9.7030305@broadcom.com> <52BEC2F6.7010505@msgid.tls.msk.ru> <52D4FC8B.6090301@msgid.tls.msk.ru> <52F925A9.1030707@msgid.tls.msk.ru> <53526124.6050407@msgid.tls.msk.ru> <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com> <53FCB2A3.1050605@msgid.tls.msk.ru> <53FCFE1A.3060508@broadcom.com> <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:51394 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbaIUPae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2014 11:30:34 -0400
In-Reply-To: <54169D4F.2090607@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

15.09.2014 12:03, Arend van Spriel wrote:
> Hi Michael,

Hello again!  I'm sorry for the long delay, I'll describe what happens
in a moment.


> Did you have any opportunity to create a log file. Got a question from
> someone else who got bad bcm4313 behaviour after a certain upgrade. Did
> you have the same experience?

No, I didn't have that opportunity.  As I mentioned before, the second
laptop where I faced the same problem with brcm4313 wasn't mine, and I
had to return it back to its owner, so I had nothing to test things on
for quite some time.

However, a few days ago, after I was searching for a good notebook of my
own (obviously without broadcom parts ;), another friend of mine sent me
a gift - a new laptop.  But this one has even worse wifi card (from linux
support PoV anyway) -- it is mediatek (formely ralink) MT7630e card.

After trying to build drivers for it for a while, I gave up, and an idea
come to me to swap this mediatek card with that broadcom 4313 card.
And surprizingly it worked - both laptops accepted the "new" cards and
I verified both works.  So now the mediatek from my laptop works in
my friend's hp envy, and his brcm4313 works on my new asus.

So from now on I again have some playground for this stuff.

As I mentioned before, the card appears to work fine, at least at
first, I wasn't able to trigger any lockups/stalls before.  Now
I can't trigger any stalls either, again, at least easily.

However, I found a 100%-reliable - so far - reproducer for the
initial behavour I described in the very first message in this
thread, which soon be one year old...

Namely, after resume, the card does not work. ARP works, ping and
DNS sometimes/somewhat work, inital TCP connection establisment
works, but eg http download does not work, it stalls almost
immediately.

Also during resume, I see the following kernel messages:

[  202.607767] CPU: 2 PID: 2706 Comm: kworker/u9:0 Not tainted 3.16-amd64 #3.16.3
[  202.607769] Hardware name: ASUSTeK COMPUTER INC. X200LA/X200LA, BIOS X200LA.204 06/16/2014
[  202.607776] Workqueue: hci0 hci_power_on [bluetooth]
[  202.607778]  0000000000000000 0000000000000009
[  202.607780] Restarting tasks ...  ffffffff814208bf 0000000000000000
[  202.607783]  ffffffff8104c926 ffff8800d5843d08 ffff8800d052f300 ffff8801189ea940
[  202.607786]  ffff8800d5843d00 0000000000000000 ffffffff8131c0d9 0000000000000000
[  202.607790] Call Trace:
[  202.607797]  [<ffffffff814208bf>] ? dump_stack+0x41/0x51
[  202.607802]  [<ffffffff8104c926>] ? warn_slowpath_common+0x86/0xb0
[  202.607807]  [<ffffffff8131c0d9>] ? _request_firmware+0x439/0xa20
[  202.607812]  [<ffffffff8131c7a5>] ? request_firmware+0x35/0x60
[  202.607816]  [<ffffffffa0121780>] ? btusb_setup_bcm_patchram+0x70/0x3f0 [btusb]
[  202.607823]  [<ffffffffa0a0618d>] ? hci_dev_do_open+0x24d/0x8c0 [bluetooth]
[  202.607829]  [<ffffffff81082ade>] ? enqueue_task_fair+0x32e/0xce0
[  202.607834]  [<ffffffff8100bbb5>] ? sched_clock+0x5/0x10
[  202.607839]  [<ffffffff8107832b>] ? update_rq_clock+0x3b/0xd0
[  202.607846]  [<ffffffffa0a06818>] ? hci_power_on+0x18/0x120 [bluetooth]
[  202.607877]  [<ffffffff8106cad0>] ? kthread_freezable_should_stop+0x60/0x60
[  202.607881]  [<ffffffff81425dbc>] ? ret_from_fork+0x7c/0xb0
[  202.607885]  [<ffffffff8106cad0>] ? kthread_freezable_should_stop+0x60/0x60
[  202.607887] ---[ end trace da2a7947839f7b1e ]---
[  202.607891] bluetooth hci0: firmware: brcm/BCM20702A0-0a5c-21e3.hcd will not be loaded
[  202.607894] Bluetooth: hci0: BCM: patch brcm/BCM20702A0-0a5c-21e3.hcd not found

I dunno how related these are -- bluetooth is another function of
this card.


http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-20140921.dat.gz -- this
is a trace collected after resuming from suspend-to-disk, after the above
kernel message, and doing this:

  stop network-manager
  rmmod brcmsmac brcmutil
  modpobe brcmsmac
  trace-cmd record brcmsmac:* &
  start network-manager
  wget http://<ip-over-wifi>/some-random-file
  <Ctrl+C>

wget did received some series of packets, with pauses in-between, but overal
the progress looks like it is stalled completely, there's almost no progress.

This is 3.16.3 kernel.  Note that reloading module after resume is not
sufficient (I'll try reloading whole brcm stack).

Thank you for your interest!

/mjt
