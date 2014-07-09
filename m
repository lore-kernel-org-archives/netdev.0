From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH v2 net-next 0/3] net: sctp:  Add partial MSG_MORE support to
 SCTP
Date: Wed, 9 Jul 2014 08:29:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726E6A3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54407 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753955AbaGIIao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 04:30:44 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26166-08 for <netdev@vger.kernel.org>;
 Wed,  9 Jul 2014 09:30:34 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an application has disabled Nagle then it is almost impossible
to get more than one DATA chunk into an ethernet packet even if
the application has more than one data chunk ready to transmit.

This could be fixed by adding an SCTP_CORK socket option - but
using that requires a lot of system calls.
An alternative is to honour MSG_MORE - using it to mean that
another chunk will be sent soon.
(There isn't much point using MSG_MORE to allow a chunk be extended,
sendv() can be used for fragmented data.)

This is a partial implementation and takes a couple of shortcuts:
1) We only worry about whether MSG_MORE was set on the last send.
   Data sent (by the application) with MSG_MORE unset will only be
   unsent for flow control reasons.
   So if the last send had MSG_MORE set, and an ack opens the window
   then the unsent data won't be sent immediately.

2) If the application doesn't do a send with MSG_MORE unset, then
   buffered data shouldn't be buffered forever.
   Rather than using a timer (as TCP does - which ought to be configurable
   on a per-socket basis) we use the same rules as Nagle and ensure
   that there is always some data outstanding.
   This does mean that the first data chunk on an idle connection
   is send in its own packet even if MSG_MORE is set.

Because of the way Nagle is implemented in SCTP, the change is effectively
just enabling and disabling Nagle prior to each send.

The patch is split into 3 parts:
Parts 1 and 2 do not affect the logic.
1) Splits out the 6-clause condition (all of which must be true)
   for Nagle to delay sends into 6 if statements.
   This allows each condition to have its own comment.
2) Renames an internal return value.
3) Renames the 'nodelay' field to 'tx_delay' and defines separate bits for 'Nagle'
   and MSG_MORE (an extra bit could be used for SCTP_CORKED).
   So 'tx_delay' contains the 'reason(s) why a transmit should be delayed'.
   Save the MSG_MORE bit from the last send in 'tx_delay', apply the same
   delay rules as if Nagle were enabled.

Changes for v2:
Parts 1 and 2 added, constants replaced by defines.

	David
