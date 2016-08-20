From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's
 bind address list
Date: Sat, 20 Aug 2016 14:41:01 +0800
Message-ID: <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com> <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35947 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbcHTGqt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 02:46:49 -0400
Received: by mail-qk0-f181.google.com with SMTP id l2so58146497qkf.3
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 23:46:49 -0700 (PDT)
In-Reply-To: <20160819175007.GB3578@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ah, I see what you're doing.  Ok, this makes some sense, at least on the receive
> side, when you get a cookie unpacked and modify the remote peers address list,
> it makes sense to check for duplicates.  On the local side however, I would,
> instead of checking it when the list gets copied, I'd check it when the master
> list gets updated (in the NETDEV_UP event notifier for the local address list,

I was thinking about to check it in the NETDEV_UP, yes it can make the
master list has no duplicated addresses.  But what if two same addresses
events come, and they come from different NICs (though I can't point  out
the valid use case), then we filter there.

Later, sctp may receive one  NETDEV_DOWN event,sctp will remove that
addr in the master list, but it shouldn't have been removed, as another local
NIC still has that addr.

That's why I have to leave the master alone, just check when they are really
being bind to asoc addr list.

> and the sctp_add_bind_addr function for the endpoint address list).  That way

As to the endpoint address list, sctp has different process for binding
the address 'ANY' from assoc address list (note that this issue only
happened in binding the address 'ANY'). instead of  copying the master
address list to  the endpoint, it only adds address 'ANY' to the EP
address list. Only when starting a connection and create the assoc, it
copy the master address list to ASOC.

So no need to do it in sctp_add_bind_addr for endpoint address list.
Besides, sctp_add_bind_addr  is supposed to be called after checking
the duplicated address(I got it from sctp_do_bind()). :-)

> you can keep that nested for loop out of the send path on the local system.
>
>
