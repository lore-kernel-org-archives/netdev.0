From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we need MSG_SENDPAGE_NOTLAST?
Date: Sat, 06 May 2017 10:13:57 -0700
Message-ID: <1494090837.7796.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <VI1PR0502MB2957F149F915013F6813559FD4EA0@VI1PR0502MB2957.eurprd05.prod.outlook.com>
         <1493922776.7796.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <VI1PR0502MB29571B2B852BF681FC1DB9B0D4E80@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        tls-fpga-sw-dev <tls-fpga-sw-dev@mellanox.com>,
        Dave Watson <davejwatson@fb.com>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35494 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751157AbdEFROA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 13:14:00 -0400
Received: by mail-pg0-f43.google.com with SMTP id o3so16444905pgn.2
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 10:14:00 -0700 (PDT)
In-Reply-To: <VI1PR0502MB29571B2B852BF681FC1DB9B0D4E80@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not top-post on netdev, please.


On Sat, 2017-05-06 at 05:46 +0000, Ilya Lesokhin wrote:
> I don't follow.
> Why can't splice use MSG_MORE for the individual pages?
> Why does tcp_sendpage need to know if the MORE indicator is coming from the user or from splice?
> 
> I also don't understand your comment about partial writes.
> 

Make sure that sendpage() wont end up with a stall on TCP, if the socket
has not enough room to store the 16 pages provided by splice() or
sendpage()

Just use MSG_SENDPAGE_NOTLAST and be happy.


> Thanks,
> Ilya
> 
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> > Sent: Thursday, May 4, 2017 9:33 PM
> > To: Ilya Lesokhin <ilyal@mellanox.com>
> > Cc: netdev@vger.kernel.org; tls-fpga-sw-dev <tls-fpga-sw-
> > dev@mellanox.com>; Dave Watson <davejwatson@fb.com>
> > Subject: Re: Why do we need MSG_SENDPAGE_NOTLAST?
> > 
> > On Thu, 2017-05-04 at 17:03 +0000, Ilya Lesokhin wrote:
> > > I don't understand the need for MSG_SENDPAGE_NOTLAST and I'm hoping
> > > someone can enlighten me.
> > >
> > > According to commit 35f9c09 ('tcp: tcp_sendpages() should call
> > > tcp_push() once'):
> > > "We need to call tcp_flush() at the end of the last page processed in
> > > tcp_sendpages(), or else transmits can be deferred and future sends
> > > stall."
> > >
> > > I don't understand why we need to differentiate between the user
> > > setting MSG_MORE
> > > and splice indicating that more data is going to be sent.
> > > if the user passed MSG_MORE and didn't push any extra data, isn't it
> > > the users fault?
> > > Do we need it because poorly written applications were broken when
> > > MSG_MORE was added to tcp_sendpage? Or is there a deeper reason?
> > >
> > 
> > The answer lies to how splice() is working.
> > 
> > User can issue one splice without MSG_MORE semantic, right ?
> > 
> > Still, we want an implicit MORE behavior for all individual pages, but
> > the last one.
> > 
> > 
> > > The reason I'm asking is that we are working on a kernel TLS
> > > implementation
> > > and I would like to know if we can coalesce multiple tls_sendpage
> > > calls with MSG_MORE into a single
> > > tls record or whether we must push out the record as soon as
> > > MSG_SENDPAGE_NOTLAST is cleared?
> > 
> > Make sure you handle partial writes (you want to coalesce 10 pages, but
> > stack will only take 5 of them)
> > 
> > 
> 
