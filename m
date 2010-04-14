From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: Re: [RFC] random SYN drops causing connect() delays
Date: Wed, 14 Apr 2010 13:37:17 +0200
Message-ID: <4BC5A8ED.6040908@nets.rwth-aachen.de>
References: <20100412080633.GA27418@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.informatik.RWTH-Aachen.DE ([137.226.12.21]:4638 "EHLO
	mail-i4.informatik.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755115Ab0DNMAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 08:00:14 -0400
In-Reply-To: <20100412080633.GA27418@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
this is very similar to what i have noticed, but up to now I couldn't figure out where it came from. 
Thanks very much for clearing it up!

> I have been tracking down an issue commonly referred to as the 3-sec
> connect() delay. It exists since recent 2.6.x kernels and has never
> been fixed even though it disappeared in recent releases unless
> sched_child_runs_first is set to 1 again.
>
> What happens is that if a client attemps to open many connections to
> a socket with only minimal delay inbetween attemps some SYNs are
> randomly dropped on the server side causing the client to resend after
> the 3 sec TCP timeout and thus causing connect()s to be randomly delayed.
>
> Facts:
>  - Issue can be reproduced over loopback or real networks.
>  - Enabling SO_LINGER on the client side will make the issue disappear!!
>  - While the issue is appearing, the acceptq seems to be overflowing. Both
>    LISTENOVERFLOWS and LISTENDROPS are increasing although not by the exact
>    number of delay occurences. inetdiag reports sk_max_ack_backlog to be 0
>    therefore one possibility that comes to mind is that sk_ack_backlog
>    underflows due to a race.
>  - The issue disappeared in recent kernels, I bisected it down to the following
>    commit:
> 	commit 2bba22c50b06abe9fd0d23933b1e64d35b419262
> 	Author: Mike Galbraith <efault@gmx.de>
> 	Date:   Wed Sep 9 15:41:37 2009 +0200
>
> 	    sched: Turn off child_runs_first
> 	    
> 	    Set child_runs_first default to off.
>
>    Setting kernel.sched_child_runs_first=1 makes the isssue reappear in recent
>    kernels.  This hardens the theory of a race condition.
>  - It looks like that the issue can only be reproduced if the server
>    socket sends out data immediately after the connection has been established
>    but I cannot proof this theory.
