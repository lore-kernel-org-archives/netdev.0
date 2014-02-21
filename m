From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Deliver skbs to intermediate interfaces, when using cascaded
 rx-handlers
Date: Fri, 21 Feb 2014 11:01:58 +0100
Message-ID: <20140221100158.GA19594@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:40126 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbaBUKC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:02:26 -0500
Received: by mail-la0-f49.google.com with SMTP id y1so2155720lam.36
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 02:02:25 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id th3sm7111274lbb.11.2014.02.21.02.02.23
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 02:02:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a system with the following configuration:

   * eth0 is a regular Ethernet MAC, connected to a hardware switch.
   * port[1-4] are the in-kernel representation of the switch.
   * team0 is a regular team-interface which bonds port1 and port2.

      +-------+
      | team0 |
      +---+---+
          |
     +----+----+
     |         |
 +---+---+ +---+---+ +-------+ +-------+
 | port1 | | port2 | | port3 | | port4 | 
 +---+---+ +---+---+ +---+---+ +---+---+
     |         |         |         |
     +---------+----+----+---------+
                    |
                +---+---+
                | eth0  |
                +-------+

Both the switch and the team driver attaches rx-handlers to their
lower layers. The problem is that team expects LACP frames that
are intercepted by team0, to also be delivered to the port interface
by __netif_receive_skb_core (in the final iteration of the registered
protocols). However in this case, when two rx-handlers are cascaded,
the skb will be delivered to eth0, since that is the original device
(orig_dev).

There are a few ways this can be solved as far as i can see:

   1. Introduce a new rx-handler return code that specifies that
   skb->dev has been altered, like RX_HANDLER_ANOTHER, and that we
   also want to change orig_dev to this new device.

   2. Change the switch driver to return RX_HANDLER_CONSUMED and then
   queue the skb all over again, though I am afraid that this will eat
   some cycles.

   3. Keep track of all traversed interfaces and change the final
   protocol iteration to deliver the skb to all intermediate devices.

What would be your suggestion?

-- 
Thanks
 - wkz
