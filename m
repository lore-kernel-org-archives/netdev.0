From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/2] gianfar: convert u64 status counters to
 atomic64_t
Date: Wed, 13 Feb 2013 19:47:20 +0200
Message-ID: <511BD1A8.4090506@freescale.com>
References: <1360715064-2689-1-git-send-email-paul.gortmaker@windriver.com>  <1360715064-2689-3-git-send-email-paul.gortmaker@windriver.com>  <511BAFC4.9060006@freescale.com> <1360772065.6884.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:4473 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934405Ab3BMRrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 12:47:31 -0500
In-Reply-To: <1360772065.6884.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2013 6:14 PM, Eric Dumazet wrote:
> On Wed, 2013-02-13 at 17:22 +0200, Claudiu Manoil wrote:
>
>> At least it seems that this conversion results in fewer asm
>> instructions, as apparently addze and the double lwz/stw are
>> not generated anymore. Hopefully it's faster too :P
>
> Strange, could you show us these asm instructions ?
>
>
>

Ok, I'm looking over gfar_clean_rx_ring's asm code, with and w/o this
patch. They are difficult to compare as asm code changed considerably,
the initial version having more lines.
The first thing I notice is that the initial ver has 13 'addic'
instructions, and the new version has 7.

Now taking the code around the last 'addic' instruction (from the
gfar_clean_rx_ring function):

Initial version looks like this:

     5024:	4b ff ff ac 	b       4fd0 <gfar_clean_rx_ring+0x450>
     5028:	81 5d 06 30 	lwz     r10,1584(r29)
     502c:	81 7d 06 34 	lwz     r11,1588(r29)
     5030:	31 6b 00 01 	addic   r11,r11,1
     5034:	7d 4a 01 94 	addze   r10,r10
     5038:	91 5d 06 30 	stw     r10,1584(r29)
     503c:	91 7d 06 34 	stw     r11,1588(r29)
     5040:	4b ff fe fc 	b       4f3c <gfar_clean_rx_ring+0x3bc>

New version looks like this:

     4ff8:	4b ff fd a8 	b       4da0 <gfar_clean_rx_ring+0x1ec>
     4ffc:	80 1c 00 a0 	lwz     r0,160(r28)
     5000:	38 60 00 00 	li      r3,0
     5004:	80 a1 00 18 	lwz     r5,24(r1)
     5008:	38 80 00 01 	li      r4,1
     500c:	30 00 00 01 	addic   r0,r0,1
     5010:	90 1c 00 a0 	stw     r0,160(r28)
     5014:	48 00 00 01 	bl      5014 <gfar_clean_rx_ring+0x460>
     5018:	4b ff ff 4c 	b       4f64 <gfar_clean_rx_ring+0x3b0>


I have the whole function's asm excepts, if needed.
