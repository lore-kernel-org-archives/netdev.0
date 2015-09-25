From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] switchdev: push bridge attributes down
Date: Thu, 24 Sep 2015 18:23:20 -0700
Message-ID: <5604A208.3030902@gmail.com>
References: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33063 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbbIYBX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 21:23:29 -0400
Received: by pacex6 with SMTP id ex6so88890150pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 18:23:29 -0700 (PDT)
In-Reply-To: <1443128370-27353-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/09/15 13:59, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> Push bridge-level attributes down to switchdev drivers.  This patchset
> adds the infrastructure and then pushes, as an example, ageing_time attribute
> down from bridge to switchdev (rocker) driver.  Add some range-checking
> for ageing_time.
> 
> # ip link set dev br0 type bridge ageing_time 1000
> 
> # ip link set dev br0 type bridge ageing_time 999
> RTNETLINK answers: Numerical result out of range
> 
> Up until now, switchdev attrs where port-level attrs, so the netdev used in
> switchdev_attr_set() would be a switch port or bond of switch ports.  With
> bridge-level attrs, the netdev passed to switchdev_attr_set() is the bridge
> netdev.  The same recusive algo is used to visit the leaves of the stacked
> drivers to set the attr, it's just in this case we start one layer higher in
> the stack.  One note is not all ports in the bridge may support setting a
> bridge-level attribute, so rather than failing the entire set, we'll skip over
> those ports returning -EOPNOTSUPP.

So, without a better device to hold that kind of information (in the
future it could be a global, switch-specific device holding that
information), I agree with your decision to take the bridge device to
hold that attribute, it still feels a bit uncomfortable to have
switchdev_attr_port() take a bridge device parameter, but whatever, here
is a scenario I am wondering how we would want to proceed with:

- suppose we have a switch which is only able to control ageing
globally, not per port or any other kind of logical domain

- we have enabled two software bridges on the same physical switch, with
different ageing timeouts

It does not seem to me like it hurts ageing the other bridge faster than
expected (even though that could be expensive for MDIO devices), but we
would need to have consistent reporting here for the other bridge.

We could therefore have the driver return different things:

- < 0: error, value is too low or too high for the hardware to support that

- == 0: supports ageing in a more fine-grained way that globally

- > 0 (== ageing): supports ageing globally and switchdev/bridge also
needs to update the other bridge devices with the same ageing parameters

Alternatively, as soon as we have more bridges than supported ageing
control knobs, we could have the driver just return -EPERM or something
like that, but that means keeping track of bridges attached to the
switch's ports.

Other than that, this looks good to me, thanks!

> 
> Scott Feldman (4):
>   switchdev: add bridge attributes
>   switchdev: skip over ports returning -EOPNOTSUPP when recursing ports
>   bridge: push bridge setting ageing_time down to switchdev
>   rocker: handle setting bridge ageing_time
> 
>  drivers/net/ethernet/rocker/rocker.c |   22 ++++++++++++++++++++++
>  include/net/switchdev.h              |    6 ++++++
>  include/uapi/linux/if_link.h         |    2 +-
>  net/bridge/br_ioctl.c                |    3 +--
>  net/bridge/br_netlink.c              |    6 +++---
>  net/bridge/br_private.h              |    1 +
>  net/bridge/br_stp.c                  |   24 ++++++++++++++++++++++++
>  net/bridge/br_sysfs_br.c             |    3 +--
>  net/switchdev/switchdev.c            |    9 ++++++++-
>  9 files changed, 67 insertions(+), 9 deletions(-)
> 


-- 
Florian
