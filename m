From: Martin Kelly <martin@martingkelly.com>
Subject: Question about synchronize_net() in AF_PACKET close()
Date: Tue, 9 Sep 2014 14:44:56 -0700
Message-ID: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:65296 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbaIIVo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 17:44:57 -0400
Received: by mail-qc0-f182.google.com with SMTP id x13so5123184qcv.13
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 14:44:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have been reading the code in net/packet/af_packet.c in order to
optimize the runtime for raw socket close(). In certain cases, close()
can take a long time to return because of the synchronize_net()
overhead. In pursuit of speeding up close(), I have been testing a patch
that defers the socket buffer memory release via call_rcu() in order to
make close() return faster. However, I hit a tricky RCU question for
which I don't have the answer and wanted to know if any RCU/networking
experts could provide some guidance.

In net/packet/af_packet.c, I noticed the following few lines within
packet_release:

         synchronize_net();
         /*
          *      Now the socket is dead. No more input will appear.
          */
         sock_orphan(sk);
         sock->sk = NULL;

>From testing and code analysis, I have found that it appears to be safe
to move sock_orphan and sock->sk = NULL before the synchronize_net()
call like so:

         /*
          *      Now the socket is dead. No more input will appear.
          */
         sock_orphan(sk);
         sock->sk = NULL;
         synchronize_net();

Could some RCU and/or networking experts chime in about whether this a
safe operation? For all I know, there is some deep, fundamental reason
why those lines are in the order they are. On the other hand, perhaps
there is not.

Thanks,
Martin
