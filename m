From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Sun, 23 Oct 2016 18:51:53 -0700
Message-ID: <CAJmoNQFJhvc4VSdTRWcTZD7T2E1LQ_2BZoMQhZM18jFH8hpQCQ@mail.gmail.com>
References: <1477109243-29520-1-git-send-email-shrijeet@gmail.com> <20161023093808.161535f3@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shrijeet Mukherjee <shrijeet@gmail.com>, mst@redhat.com,
        Tom Herbert <tom@herbertland.com>,
        Netdev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:35368 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752313AbcJXBwf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 21:52:35 -0400
Received: by mail-vk0-f41.google.com with SMTP id q126so160371990vkd.2
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 18:52:34 -0700 (PDT)
In-Reply-To: <20161023093808.161535f3@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 23, 2016 at 9:38 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Overall, I am glad to see XDP support more widely available. Minor stuff
> in implementation.
>
>>
>> +/* this function is not called from the receive_buf path directly as
>> + * we want to use the page model for rx merge buffer and big buffers
>> + * and not use the fast path for driving skb's around
>> + */
>> +static inline u32 do_xdp_prog(struct virtnet_info *vi,
>> +                           struct receive_queue *rq,
>> +                           void *buf, int offset, int len)
>> +{
>
> Do not mark non-trivial static functions as inline. The compiler will
> do it anyway if it thinks it is appropriate.
>
> +static int virtnet_xdp_query(struct net_device *dev)
>
> Use bool here.
>

Ack on the bool.

the inline was my feeble attempt to minimize the overhead in the
"normal" path as currently I need a rcu deref followed by a
conditional. Wanted to ensure that we don't incur a call stack
overhead as well. But I will trust the compiler :)


> @@ -366,13 +420,22 @@ static struct sk_buff *receive_mergeable(struct net_device *dev,
hdr_len;
>
> This parts of the patch is white space creep. I.e other edits you did
> that stayed around.

Will clean up, thought I did .. but something must have come through.

>
> Do you have any performance numbers? Does the receive into pages hurt
> the non XDP performance?
>

No perf yet, on my limited env (laptop) I see higher packet drop rates
using the xdp_drop example, which is no surprise .. but I did not
change anything to recv into pages and instead opted to not support
the skb direct recv at all. And the other two modes were receiving
into pages and then forming skb's which is what I skipped if anything
other than XDP_PASS was returned.

The main goal of this patch was to start that discussion. My v2 patch
rejects the ndo op if neither of rx_mergeable or big_buffers are set.
Does that sound like a good tradeoff ? Don't know enough about who
turns these features off and why.

I can say that virtualbox always has the device features enabled .. so
seems like a good tradeoff ?
