From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2] netfilter: fix bad checksum on IPv6 when NAT is performed
Date: Thu, 8 Oct 2015 15:11:50 -0700
Message-ID: <CALx6S34mEeFT_4kBWnEJ2H8P7+FCG_ZpN-CUEgSj4FBH1YeeeQ@mail.gmail.com>
References: <1444141425.14655.341.camel@sakura.staff.proxad.net>
	<1444335587.14655.387.camel@sakura.staff.proxad.net>
	<1444335972.14655.388.camel@sakura.staff.proxad.net>
	<CALx6S37AdH=icFEqXjH5hDJ2O0dkwLEx6_KqpFkoPYF2sr1N_Q@mail.gmail.com>
	<1444339594.14655.392.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	kaber <kaber@trash.net>, pablo@netfilter.org,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35277 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbbJHWLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 18:11:51 -0400
Received: by ioiz6 with SMTP id z6so73506075ioi.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 15:11:50 -0700 (PDT)
In-Reply-To: <1444339594.14655.392.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 2:26 PM, Maxime Bizon <mbizon@freebox.fr> wrote:
>
> On Thu, 2015-10-08 at 14:09 -0700, Tom Herbert wrote:
>
>> I think inet_proto_csum_replace16 should be called here.
>
> inet_proto_csum_replace16() wants a non NULL checksum pointer to update,
> and there is no such thing here.
>
> I could pass a dummy value, but inet_proto_csum_replace16() will do
> twice more work for nothing
>
> or I could modify inet_proto_csum_replace16() to allow a NULL sum
> argument.
>
If I am reading the code correctly, it looks like
inet_proto_csum_replace16 is called from
{tcp,dccp,tcp.udp,udplite}_manip_pkt via l3proto->csum_update which is
a call to nf_nat_ipv6_csum_update for IPv6. So for these protocols
when the transport checksum is updated skb->csum is also correctly
updated. For other protocols or when UDP checksum is zero or for
fragments-- I don't see where skb->csum is being properly updated.
This potentially seems to be a major bug.

I would suggest:
1) Modify the inet_proto_csum_replace* routines to check for NULL
check pointer and and only write it when non-NULL
2) Call l3proto->csum_update from unknown_manip_pkt with check == NULL
3) In udp_manip_pkt call l3proto->csum_update with check = NULL when
UDP checksum is zero
4) For IPv6 fragments call l3proto->csum_update with check = NULL

Tom



> --
> Maxime
>
>
