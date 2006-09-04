From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sky2 problem on powerpc
Date: Mon, 04 Sep 2006 17:21:09 +1000
Message-ID: <1157354470.22705.26.camel@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37027 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S932433AbWIDHVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 03:21:20 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1157347462.22705.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Because if you look at the definition for:
> 
> struct sky2_rx_le {
> 	__le32	addr;
> 	__le16	length;
> 	u8	ctrl;
> 	u8	opcode;
> } __attribute((packed));
> 
> (As an example)
> 
> If the chips does LE accesses, then marking "lenght" as being an LE
> value isn't enough. It also needs to be swapped with ctrl and opcode.
> The layout then becomes:
> 
> struct sky2_rx_le {
> 	__le32	addr;
> 	u8	opcode;
> 	u8	ctrl;
> 	__le16	length;
> } __attribute((packed));

And of course, I'm stupid... the structure layout in memory is well
defined and the chip is accessing it just fine... The problem are
actually related to

 - That special "reverse" descriptor bit one can set in the chip....
That will indeed cause my scenario above to happen by causing the chip
to do a 32 bits byteswap it seems. But if we set this bit, we must also
remove all of the cpu_to_le/le_to_cpu conversions used to access
descriptors.

 - I've decided not to set that bit for now, thus disabled the code
doing so (and thus requiring be/le conversions). We have cases where
they are missing, and thus it's not working.

I'm trying to get it right now, will send a patch if I can get something
working. At one point, I suppose I'll have the choice of either letting
the HW do the 32 bits flip, which involves playing #ifdef __BIG_ENDIAN
with the structures in sky2.h or just ignore that bit and do cpu_to_le*
when needed. I'm tempted to do the later...

Ben



-- 
VGER BF report: U 0.526041
