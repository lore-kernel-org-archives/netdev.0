From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH 2/2] r8169: checks against wrong mac addresse init
Date: Tue, 21 Oct 2008 19:10:39 +0200
Message-ID: <48FE0D0F.7020300@redhat.com>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com>	 <20081016214808.GC27208@electric-eye.fr.zoreil.com> <1224265672.17605.27.camel@marvin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	=?ISO-8859-1?Q?=22=5C=22J=2EA=2E=5C=22_Magall=F3n=22?=
	<jamagallon@ono.com>
To: Martin Capitanio <c4p7n@capitanio.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59973 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753686AbYJURLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 13:11:37 -0400
In-Reply-To: <1224265672.17605.27.camel@marvin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Capitanio wrote:
> Please take a look at the realtek r8101_n aka RealTek RTL8101E,
> RTL8102E(L) code. Only CFG_METHOD_1, CFG_METHOD_2
> and #(ioaddr, 0x00) == 0x8128 are here allowed to EEPROM access.
> 
> ...
> 	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8129);
> 
> 	RTL_W8(Cfg9346, Cfg9346_EEM0);
> 	mdelay(15);
> 	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8128);

1) According specification when EEM0 is set to 1 and EEM1 is set to 0
then adapter enters "auto load" mode. Entering this mode will make the
adapter load the contents of the 93C46 (93C56) as when the PCI RSTB
signal is asserted. This auto-load operation will take about 2 ms.
Upon completion, the it automatically returns to normal mode
(EEM1 = EEM0 = 0) and all of the other registers are reset to default
values.
2) First 2 bytes of the EEPROM contain ID code words for the adapter.
It will load the contents of the EEPROM into the corresponding location
if the ID word (0x8129) is correct.

So the Realtek's driver at first sets these bytes to value 0x8129 to ensure
that auto-load will be a success. Then it initiates auto-load (EMM0 = 1 and
EMM1 = 0) then wait some time and finally writes back original value (0x8128).

Ivan
