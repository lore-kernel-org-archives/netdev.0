From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/3] inet: get rid of central tcp/dccp listener timer
Date: Thu, 19 Mar 2015 19:26:45 -0700
Message-ID: <CAADnVQKw8rDF9p-bjjr4TKp_5M_XTX-7NcifLqyLXLne2E8uoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34175 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbCTC1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:27:06 -0400
Received: by qcaz10 with SMTP id z10so83440456qca.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:27:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 7:04 PM, Eric Dumazet <edumazet@google.com> wrote:
> One of the major issue for TCP is the SYNACK rtx handling,
> done by inet_csk_reqsk_queue_prune(), fired by the keepalive
> timer of a TCP_LISTEN socket.
>
> This function runs for awful long times, with socket lock held,
> meaning that other cpus needing this lock have to spin for hundred of ms.
>
> SYNACK are sent in huge bursts, likely to cause severe drops anyway.
>
> This model was OK 15 years ago when memory was very tight.
>
> We now can afford to have a timer per request sock.
>
> Timer invocations no longer need to lock the listener,
> and can be run from all cpus in parallel.
>
> With following patch increasing somaxconn width to 32 bits,
> I tested a listener with more than 4 million active request sockets,
> and a steady SYNFLOOD of ~200,000 SYN per second.
> Host was sending ~830,000 SYNACK per second.
>
> This is ~100 times more what we could achieve before this patch.

wow. That is impressive!
I guess timers do scale to millions.
Outstanding.
