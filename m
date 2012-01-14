From: Bruce Jones <brucerjones@gmail.com>
Subject: neighbour table overflow errors. leaking neighbours I think
Date: Fri, 13 Jan 2012 17:29:59 -0700
Message-ID: <CAKedQg_qWUgXzsTrQJ0NGoxzKHaQvAnZ2pztzAXVHbq9H4gLRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42419 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228Ab2ANAaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 19:30:00 -0500
Received: by bkuw12 with SMTP id w12so366528bku.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 16:29:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing neighbour table overflow messages so I began exploring
neighbour structure reference counts to try and understand the issue
and see why they are not being reclaimed by the garbage collector.
I'm pretty new to the kernel so have just been sprinkling printks
around to try to understand how this all works.

The box is running 2.6.32.50.  I know that is old, but the current
code for 3.2.1 looks like it is doing basically the same thing.

I am running a test that is blasting the box with lots of bogus tcp
packets.  This results in calls to tcp_v4_send_reset().  That then
calls ip_send_reply() which calls ip_route_output_key() which causes a
new neighbour entry to be allocated.  Then back in ip_send_reply(),
ip_append_data() is called.  I find that this call is failing and
returning ENOBUFS.   The return value from ip_append_data() is not
checked in ip_send_reply() so nothing is cleaned up.  I see that other
calls to ip_append_data() do check the return value and call some
cleanup function.  Those cleanup functions do things like release skb,
dsts, etc.  I image I might be leaking those things too, though I have
only looked at nieghbours.  My question is should there be a similar
function to clean up if ip_append_data fails() in ip_send_reply() or
is there a reason that that particular call doesn't check for errors
when the others do?

Thanks,
Bruce
