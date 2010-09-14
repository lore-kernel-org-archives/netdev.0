From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [BUG] atl1 causes lockup/reboot on resume from STR
Date: Tue, 14 Sep 2010 16:22:28 +0200
Message-ID: <AANLkTincBZrpHch0rv60YRXW2g=cqgO9vueAafcs=+RQ@mail.gmail.com>
References: <20100911131209.GA3756@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: atl1 development and testing <atl1-devel@lists.sourceforge.net>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:37271 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab0INOW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 10:22:29 -0400
Received: by pwi3 with SMTP id 3so2460831pwi.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 07:22:28 -0700 (PDT)
In-Reply-To: <20100911131209.GA3756@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I've managed to track down the resume bug in the driver, I'm leaving
the full quote for reference:

On Sat, Sep 11, 2010 at 3:12 PM, Luca Tettamanti <kronos.it@gmail.com> wrote:
> Hello,
> I'm having troubles with atl1 driver (notebook is an Asus F3Sa): during
> the resume from S3 the machine either locks up or reboots.
> However I was also able to get a (partial) stack trace involving
> atl1_resume (the rest of the trace scrolled off screen) and a message
> about a recursive fault, followed by a hard lock up.
> If I rmmod atl1 before suspending, the machine comes back fine; I don't
> known whether this is a regression or not, until recently the radeon
> driver didn't survive S3 so I didn't even try suspending to RAM...
> I'm currently running -git current (2.6.36-rc3-00396-gbe6200a), but I've
> gone back till 2.6.32 without any succcess.
> I've no idea on how to debug this, the machine does not have a serial
> port (and netconsole obviously does not help)... help :)

The bug is in atl1_resume, when it clears the interrupt status:
adapter->cmb.cmb->int_stats = 0

adapter->cmb.cmb is initialized (atl1_setup_ring_resources) only when
the interface is brought up so if the interface is not in use (which
is very common for me, since I'm usually on wifi) on resume the kernel
will try to dereference a NULL pointer.
Worse still, the memory pointed by adapter->cmb.cmb is freed by
atl1_free_ring_resources when the interface is brought down, leaving a
stale pointer which is then used in the resume path.
Btw, the same applies to adapter->smb.smb, though it's not used on resume.

The bug should be solved by moving the assignment under "if
(netif_running(netdev))" (assuming netif_running does what I think it
does :P); it also probably a good idea to reset adapter->cmb.cmb and
adapter->smb.smb when the memory is freed anyway.
My notebook has survived a few suspend&resume cycles with and without
wired networking, so far so good :)
If you agree on the proposed fixes I'll send the patches.

Luca
