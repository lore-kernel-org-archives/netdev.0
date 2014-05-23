From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] enic: fix adaptive irq coalescing on 32-bit
Date: Fri, 23 May 2014 08:29:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724C45F@AcuExch.aculab.com>
References: <10713072.kCczZxGWdQ@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Sujith Sankar <ssujith@cisco.com>, Neel Patel <neepatel@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>
To: 'Arnd Bergmann' <arnd@arndb.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52435 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750872AbaEWIaf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 04:30:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03974-02 for <netdev@vger.kernel.org>;
 Fri, 23 May 2014 09:30:26 +0100 (BST)
In-Reply-To: <10713072.kCczZxGWdQ@wuerfel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann
> 7c2ce6e60f703 "enic: Add support for adaptive interrupt coalescing"
> introduced a 64-bit division that causes a link error on all 32-bit
> machines:
> 
> drivers/built-in.o: In function `enic_poll_msix':
> :(.text+0x54ff00): undefined reference to `__aeabi_uldivmod'
> 
> Since we are dividing another 32-bit value and are only interested
> in the approximate range here, it should always be safe to limit
> the delta to an u32 value.
...
>  	traffic <<= 3;
> -	traffic /= delta;
> +	traffic /= min_t(u32, delta, UINT_MAX);

I suspect that doesn't have the desired effect.
I think it is the same as:
	traffic /= (u32)delta;
If you was the correct value for large 'delta' then maybe:
	traffic = delta > UINT_MAX ? 0 : traffic / (u32)delta;

	David
