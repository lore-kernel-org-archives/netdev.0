From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 12:34:15 -0700
Message-ID: <1472153655.14381.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32943 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751990AbcHYTl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 15:41:29 -0400
Received: by mail-pa0-f53.google.com with SMTP id ti13so19620883pac.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 12:41:29 -0700 (PDT)
In-Reply-To: <1471524527-10029-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> added the main infrastructure that is needed for per-connection
> randomization, in particular writing/reading the on-wire tcp header
> format takes the offset into account so rest of stack can use normal
> tcp_time_stamp (jiffies).
> 
> So only two items are left:
>  - add a tsoffset for request sockets
>  - extend the tcp isn generator to also return another 32bit number
>  in addition to the ISN.
> 
> Re-use of ISN generator also means timestamps are still monotonically
> increasing for same connection quadruple.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  include/linux/tcp.h      |  1 +
>  include/net/secure_seq.h | 13 +++++++++----
>  include/net/tcp.h        |  2 +-
>  net/core/secure_seq.c    | 19 +++++++++++++------
>  net/ipv4/syncookies.c    |  1 +
>  net/ipv4/tcp_input.c     |  7 ++++++-
>  net/ipv4/tcp_ipv4.c      | 30 ++++++++++++++++++++----------
>  net/ipv4/tcp_minisocks.c |  4 +++-
>  net/ipv4/tcp_output.c    |  2 +-
>  net/ipv6/syncookies.c    |  1 +
>  net/ipv6/tcp_ipv6.c      | 28 ++++++++++++++++++----------
>  11 files changed, 74 insertions(+), 34 deletions(-)

It seems tcp_v4_reqsk_send_ack() and tcp_v6_reqsk_send_ack() were not
taken into account.

See commit 20a2b49fc5385 changelog
packetdrill test showing the possible issue if the TS sent on an ACK in
SYN_RECV state is wrong.
