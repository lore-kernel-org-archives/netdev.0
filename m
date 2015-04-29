From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Wed, 29 Apr 2015 15:58:05 -0700
Message-ID: <CACcJQnTThOxOunMCFCzKWm1MFwdWeWHAALQixBXMXyzhLm+AQw@mail.gmail.com>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
	<20150429150841.55477595@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33758 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbD2W6G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:58:06 -0400
Received: by lbbzk7 with SMTP id zk7so31698743lbb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:58:05 -0700 (PDT)
In-Reply-To: <20150429150841.55477595@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2015 at 3:08 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 27 Apr 2015 10:38:20 -0700
> anuradhak@cumulusnetworks.com wrote:
>
>> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>>
>> User space daemons can detect errors in the network that need to be
>> notified to the switch device drivers.
>>
>> Drivers can react to this error state by doing a phy-down on the
>> switch-port which would result in a carrier-off locally and on the
>> directly connected switch. Doing that would prevent loops and
>> black-holes in the network.
>>
>> One such use case is the multi-chassis LAG application -
>> 1. The MLAG application runs on peer switches (say Switch0 and Switc=
h1)
>>    synchronizing states, forwarding entries etc. between the two
>>    switches over the peer-link (this is a link directly connecting t=
he
>>    two switches).
>> 2. An MLAG election process designates one of the switches as a prim=
ary
>>    (for e.g. Switch0 is primary and Switch1 is secondary).
>> 3. The peer link plays a critical role in allowing Switch0-Switch1 t=
o
>>    function as a single LAG partner to the downstream dual-connected
>>    servers. When the peer-link between the switches goes down we hav=
e a
>>    split-brain situation. Switch0 and Switch1 are no longer in sync =
and
>>    are acting independently. This can result in traffic loops and
>>    traffic black-holing in the network.
>> 4. To prevent these problems the MLAG application on the secondary
>>    switch phy-downs the MLAG ports on detecting the peer-link down.
>>    This will be seen as a carrier down on servers that are
>>    dual-connected to Switch0 and Switch1.
>> 5. Specifically a dual-connected server will see a carrier-down on t=
he
>>    port connected to the MLAG secondary, Switch1, and will stop usin=
g
>>    that port for traffic TX. So traffic black holing is prevented.
>>
>> v2 to v3:
>>    In response to Dave=E2=80=99s comments I have tried to make IFF_P=
ROTODOWN
>>    more easily consumable by providing switchdev APIs to control the
>>    phy state of the switch port. The use case is relevant primarily =
to
>>    switch drivers at this point. That is the reason for making the
>>    change in rocker (commonly used switch driver example).
>>
>>    One other change that could be done is to bring back the net-core
>>    change to hold the oper state down in response to IFF_PROTO_DOWN.
>>    This would be a driver agnostic change and the phy-down could be =
done
>>    in addition by interested switch drivers.
>>
>> v1 to v2:
>>    Based on Dave's suggestion I have moved out aggregating of error =
bits
>>    across applications to a user space framework. This patch now sim=
ply
>>    notifies an aggregated error bit to drivers enabling them to hand=
le
>>    the error gracefully.
>>
>>
>> Anuradha Karuppiah (4):
>>   net core: Add IFF_PROTO_DOWN support.
>>   switchdev: APIs for setting physical state of the switch port.
>>   rocker: Handle IFF_PROTODOWN by doing a PHYS-DOWN on the switch po=
rt.
>>   ip link: Config and display IFF_PROTO_DOWN flag.
>>
>> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>
>>  drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
>>  include/net/switchdev.h              |   12 ++++++++++++
>>  include/uapi/linux/if.h              |    4 ++++
>>  net/8021q/vlan_dev.c                 |    3 ++-
>>  net/core/dev.c                       |    8 +++++++-
>>  net/switchdev/switchdev.c            |   23 +++++++++++++++++++++++
>>  6 files changed, 63 insertions(+), 3 deletions(-)
>>
>
> How does this interact with operstate?
> It seems RFC2863 operstate (Documentation/network/operstates.txt) alr=
eady
> has concept of LOWERLAYERDOWN
>

IFF_PROTO_DOWN doesn't directly change (or interact with) the RFC2683 d=
efined
oper state machine.

It is intended to notify the switch driver that an APP detected errors =
on a
switch port (say swp1). And the switch driver is expected to react to t=
he
notification by doing a phy down on the switch port (if it did have phy=
 control
of the port via the corresponding SDK).
1. Doing that would result in a carrier down locally and on the directl=
y
connected remote switch.
2. This in turn will be reported as a netif_carrier_off(swp1) by the sw=
itch
driver and result in an IF_OPER_LOWERLAYERDOWN on swp1 via the existing
link_watch/rfc2863_policy processing itself.
