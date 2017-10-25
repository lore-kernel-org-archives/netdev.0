From: Jonathan Basseri <misterikkit@google.com>
Subject: Re: [PATCH net] xfrm: Clear sk_dst_cache when applying per-socket policy.
Date: Wed, 25 Oct 2017 09:52:42 -0700
Message-ID: <CABcqWgJ+DY1CHWe3Yst35xOVZqqn5a5w7wdAooeAv2jJ9GmtwA@mail.gmail.com>
References: <20170815222510.21711-1-misterikkit@google.com>
 <20171024011855.8658-1-misterikkit@google.com> <20171024070414.GJ3323@secunet.com>
 <CABcqWgLEQ6j0FDPOQmMpQugPonBoUfKB2sfnP8+bJtYdNS8Viw@mail.gmail.com> <20171025042551.GO3323@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Jakub Sitnicki <jkbs@redhat.com>,
        David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:49031 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751855AbdJYQxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 12:53:04 -0400
Received: by mail-io0-f178.google.com with SMTP id j17so1700865iod.5
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 09:53:04 -0700 (PDT)
In-Reply-To: <20171025042551.GO3323@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 9:25 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Oct 24, 2017 at 09:58:48AM -0700, Jonathan Basseri =F0=9F=98=B6 w=
rote:
>> On Tue, Oct 24, 2017 at 12:04 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> >
>> > On Mon, Oct 23, 2017 at 06:18:55PM -0700, Jonathan Basseri wrote:
>> > > If a socket has a valid dst cache, then xfrm_lookup_route will get
>> > > skipped. However, the cache is not invalidated when applying policy =
to a
>> > > socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
>> > > sometimes ignored on those sockets. (Note: This was broken for IPv4 =
and
>> > > IPv6 at different times.)
>> > >
>> > > This can be demonstrated like so,
>> > > 1. Create UDP socket.
>> > > 2. connect() the socket.
>> > > 3. Apply an outbound XFRM policy to the socket.
>> > > 4. send() data on the socket.
>> > >
>> > > Packets will continue to be sent in the clear instead of matching an
>> > > xfrm or returning a no-match error (EAGAIN). This affects calls to
>> > > send() and not sendto().
>> > >
>> > > Invalidating the sk_dst_cache is necessary to correctly apply xfrm
>> > > policies. Since we do this in xfrm_user_policy(), the sk_lock was
>> > > already acquired in either do_ip_setsockopt() or do_ipv6_setsockopt(=
),
>> > > and we may call __sk_dst_reset().
>> > >
>> > > Performance impact should be negligible, since this code is only cal=
led
>> > > when changing xfrm policy, and only affects the socket in question.
>> > >
>> > > Note: Creating normal XFRM policies should have a similar effect on
>> > > sk_dst_cache entries that match the policy, but that is not fixed in
>> > > this patch.
>> >
>> > I think we don't have this problem with 'normal' policies. When
>> > inserting such a policy, we bump the IPv4/IPv6 genid. This should
>> > invalidate all cached dst entries, no?
>> >
>> That sounds reasonable to me. I had not confirmed the behavior for
>> normal policies, so I was trying to point out that this fix is only
>> for socket policies. Should I modify the commit message?
>
> Yes, please do so. This comment may lead people to the wrong direction.
>
> Thanks!
Thank you for the feedback. Sending a v2 patch with updated message.
