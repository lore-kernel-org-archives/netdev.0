From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 42699] New: vmsplice() appears to be returning to caller
 while buffers are still in use
Date: Mon, 30 Jan 2012 19:48:34 -0800
Message-ID: <20120130194834.024a5e5a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39323 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558Ab2AaDsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 22:48:36 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 720CF1410057
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 19:48:36 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oyLq0wR2mJyo for <netdev@vger.kernel.org>;
	Mon, 30 Jan 2012 19:48:35 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 2E4D71410022
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 19:48:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IMHO vmsplice() is like splice() and the caller needs to assume that buffers
are in use. This semantic goes all the way back to the earlier sendfile.

Begin forwarded message:

Date: Tue, 31 Jan 2012 02:26:27 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 42699] New: vmsplice() appears to be returning to caller while buffers are still in use


https://bugzilla.kernel.org/show_bug.cgi?id=42699

           Summary: vmsplice() appears to be returning to caller while
                    buffers are still in use
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.38.6-26.rc1.fc15.i686
          Platform: All
        OS/Version: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: vomlehn@texas.net
        Regression: No


Created an attachment (id=72238)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=72238)
User space code demonstrating the issue into a loopback scenario

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

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
