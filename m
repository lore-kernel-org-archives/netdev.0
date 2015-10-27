From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 3/4] ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked
 sockets
Date: Tue, 27 Oct 2015 22:42:45 +0100
Message-ID: <1445982165.537052.421960617.70351761@webmail.messagingengine.com>
References: <1445958135-19805-1-git-send-email-hannes@stressinduktion.org>
 <1445958135-19805-4-git-send-email-hannes@stressinduktion.org>
 <CALx6S37qAxOxYRxxFQGR4P2r937yCnCqdASHV0qsi2UPj675iQ@mail.gmail.com>
 <1445964249.1414779.421671593.5D1C863C@webmail.messagingengine.com>
 <CALx6S34m5jEDMUtVZpsU05Z8ydXAYFoVBAsbAQF=sUc5h0TLiQ@mail.gmail.com>
 <1445970551.497935.421785961.521DBDF0@webmail.messagingengine.com>
 <CALx6S37X_+fEH0-_0DZTuGi4VJ6Xk86zi4wSnDiiH_fkUC3sQw@mail.gmail.com>
 <1445973550.508206.421832305.2B25EDF1@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:51166 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932068AbbJ0Vmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 17:42:46 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 350EF209DF
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 17:42:46 -0400 (EDT)
In-Reply-To: <1445973550.508206.421832305.2B25EDF1@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Tue, Oct 27, 2015, at 20:19, Hannes Frederic Sowa wrote:
> On Tue, Oct 27, 2015, at 19:37, Tom Herbert wrote:
> > On Tue, Oct 27, 2015 at 11:29 AM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> > > On Tue, Oct 27, 2015, at 18:32, Tom Herbert wrote:
> > >> On Tue, Oct 27, 2015 at 9:44 AM, Hannes Frederic Sowa
> > >> <hannes@stressinduktion.org> wrote:
> > >> >
> > >> >
> > >> > On Tue, Oct 27, 2015, at 17:36, Tom Herbert wrote:> > -               if
> > >> > (cork->length + length > maxnonfragsize - headersize) {
> > >> >> > +       if (cork->length + length > maxnonfragsize - headersize) {
> > >> >> >  emsgsize:
> > >> >> > -                       ipv6_local_error(sk, EMSGSIZE, fl6,
> > >> >> > -                                        mtu - headersize +
> > >> >> > -                                        sizeof(struct ipv6hdr));
> > >> >> > -                       return -EMSGSIZE;
> > >> >> > -               }
> > >> >> > +               ipv6_local_error(sk, EMSGSIZE, fl6,
> > >> >> > +                                mtu - headersize +
> > >> >> > +                                sizeof(struct ipv6hdr));
> > >> >> > +               return -EMSGSIZE;
> > >> >> >         }
> > >> >> >
> > >> >> > +       /* CHECKSUM_PARTIAL only with no extension headers and when
> > >> >>
> > >> >> No, please don't do this. CHECKSUM_PARTIAL should work with extension
> > >> >> headers as defined, so this is just disabling otherwise valid and
> > >> >> useful functionality. If (some) drivers have problems with this they
> > >> >> need to be identified and fixed.
> > >> >
> > >> > I don't understand. The old code already didn't allow the use of
> > >> > opt_flen with CHECKSUM_PARTIAL.
> > >> >
> > >> Then that's a problem with the old code :-). Is there any other reason
> > >> that we can't use CHECKSUM_PARTIAL with extension headers other than
> > >> lack of correct driver support?
> > >
> > > The lack of correct driver support is a big bumper, but as I wrote, I
> > > don't see a reason to not lift this restriction in net-next. I proposed
> > > a new feature flag, or by looking at your series, we could probably use
> > > the extension header okay field for that.
> > >
> > Okay, but why bother doing this for net? This problem has obviously
> > existed for a while, and even if the restriction is maintained here
> > there are still other paths that don't go through ip_append_data that
> > could trip the bug. Also, drivers are welcome to fix their issues in
> > net I believe.
> 
> I even don't know if it could be a hardware issue. Also I don't want to
> break people's communication with a patch.
> IMHO without the WARN_ON_ONCEs, which I agreed to remove, I currently
> don't see any problem for net.
> 
> You don't agree on a netdev-feature flag, indicating the driver is okay
> with hardware checksumming and extension headers? We could add this to
> net-next pretty fast, I think. It does not require people to revert this
> patch in case their driver misbehaves and we don't get a fix for it,
> soon. Also what should we do if the driver simply does not support
> extension headers + checksum offloading? Completely kill checksum
> offloading for IPv6?

I posted v3 just now. I would like to let David consider it for net
inclusion. We can work on how to lift this limitation then in net-next,
okay? I am currently in favor of a new netdev-feature. What do you
think? Your RFC series could help here, too.

Thanks,
Hannes
