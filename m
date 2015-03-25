From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Thu, 26 Mar 2015 00:25:20 +0300
Message-ID: <551327C0.3020303@oracle.com>
References: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com> <1427118726.25985.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427118726.25985.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
On 03/23/2015 04:52 PM, Eric Dumazet wrote:
> On Mon, 2015-03-23 at 13:38 +0300, Alexey Kodanev wrote:
>> Regression introduced by commit 2dc49d1680.
>>
>> tcp_v6_fill_cb() will be called twice if socket's state changes from
>> TCP_TIME_WAIT to TCP_LISTEN. That can result in performance loss and
>> control buffer data corruption because in the second tcp_v6_fill_cb()
>> it's not copying the 'header' anymore, but 'seq', 'end_seq', etc.
>>
>> Reproduced with LTP/tcp_fastopen test and netperf -t TCP_CRR, so when
>> we're constantly closing and opening TCP connections after several
>> requests/responses from client.
>>
>> This can be fixed if we move 'header' union back to the beginning of
>> 'struct tcp_skb_cb' and getting skb->next, TCP_SKB_CB(skb)->seq and
>> TCP_SKB_CB(skb)->end_seq on the same cache line by moving 'cb[48]'
>> closer to 'skb->next', above the *sk and *dev pointers.
>
> NACK.  DO not change sk and dev pointers.
>
> Fix the bug yes, do not change skb layout so radically, it will have
> serious performance impact for other part of the stack.

Did various testing with exactly that change and hadn't found any 
"serious performance impact" on the stack (at least on my configuration).

Alright, what about other part of the patch, is it acceptable?

I came up with one more solution... not so radical :)
We can restore inet6_skb_parm with

     memmove(IP6CB(skb), &TCP_SKB_CB(skb)->header.h6, ...)

in the two places in tcp_v6_rcv(), before xfrm6_policy_check() + 
tcp_v6_fill_cb() are called again:

  static int tcp_v6_rcv(struct sk_buff *skb)
  {
         const struct tcphdr *th;
@@ -1543,6 +1552,7 @@ do_time_wait:
                         inet_twsk_deschedule(tw, &tcp_death_row);
                         inet_twsk_put(tw);
                         sk = sk2;
+                       tcp_v6_restore_cb(skb);
                         goto process;
                 }
                 /* Fall through to ACK */
@@ -1551,6 +1561,7 @@ do_time_wait:
                 tcp_v6_timewait_ack(sk, skb);
                 break;
         case TCP_TW_RST:
+               tcp_v6_restore_cb(skb);
                 goto no_tcp_socket;
         case TCP_TW_SUCCESS:


Thanks,
Alexey
