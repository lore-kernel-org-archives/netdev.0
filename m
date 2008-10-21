From: Martin Capitanio <c4p7n@capitanio.org>
Subject: Re: [PATCH 2/2] r8169: checks against wrong mac addresse init
Date: Tue, 21 Oct 2008 23:55:45 +0200
Message-ID: <1224626145.6369.53.camel@marvin>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
	 <20081016214808.GC27208@electric-eye.fr.zoreil.com>
	 <1224265672.17605.27.camel@marvin>  <48FE0D0F.7020300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	"\"\\\"J.A.\\\"" =?ISO-8859-1?Q?Magall=F3n=22?=
	<jamagallon@ono.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:54248 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbYJUV4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 17:56:12 -0400
In-Reply-To: <48FE0D0F.7020300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-21 at 19:10 +0200, Ivan Vecera wrote:
Martin Capitanio wrote:
> > Please take a look at the realtek r8101_n aka RealTek RTL8101E,
> > RTL8102E(L) code. Only CFG_METHOD_1, CFG_METHOD_2
> > and #(ioaddr, 0x00) == 0x8128 are here allowed to EEPROM access.
> > 
> > ...
> > 	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8129);
> > 
> > 	RTL_W8(Cfg9346, Cfg9346_EEM0);
> > 	mdelay(15);
> > 	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8128);
> 
> 1) According specification when EEM0 is set to 1 and EEM1 is set to 0
> then adapter enters "auto load" mode. Entering this mode will make the
> adapter load the contents of the 93C46 (93C56) as when the PCI RSTB
> signal is asserted. This auto-load operation will take about 2 ms.
> Upon completion, the it automatically returns to normal mode
> (EEM1 = EEM0 = 0) and all of the other registers are reset to default
> values.
> 2) First 2 bytes of the EEPROM contain ID code words for the adapter.
> It will load the contents of the EEPROM into the corresponding location
> if the ID word (0x8129) is correct.
> 
> So the Realtek's driver at first sets these bytes to value 0x8129 to ensure
> that auto-load will be a success. Then it initiates auto-load (EMM0 = 1 and
> EMM1 = 0) then wait some time and finally writes back original value (0x8128).
>

My current working hypothesis is, that some of the devices due a hw bug
doesn't like a auto-load on the 'pci-hardwired-reset'. So they have the
value (0x8128).

Second thing is, that thru vpd you have full r/w
access to the EEPROM and the difference between read and write
is just flipping 1 bit. Although my brain refuses to parse the related
linux's pci core code, I think the access should be hw disabled
at the driver start and in the read case as soon as possible
to keep the window for the devil tinier ( http://lwn.net/Articles/303390/ ),
i.e. the realtek's code:

	RTL_W8(Cfg9346, Cfg9346_Unlock);
        RTL_W8(Config1, RTL_R8(Config1) | VPDEnable);
        RTL_W8(Cfg9346, Cfg9346_Lock);

        for (i = 0, read_addr = 0; i < eeprom_size / 4; i++)
                *(eeprom_cont + i) = rtl8169_vpd_read(dev, read_addr + i * 4);

        RTL_W8(Cfg9346, Cfg9346_Unlock);
        RTL_W8(Config1, RTL_R8(Config1) & ~VPDEnable);
        RTL_W8(Cfg9346, Cfg9346_Lock);

Martin

