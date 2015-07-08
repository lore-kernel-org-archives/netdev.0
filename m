From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source addresses
Date: Wed, 8 Jul 2015 20:17:40 +0900
Message-ID: <CAKD1Yr3_mCACJArz1cM_cTj8GuZ=Um+rgk18xpNX_f0aBO3W1A@mail.gmail.com>
References: <1436151944-21072-1-git-send-email-ek@google.com>
 <CAKD1Yr02efR=-PxKsR0nhpJyXJBSMmTvRctcJnoqqkfreUpAig@mail.gmail.com>
 <1436342988.2928.9.camel@stressinduktion.org> <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>
 <1436345014.3846.11.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erik Kline <ek@google.com>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35833 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934465AbbGHLSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 07:18:00 -0400
Received: by ykee186 with SMTP id e186so4151482yke.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 04:18:00 -0700 (PDT)
In-Reply-To: <1436345014.3846.11.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 8, 2015 at 5:43 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> For example, consider the case where you have an IPv6 default route
>> but not an IPv6 address on one interface (e.g., wifi), and a working
>> configuration (IPv6 default route and IPv6 address) on another
>> interface (e.g., cellular data). In this situation, the host will send
>> the packet out on the wifi interface using the source address from the
>> the cellular interface to try to talk to wifi. This will not work
>> because the wifi network will almost certainly drop the packet due to
>> BCP-38 ingress filtering.
>
> So in this case we report errors to user space instead of picking an
> address from another interface.

So you're proposing that when the sysctl is turned on, if we've picked
an outgoing interface, but that interface only has a link-local
address, then we return EADDRNOTAVAIL instead of picking the
link-local address?

That would preclude the ability to use a link-local address to talk to
an on-link (directly-connected) global address, which is possible
today. But it's at least better than the current behaviour. I'm not
sure how to implement this though - I think it's equivalent to
ordering rule 5 above rule 2, but that's a pretty big change and hard
to make in the current code because the rules are an enum.

> If we turn on this knob unconditionally
> we cannot leave the set of possible source addresses empty, this will
> change application behavior and admin habits too much, I fear.

In general, even if the user turns on this setting, there will always
be at least one address - the link-local address on the interface.
That's what RFC 6724 says the host should use. In this case, what will
happen is that once the source address lookup is complete, when
getaddrinfo() chooses the destination address, it will sort this
combination last, because of rule 2 (prefer matching scope), which is
the highest priority rule apart from rule 1 (avoid unreachable). So
the application will try other combinations, which will include
falling back to IPv4 in the likely case that it is available.

What happens today is that getaddrinfo sorts the (global address, ipv6
address on wrong interface) combination first, and the app gets stuck.

>> At the moment, we're going against the explicit recommendation of the
>> RFC, and I don't see a good reason for that.
>
> I really would like to come up with a sane works-always behavior for
> this, but besides doing a retry on the complete source address selection
> algorithm I currently cannot come up with an idea.

Nothing is works-always in the presence of broken configurations. I
think we should have a mode where we follow the RFC, because in that
case when we get stuck we can convincingly argue that the network is
broken and not our implementation.

In IETF language, "RECOMMENDED" means that "there may exist valid
reasons in particular circumstances to ignore a particular item, but
the full implications must be understood and carefully weighed before
choosing a different course". What I don't understand is - what's the
harm here if we provide a mode that follows the RFC? What are do
gaining by not following it?
