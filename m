From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 22:27:16 +0200
Message-ID: <CALzJLG-CR1Ac5biwP5CuFbygqCOWh4-VGQc-XZ=BuZQLRnnRDg@mail.gmail.com>
References: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>
	<20160224.114839.300751853393269073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35448 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbcBXU1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 15:27:17 -0500
Received: by mail-yw0-f193.google.com with SMTP id u200so1294903ywf.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 12:27:17 -0800 (PST)
In-Reply-To: <20160224.114839.300751853393269073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Netdev features can be changed dynamically to off after vlan_vid_add
>> was called, thus vlan_vid_del will skip ndo_vlan_rx_kill_vid and will
>> leave the device driver with un-freed resources.
>
> Are you sure the fix isn't to make vlan_vid_add() check ->features instead
> of ->hw_features.

This is exactly what this fix suggests, "->features" is not consistent
and can be turned ON/OFF between vlan_add/del which can leave the NIC
driver in inconsistent state !

>
> Should we really be trying to add VLAN filters when the user has
> turned it off?

Well, I think it is debatable, but the current implementation is not
consistent, especially for adding vlan 0 by default and then the user
disables the vlan filter, this will cause the stack to never call the
nic ndo_vlan_rx_kill_vid for the pre added vlan 0 and vise versa call
kill_vid without add_vid, BUG ?

So i think we have two options, use this patch, and always trust to
delegate vlan_vid_add/del to the NIC when it's HW supports it, and the
nic will be smart enough to know what to do with it (in case vlan
filter is enabled/disabled). Or, for each vlan we can remember if it
was added to the NIC or not so the stack will know whether to clean it
up or not.
