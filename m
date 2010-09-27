From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not equal
 to /proc/sys/net/ipv4/tcp_syn_retries
Date: Mon, 27 Sep 2010 22:00:08 +0200
Message-ID: <1285617608.9983.30.camel@nexus>
References: <20100922020212.d2aaec57.akpm@linux-foundation.org>
 <20100924.200557.229751150.davem@davemloft.net>
 <201009271007.06705.yuri@itinteg.net>
 <20100927.011046.45906887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: yuri@itinteg.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:44194 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755947Ab0I0UAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 16:00:11 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9F00CTS8W9E420@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 27 Sep 2010 22:00:09 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [62.143.253.104])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9F00LOS8W9AJ70@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Mon, 27 Sep 2010 22:00:09 +0200 (CEST)
In-reply-to: <20100927.011046.45906887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I see.

When I read your mail this morning, I was afraid, that this is another
bug in the calculation routine. However, the routine seems ok to me.

The problem is the high discrepancy between the RTO_MIN-based
calculation and TCP_TIMEOUT_INIT-based actual backoff in the SYN-case.

Yuris example did not reveal a conceptually new bug, as the same
behaviour can be observed on pre 2.6.32 kernels at higher values.
I tested wget on a 2.6.26 kernel with timeout values of 300 and above.
All runs did time out after 189 seconds, with the sysctl-value as their
hard limit.

My suggestion for solving this issue:
Introducing a third boolean parameter for retransmits_timed_out()
indicating whether the socket is in SYN state or not. In the SYN case, 
TCP_TIMEOUT_INIT will be used for the calculation instead of
TCP_RTO_MIN.

Is that ok?

Regards
 Damian


Am Montag, den 27.09.2010, 01:10 -0700 schrieb David Miller:
> From: Yuri Chislov <yuri@itinteg.net>
> Date: Mon, 27 Sep 2010 10:07:06 +0200
> 
> >   It looks like the behavior changed in 2.6.32. 2.6.32 and up, uses some 
> > calculation instead of a direct definition of the retries number, that makes it 
> > harder to achieve the necessary system behavior.
> > 
> >  The default behavior of the system changed completely
> > (the old default connect timeout was ~ 180 seconds, while the new one is ~21 
> > sec). 
> > 
> > The new behavior invalidates the kernel documentation and tcp man page.
> > 
> > It's not possible to set a connect timeout > 25 sec in the applications while 
> > using the default values in /proc. 
> > 
> > From my view point is regression.
> 
> Agreed, Damian you have to fix this.
> 
> Otherwise I'm reverting all of your Revert Backoff commits.


