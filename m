From: =?UTF-8?Q?Juan_Jos=C3=A9_Echevarria?=
        <juanjose.echevarria@gmail.com>
Subject: SYN cookies: validity range
Date: Wed, 7 Jun 2017 00:12:36 +0200
Message-ID: <CACBbrCDcgxDirTvrM39o5ZX8gmr2O3WJhkxyCzwN0LMLhcdwKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:36345 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdFFWMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 18:12:37 -0400
Received: by mail-vk0-f54.google.com with SMTP id p85so86946811vkd.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 15:12:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is my first post, hope I'm not using the mailing list wrongly.

As proposed in an old thread
(https://www.spinics.net/lists/netdev/msg329144.html), when we send
SYN cookies and then exit this mode, tcp_synq_no_recent_overflow()
returns false if cookies are received until 2 minutes later
(TCP_SYNCOOKIE_VALID).

Despite the rest of the SYN cookie code allows ACKs be aged up to 2
minutes, we should not accept cookies for that long if the SYN cookie
episode is over. As we dont keep state, an ACK with a previous cookie
will be assumed as a valid third packet of a TCP connection.

In this scenario, the validity range allows a client not to wait for a
SYN-ACK most of the time. A client could intentionally send the
required number of packets to fill the queue (eg, with a spoofed IP
address). Then, it could open a connection, collect the cookie, and
reuse it to speed up the opening of successive connections for 2
minutes. This cheat -specially attractive in low-end devices, where
the SYN queue is rather small- may behave similarly to TCP Fast Open,
but without the awareness of the server.

Decreasing TCP_SYNCOOKIE_VALID would prevent the replay of cookies.
