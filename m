From: Timo Teras <timo.teras@iki.fi>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and
 performance degration
Date: Tue, 20 Mar 2012 17:31:24 +0200
Message-ID: <20120320173124.3da2b21c@vostro>
References: <20120314215142.655ae607@vostro>
	<1331755965.6022.55.camel@edumazet-glaptop>
	<20120314223343.23dc9df3@vostro>
	<20120314205319.GA28394@electric-eye.fr.zoreil.com>
	<20120315080635.1f76512b@vostro>
	<20120315171148.0050714d@vostro>
	<20120315191118.GA19809@electric-eye.fr.zoreil.com>
	<20120316221557.235f5ffd@vostro>
	<20120317115625.3fc04de4@vostro>
	<20120317113501.GC20532@electric-eye.fr.zoreil.com>
	<20120317222004.GA25455@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34049 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759211Ab2CTPcM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 11:32:12 -0400
Received: by bkcik5 with SMTP id ik5so147849bkc.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 08:32:09 -0700 (PDT)
In-Reply-To: <20120317222004.GA25455@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 Mar 2012 23:20:04 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> > > Or as easy alternative, enabling the VPD bit in Config1 should
> > > allow me to read the EEPROM contents using the PCI /sys/.../vpd
> > > interface, right?
> > 
> > In theory, yes. I have not tested it. Imho both access methods will
> > be useful.
> 
> I tried vpd and got the eeprom content, duplicated 256 times.
> 
> The eeprom content is fairly boring:
> 
> # ethtool -e
> 8169sc-1 Offset          Values
> ------          ------
> 0x0000          29 81 ec 10 67 81 ec 10 67 81 20 40 01 a1 00 e0 
> 0x0010          4c 67 00 01 15 cd c2 f7 ff 80 ff ff ff ff ff 13 
> 0x0020          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0030          ff ff fa d6 ff ff ff ff ff ff ff ff ff ff ff 20 
> 0x0040          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0050          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0060          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
> 0x0070          ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

Ok. I now have the box that was sending faulty packets and has weird
PCI ID on my desk for playing. I swapped it for identical box - the
software and configuration are identical - and now the 1 gig mode errors
are gone on the setup. So the problem is caused by hardware; either due
to bad eeprom/firmware in the rtl8110sc or some other issue.

I also built net-next and took the ehttool -e dumps of the eeproms.

>From a working eth0:

Offset          Values
------          ------
0x0000          29 81 ec 10 67 81 f3 16 ec 10 20 40 00 a1 00 30 
0x0010          18 a8 14 ac 15 0d c2 f7 00 80 00 00 00 00 00 13 
0x0020          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0030          00 00 82 c7 00 00 00 00 00 00 00 00 00 00 00 20 
0x0040          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0070          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

And the "broken" eth1:

Offset          Values
------          ------
0x0000          29 81 ec 10 69 81 f3 16 ec 10 20 40 00 a1 00 30 
0x0010          18 ab 69 4b 14 0d c2 f7 00 80 00 00 00 00 00 13 
0x0020          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0030          00 00 2c 25 00 00 00 00 00 00 00 00 00 00 00 20 
0x0040          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0070          00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

The only differences seem to be the PCI ID field at byte offset 4-5,
Config 0 field at byte offset 0x14, and the checksum at 0x32-0x33.

If I understand correctly, the Config 0 bit 0 affects Boot ROM size. It
affects only the PXE boot sequence?

Additionally, I can verify that all the chips have "RTL8110SC 67233S1
G28B" on them. So the differing PCI IDs is an oddity.

I can do some additional tests, and test if the bad packets can be
reproduced against a switch and captured.

But other than that, I'm wondering if the failed mdio writing could have
caused permanent damage in the PHY.
