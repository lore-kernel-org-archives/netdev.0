From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss >
 window)
Date: Wed, 18 Jan 2017 20:32:51 +0300
Message-ID: <3dbbcda8-ce79-641c-cf3b-21f41c563939@oracle.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39325 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdARR1V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:27:21 -0500
In-Reply-To: <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 01/13/2017 08:07 PM, Alexey Kodanev wrote:

> Hi Eric,
> On 13.01.2017 18:35, Eric Dumazet wrote:
>
>> I would suggest to clamp MSS to half the initial window, but I guess
>> this is impractical since window in SYN/SYNACK are not scaled.

Looks like max_window not correctly initialized for tfo sockets.
On my test machine it has set to '5592320' in tcp_fastopen_create_child().

This diff fixes the issue, the question: is this the right place to do it?

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 4e777a3..33ed508 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -206,6 +206,8 @@ static struct sock *tcp_fastopen_create_child(struct 
sock *sk,
          */
         tp->snd_wnd = ntohs(tcp_hdr(skb)->window);

+       tp->max_window = tp->snd_wnd;
+
         /* Activate the retrans timer so that SYNACK can be retransmitted.
          * The request socket is not added to the ehash
          * because it's been added to the accept queue directly.


Thanks,
Alexey
