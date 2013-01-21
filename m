From: Timo Teras <timo.teras@iki.fi>
Subject: r8169 doing more work than napi weight
Date: Mon, 21 Jan 2013 17:12:41 +0200
Message-ID: <20130121171241.2af52e12@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:39986 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab3AUPMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 10:12:34 -0500
Received: by mail-lb0-f182.google.com with SMTP id gg6so3790013lbb.41
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2013 07:12:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm getting:

WARNING: at linux-grsec/src/linux-3.4/net/core/dev.c:3875 net_rx_action+0xab/0x153()

on one of my r8169 boxes.

This would be the:
	WARN_ON_ONCE(work > weight); 

Now the only way this seems to be possible to happen is that the AMD
workaround triggers:
        if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
            (tp->mac_version == RTL_GIGA_MAC_VER_05)) {
                 desc->opts2 = 0;
                 cur_rx++;
        }

And yes, the hardware where the WARN_ON_ONCE triggers is indeed
RTL_GIGA_MAC_VER_05.

This would cause cur_rx to be incremented twice in the loop, but
rx_left not decremented accordingly.

As the work done is counted finally based on cur_rx, we might end up
returning more work done than what was our quota.

This has also the unwanted consequence of messing NAPI state as if more
work than quota was done then polling is stopped as the work == weight
does not trigger and the polling is not rescheduled.

Git log says that this workaround was copied from Realtek's r8168
driver, but I don't see anything like this there anymore.

I'm wondering if we should just delete the
	cur_rx++;
Or add:
	rx_left--;

Or just delete the whole block as obsolete. 'git log' says the problem
should have gone away by always using hardware Rx VLAN. See commit
05af214 "r8169: fix Ethernet Hangup for RTL8110SC rev d".

Thanks,
 Timo
