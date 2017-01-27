From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Thu, 26 Jan 2017 19:08:44 -0500
Message-ID: <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com> <20170126213742.GE29475@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33063 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752518AbdA0AJ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 19:09:27 -0500
Received: by mail-wm0-f66.google.com with SMTP id r144so54269701wme.0
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 16:09:26 -0800 (PST)
In-Reply-To: <20170126213742.GE29475@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 4:37 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/26/17 15:21), Willem de Bruijn wrote:
>> > If the application has provided fewer than hard_header_len bytes,
>> > dev_validate_header() will zero out the skb->data as needed. This is
>> > acceptable for SOCK_DGRAM/PF_PACKET sockets but in all other cases,
>>
>> This was added not for datagram sockets, but to be able to bypass
>> validation. See the message in commit 2793a23aacbd ("net: validate
>> variable length ll header") and discussion leading up to that patch.
>
> some context, I got inot this patch as a result of  the comments in
>  https://www.mail-archive.com/netdev@vger.kernel.org/msg149031.html
>
>> As David pointed out, this does not handle variable length headers
>> correctly. In link layers that support these, hard_header_len defines
>> the maximum header length. A hard failure on len < hard_header_len
>> would be incorrect.
>
> right, since DaveM's comments, I took a look at the drivers
> that have a ->validate - afaict (from cscope) ax25 is the only
> in-kernel driver that actually passes a ->validate pointer..
> I tried patching ax25 here:
>   http://marc.info/?l=linux-hams&m=148537926422828&w=2
> Still waiting to hear back from that list (which doesnt seem to have
> much traffic so maybe I should time out on it). Does that
> patch make better sense (I'll look up the comments leading up
> to 2793a23aacbd later tonight)

Thanks for the context. ax25_addr_parse doesn't adjust length, it only
verifies that the contents of the variable length header matches
protocol spec. I don't think that it or the .validate callback have to
be modified to return length.

To ensure that skb_headlen(skb) is at least a valid header length even
when CAP_SYS_RAWIO bypasses validation perhaps revise
dev_validate_header to take an additional skb->len parameter and
call skb_put directly from inside that branch.

>> The ->validate callback was added to allow specifying additional
>> constraints on a per protocol basis. This is where a min constraint
>> can be added, e.g., for ethernet.
>>
>> > -       if (!dev_validate_header(dev, skb->data, len)) {
>> > +       newlen = dev_validate_header(dev, skb->data, len);
>> > +       /* As comments above this function indicate, a full L2 header
>> > +        * must be passed to this function, so if newlen > len, bail.
>> > +        */
>> > +       if (newlen < 0 || newlen > len) {
>>
>> If callers only care whether the function returned failure or
>> increased len, which also indicates failure, it is cleaner to leave it
>> a boolean and fail in cases where len < the minimum for that link
>> layer type. No caller actually uses newlen.
>>
>> > +               /* Caller has allocated for copylen in non-paged part of
>> > +                * skb so we should never find newlen > hdrlen
>> > +                */
>> > +               WARN_ON(newlen > hdrlen);
>>
>> WARN_ON_ONCE is safer.
>
> Ok that's easy enough to do.
>
