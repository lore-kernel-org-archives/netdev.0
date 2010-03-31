From: Neil Brown <neilb@suse.de>
Subject: Undefined behaviour of connect(fd, NULL, 0);
Date: Wed, 31 Mar 2010 22:36:37 +1100
Message-ID: <20100331223637.31f5f6ed@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53633 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0CaLgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 07:36:45 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.221.2])
	by mx2.suse.de (Postfix) with ESMTP id D1F2B86391
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 13:36:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Netdev.

We have a customer who was reporting strangely unpredictable behaviour of an
in-house application that used networking.

It called connect on a non-blocking socket and subsequently called
   connect(fd, NULL, 0)

to check if the connection had succeeded.
This would sometime "work" and sometimes close the connection.

Looking at the code (sys_connect, move_addr_to_kernel, inet_stream_connect),
it seems that in this case an uninitialised on-stack address is passed
to inet_stream_connect and it makes a decision based on ->sa_family (which is
uninitialised).

It seems clear that connect(fd, NULL, 0) is the wrong thing to do in this
circumstance, but I think it would be good if it failed consistently rather
than unpredictably.

Would it be appropriate for move_addr_to_kernel to zero out the remainder of
the address?
   memset(kaddr+ulen, 0, MAX_SOCK_ADDR-ulen);
??

Then connect(fd, NULL, 0) would always break the connection.

Thanks,
NeilBrown
