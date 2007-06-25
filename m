From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Mon, 25 Jun 2007 11:28:58 +0200
Message-ID: <467F8ADA.7060702@trash.net>
References: <bug-8668-10286@http.bugzilla.kernel.org/> <20070624222430.8d5b4bd7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63280 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbXFYJ3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 05:29:01 -0400
In-Reply-To: <20070624222430.8d5b4bd7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sun, 24 Jun 2007 21:57:19 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
>>I've been experiencing problems with HTB where the whole machine locks
>>up. This usually happens when the whole qdisc is being removed and
>>occasionally when a leaf is being removed.


It shouldn't happen when leaves are removed, you might be running
into some endless dequeue loops however that got fixed in 2.6.20.

>>Common is that it always happens when some sort of removal is in
>>progress.
>>
>>Console output I have captured is at the end of this message. The same
>>behavior exists from vanilla 2.6.19.7 and above. It is possible that the
>>problem also exist in the earlier versions however I did not go further
>>back.
>>
>>I also believe I have found where the actual problem is:
>>
>>qdisc_destroy() function is always called with dev->queue_lock locked.
>>htb_destroy() function up the stack is using del_timer_sync() call to
>>deactivate HTB qdisc timers. 
> 
> 
> yep, I would agree with that analysis.  del_timer_sync() under a lock is
> quite dangerous in this regard.
> 
> If the (misspelled) comment over htb_destroy() is true, current mainline
> appears still to have this bug.


It is. This patch I had originally planned for 2.6.23 switches HTB
to the generic estimator, which shouldn't suffer from this.

Ranko, can you try if it fixes your timer problem?
