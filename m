From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 11:47:46 +0100
Message-ID: <87fw1qhn71.fsf@nemi.mork.no>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60952 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462Ab3AXKsz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 05:48:55 -0500
In-Reply-To: <1359023152-32576-1-git-send-email-bjorn@mork.no>
 (=?utf-8?Q?=22Bj=C3=B8rn?= Mork"'s
	message of "Thu, 24 Jan 2013 11:25:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> A device sending 0 length frames as fast as it can has been
> observed killing the host system due to the resulting memory
> pressure. We handle the done queue as fast as we can, so
> if this queue is filling up then that is an indication that we
> are under too heavy pressure.  Refusing further allocations
> until the done queue is handled prevents the buggy device
> from taking the system down.
>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> Hello Oliver,
>
> The MBIM firmware for the Sierra Wireless MC7710 is a nice source
> of "interesting" device issues.  One of the uglier ones is that
> it under certain conditions will start flooding us with frames
> having length 0 as fast as it can.  And that is pretty fast...
>
> My older laptop dies immediately under this.  It just cannot keep
> up with the infinite allocations usbnet will do when the done
> queue first starts growing beyond reason.
>
> I really do not have a clue how to handle this problem, but this
> patch seems to do the job for me without affecting normal devices.
> The queue limit is just a number which Works For Me, leaving the
> system running with the buggy device and not kicking in under
> normal load.
>
> What do you think? Is there some other way this should be solved?


To illustrate the problem, this the start and stop debug output for suc=
h
a buggy device session *with* the RFC patch applied:

Jan 24 11:16:23 nemi kernel: [ 3187.624164] qmi_wwan 8-4:1.8 wwan0: ope=
n: enable queueing (rx 60, tx 60) mtu 1500 simple framing
Jan 24 11:16:38 nemi kernel: [ 3202.536921] qmi_wwan 8-4:1.8 wwan0: sto=
p stats: rx/tx 1/11, errs 738980/0

I believe the stats tell the full story...

I do not have any logs without the throttling patch, as that takes down
everything on my laptop including the ahci driver and keyboard.  Not
even the magic sysrq is working then.

If anyone is interested in the full debug log (211KB compressed) from
the above session, then I've put it on
http://www.mork.no/~bjorn/usbnet-zero-packet-fix.log.gz


It is mostly full of "rx length 0" lines, but with an occasional
sequence of

Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1025) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1026) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1027) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1028) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1029) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1030) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1031) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1032) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1033) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: rx =
length 0
Jan 24 11:16:23 nemi kernel: [ 3187.682669] qmi_wwan 8-4:1.8 wwan0: don=
e queue filling up (1034) - throttling
Jan 24 11:16:23 nemi kernel: [ 3187.697826] qmi_wwan 8-4:1.8 wwan0: rxq=
len 0 --> 10


showing that the throttling is kicking in and doing its job.



Bj=C3=B8rn
