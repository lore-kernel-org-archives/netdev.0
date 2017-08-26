From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Sat, 26 Aug 2017 06:08:47 -0700
Message-ID: <1503752927.11498.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170826015346.24247-1-colona@arista.com>
         <20170826015346.24247-2-colona@arista.com>
         <1503718885.11498.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170826055348.jjzv3n5vao34mkgb@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33144 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbdHZNIu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 09:08:50 -0400
Received: by mail-pg0-f68.google.com with SMTP id q16so2813818pgc.0
        for <netdev@vger.kernel.org>; Sat, 26 Aug 2017 06:08:50 -0700 (PDT)
In-Reply-To: <20170826055348.jjzv3n5vao34mkgb@ycc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-08-26 at 07:53 +0200, Ivan Delalande wrote:

> 
> Sorry, I probably should have detailed my changes. I tried to address
> this by locking the whole socket in the caller, tcp_diag_get_aux, just
> outside of the rcu_read_lock. Would this work here, or do you see a
> better way?
> 

locking the socket is problematic.

It is already done in tcp_get_info() since linux-4.10 and unfortunately
it added unreasonable stall when a socket is flooded with tiny SACK
messages (socket backlog is huge)

People are now making tcp_rmem and tcp_wmem much bigger to allow BBR
flows to reach line rate on very long distance communications.

We are working to make tcp_rack_mark_lost() not having O(N) behavior,
but it is not done yet.


I would stick to RCU, but add sanity checks, so that _if_ the list is
different on the second RCU list traversal, you make sure :

1) We do not try to put more data in the reserved space

2) We memset(ptr, 0, remaining) the remaining space if we found less
entries in the 2nd loop.
