From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: Port STP state after removing port from bridge
Date: Thu, 19 Feb 2015 23:46:28 -0500
Message-ID: <CAE4R7bB3im1-4FA5wL0h753tPpeeVcg_SN9NDVcvA4ow5uh8hg@mail.gmail.com>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:46219 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbbBTEq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 23:46:28 -0500
Received: by mail-qa0-f52.google.com with SMTP id v10so10511731qac.11
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 20:46:28 -0800 (PST)
In-Reply-To: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2015 at 11:39 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>
> Hi,
>
> It just occured to me that the following sequence:
>
> brctl addbr br0
> brctl addif br0 port0
> ... STP happens
> brctl delif br0 port0
>
> will leave port0 in STP disabled state, because the bridge code will
> set the STP state to DISABLED, and only a down/up sequence can bring
> it back to FORWARDING.
>
> Is this something that we should somehow fix? As an user it seems a
> little convoluted having to do a down/up sequence to restore things. I
> believe however that it is valid for the bridge layer to mark a port
> as DISABLED when removing it. This is typically not noticed or even
> remotely a problem with software bridges because we cannot enforce an
> actual STP state at the HW level.
>
> Let me know your thoughts.


The fix in rocker would be:

diff --git a/drivers/net/ethernet/rocker/rocker.c
b/drivers/net/ethernet/rocker/rocker.c
index 34389b6a..e2004fb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4456,8 +4456,10 @@ static int rocker_port_bridge_leave(struct
rocker_port *rocker_port)
                rocker_port_internal_vlan_id_get(rocker_port,
                                                 rocker_port->dev->ifindex);
        err = rocker_port_vlan(rocker_port, 0, 0);
+       if (err)
+               return err;

-       return err;
+       return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING);
 }


This will return the port back to it's initial state of
BR_STATE_FORWARDING, after it's removed from the bridge.

I'll include this patch in the rocker pile to be pushed later.

-scott
