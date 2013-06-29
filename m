From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] 8021q: fix vlan 0 inconsistencies
Date: Sat, 29 Jun 2013 13:46:09 +0200
Message-ID: <51CEC901.70200@redhat.com>
References: <1371731078-12531-1-git-send-email-nikolay@redhat.com> <51C30CE2.5030803@redhat.com> <20130627.222749.1795566196568945291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468Ab3F2LqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 07:46:16 -0400
In-Reply-To: <20130627.222749.1795566196568945291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2013 07:27 AM, David Miller wrote:
> I don't think I can apply this patch, it seems to revert very much intentional
> behavior.
> 
> If you have the 8021q module available, and you bring a device up, it gets
> VLAN 0 by default, and if necessary programmed into the HW filters of the
> device.
> 
> This VLAN 0 entry is not treated like a real VLAN, it is just there to be
> decapsulated for the sake of 802.1p Priority Code Points (QoS).
> 
> If the user explicitly configures other VLAN entries, then removes them all,
> that conditional check on vlan_id in the delete path retains this default
> VLAN 0 configuration and is very much intended to behave that way.
> 
> Your patch breaks this, so I cannot apply it.
> 
> If bonding is so broken that it cannot cope with this default 802.1p behavior,
> that is really bonding's problem.  It seemingly needs logic to handle 802.1p,
> and that default VID 0, properly.
> 
Another analysis of this problem by commits:
before commit 5b9ea6e022e9ba0fe39cb349ac40361f78d5da5b ("vlan: introduce
vid list with reference counting") ndo_vlan_rx_kill_vid was called directly
which would've broken this functionality as you said. But after that commit
(and the beginning of refcounting) that is not the case, since when a
device is opened VLAN 0 is added and its refcount always has at least +1
until the device is closed (now ndo_vlan_rx_kill_vid is called only when
refcount == 0). But by creating/destroying VLAN 0 on top you can bump that
to whatever value you'd like which leads to:
commit efc73f4bbc238d4f579fb612c04c8e1dd8a82979 ("net: Fix memory leak -
vlan_info struct"), which added vlan_vid_del in the 8021q netdev notifier
which is called upon NETDEV_DOWN which is intended to remove the VLAN 0
that was added upon NETDEV_UP. But via ruining the refcount you can again
leak memory that way (since vlan 0's refcnt will be > 1, so it will not get
deleted/freed).

Nik
