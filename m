From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: ipv6 debugging
Date: Mon, 18 Feb 2008 16:02:05 +0100
Message-ID: <3740A925537C481CAA40DE393FA0D00E@intranet.dti2.net>
References: <87zltyjr50.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: "Ferenc Wagner" <wferi@niif.hu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:3646 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbYBRPIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 10:08:43 -0500
Received: from cintasverdes ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.4)
	with ESMTP id md50009716609.msg
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 16:02:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    This sounds to me like the same problem that I was having with OSPF, I 
think ARP(6) uses multicast ethernet address too. Can you try if the patch 
below, that I sent Patrick McHardy some days ago, fixes your problem?

    Regards,

    Jorge
---
    Hi Patrick,

    Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
    introduced a new field "da_synced" to struct dev_addr_list that is
    not properly initialized to 0. So when any of the current users (8021q,
    macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
    list for both devices.

    The attached patch fixed it for me and avoid future problems.

    Regards,

    Jorge

Signed-off-by: Jorge Boncompte [DTI2] jorge@dti2.net
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 9549417..f1b6708 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2900,7 +2900,7 @@ int __dev_addr_add(struct dev_addr_list **list, int
*count,
                }
        }

-       da = kmalloc(sizeof(*da), GFP_ATOMIC);
+       da = kzalloc(sizeof(*da), GFP_ATOMIC);
        if (da == NULL)
                return -ENOMEM;
        memcpy(da->da_addr, addr, alen);

----- Original Message ----- 
From: "Ferenc Wagner" <wferi@niif.hu>
To: <netdev@vger.kernel.org>
Sent: Monday, February 18, 2008 3:06 PM
Subject: ipv6 debugging


> Hi,
>
> I'm kindly asking for some debugging tips with the following problem:
> a machine is running Linux 2.6.24.2, several 802.1q VLAN-s over
> active/backup bonding over two physical interfaces.  Everything is
> allright, except for after a reboot, there's no IPv6, while IPv4
> works.  The router's ARP(6) table is empty, the machine doesn't answer
> ping6.  However, if I start tcpdump -i bond0 ip6, everything is
> allright again.  There are some indications that after some period
> without IPv6 traffic, the same can happen again.  Are there known
> issues which can exhibit themselves like this?  Other very similar
> setups don't show this erratic behaviour.
>
> I know that the above doesn't give a fully detailed picture, but
> thought that I'd better ask before taking the setup into pieces.
> -- 
> Thanks for your thoughts,
> Feri.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


