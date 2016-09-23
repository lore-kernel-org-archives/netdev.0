From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in vxlan_build_skb()
Date: Fri, 23 Sep 2016 07:17:03 -0700
Message-ID: <CAKgT0UcoDb5T9xwfAq83cNwU=XAKZxf0TmPiJZQyHFPr82zggg@mail.gmail.com>
References: <20160920190929.57ddaeb0@griffin> <20160922.015242.735026657310158125.davem@davemloft.net>
 <20160922213010.GA32052@oracle.com> <20160923.080618.678103827885223586.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Jiri Benc <jbenc@redhat.com>, Netdev <netdev@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:37403 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759964AbcIWORF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 10:17:05 -0400
Received: by mail-it0-f53.google.com with SMTP id 186so16578174itf.0
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 07:17:04 -0700 (PDT)
In-Reply-To: <20160923.080618.678103827885223586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 5:06 AM, David Miller <davem@davemloft.net> wrote:
> From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Date: Thu, 22 Sep 2016 17:30:10 -0400
>
>> On (09/22/16 01:52), David Miller wrote:
>>> Alternatively we can do Alexander Duyck's trick, by pushing
>>> the headers into the frag list, forcing a pull and realignment
>>> by the next protocol layer.
>>
>> What is the "Alexander Duyck trick" (hints about module or commit id,
>> where this can be found, please)?
>>
>> Is this basically about, e.g., putting the vxlanhdr in its own
>> skb_frag_t, or something else?
>
> Yes, and this way skb_header_pointer() is forced to do a memcpy.

It is something I had proposed on the Rx side of things back in
February when the issue came up in relation to skb parsing.  On
architectures that require NET_IP_ALIGN to be set I had proposed that
we should only pull the outer headers from the page frag, and then
when the time is right we drop the outer headers and pull the inner
headers from the page frag.  That way we can keep all the headers
aligned.

For Tx it all becomes a bit trickier since it would likely require us
to shift the frags up by 1 when we go from outer headers to inner
headers.  One thought I had on that is that we could possibly avoid
having to do any allocation and could just take a reference on the
head_frag if that is what we are using.  Then we just add a 2 byte pad
and resume writing headers in place and the pointer offsets for the
inner headers would remain valid, though they would be past the point
of skb->tail.

- Alex
