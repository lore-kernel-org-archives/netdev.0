From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Mon, 23 Mar 2015 06:52:06 -0700
Message-ID: <1427118726.25985.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-23 at 13:38 +0300, Alexey Kodanev wrote:
> Regression introduced by commit 2dc49d1680.
> 
> tcp_v6_fill_cb() will be called twice if socket's state changes from
> TCP_TIME_WAIT to TCP_LISTEN. That can result in performance loss and
> control buffer data corruption because in the second tcp_v6_fill_cb()
> it's not copying the 'header' anymore, but 'seq', 'end_seq', etc.
> 
> Reproduced with LTP/tcp_fastopen test and netperf -t TCP_CRR, so when
> we're constantly closing and opening TCP connections after several
> requests/responses from client.
> 
> This can be fixed if we move 'header' union back to the beginning of
> 'struct tcp_skb_cb' and getting skb->next, TCP_SKB_CB(skb)->seq and
> TCP_SKB_CB(skb)->end_seq on the same cache line by moving 'cb[48]'
> closer to 'skb->next', above the *sk and *dev pointers.


NACK.  DO not change sk and dev pointers.

Fix the bug yes, do not change skb layout so radically, it will have
serious performance impact for other part of the stack.
