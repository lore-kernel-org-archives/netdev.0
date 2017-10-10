From: William Tu <u9012063@gmail.com>
Subject: Re: [net-next 2/3] ip_gre: fix erspan tunnel mtu calculation
Date: Tue, 10 Oct 2017 05:59:53 -0700
Message-ID: <CALDO+SZhdSXQB-n_o006_fOGnmz1j99uJBAOVixD0YCFgKnVFw@mail.gmail.com>
References: <1507582067-36718-1-git-send-email-u9012063@gmail.com>
 <1507582067-36718-3-git-send-email-u9012063@gmail.com> <CADvbK_eu=FJ5H3cf399UNBqAAq8bpRaDODwHHrNPkq47RXkzsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: therbert@google.com, davem <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:47413 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdJJNAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 09:00:34 -0400
Received: by mail-it0-f42.google.com with SMTP id p138so2361338itp.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 06:00:34 -0700 (PDT)
In-Reply-To: <CADvbK_eu=FJ5H3cf399UNBqAAq8bpRaDODwHHrNPkq47RXkzsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -1242,14 +1241,14 @@ static int erspan_tunnel_init(struct net_device *dev)
>>         struct ip_tunnel *tunnel = netdev_priv(dev);
>>         int t_hlen;
>>
>> -       tunnel->tun_hlen = 8;
>> +       tunnel->tun_hlen = ERSPAN_GREHDR_LEN;
>>         tunnel->parms.iph.protocol = IPPROTO_GRE;
>>         tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen +
>>                        sizeof(struct erspanhdr);
>>         t_hlen = tunnel->hlen + sizeof(struct iphdr);
>>
>> -       dev->needed_headroom = LL_MAX_HEADER + t_hlen + 4;
>> -       dev->mtu = ETH_DATA_LEN - t_hlen - 4;
>> +       dev->needed_headroom = LL_MAX_HEADER + t_hlen;
>> +       dev->mtu = ETH_DATA_LEN - t_hlen;
> 1. I guess '+4-4' stuff was copied from __gre_tunnel_init(), I'm thinking
> it may be there for some reason.
>
I traced back to
4565e9919cda ("gre: Setup and TX path for gre/UDP foo-over-udp encapsulation")
and I think '+4-4' is there for GRE base header length.

Since now we do
    dev->mtu = ETH_DATA_LEN - t_hlen;
and t_hlen already counts the the gre base header + optional header
len, I think it's not needed.

> 2. 'dev->needed_headroom =' and 'dev->mtu =' are really needed ?
> As I've seen both will be updated in .newlink:
> ipgre_newlink() -> ip_tunnel_newlink() -> ip_tunnel_bind_dev()
>
right, I also find both values gets overwritten by
ip_tunnel_bind_dev() using my test cases. Maybe we can remove them?

Thanks
William
