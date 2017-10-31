From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix tcp_mtu_probe() vs highest_sack
Date: Mon, 30 Oct 2017 23:21:42 -0700
Message-ID: <1509430902.3828.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170921014620.GA20906@castle>
         <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
         <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com>
         <2325466.Xo6SG5M5hd@natalenko.name>
         <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
         <20171026020724.bgobtktvcpkhco4h@ast-mbp>
         <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
         <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com>
         <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
         <20171031061750.al6gjwa7hknefwfy@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Oleksandr Natalenko <oleksandr@natalenko.name>,
        Roman Gushchin <guro@fb.com>, netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Lawrence Brakmo <brakmo@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:52691 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752216AbdJaGVo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 02:21:44 -0400
Received: by mail-io0-f195.google.com with SMTP id f20so32583928ioj.9
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 23:21:44 -0700 (PDT)
In-Reply-To: <20171031061750.al6gjwa7hknefwfy@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-30 at 23:17 -0700, Alexei Starovoitov wrote:
> On Mon, Oct 30, 2017 at 11:08:20PM -0700, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Based on SNMP values provided by Roman, Yuchung made the observation
> > that some crashes in tcp_sacktag_walk() might be caused by MTU probing.
> > 
> > Looking at tcp_mtu_probe(), I found that when a new skb was placed
> > in front of the write queue, we were not updating tcp highest sack.
> > 
> > If one skb is freed because all its content was copied to the new skb
> > (for MTU probing), then tp->highest_sack could point to a now freed skb.
> > 
> > Bad things would then happen, including infinite loops.
> > 
> > This patch renames tcp_highest_sack_combine() and uses it
> > from tcp_mtu_probe() to fix the bug.
> > 
> > Note that I also removed one test against tp->sacked_out,
> > since we want to replace tp->highest_sack regardless of whatever
> > condition, since keeping a stale pointer to freed skb is a recipe
> > for disaster.
> > 
> > Fixes: a47e5a988a57 ("[TCP]: Convert highest_sack to sk_buff to allow direct access")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> > Reported-by: Roman Gushchin <guro@fb.com>
> > Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
> 
> Thanks!
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
> wow. a bug from 2007.
> Any idea why it only started to bite us in 4.11 ?
> 
> It's not trivial for us to reproduce it, but we will definitely
> test the patch as soon as we can.
> Do you have packet drill test or something for easy repro?

I tried to cook a packetdrill test but could not trigger the issue.

When have you started to enable mtu probing ?

(Linux defaults to not enabling it )
