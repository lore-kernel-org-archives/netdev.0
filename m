From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH 1/2] tcp: setup random timestamp offset when write_seq
 already set
Date: Sat, 18 Feb 2017 12:19:04 +0300
Message-ID: <309e3579-8cdb-ca96-f995-5629fa132e5c@oracle.com>
References: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21511 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750850AbdBRJT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 04:19:27 -0500
In-Reply-To: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On 18.02.2017 3:56, Alexey Kodanev wrote:
> Found that when random offset enabled (default) TCP client can
> still start new connections with and without random offsets. Later,
> if server does active close and re-use sockets in TIME-WAIT state,
> new SYN from client can be rejected on PAWS check inside
> tcp_timewait_state_process().
>

Actually, on second thoughts, we can just copy tsoffset from tw socket:

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 89a95da..f40a61d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -126,6 +126,7 @@ int tcp_twsk_unique(struct sock *sk, struct sock
*sktw, void *twp)
                        tp->write_seq = 1;
                tp->rx_opt.ts_recent       = tcptw->tw_ts_recent;
                tp->rx_opt.ts_recent_stamp = tcptw->tw_ts_recent_stamp;
+               tp->tsoffset               = tcptw->tw_ts_offset;
                sock_hold(sktw);
                return 1;
        }

Will test this and send a new version.

Thanks,
Alexey
