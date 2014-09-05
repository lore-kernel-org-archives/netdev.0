From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: socket: do not validate msg_namelen unless
 msg_name is non-NULL
Date: Fri, 05 Sep 2014 23:26:59 +0200
Message-ID: <1409952419.5306.29.camel@localhost>
References: <CAOxq_8O=8epuyj2+V8RFep2tHVwk06q5gEK1ho0RUSV4GQV0Kw@mail.gmail.com>
	 <1409951660.1177372.164202273.1FB2783A@webmail.messagingengine.com>
	 <CAOxq_8NSGeeJYZP-5Pau+ehhnzrywYJ0Qr4fqrVD3cwQT-2eZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"matthew.leach" <matthew.leach@arm.com>, netdev@vger.kernel.org,
	fenner <fenner@arista.com>, fruggeri <fruggeri@arista.com>,
	travisb <travisb@arista.com>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:43105 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751193AbaIEV1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:27:03 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 899CB20AF6
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2014 17:27:01 -0400 (EDT)
In-Reply-To: <CAOxq_8NSGeeJYZP-5Pau+ehhnzrywYJ0Qr4fqrVD3cwQT-2eZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-09-05 at 14:21 -0700, Ani Sinha wrote:
> On Fri, Sep 5, 2014 at 2:14 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi,
> >
> > On Fri, Sep 5, 2014, at 23:00, Ani Sinha wrote:
> >> Hi guys :
> >>
> >> I am looking at the thread :
> >>
> >>  [PATCH] net: socket: error on a negative msg_namelen
> >>
> >> and the patch that was submitted in that thread :
> >>
> >> commit dbb490b96584d4e958533fb637f08b557f505657
> >> Author: Matthew Leach <matthew.leach@arm.com>
> >> Date:   Tue Mar 11 11:58:27 2014 +0000
> >>
> >>     net: socket: error on a negative msg_namelen
> >>
> >>
> >> According to the linux recvmsg manpage, the caller of recvmsg() may
> >> set msg_name to NULL if he does not care about source address but the
> >> manpage does not say that one has to set msg_namelen to 0 in this
> >> case. Essentially msg_namelen is a don't care if msg_name is NULL. I
> >> think in the kernel, we should validate msg_namelen only if the caller
> >> has also set msg_name and return EINVAL only when msg_name is non-null
> >> and msg_namelen is negative.
> >>
> >> The following patch will do the intended :
> >>
> >>
> >> From ef8e8bd78635ac677f2d4b76fec9990ed1db763c Mon Sep 17 00:00:00 2001
> >> From: Ani Sinha <ani@aristanetworks.com>
> >> Date: Fri, 5 Sep 2014 13:25:22 -0700
> >> Subject:[PATCH] net: socket: do not validate msg_namelen unless
> >> msg_name is non-NULL
> >>
> >> The value of msg_namelen in msghdr structure is irrelevant
> >>  when msg_name is NULL. We should not validate the value
> >>  passed in msg_namelen unless msg_name is non-NULL.
> >>
> >> Signed-off-by: Ani Sinha <ani@aristanetworks.com>
> >> ---
> >>  net/socket.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/net/socket.c b/net/socket.c
> >> index 95ee7d8..a5dfe01 100644
> >> --- a/net/socket.c
> >> +++ b/net/socket.c
> >> @@ -1997,7 +1997,7 @@ static int copy_msghdr_from_user(struct msghdr
> >> *kmsg,
> >>   if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
> >>   return -EFAULT;
> >>
> >> - if (kmsg->msg_namelen < 0)
> >> + if (kmsg->msg_name && kmsg->msg_namelen < 0)
> >>   return -EINVAL;
> >>
> >>   if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
> >
> > The reason for the above mentioned commit was the signed/unsigned
> > conversion by this check. To not trigger any static checker tools, I
> > would suggest to just set kmsg->msg_namelen to zero in case msg_name is
> > NULL.
> 
> I suspect any code that was previously written without taking into
> account this new restriction will now begin to fail. For some of them,
> we may not have the freedom to change the code as per this new
> restrictions. Since the manpage did not enforce this, the developers
> can not be blamed for not setting namelen when passing name with NULL
> value.

Yes, I understood. Same issues with sin6_flowinfo where a specific
setsockopt is needed so the kernel will look at it at all.

If you set msg_namelen = 0 if msg_name == NULL prior to the < 0 check it
should not trigger the return -EINVAL and also we don't run into the
unsafe implicit conversion case when comparing msg_namelen with the
result of the sizeof(). Do you see any problems with that?

Thanks,
Hannes
