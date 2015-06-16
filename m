From: Craig Gallek <kraig@google.com>
Subject: Re: [PATCH iproute2] ss: Include -E option for socket destroy events
Date: Tue, 16 Jun 2015 16:17:18 -0400
Message-ID: <CAEfhGiyVWT_dq3p0E4hhsOtCxOXSXJOzH4qek0dduRYsZHvWug@mail.gmail.com>
References: <1434470578-25796-1-git-send-email-kraig@google.com>
	<1434473455.27504.179.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38324 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757120AbbFPURV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 16:17:21 -0400
Received: by igblz2 with SMTP id lz2so22504529igb.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 13:17:18 -0700 (PDT)
In-Reply-To: <1434473455.27504.179.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am not sure filter works, and apparently some fields are not properly
> reported ? (source port for example looks wrong)
>
> (Note : you probably need to filter in user space, but ss should already
> have support for this)
Ah, good catch on the filter.  It can be fixed by
- if ((err = inet_show_sock(h, NULL, diag_arg->protocol)) < 0)
+ if ((err = inet_show_sock(h, diag_arg->f, diag_arg->protocol)) < 0)
in show_one_inet_sock.  I believe this worked previously because the
filter determined the parameters of the netlink request, effectively
causing the filtering to happen in the kernel.  However, if the
ssfilter defined a parameter that could not be used select sockets via
the netlink request (either because it is a concept not available in
the request structure or because the multicast groups have no request
concept), this user space filtering parameter would be necessary.
Perhaps this was an optimization to not do userspace filtering when we
know we won't need it?  In that case, my updated version of this patch
should probably set the filter parameter of inet_diag_arg to NULL in
the case of a get request and to the actual userspace filter in the
case of monitoring the broadcast data.

The source port issue is a harder problem (related to the kernel
patches, not this one).  The point at which socket information is
broadcast happens after the unhash callback of the appropriate
protocol (called in sk_common_release).  This process sets the source
port of the socket to zero (via __inet_put_port for tcp and
udp_lib_unhash for udp).  If we want the source port to be returned, I
believe the only options are broadcasting earlier in the destruction
path (potentially missing any activity that may happen after that
point) or to store the source port in an additional location for later
use...
