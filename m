From: Li Er <phoooyb@gmail.com>
Subject: iproute2 ss outputs duplicate tcp sockets info on kernel 3.10.105
Date: Mon, 08 May 2017 18:56:04 -0700 (PDT)
Message-ID: <591121b4.213b9f0a.5aed.b3a8@mx.google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:33942 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdEIB4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 21:56:06 -0400
Received: by mail-ua0-f169.google.com with SMTP id g49so60212548uaa.1
        for <netdev@vger.kernel.org>; Mon, 08 May 2017 18:56:05 -0700 (PDT)
Received: from localhost (148.104-88-23.rdns.scalabledns.com. [23.88.104.148])
        by smtp.gmail.com with ESMTPSA id i33sm1321615uah.16.2017.05.08.18.56.01
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 18:56:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i'm using v4.11.0 release of iproute2 and kernel 3.10.105, simply
running

        $ ss
        Netid  State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
        tcp    CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
        tcp    CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https
        tcp    CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
        tcp    CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https

as you can see, there's one duplicate entry of each  tcp  socket,
however,  if  i  explicitly  specify  tcp socket by adding the -t
switch,

        $ ss -t
        State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port
        CLOSE-WAIT 434    0      10.0.0.1:47931                65.49.18.136:https
        CLOSE-WAIT 432    0      10.0.0.1:47932                65.49.18.136:https

the duplication is gone.

this problem also occurs on  git  master,  but  not  on  iproute2
v4.3.0,  so  i  did  a  git bisect and found out the commit which
caused this is 9f66764e308e9c645b3fb2d1cfbb7fb207eb5de1,  and  by
revert this commit on git master, i.e. removing

                                        err = rtnl_dump_done(rth, h);
                                        if (err < 0)
                                                return -1;

these 3 lines of code of lib/libnetlink.c, the problem is gone.

since  i'm not familiar with the source code, i doubt this is the
right way to solve the problem, what's your suggestions? thanks.
