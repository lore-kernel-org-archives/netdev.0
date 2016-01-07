From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv2 net-next 0/4] MTU changes and other fixes
Date: Thu, 7 Jan 2016 20:49:28 +0000
Message-ID: <20160107204928.0cd91c16@jkicinski-Precision-T1700>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
	<20160107.145750.213741381921685070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:32801 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620AbcAGUte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:49:34 -0500
Received: by mail-wm0-f42.google.com with SMTP id f206so112978569wmf.0
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:49:33 -0800 (PST)
In-Reply-To: <20160107.145750.213741381921685070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Jan 2016 14:57:50 -0500 (EST), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Tue,  5 Jan 2016 11:57:27 +0000
> 
> > v2:
> >  - add first patch (return error on fail).
> 
> You didn't read my feedback, so I'm not going to read your patches.

Assuming that I'm that stupid/disrespectful to you makes me sad.
If you did read the patches you would see the note the first patch
contains...  I assumed it would be easier for you to read it there since
patchwork does not pick up cover letters, my bad.  Here is that note:

I know this is not what you asked for but, since we are using FW
commands to disable/enable RX, even if we allocate all required
resources before freeing old ones we still cannot guarantee that
the reenabling operation will not fail.  Should we refuse to do
MTU changes while the interface is running altogether?

> I said that you need to reorganize how you do the MTU
> changes.
> 
> You _MUST_ try to allocate the resources (queues, data
> structures, whatever) for the new MTU size.
> 
> And if that fails, release those new resources and leave
> the device exactly in the state it was in prior to the MTU
> change call.
> 
> This means you can't use the close/open scheme, I'm explicitly
> telling you not to use that mechanism to change the MTU because
> it can leave the device inoperative if the re-open fails.
> 
> That is completely unexpected behavior for the user.
> 
> The interface must remain up and functioning at the original
> MTU if the MTU change operation fails.  Your code does not
> do this.
> 
> Yes, this is a lot of more work, but that's the only correct
> way to implement this.

I understood you the first time 100% and agree with you 100%.
The situation is the same when configuring number or size of
rings FWIW.  All drivers I've seen ignore this problem and at
most return an error which is stupid and makes users expect
that everything can be configured while interface is up.
For rings it's even more stupid since there is currently no way to
increase number of allocated MSI-X irqs without freeing them first
so the prepare/commit paradigm is basically impossible.
At the extreme one could argue that none of the reconfig should
be allowed unless driver guarantees not to drop frames.

Please respond if you want me to proceed with the preallocation
even though it won't guarantee that the whole operation succeeds
or refusing to do runtime changes is the right way to go.

Sorry I didn't ask the clarifying question right away.
