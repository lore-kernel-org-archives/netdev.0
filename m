From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 09:37:14 -0500
Message-ID: <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com> <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:35153 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754879AbdA0Oh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 09:37:56 -0500
Received: by mail-wj0-f194.google.com with SMTP id i7so6098711wjf.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 06:37:56 -0800 (PST)
In-Reply-To: <20170127020836.GH29475@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 9:08 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/26/17 19:08), Willem de Bruijn wrote:
>>
>> Thanks for the context. ax25_addr_parse doesn't adjust length, it only
>> verifies that the contents of the variable length header matches
>> protocol spec. I don't think that it or the .validate callback have to
>> be modified to return length.
>
> Yes, I noticed that too, but my reading of ax25_addr_parse
> was that it checks to see that a sane L2 header has been
> passed in, and if that (sane-header) is the case, it
> returns pointer to the start of data. Thus the returned
> (non-null) pointer minus start should tell you the "real"
> header length- is my understanding correct?

Yes. ax25_validate_header reads up to len bytes to parse the header,
so it is smaller than or equal to len or the function returns false.
It is not necessary to check whether the return value exceeds the len
passed to dev_validate_header.

The immediate problem you were facing is that dev_validate_header
accepts values smaller than hard_header_len even for protocols with
fixed header lengths.

This is a consequence of that CAP_SYS_RAWIO branch. Without it,
dev_validate_header would have correctly dropped your packet. That
branch was added because there are tests that explicitly test bad
input. Ideally, it would be behind sysctl and static key, but doing so
might start failing active tests.

See also this discussion

  Sending short raw packets using sendmsg() broke
  https://www.mail-archive.com/netdev@vger.kernel.org/msg99081.html
