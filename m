From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Fri, 25 Feb 2011 17:08:01 -0800
Message-ID: <AANLkTikSvs7jF9BZzbsYkLAawpCH2h1Z0r09ft219uaa@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
	<AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
	<201101241625.45367.maciej.rutecki@gmail.com>
	<loom.20110205T163216-459@post.gmane.org>
	<AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
	<loom.20110206T203347-475@post.gmane.org>
	<4D4FE100.5090808@gmail.com>
	<loom.20110214T141934-88@post.gmane.org>
	<AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com>
	<loom.20110226T011347-702@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36677 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab1BZBIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 20:08:02 -0500
Received: by vxi39 with SMTP id 39so1895509vxi.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 17:08:01 -0800 (PST)
In-Reply-To: <loom.20110226T011347-702@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 4:16 PM, chriss <mail_to_chriss@gmx.net> wrote:
> Jesse Gross <jesse <at> nicira.com> writes:
>
>>
>> What driver is in use with the NIC you are seeing this on?
>>
>
> He there
>
> the device in question is (as lspci told)
> Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit
> Ethernet (rev 10)
>
> handled by kernel module r8169.

I'm guessing that you're hitting the special case in this code in
r8169.c:rtl8169_vlan_rx_register():

         /*
          * Do not disable RxVlan on 8110SCd.
          */
         if (tp->vlgrp || (tp->mac_version == RTL_GIGA_MAC_VER_05))
                 tp->cp_cmd |= RxVlan;
         else
                 tp->cp_cmd &= ~RxVlan;

Since before you were getting the vlans directly off the device there
was a vlan group configured.  However, now that the packets are going
through the bridge, the group is not being configured on the device
and the tag gets dropped.  Assuming that this is the case, the
solution is to convert the driver to use the new vlan model, which
does not require knowledge of the vlan group.

Can you confirm this by running tcpdump -eni br0?  I would expect that
you see the correct packets but without vlan tags.
