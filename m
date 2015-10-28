From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
Date: Tue, 27 Oct 2015 17:31:37 -0700
Message-ID: <CALx6S373cjOH8dkoEMuO_roCbmvN6-7_JY_qsvSGGesHSt76pg@mail.gmail.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
	<1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
	<CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
	<1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
	<CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
	<1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
	<CALx6S37X_+fEH0-_0DZTuGi4VJ6Xk86zi4wSnDiiH_fkUC3sQw@mail.gmail.com>
	<1445973550.508206.421832305.2B25EDF1@webmail.messagingengine.com>
	<1445982165.537052.421960617.70351761@webmail.messagingengine.com>
	<CALx6S37F236V6YxMhHGbZNCsXxHTTfeXpAXj99GMyA3hnyH5XA@mail.gmail.com>
	<1445991150.565234.422057353.69DCA015@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:33708 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932224AbbJ1Abi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:31:38 -0400
Received: by iodd200 with SMTP id d200so77062704iod.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 17:31:37 -0700 (PDT)
In-Reply-To: <1445991150.565234.422057353.69DCA015@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 27, 2015 at 5:12 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Tue, Oct 27, 2015, at 23:03, Tom Herbert wrote:
>> On Tue, Oct 27, 2015 at 2:42 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > I posted v3 just now. I would like to let David consider it for net
>> > inclusion. We can work on how to lift this limitation then in net-next,
>> > okay? I am currently in favor of a new netdev-feature. What do you
>> > think? Your RFC series could help here, too.
>> >
>> I really do not like the feature flag, it's just a bandaid over the
>> real problem-- in fact my goal is to eliminate NETIF_F_IP{V6}_CSUM and
>> just have NETIF_F_HW_CSUM. I will repost the helper patches, but we
>> really do need to start fixing this stuff in the drivers instead of
>> more hacking in the stack.
>
> It would be great if this is doable but I doubt so. There might be a lot
> of unresponsive driver maintainers and I don't see that we should simply
> eliminate IPv4 csum offloading for those drivers, too. Sometimes it is
> hard to patch drivers without documentation.
>
> I am against lifting restrictions which will have unforeseeable
> consequences for some people (as in partial communication errors) or
> having huge performance drawbacks (as in disabling ipv4 csum offloading,
> too).
>
> I could even imagine this needs to be more configurable as in how many
> extension headers some hardware can process, I fear. One extension
> header might be okay (jumping over a fragmentation header), but two... I
> simply don't know, yet. Maybe there is no problem with hardware at all.
>
Hardware that implement NETIF_F_HW_CSUM (ie. calculate csum based on
start and offset) should have no problem with extension headers. The
plea in skbuff.h for HW vendors to implement that generic algorithm
has been around a long time, but unfortunately a lot of new HW is
still do protocol specific algorithms. Realistically, I can't deploy
extension headers at scale without checksum offload anyway, so this
just degenerates into another instance where poor HW design decisions
limit the protocols and features we're able to deploy in data center.
Oh well...

> I don't really see this series as a hack. ;)
>
> Unluckily it seems we don't get feedback from the hardware about not
> being able to construct a proper checksum, so we cannot even close the
> loop and add code which warns us about misbehaving drivers.
>
> Bye,
> Hannes
