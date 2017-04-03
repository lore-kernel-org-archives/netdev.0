From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Mon, 03 Apr 2017 05:24:53 -0700
Message-ID: <1491222293.10124.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170402114545.GA31804@breakpoint.cc>
         <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
         <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
         <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491153972.10124.14.camel@edumazet-glaptop3.roam.corp.google.com>
         <35bef48734458fd995d9d4080da5db22@nuclearcat.com>
         <1491221343.10124.16.camel@edumazet-glaptop3.roam.corp.google.com>
         <194a53b80a3cd7fcc360ecf4e1dbf692@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36076 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752143AbdDCMY4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 08:24:56 -0400
In-Reply-To: <194a53b80a3cd7fcc360ecf4e1dbf692@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-03 at 15:14 +0300, Denys Fedoryshchenko wrote:
> On 2017-04-03 15:09, Eric Dumazet wrote:
> > On Mon, 2017-04-03 at 11:10 +0300, Denys Fedoryshchenko wrote:
> > 
> >> I modified patch a little as:
> >> if (th->doff * 4 < sizeof(_tcph)) {
> >>   par->hotdrop = true;
> >>   WARN_ON_ONCE(!tcpinfo->option);
> >>   return false;
> >> }
> >> 
> >> And it did triggered WARN once at morning, and didn't hit KASAN. I 
> >> will
> >> run for a while more, to see if it is ok, and then if stable, will try
> >> to enable SFQ again.
> > 
> > Excellent news !
> > We will post an official fix today, thanks a lot for this detective 
> > work
> > Denys.
> I am not sure it is finally fixed, maybe we need test more?
> I'm doing extensive tests today with identical configuration (i had to 
> run fifo, because customer cannot afford anymore outages). I've dded sfq 
> now different way, and identical config i will run after 3 hours approx.

I did not say this bug fix would be the last one.

But this check is definitely needed, otherwise xt_TCPMSS can iterate
whole memory, and either crash or scramble two bytes in memory, that do
not belong to the frame at all.

If tcp_hdrlen is 0 (can happen if tcph->doff is 0)

Then :

for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i +=
optlen(opt, i)) {

Can look at 4 GB of memory, until it finds a 0x02, 0x04  sequence.

It can also loop forever in some cases, depending on memory content.
