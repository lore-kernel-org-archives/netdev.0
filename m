From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 4/4] phylib: Allow reading and writing a mii bus from
	atomic context.
Date: Tue, 6 Jul 2010 12:09:10 -0500
Message-ID: <AANLkTikEF3B-0JGvqosY5jMaChbpYctOmKW1jJKOWsQE@mail.gmail.com>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45299 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab0GFTHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 15:07:09 -0400
Received: by wwb24 with SMTP id 24so2138591wwb.1
        for <netdev@vger.kernel.org>; Tue, 06 Jul 2010 12:07:08 -0700 (PDT)
In-Reply-To: <a06cf09ed5096bf8f9434d90828adfa70586e936.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 5, 2010 at 12:33 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> In order to support hardware time stamping from a PHY, it is necessary to
> read from the PHY while running in_interrupt(). This patch allows a mii
> bus to operate in an atomic context. An mii_bus driver may declare itself
> capable for this mode. Drivers which do not do this will remain with the
> default that bus operations may sleep.
>
> Before commit 35b5f6b1a82b5c586e0b24c711dc6ba944e88ef1 mii bus
> operations were protected with spin locks. That commit replaced the
> locks with mutexs in order to accommodate i2c buses that need to
> sleep. Thus, this patch restores the original behavior as a run time
> option.


The reason we moved to mutexes was because we didn't want PHY
operations to be done in interrupt context.  They are too slow.  Also,
some MII busses will trigger an interrupt when the operation is done,
which means their driver has the option of sleeping.  As such, it was
an original principle of the PHY lib that MII transactions were not
allowed in interrupt context.  *Certainly*, once you *do* allow MII
transactions in interrupt context, you *cannot* use spin_lock().  You
at least have to use spin_lock_irq[save].

Also, I agree with David's comments, and Grant's.  There's got to be
another way to do this.

Andy
