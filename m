From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v5 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Sat, 26 Apr 2014 12:40:12 +0900
Message-ID: <CAKD1Yr2ekC+dBO+o10Ot4ZMNHg+Qd47WbPHQRbAL6kLHvQ73hA@mail.gmail.com>
References: <1398424172-17530-1-git-send-email-lorenzo@google.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com> <20140425.125155.861435686727308330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David.Laight@aculab.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:60569 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaDZDkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 23:40:32 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so4675247iec.37
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 20:40:32 -0700 (PDT)
In-Reply-To: <20140425.125155.861435686727308330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 1:51 AM, David Miller <davem@davemloft.net> wrote:
> This consolidation makes the code much worse, not better.

This is because the three codepaths differ at the beginning, have a
common middle, and then later on UDP differs because it supports
corking and udplite, and because it does a ip6_dst_store at the end
(which I'd argue l2tp and ping should do as well but...).

I thought reducing duplication was useful, so I sent a patch to factor
out the duplicated code in the middle. The problem is that since the
codepaths also differ at the end, it has to pass in a lot of
parameters in, and pointers to local variables that we need later on.

I see a few ways to proceed here.

1. Refactor all these codepaths into a ip6_datagram_sendmsg that
handles all the code all the way to sending the packet. That would
basically look like udpv6_sendmsg does today, but it would also
support non-UDP sockets. A few more if statements, but no more
duplicated code.
2. Rework raw and l2tp (which are almost identical), into one
function, make ping use that function, and leave UDP alone.
3. Duplicate the cmsg / flowlabel parsing code into ping6.
4. Do nothing and have ping6 not support these APIs.

Thoughts?
