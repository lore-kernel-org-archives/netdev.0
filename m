From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 10:00:42 -0700
Message-ID: <1458925242.6473.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAEfhGizvwATcG--OH_xhrV-c1t11ie-vNibJY8kqFAq3GX9upw@mail.gmail.com>
	 <20160325162114.GA72479@ast-mbp.thefacebook.com>
	 <CAEfhGiy-V0da6LQ_SY+E4u7S49n5dEpVaKiOOo103ijQtPujAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35379 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcCYRAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 13:00:45 -0400
Received: by mail-pf0-f180.google.com with SMTP id n5so86057721pfn.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 10:00:45 -0700 (PDT)
In-Reply-To: <CAEfhGiy-V0da6LQ_SY+E4u7S49n5dEpVaKiOOo103ijQtPujAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-25 at 12:31 -0400, Craig Gallek wrote:

> I believe the issue here is that closing the listen sockets will drop
> any connections that are in the listen queue but have not been
> accepted yet.  In the case of reuseport, you could in theory drain
> those queues into the non-closed sockets, but that probably has some
> interesting consequences...

It is more complicated than this.

Ideally, no TCP connection should be dropped during a server change.

The idea is to let old program running as long as :
1) It has established TCP sessions
2) Some SYN_RECV pseudo requests are still around

Once 3WHS completes for these SYN_RECV, children are queued into
listener accept queues.

But the idea is to direct all new SYN packets to the 'new' process and
its listeners. (New SYN_RECV should be created on behalf on the new
listeners only)


In some environments, the listeners are simply transfered via FD
passing, from the 'old process' to the new one.
