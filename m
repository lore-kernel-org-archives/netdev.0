From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 3/3] ipvlan: set dev_id for l2 ports to generate unique IPv6
 addresses
Date: Thu, 21 May 2015 14:09:07 +0200
Message-ID: <1432210147.2501736.274695753.11571414@webmail.messagingengine.com>
References: <20150514134657.14062.87579.stgit@buzz>
 <20150514135620.14062.1034.stgit@buzz>
 <CAF2d9jg0abaZY+w54yWTgYgOxJbJTQsf5nhgXJYhA8hOC=C2CQ@mail.gmail.com>
 <555DC3AC.5020604@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-netdev" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58509 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753730AbbEUMJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 08:09:08 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 41AB220C85
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 08:09:08 -0400 (EDT)
In-Reply-To: <555DC3AC.5020604@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015, at 13:38, Konstantin Khlebnikov wrote:
> On 20.05.2015 02:59, Mahesh Bandewar wrote:
> > On Thu, May 14, 2015 at 6:56 AM, Konstantin Khlebnikov
> > <khlebnikov@yandex-team.ru> wrote:
> >> All ipvlan ports use one MAC address, this way ipv6 RA tries to assign
> >> one ipv6 address to all of them. This patch assigns unique dev_id to each
> >> ipvlan port. This field is used instead of common FF-FE in Modified EUI-64.
> >>
> >> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> >> ---
> >>   Documentation/networking/ipvlan.txt |   12 +++++++++++-
> >>   drivers/net/ipvlan/ipvlan.h         |    1 +
> >>   drivers/net/ipvlan/ipvlan_main.c    |   20 ++++++++++++++++++++
> >>   3 files changed, 32 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
> >> index cf996394e466..cb0b777bce58 100644
> >> --- a/Documentation/networking/ipvlan.txt
> >> +++ b/Documentation/networking/ipvlan.txt
> >> @@ -24,7 +24,7 @@ using IProute2/ip utility.
> >>
> >>          ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | L3 }
> >>
> >> -       e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
> >> +       e.g. ip link add link eth0 ipvl0 type ipvlan mode l2
> >>
> >>
> >>   4. Operating modes:
> >> @@ -41,6 +41,15 @@ slave device and packets are switched and queued to the master device to send
> >>   out. In this mode the slaves will RX/TX multicast and broadcast (if applicable)
> >>   as well.
> >>
> >> +       In L2 mode slave devices receive Router Advertisements from the network
> >> +and perform autoconfiguration as well as master device. Each port has unique
> >> +16-bit device id which is used for filling octets 4-5 of Modified EUI-64.
> >> +That gives 65533 addresses (FF-FE used by master, FF-FF/00-00 reserved/not used).
> >> +
> > This is nice, thanks for fixing this! However how is "unique" id
> > guaranteed? Especially when multiple virtual drivers are stacked? Not
> > necessarily all of them may use the dev_id, but to avoid any possible
> > collision, shouldn't the device hierarchy (especially lower_dev) be
> > traversed before settling on the initial value?
> 
> Well, uniqueness isn't guaranteed but that should work in most cases.
> ipv6 anyway checks for duplicate addresses after configuration.
> 
> As I see creation of ipvlan on ipvlan just creates slave at original
> master device, so this will work as expected. And ipvlan cannot share 
> physical device with bonding/bridge/macvlan, so I don't see how to
> stack more than one layer of ipvlans accidentally.

I hope that stable ipv6 privacy addresses will be used in future and old
eui-48 based LL addresses will just disappear. That said, I would be
even fine with a RNG generated dev_id, because we cannot really ensure
uniqueness.

Stable privacy addresses even use DAD retry counter to regenerate a new
LL address in case the address becomes IFA_F_DADFAILED.

Bye,
Hannes
