From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Why RTM_NEWADDR is sent before FIB update?
Date: Wed, 20 Oct 2010 13:23:10 +0300
Message-ID: <4CBEC30E.2040407@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65275 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab0JTKXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 06:23:16 -0400
Received: by eyx24 with SMTP id 24so724558eyx.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 03:23:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wonder why does devinet.c:__inet_insert_ifa() (and other places)
send first the RTM_NEWADDR notification and only after that calls
inetaddr_chain notifiers?

The reason I'm asking that this gives a race condition to user land:
 1. process A changes IP address
 2. kernel sends RTM_NEWADDR
 3. process B gets notification
 4. process B tries to bind() to new IP but that fails with
EADDRNOTAVAIL because FIB is not yet updated and inet_addr_type() in
inet_bind() does not recognize the IP as local
 5. kernel calls inetaddr_chain notifiers which updates FIB

My understanding was that RTM_NEWADDR was notification about new address
being usable. But it's currently a notification about "new address will
be usable soon".

So should we:
 a) call first notifiers and after that send RTM_NEWADDR?
 b) synchronise inet_bind() with address changes somehow?
 c) live with the bad semantics of the notification in userland
 d) ??

- Timo
