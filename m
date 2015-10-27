From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/4] ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Wed, 28 Oct 2015 00:53:51 +0100
Message-ID: <1445990031.562267.422041489.195AFF12@webmail.messagingengine.com>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
 <1445982042-3207-2-git-send-email-hannes@stressinduktion.org>
 <CALx6S35udd410V5bEzH2OxE=Qug0fydo10-X6E__gwzeGYCtzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45612 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752138AbbJ0Xxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 19:53:52 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 2362B204A8
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 19:53:52 -0400 (EDT)
In-Reply-To: <CALx6S35udd410V5bEzH2OxE=Qug0fydo10-X6E__gwzeGYCtzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015, at 23:22, Tom Herbert wrote:
> On Tue, Oct 27, 2015 at 2:40 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > We cannot reliable calculate packet size on MSG_MORE corked sockets
> > and thus cannot decide if they are going to be fragmented later on,
> > so better not use CHECKSUM_PARTIAL in the first place.
> >
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Cc: Benjamin Coddington <bcodding@redhat.com>
> > Cc: Tom Herbert <tom@herbertland.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv4/ip_output.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> > index 50e2973..0b02417 100644
> > --- a/net/ipv4/ip_output.c
> > +++ b/net/ipv4/ip_output.c
> > @@ -911,6 +911,7 @@ static int __ip_append_data(struct sock *sk,
> >         if (transhdrlen &&
> >             length + fragheaderlen <= mtu &&
> >             rt->dst.dev->features & NETIF_F_V4_CSUM &&
> > +           !(flags & MSG_MORE) &&
> 
> I still don't understand this. It seems like the effect is to disable
> checksum offload for all UDP messages sent with MSG_MORE flag set.

Exactly.

MSG_MORE/UDP_CORK is a method to append data on the *same* UDP packet.
The probability this packet exceeds the MTU size is rather large, as it
is mostly used to prepare a header and later on send data via
sendpage/sendfile-syscall (IPv6 UDP as no sendpage so it falls back to
normal udpv6_sendmsg path). sendpage is mostly used to send rather large
amount of data because for small amounts regular copying might be faster
(IMHO). So the probability we exceed the MTU is quiet high. This is the
case for NFSv4 which uses this flag over UDP, sending xdr header and
later on the filesystem data directly from the page cache. You will
still have CHECKSUM_PARTIAL capability with sendmsg and multiple iovecs!

Because we cannot simply switch back to CHECKSUM_NONE in the second
write, the first write would not yet have been checksumed, I decided to
exclude MSG_MORE to set up a CHECKSUM_PARTIAL skb.

Because there would be at least some more syscalls between the first
write and the second write (not so in the  NFS example directly from the
kernel but normal user space usage) the data would already be cold in
the caches. So it makes sense to me to checksum the data during copy-in
to trash the CPU caches only once.

The ip6_fragment logic will now catch this case and fragment anyway, but
as I wrote, this is only a last resort.

Hope that makes it more clear.

Bye,
Hannes
