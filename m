From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Sat, 21 Feb 2015 13:12:28 -0800
Message-ID: <CAE4R7bCme-O6kkCWgmK_XXXfyi_uej8SvbVzDY7Q+WFp2STyRA@mail.gmail.com>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
	<1424429473-4601-2-git-send-email-jonasj76@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:33134 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbbBUVM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 16:12:29 -0500
Received: by qcxm20 with SMTP id m20so5959747qcx.0
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 13:12:28 -0800 (PST)
In-Reply-To: <1424429473-4601-2-git-send-email-jonasj76@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 2:51 AM, Jonas Johansson <jonasj76@gmail.com> wrote:
> From: Jonas Johansson <jonas.johansson@westermo.se>
>
> This patch will implement hooks for hardware bonding support for the DSA
> driver. When the team driver adds a DSA slave port the port will be assigned
> a bond group id and the DSA slave driver can setup the hardware. When team
> changes the port state (enabled/disabled) the DSA slave driver is able to
> use the attach/detach callback which will allow the hardware to change the
> hardware settings to reflect the state.
>
> Added DSA hooks:
>  bond_add_group: To add a port to a bond group
>  bond_del_group: To remove a port from a bond group
>  bond_attach: To mark the port in a bond group as attached/active
>  bond_detach: To unmark the port in a bond group as detach/inactive
>
> Added new network device hooks:
>  ndo_bond_attach: To attach a device to a bond group.
>  ndo_bond_detach: To detach a device from a bond group.
>
> Team:
>  Added callback to ndo_bond_attach when port is enabled.
>  Added callback to ndo_bond_detach when port is disabled.
>
> Added DSA notifier:
>  Listening on NETDEV_CHANGEUPPER to add or deleta a port to/from a bond group.

Hi Jonas,

Cc:'ing Andy as he mentioned at netdev01 he was looking into something
similar for switchdev.

My comments are along the lines of the others:

Can we up-level this not for just DSA but for switchdev in general?  I
think the requirements are:

1) It should work for team or bonding.

2) Port driver needs to know a) bond membership, and b) port (active,
inactive) status, at least for 802.3ad.

3) Try to avoid adding new ndo ops if possible, and rather use what's there.

It took me a bit to figure out your new ndo ops in this patch.  Going
by the name ndo_bond_attach/dettach, I thought these were for port
membership, but you're using them for port status change.  So the name
was confusing.  Since you already have port membership covered with
netdevice event NETDEV_CHANGEUPPER, can we also adapt port status
change into netdevice event NETDEV_BONDING_INFO?  (See
netdev_bonding_info_change()).

-scott
