From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: sky2: Fix VLAN unregistration
Date: Fri, 01 Jun 2007 17:16:24 +0200
Message-ID: <46603848.5000604@trash.net>
References: <4659D174.70301@trash.net>	<20070531101945.2b19faa7@freepuppy>	<465F07C3.2090503@trash.net> <20070531112117.584141d6@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34184 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757066AbXFAPR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 11:17:56 -0400
In-Reply-To: <20070531112117.584141d6@freepuppy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 31 May 2007 19:37:07 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> 
>>Stephen Hemminger wrote:
>>
>>>On Sun, 27 May 2007 20:44:04 +0200
>>>Patrick McHardy <kaber@trash.net> wrote:
>>>
>>>
>>>
>>>>Fix sky2 disabling VLAN completely when the first vid is unregistered.
>>>>
>>>>For some reason the VLAN code insists on the driver providing a
>>>>vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
>>>>NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
>>>>function. This seems to be a bug though, vlan_rx_add_vid is only
>>>>required with NETIF_F_HW_VLAN_FILTER. Ben?
>>>>
>>>
>>>
>>>Reading other drivers, it looks like a better patch would be to
>>>handle mode change in both set and kill.
>>
>>
>>The VLAN code tracks registered VIDs and will always call
>>vlan_rx_register(NULL) when the last VID is unregistered,
>>so this is not necessary.
>>
> 
> 
> Then should others be fixed...
> 	tg3, bnx2, r8169, gianfar, s2io, 8139cp, acenic, ...


tg3 and r8169 both look fine, they only unregister a single VID
within kill_vid and rely on VLAN to call rx_register(NULL) when
the group is unregistered (haven't looked at the others).

As I wrote in my previous mails, they do have a part that looks
unnecessary

        tg3_full_lock(tp, 0);
        vlan_group_set_device(tp->vlgrp, vid, NULL);

        tg3_full_unlock(tp);

since the vid is also removed by the VLAN code itself and locking
doesn't seem to be necessary because the VLAN hwaccel rx helper
deals with removal races itself.

