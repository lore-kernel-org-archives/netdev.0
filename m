From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch net-next 0/2] Fixes for raw diag sockets handling
Date: Wed, 2 Nov 2016 18:45:38 +0300
Message-ID: <20161102154537.GD1852@uranus.lan>
References: <20161102123630.784612652@openvz.org>
 <2a540f59-4495-573c-7dda-0303f1810e6e@cumulusnetworks.com>
 <20161102152900.GC1852@uranus.lan>
 <ec9f3fbe-c95c-6e07-1263-29784d9ba361@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36719 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932311AbcKBPpl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:45:41 -0400
Received: by mail-lf0-f67.google.com with SMTP id o20so1199021lfg.3
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 08:45:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ec9f3fbe-c95c-6e07-1263-29784d9ba361@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 09:36:55AM -0600, David Ahern wrote:
> 
> Limited to raw sockets or are you looking at multiple spec options (dev, address, port)?
> 
> I have not seen issues with tcp or udp. Running:
> 
>     ss -aK 'dev == red' 
> 
> drops all sockets bound to device 'red' (or at least signaling the socket failure for the app to handle):

Limited to raw socket. I didn't modify lookup kernel code but use already existing helpers.
The tcp/udp sockets do use port value in lookup (iirc, don't have code under my hand
at moment), in turn raw lookup uses only net,raw-protocol, src/dst and device index.
In my test case the sokets were unconnected so the have no address but bound to
device and I hit mismatch. Then looking into inet matching code I found this weird
snippet I posted previously.

> 
> root@jessie4:~# ss -ap 'dev == red'
> Netid  State      Recv-Q Send-Q     Local Address:Port                      Peer Address:Port
> udp    UNCONN     0      0                  *%red:12345                                *:*                     users:(("vrf-test",pid=765,fd=3))
> tcp    LISTEN     0      1                  *%red:12345                                *:*                     users:(("vrf-test",pid=766,fd=3))
> tcp    ESTAB      0      0         10.100.1.4%red:ssh                       10.100.1.254:60298                 users:(("sshd",pid=738,fd=3))
> 
> root@jessie4:~# ss -aKp 'dev == red'
> Netid State      Recv-Q Send-Q                      Local Address:Port                                       Peer Address:Port
> udp   UNCONN     0      0                                   *%red:12345                                                 *:*                     users:(("vrf-test",pid=765,fd=3))
> tcp   LISTEN     0      1                                   *%red:12345                                                 *:*                     users:(("vrf-test",pid=766,fd=3))
> tcp   ESTAB      0      0                          10.100.1.4%red:ssh                                        10.100.1.254:60298                 users:(("sshd",pid=738,fd=3))
> 
> root@jessie4:~# ss -ap 'dev == red'
> Netid State      Recv-Q Send-Q                      Local Address:Port                                       Peer Address:Port

	Cyrill
