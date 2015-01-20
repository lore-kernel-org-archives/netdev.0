From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/3] skbuff: Add skb_list_linearize()
Date: Tue, 20 Jan 2015 14:46:19 -0800
Message-ID: <CALnjE+pDdvcSdQV83J_DLJwmcM8OsC94xDnH2mSSsxDCNnsztg@mail.gmail.com>
References: <1421785543-19823-1-git-send-email-pshelar@nicira.com>
	<1421790195.4832.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:42049 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752006AbbATWqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 17:46:20 -0500
Received: by mail-ig0-f182.google.com with SMTP id z20so9967901igj.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 14:46:20 -0800 (PST)
In-Reply-To: <1421790195.4832.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 1:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-01-20 at 12:25 -0800, Pravin B Shelar wrote:
>> similar to skb_linearize(), this API takes skb list as arg and
>> linearize it into one big skb. STT driver patch will use this.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
...
>> @@ -2329,6 +2329,41 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
>>  }
>>  EXPORT_SYMBOL(skb_copy_and_csum_dev);
>>
>> +int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask)
>> +{
>> +     struct sk_buff *skb;
>> +     int tlen = 0;
>> +     int err;
>> +
>> +     err = skb_linearize(head);
>> +     if (err)
>> +             return err;
>> +
>> +     skb = head->next;
>> +     while (skb) {
>> +             tlen += skb->len;
>> +             skb = skb->next;
>> +     }
>> +     err = pskb_expand_head(head, 0, tlen, gfp_mask);
>> +     if (err)
>> +             return err;
>> +
>> +     skb = head->next;
>> +     while (skb) {
>> +             err = skb_copy_bits(skb, 0, skb_tail_pointer(head), skb->len);
>> +             if (err)
>> +                     return err;
>> +             head->tail += skb->len;
>> +             skb = skb->next;
>> +     }
>> +     kfree_skb_list(head->next);
>> +     head->next = NULL;
>> +     head->len += tlen;
>> +     head->truesize = SKB_TRUESIZE(skb_end_offset(head));
>
> This is buggy : skb can have a destructor, like sock_wfree()
>

In current use-case it is never called for skb which is tied to
socket. But I agree it need to be fixed. I can call skb_orphan() to
fix it.

Thanks.
