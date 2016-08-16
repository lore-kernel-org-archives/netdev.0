From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 / master]
Date: Tue, 16 Aug 2016 13:19:13 -0700
Message-ID: <CAM_iQpXV-jV0FsAzxt4JYrc6d5LCCLt-5_0uMvM49sV8-+SDDQ@mail.gmail.com>
References: <20160816104551.GA28052@kroah.com> <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34592 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbcHPUTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 16:19:36 -0400
Received: by mail-io0-f194.google.com with SMTP id i199so8348971ioi.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 13:19:36 -0700 (PDT)
In-Reply-To: <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 11:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-08-16 at 08:39 -0700, Eric Dumazet wrote:
>> On Tue, 2016-08-16 at 12:45 +0200, Greg KH wrote:
>> > For some reason Marco's emails can't make it to netdev, so I'm
>> > forwarding this on.  Please cc: him on responses.
>>
>> Thanks for the report Greg and Marco.
>>
>> My first guess is this is caused by
>>
>> d41a69f1d390 tcp: make tcp_sendmsg() aware of socket backlog
>>
>> And a combination of funky sendmsg() flags (like FastOpen)
>>
>> I will look at this problem today.
>>
>
> No, above commit was innocent ;)
>
> It looks like the bug is very old, and following patch would fix it.
> I will submit it formally after few tests.
>
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c00e7d51bb18..7717302cab91 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1523,6 +1523,8 @@ static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unli
>  {
>         if (sk->sk_send_head == skb_unlinked)
>                 sk->sk_send_head = NULL;
> +       if (tcp_sk(sk)->highest_sack == skb_unlinked)
> +               tcp_sk(sk)->highest_sack = NULL;
>  }

Hmm, but from the stack traces it indicates the skb is freed
inside tcp_sendmsg(), which must be:


do_fault:
        if (!skb->len) {
                tcp_unlink_write_queue(skb, sk);
                /* It is the one place in all of TCP, except connection
                 * reset, where we can be unlinking the send_head.
                 */
                tcp_check_send_head(sk, skb);
                sk_wmem_free_skb(sk, skb);
        }

In this case, skb->len == 0 means it is newly allocated skb by
sk_stream_alloc_skb(), so it should not have a chance to be
picked by tp->highest_sack yet b/c the whole function locks
the sock?

I must miss something here.
