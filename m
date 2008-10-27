From: "Leonid Slobodchikov" <curvex@gmail.com>
Subject: Re: [PATCH] at91_ether: multicast packet are not received due to incorrect setting of the multicast hashtable, kernel linux-2.6.17.3
Date: Mon, 27 Oct 2008 07:10:41 +0600
Message-ID: <5f59dc1a0810261810s2bd29f6qbcc858311618487f@mail.gmail.com>
References: <5f59dc1a0810261031w2fa3f40bne1edb2d710f64404@mail.gmail.com>
	 <4905027C.4080504@magtech.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	"Andrew Victor" <avictor.za@gmail.com>
To: "Aras Vaichas" <arasv@magtech.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:36409 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbYJ0BKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 21:10:43 -0400
Received: by ug-out-1314.google.com with SMTP id 39so122145ugf.37
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 18:10:41 -0700 (PDT)
In-Reply-To: <4905027C.4080504@magtech.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Just for more info regarding this issue. I could not recevieve
multicast packets adding 01-00-5e-00-01-81 MAC address to the driver's
multicast table. After applying the patch this was fixed for me.
The MAC address above corresponds to 224.0.1.229 IP address. This IP
is used in IEEE-1588 protocol. I have been testing it with the
PTPd-1.0.0 http://sourceforge.net/projects/ptpd/.


Best regards,
Leonid Slobodchikov



On Mon, Oct 27, 2008 at 5:51 AM, Aras Vaichas <arasv@magtech.com.au> wrote:
> Leonid Slobodchikov wrote:
>> Hello,
>>
>> Multicast packets are not received by the Ethernet driver for the
>> Atmel AT91RM9200. This is due to incorrect mc_filter array index
>> evaluation in the at91ether_sethashtable function. The point is that
>> AT91_EMAC_HSH and AT91_EMAC_HSL registers are 64-bit length. So when
>> evaluating the index the bit number must be diveded at 64, which is
>> 2^6, not 2^5.
>> The below is a fix for that issue.
>>
>>
>> --- drivers/net/arm/at91_ether.c.orig 2006-06-30 20:37:38.000000000 +0300
>> +++ drivers/net/arm/at91_ether.c      2008-10-26 17:35:50.000000000 +0200
>> @@ -520,7 +520,7 @@ static void at91ether_sethashtable(struc
>>               if (!curr) break;       /* unexpected end of list */
>>
>>               bitnr = hash_get_index(curr->dmi_addr);
>> -             mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
>> +             mc_filter[bitnr >> 6] |= 1 << (bitnr & 31);
>>       }
>>
>>       at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
>>
> Hmm, that is strange. I received a patch quite some time ago from Andrew
> Victor to fix just such a problem. Maybe it reappeared? Or maybe I
> didn't test my patch patch well enough?
>
> --- SNIP ---
>
> hi Aras,
>
>> I'm using 2.6.16, at91rm9200 with a DM9161 PHY. I can't receive multicast
>> packets on eth0 unless I enable "allmulti" using ifconfig - which I
> shouldn't
>> have to do.
>
> Looks like the bug in the AT91RM9200 Ethernet driver's Multicast support
> might have been found.
>
> Since I know you use multicast, could you possibly test this patch
> (without enabling "allmulti") and let me know?  Thanks.
>
> Regards.
>  Andrew Victor
>
>
>
> --- linux-2.6/drivers/net/arm/at91_ether.c.orig  2007-04-25
> 09:46:29.000000000 +0200
> +++ linux-2.6/drivers/net/arm/at91_ether.c      2007-04-25
> 10:00:25.000000000 +0200
> @@ -535,8 +535,8 @@ static void at91ether_sethashtable(struc
>                mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
>        }
>
> -       at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
> -       at91_emac_write(AT91_EMAC_HSL, mc_filter[1]);
> +       at91_emac_write(AT91_EMAC_HSL, mc_filter[0]);
> +       at91_emac_write(AT91_EMAC_HSH, mc_filter[1]);
>  }
>
>  /*
>
>
> ______________________________________________________________________
> This email has been scanned by the MessageLabs Email Security System.
> For more information please visit http://www.messagelabs.com/email
> ______________________________________________________________________
>
