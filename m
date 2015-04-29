From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next v3 0/4] net: Introduce IFF_PROTO_DOWN flag.
Date: Wed, 29 Apr 2015 15:08:41 -0700
Message-ID: <20150429150841.55477595@urahara>
References: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33625 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbbD2WIk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:08:40 -0400
Received: by pdbnk13 with SMTP id nk13so40482909pdb.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:08:39 -0700 (PDT)
In-Reply-To: <1430156304-13187-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2015 10:38:20 -0700
anuradhak@cumulusnetworks.com wrote:

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>=20
> User space daemons can detect errors in the network that need to be
> notified to the switch device drivers.=20
>=20
> Drivers can react to this error state by doing a phy-down on the
> switch-port which would result in a carrier-off locally and on the
> directly connected switch. Doing that would prevent loops and
> black-holes in the network.
>=20
> One such use case is the multi-chassis LAG application -
> 1. The MLAG application runs on peer switches (say Switch0 and Switch=
1)
>    synchronizing states, forwarding entries etc. between the two
>    switches over the peer-link (this is a link directly connecting th=
e
>    two switches).
> 2. An MLAG election process designates one of the switches as a prima=
ry
>    (for e.g. Switch0 is primary and Switch1 is secondary).=20
> 3. The peer link plays a critical role in allowing Switch0-Switch1 to
>    function as a single LAG partner to the downstream dual-connected
>    servers. When the peer-link between the switches goes down we have=
 a
>    split-brain situation. Switch0 and Switch1 are no longer in sync a=
nd
>    are acting independently. This can result in traffic loops and
>    traffic black-holing in the network.=20
> 4. To prevent these problems the MLAG application on the secondary
>    switch phy-downs the MLAG ports on detecting the peer-link down.
>    This will be seen as a carrier down on servers that are
>    dual-connected to Switch0 and Switch1.
> 5. Specifically a dual-connected server will see a carrier-down on th=
e
>    port connected to the MLAG secondary, Switch1, and will stop using
>    that port for traffic TX. So traffic black holing is prevented.
>=20
> v2 to v3:
>    In response to Dave=E2=80=99s comments I have tried to make IFF_PR=
OTODOWN
>    more easily consumable by providing switchdev APIs to control the
>    phy state of the switch port. The use case is relevant primarily t=
o
>    switch drivers at this point. That is the reason for making the
>    change in rocker (commonly used switch driver example).
>=20
>    One other change that could be done is to bring back the net-core
>    change to hold the oper state down in response to IFF_PROTO_DOWN.
>    This would be a driver agnostic change and the phy-down could be d=
one
>    in addition by interested switch drivers.
>=20
> v1 to v2:
>    Based on Dave's suggestion I have moved out aggregating of error b=
its
>    across applications to a user space framework. This patch now simp=
ly
>    notifies an aggregated error bit to drivers enabling them to handl=
e
>    the error gracefully.
>=20
>=20
> Anuradha Karuppiah (4):
>   net core: Add IFF_PROTO_DOWN support.
>   switchdev: APIs for setting physical state of the switch port.
>   rocker: Handle IFF_PROTODOWN by doing a PHYS-DOWN on the switch por=
t.
>   ip link: Config and display IFF_PROTO_DOWN flag.
>=20
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>=20
>  drivers/net/ethernet/rocker/rocker.c |   16 +++++++++++++++-
>  include/net/switchdev.h              |   12 ++++++++++++
>  include/uapi/linux/if.h              |    4 ++++
>  net/8021q/vlan_dev.c                 |    3 ++-
>  net/core/dev.c                       |    8 +++++++-
>  net/switchdev/switchdev.c            |   23 +++++++++++++++++++++++
>  6 files changed, 63 insertions(+), 3 deletions(-)
>=20

How does this interact with operstate?
It seems RFC2863 operstate (Documentation/network/operstates.txt) alrea=
dy
has concept of LOWERLAYERDOWN
