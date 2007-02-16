From: Elad Lahav <elad_lahav@users.sourceforge.net>
Subject: ip_append_page and the socket send buffer
Date: Fri, 16 Feb 2007 15:02:53 -0500
Message-ID: <45D60DED.7050709@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from services110.cs.uwaterloo.ca ([129.97.152.166]:38855 "EHLO
	services110.cs.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946119AbXBPU0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 15:26:19 -0500
Received: from [129.97.75.6] (jethro.cs.uwaterloo.ca [129.97.75.6])
	by services110.cs.uwaterloo.ca (8.13.8/8.13.8) with ESMTP id l1GK2qWM025262
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 15:02:57 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote a function that is equivalent to udp_sendmsg, but uses 
ip_append_page to attach data to an skb. The function is implemented as 
follows:

1. Allocate a page and copy the given data to that page
2. Set up routing and cork the socket
3. Call ip_append_data to create an initial skb (with data length set to 0)
4. Call ip_append_page with the allocated page
5. Call udp_push_pending_frames to send the packet

The function works correctly. Packets are generated and sent as 
expected: this was verified by looking at the packet contents on the 
receiving machine.
However, under load, there is a significant difference in the behaviour 
of udp_sendmsg, compared with my function. The problem is that the 
socket send buffer (wmem_alloc) quickly grows beyond its upper limit 
(which is 131071 by default). This results in numerous failures of 
ip_append_data with EAGAIN, degrading performance considerably.
udp_sendmsg, on the other hand, keeps wmem_alloc in a much smaller range 
under the same load.

Two notes:
1. Modifying the upper limit to 524287 solved the problem completely 
(regardless of the load)
2. The same thing happens with multiple calls to ip_append_data (e.g., 
if I want to copy the data in two sections), so it is not a problem with 
ip_append_page. This leads me o believe that the problem lies with 
Scatter/Gather I/O.

Any thoughts?

Elad
