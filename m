From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fw: [Bug 12014] New: Incorrect Urgent Pointer in outgoing packets
Date: Wed, 12 Nov 2008 23:12:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811122129260.17579@wrl-59.cs.helsinki.fi>
References: <20081112082735.5aa06a15@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: kernel@tesarici.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:32907 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbYKLVMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 16:12:50 -0500
In-Reply-To: <20081112082735.5aa06a15@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Nov 2008, Stephen Hemminger wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12014
> 
>            Summary: Incorrect Urgent Pointer in outgoing packets
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: kernel@tesarici.cz
> 
> 
> Latest working kernel version: ??? (maybe never)
> Earliest failing kernel version: 2.6.27
> Distribution: kernel.org
> Hardware Environment: x86, x86_64
> Software Environment: Oracle, testcase
> Problem Description:
> 
> When urgent mode is initiated using send(..., MSG_OOB), and the current
> outgoing queue is longer than MTU, several packets are sent out with the URG
> flag set.

This urg flag in many segments is expected to happen (the urg pointer
might not point to the current segment but something that will follow)...

> However, the Urgent Pointer field in the TCP header is not updated
> correctly. Instead, it stays the same.

...but I've hard time believing that this true since the the only place
where urg_ptr is assigned is in tcp_output.c and that's done relative
to segments seqno:

	th->urg_ptr = htons(tp->snd_up - tcb->seq);

So if what you say is true, it means that snd_up should advance equally
to the segments seqno. Which means that writes would update it.

> The receiving end interprets this as a new urgent message inserted further in
> the stream, sends multiple SIGURGs to the server application and reads across
> the urgent data. This behaviour is correct.
> 
> Steps to reproduce:
> 
> 1. Initiate a TCP connection
> 2. Fill the outgoing queue with some (normal) data
> 3. Send an urgent message (with MSG_OOB)
> 4. Send some more non-urgent data.

Can you prove that your application is doing what you describe, I suspect 
that you e.g., forget to clear MSG_OOB... Can you strace the program 
please...  Getting a tcpdump at the same time wouldn't hurt either.

I've tried with this exact sequence recently (though after the rewrite of 
urg handling for 2.6.28), and did get a nicely working urg after fixing 
the bug that got introduced by the rewrite and just a single sigurg. It 
seems that I've lost that tcpdump somewhere though. I was using sendfile 
though for the normal data while you might not be doing the same.


-- 
 i.
