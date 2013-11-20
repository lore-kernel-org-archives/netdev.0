From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 65271] New: Acceptable RST packets (with seq number in
 window) are ignored in LAST_ACK state (and previously sent data pending
 acknowledgement)
Date: Wed, 20 Nov 2013 12:22:11 -0800
Message-ID: <20131120122211.386c9680@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:61721 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755149Ab3KTUWP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:22:15 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so1580560pad.38
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:22:14 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id hw10sm40010681pbc.24.2013.11.20.12.22.13
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 12:22:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 20 Nov 2013 07:03:59 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 65271] New: Acceptable RST packets (with seq number in window) are ignored in LAST_ACK state (and previously sent data pending acknowledgement)


https://bugzilla.kernel.org/show_bug.cgi?id=65271

            Bug ID: 65271
           Summary: Acceptable RST packets (with seq number in window) are
                    ignored in LAST_ACK state (and previously sent data
                    pending acknowledgement)
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.32.59-0.7-default
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: julien.delacroix@gmail.com
        Regression: No

Created attachment 115271
  --> https://bugzilla.kernel.org/attachment.cgi?id=115271&action=edit
TCP dump showing described scenario

PCAP file of traffic capture is attached.
Note that capture was taken directly on server host, so RST packets definitely
reached the server host.


Here is the flow:

1: Client ---- SYN ----> Server
2: Client <- SYN, ACK -- Server
3: Client ---- ACK ----> Server 
4: Client ---- FIN ----> Server ( server in CLOSE_WAIT state)
5: Client <- PSH, ACK -- Server 
6: Client <- FIN, ACK -- Server ( server in LAST_ACK state)

7: Client ---- RST ----> Server 

Then repeat N times:
    8: Client <- PSH, ACK -- Server 
    9: Client ---RST, ACK -> Server 


Notes:
5: packet contains 3 bytes of data
7: no ACK flag, and sequence number is correct, but RST packet is ignored
8: retransmission of step 5
9: the sequence number is correct as well as the acknowledgment number
(acknowledging data in 5, but not yet FIN in 6), but this RST is again ignored.

>From this point client keeps retransmitting 5, while server keeps answering
with acceptable RST packets.

You can observe this scenario (with 5 retransmissions and 5 RST) in the
attached PCAP file.

-- 
You are receiving this mail because:
You are the assignee for the bug.
