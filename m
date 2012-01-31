From: David VomLehn <dvomlehn@cisco.com>
Subject: vmsplice() appears to be returning to caller while buffers are still
 in use
Date: Tue, 31 Jan 2012 09:50:06 -0800
Message-ID: <20120131175006.GA5283@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:26730 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab2AaR7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:59:48 -0500
Received: from dvomlehn-lnx2.corp.sa.net (dhcp-171-71-47-241.cisco.com [171.71.47.241])
	by mtv-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id q0VHoM00011248
	for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 17:50:22 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Apologies to anyone who has already seen this--didn't realize the mailing
list changed from linux-net to netdev)
Entered in kernel bug tracker as bug #42699.

This problem appears to occur both with sending packets over a network and with
the loopback device, though the specifics vary slightly. The simplest case is a
loopback. When task A sends a big buffer to task B, an sk_buff will be set up
with the mapped buffer as sk_bufs data. The problem is that vmsplice appears to
return to task A at that point, even though task B may not have read any or all
of the data. When task A writes to the buffer, it overwrites the data being
sent to task B, even though task B has not read the data. Thus, task B gets
corrupted data.

The scenario with TCP appears similar, but can be worse because of the
requirement to keep the buffer around for quite a while in order to
retransmitted if necessary.

So long as task A is writing data into the buffer area intended for task B,
this is only a data corruption issue. This may not be the case, however. Should
task A write data intended for some other use into the memory that had been
used for the buffer, that data can leak to task B.

One possible fix would be to add the ability to support sk_buff- or
page-specific notifiers to handle buffer freeing, rather like Ian Campbell's
recent proposal (http://lwn.net/Articles/474791/)

The Bugzilla report has code attached for the loopback case.
-- 
David VL
