From: David Stevens <dlstevens@us.ibm.com>
Subject: RFC - VXLAN port range facility
Date: Thu, 30 May 2013 08:40:56 -0400
Message-ID: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:59712 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab3E3MlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 08:41:08 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 30 May 2013 06:41:07 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 48AFF3E40026
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 06:40:48 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4UCf3VN060742
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 06:41:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4UCf1k2004418
	for <netdev@vger.kernel.org>; Thu, 30 May 2013 06:41:01 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,
        I think there are some issues with the port range facility in
VXLAN. Currently, it picks a random port from a wide range (nearly half 
the
port space) and uses that random value as a source port for a generated
UDP packet.
        There are no checks to see if the port is in use by something 
else.

        I can see the value of using a range of ports, but::

1) VXLAN should use its listen port by default
2) VXLAN should actually bind to any source ports it uses, because...
3) VXLAN should never use a port already exclusively in use by something 
else.

As is, VXLAN is not playing well with other UDP users because, for 
example,
it can trigger ICMP errors which will be delivered to some unwitting 
application
whose port it has hijacked.

I think a port ranges may be useful in the context of a small number (say 
10)
of ports that you are actually bound to, so then as part of multi-port 
binding
support. But then a default range of 32K-61K is too large. It then, at 
least,
has the potential to manage ICMP errors triggered by VXLAN.

I think if you want to use port ranges like a range of empheremal ports, 
it's
less useful, but at a minimum it should be a port that you can legally 
bind
to at the time it's in use. Since actually binding/unbinding for each 
packet
would probably be too expensive, I think it'd be better to:

1) use smaller ranges by default
2) actually bind to the entire range on start-up, to prevent other apps 
from using them
3) fail if any in the range is already bound
4) then, with a range of bound ports, select as currently on sends

                                                +-DLS
