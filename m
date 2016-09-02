From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's
 bind address list
Date: Fri, 2 Sep 2016 10:46:57 -0300
Message-ID: <20160902134657.GB11159@localhost.localdomain>
References: <cover.1471605833.git.lucien.xin@gmail.com>
 <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org>
 <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
 <20160822142538.GA10323@hmsreliant.think-freely.org>
 <20160824112338.GB11144@localhost.localdomain>
 <CADvbK_dJbaze7qMsDp-7x0xANsXZX=JfYBNhKOo=2VgbM_ywZg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00EF186@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Xin Long'" <lucien.xin@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        davem <davem@davemloft.net>, Vlad Yasevich <vyasevich@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44558 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752294AbcIBNrB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 09:47:01 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00EF186@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 01:22:05PM +0000, David Laight wrote:
> From: Of Xin Long
> > Sent: 25 August 2016 05:04
> ...
> > But I still prefer the current patch.
> > 1. This issue only happens when server bind 'ANY' addresses.
> >     we don't need to add any new members to struct sctp_sockaddr_entry.
> >     especially if it's a really corner issue,  we fix this as an improvement.
> > 
> > 2. It's yet two issues  here, the duplicate addrs may be from
> >    a) different local NICs.
> >    b) the same one NIC.
> >    It may be unexpectable to filter them in NETDEV_UP/DOWN events.
> > 
> > 3. We check it only when sctp really binds it, just like sctp_do_bind.
> > 
> > What do you think ?
> 
> I want to know what kind of weed the SCTP authors were smoking when they
> decided it was appropriate to put all of a systems IP addresses in the
> cookie and cookie-ack messages.
> 

The 'best effort' one I guess :-)

> It would be nice to have the local addresses selected by the kernel on the
> basis of the remote address - removing the necessity of the application
> to know the current network topology (and IP addresses) in order to bind
> to the correct local addresses before making an outward call.
> 
> This sort of requires that local addresses for a connection are more of a
> property of the routing table than anything else.
> 
> Consider the following network:
> 
>     ----+---------------+----------------------+---------
>         |               |                      |
>      x.x.1.1         x.x.1.2                y.y.1.2
>     10.1.1.1        10.1.1.2               10.1.1.2
>         |               |                      |
>     ----+---------------+                      +---------
> 
> A connection from x.x.1.1 to x.x.1.2 needs to specify the 10.1.1.* addresses,
> but a connection for x.x.1.1 to y.y.1.2 must not.
> 

Exactly. Your example is an exact match with the issue I had last week.
That 10.1.1.2 of yours, may very well be 192.168.122.1 from libvirt.
Then the host may attempt to send the packet to itself, and abort the
association due to that.

I hated this because it took me a big while to find out about it. 

I guess they just didn't predict this situation of duplicated/internal
addresses. Otherwise, the address is there, reachable or not. It's in
the best effort situation.

> I'm not at sure whether it is possible to setup listener(s) on x.x.1.1
> that can accept connections from both x.x.1.2 and y.y.1.2.

You mean without an explicit bind()?

  Marcelo
