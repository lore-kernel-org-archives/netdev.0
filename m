From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [net-next 2/3] ip_gre: fix erspan tunnel mtu calculation
Date: Wed, 11 Oct 2017 18:46:00 +0800
Message-ID: <CADvbK_dkc=-ByQw2z=14cW2g6bhoyWLTxuV8wW1nbqjo3jAAgA@mail.gmail.com>
References: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
 <1507582067-36718-3-git-send-email-u9012063@gmail.com> <CADvbK_eu=FJ5H3cf399UNBqAAq8bpRaDODwHHrNPkq47RXkzsA@mail.gmail.com>
 <CALDO+SZhdSXQB-n_o006_fOGnmz1j99uJBAOVixD0YCFgKnVFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:55253 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751888AbdJKKqB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:46:01 -0400
Received: by mail-qt0-f178.google.com with SMTP id z19so3724768qtg.11
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 03:46:01 -0700 (PDT)
In-Reply-To: <CALDO+SZhdSXQB-n_o006_fOGnmz1j99uJBAOVixD0YCFgKnVFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 8:59 PM, William Tu <u9012063@gmail.com> wrote:
>>> @@ -1242,14 +1241,14 @@ static int erspan_tunnel_init(struct net_device *dev)
>>>         struct ip_tunnel *tunnel = netdev_priv(dev);
>>>         int t_hlen;
>>>
>>> -       tunnel->tun_hlen = 8;
>>> +       tunnel->tun_hlen = ERSPAN_GREHDR_LEN;
>>>         tunnel->parms.iph.protocol = IPPROTO_GRE;
>>>         tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen +
>>>                        sizeof(struct erspanhdr);
>>>         t_hlen = tunnel->hlen + sizeof(struct iphdr);
>>>
>>> -       dev->needed_headroom = LL_MAX_HEADER + t_hlen + 4;
>>> -       dev->mtu = ETH_DATA_LEN - t_hlen - 4;
>>> +       dev->needed_headroom = LL_MAX_HEADER + t_hlen;
>>> +       dev->mtu = ETH_DATA_LEN - t_hlen;
>> 1. I guess '+4-4' stuff was copied from __gre_tunnel_init(), I'm thinking
>> it may be there for some reason.
>>
> I traced back to
> 4565e9919cda ("gre: Setup and TX path for gre/UDP foo-over-udp encapsulation")
> and I think '+4-4' is there for GRE base header length.
>
> Since now we do
>     dev->mtu = ETH_DATA_LEN - t_hlen;
> and t_hlen already counts the the gre base header + optional header
> len, I think it's not needed.

okay. thanks.

>
>> 2. 'dev->needed_headroom =' and 'dev->mtu =' are really needed ?
>> As I've seen both will be updated in .newlink:
>> ipgre_newlink() -> ip_tunnel_newlink() -> ip_tunnel_bind_dev()
>>
> right, I also find both values gets overwritten by
> ip_tunnel_bind_dev() using my test cases. Maybe we can remove them?

It's there just in case that there is no lower dev found, but
ip_tunnel_newlink/create always updates dev->mtu even if
there is no lower dev found.

let's leave as it is for now, ipgre may just not be sure ip_tunnel_xxx would
do it when no lower dev found.
