From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH 0/4] switch device: offload policy attributes
Date: Mon, 24 Nov 2014 00:18:13 -1000
Message-ID: <CAE4R7bCDp2Cf=azOJvnm3_YRdsD5vwCafbcVFuseUaPuYKDA1g@mail.gmail.com>
References: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	John Linville <linville@tuxdriver.com>, nhorman@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	vyasevic@redhat.com, Florian Fainelli <f.fainelli@gmail.com>,
	buytenh@wantstofly.org, Aviad Raveh <aviadr@mellanox.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	shrijeet@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:59252 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbaKXKSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 05:18:15 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so11744232wgh.32
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 02:18:13 -0800 (PST)
In-Reply-To: <1416610170-21224-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

I have a patch pending against Jiri's v2 that's uses existing
ndo_bridge_setlink/getlink to push policy settings down to port driver
for controlling HW offload.  I had to make a few tweaks, but for the
most part setlink/getlink already has the master/self semantics so
users can set policy flags on bridge's SW version of the port (master)
or on the offloaded version of the port (self).  I added the new
hwmode option "swdev" to the existing "vepa"|"veb" choices.  When you
specify hwmode, SELF is set and the port driver's setlink get's
called.  Did you look at setlink/getlink?  It looks like the kernel
and iproute2 where going down this route of using setlink/getlink for
SELF policy, so I'm wondering if we need more?

On FDB entries, using master/self semantics that exist, it's clear
which are owned by offloaded device and which are owned by bridge.
The one missing annotation was a flag indicating FDB entry in bridge
was synced from device.  And a policy flag to turn on/off syncing from
the device.  The policy flag is just another IFLA_BRPORT flags passed
with setlink/getlink.

The setlink/getlink patch will go out in v3 once I finish testing it
and push it to Jiri.  Hopefully tomorrow.

-scott

On Fri, Nov 21, 2014 at 12:49 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>
> This series aims at introducing new policy attibutes/flags to enable
> selective offloading of kernel network objects.
> This is in the context of supporting switch devices in the linux kernel.
>
> Assumption:
>     - All kernel network objects (routes, neighs, bridges, bonds, vxlans)
>       can be offloaded (This is true today with a few exceptions maybe)
>
> policy points:
>     - By default all objects exist in software (kernel)
>     - Per object flag to add/del/show in kernel, hardware or both
>     - System global option to turn on/off offloads for all network objects.
>       This is for systems who want to turn offloading on for all network objects
>       by default. us :). Apps dont need to know about offloading in this
>       model. (TBD)
>
> Patches are based on jiri/sfeldma's rocker work.
>
> Apologize for the incomplete and untested code. This is a sample patch
>  to get some initial feedback.
>
> Roopa Prabhu (4):
>   rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate kernel object
>     offload to hardware
>   netdev: new feature flag NETIF_F_HW_OFFLOAD to indicate netdev object
>     offload to hardware
>   swdevice: new generic op to set bridge port attr
>   bridge: make hw offload conditional on bridge and bridge port offload
>     flags
>
>  include/linux/netdev_features.h |    1 +
>  include/net/switchdev.h         |    8 ++++++-
>  include/uapi/linux/netlink.h    |    2 ++
>  net/bridge/br_netlink.c         |   50 +++++++++++++++++++++++++++++++--------
>  net/bridge/br_private.h         |    2 ++
>  net/bridge/br_stp.c             |    9 ++++---
>  net/bridge/br_stp_if.c          |    8 +++++--
>  net/core/rtnetlink.c            |    7 ++++++
>  net/switchdev/switchdev.c       |   17 +++++++++++++
>  9 files changed, 88 insertions(+), 16 deletions(-)
>
> --
> 1.7.10.4
>
