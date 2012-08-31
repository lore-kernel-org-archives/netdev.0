From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] tcp: TCP Fast Open Server - header & support
 functions
Date: Fri, 31 Aug 2012 07:21:07 -0700
Message-ID: <1346422867.2591.47.camel@edumazet-glaptop>
References: <1346369948-1722-1-git-send-email-hkchu@google.com>
	 <1346369948-1722-2-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ycheng@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu, therbert@google.com,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44033 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2HaOWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 10:22:48 -0400
Received: by dady13 with SMTP id y13so1996232dad.19
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2012 07:22:47 -0700 (PDT)
In-Reply-To: <1346369948-1722-2-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-30 at 16:39 -0700, H.K. Jerry Chu wrote:
> From: Jerry Chu <hkchu@google.com>
> 
> This patch adds all the necessary data structure and support
> functions to implement TFO server side. It also documents a number
> of flags for the sysctl_tcp_fastopen knob, and adds a few Linux
> extension MIBs.
> 
> In addition, it includes the following:
> 
> 1. a new TCP_FASTOPEN socket option an application must call to
> supply a max backlog allowed in order to enable TFO on its listener.
> 
> 2. A number of key data structures:
> "fastopen_rsk" in tcp_sock - for a big socket to access its
> request_sock for retransmission and ack processing purpose. It is
> non-NULL iff 3WHS not completed.
> 
> "fastopenq" in request_sock_queue - points to a per Fast Open
> listener data structure "fastopen_queue" to keep track of qlen (# of
> outstanding Fast Open requests) and max_qlen, among other things.
> 
> "listener" in tcp_request_sock - to point to the original listener
> for book-keeping purpose, i.e., to maintain qlen against max_qlen
> as part of defense against IP spoofing attack.
> 
> 3. various data structure and functions, many in tcp_fastopen.c, to
> support server side Fast Open cookie operations, including
> /proc/sys/net/ipv4/tcp_fastopen_key to allow manual rekeying.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>  Documentation/networking/ip-sysctl.txt |   29 ++++++++---
>  include/linux/snmp.h                   |    4 ++
>  include/linux/tcp.h                    |   45 ++++++++++++++++-
>  include/net/request_sock.h             |   36 ++++++++++++++
>  include/net/tcp.h                      |   46 +++++++++++++++---
>  net/ipv4/proc.c                        |    4 ++
>  net/ipv4/sysctl_net_ipv4.c             |   45 +++++++++++++++++
>  net/ipv4/tcp_fastopen.c                |   83 +++++++++++++++++++++++++++++++-
>  net/ipv4/tcp_input.c                   |    4 +-
>  9 files changed, 276 insertions(+), 20 deletions(-)

There are two very small points that can be addressed later, or in next
iteration if there is one.

static inline bool fastopen_cookie_present(struct tcp_fastopen_cookie *foc)
{
       return (foc)->len != -1;
}

should be :

static inline bool fastopen_cookie_present(const struct tcp_fastopen_cookie *foc)
{
       return foc->len != -1;
}

And we should add a BUILD_BUG_ON(TCP_FASTOPEN_KEY_LENGTH != 4*sizeof(u32));
in proc_tcp_fastopen_key().

Acked-by: Eric Dumazet <edumazet@google.com>
