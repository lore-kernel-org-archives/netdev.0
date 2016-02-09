From: "Karicheri, Muralidharan" <m-karicheri2@ti.com>
Subject: RE: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Tue, 9 Feb 2016 16:09:55 +0000
Message-ID: <3E54258959B69E4282D79E01AB1F32B704D12AF4@DFLE11.ent.ti.com>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDBFCC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Cooper Jr., Franklin" <fcooper@ti.com>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"Strashko, Grygorii" <grygorii.strashko@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"Arnd Bergmann" <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCDBFCC@AcuExch.aculab.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Laight [mailto:David.Laight@ACULAB.COM]
>Sent: Tuesday, February 09, 2016 9:13 AM
>To: Strashko, Grygorii; netdev@vger.kernel.org; David S . Miller; Arnd Bergmann
>Cc: Cooper Jr., Franklin; Nori, Sekhar; linux-kernel@vger.kernel.org; Kwok, WingMan;
>Karicheri, Muralidharan; N, Mugunthan V
>Subject: RE: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
>
>From: Grygorii Strashko
>> Sent: 09 February 2016 13:58
>> From: Arnd Bergmann <arnd@arndb.de>
>>
>> The commit 899077791403 ("netcp: try to reduce type confusion in
>> descriptors") introduces a regression in Kernel 4.5-rc1 and it breaks
>> get/set_pad_info() functionality.
>>
>> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
>> store DMA/MEM buffer pointer and buffer size respectively. And in both
>> cases for Keystone 2 the pointer type size is 32 bit regardless of
>> LAPE enabled or not, because CONFIG_ARCH_DMA_ADDR_T_64BIT originally
>> is not expected to be defined.
>>
>> 			!LAPE	LPAE
>> sizeof(void*)		32bit	32bit
>> sizeof(dma_addr_t) 	32bit	32bit
>> sizeof(phys_addr_t) 	32bit	64bit
>>
>> Unfortunately, above commit changed buffer's pointers save/restore
>> code (get/set_pad_info()) and added intermediate conversation to u64
>> which works incorrectly on 32bit Keystone 2 and causes TI NETCP driver
>> crash in RX/TX path due to "Unable to handle kernel NULL pointer"
>> exception. This issue was reported and discussed in [1].
>>
>> Hence, fix it by partially reverting above commit and restoring
>> get/set_pad_info() functionality as it was before.
>
>You should really get rid of most of the horrid pointer-integer casts.
>Code like:
>>  	void *buf_ptr;
>...
>> +		get_pad_info((u32 *)&buf_ptr, &buf_len, ndesc);
>is just asking for trouble.
>
>You'd be better using assignments like:
>	buf_ptr = (cast)get_pad_0(ndesc);
>	buf_len = get_pad_1(ndesc);
>Then the values are passed (and cast) as numerics.
>
>In reality the 'pad' fields ought to be renamed - since they aren't pads.
>Perhaps they should be a union?
No. At the end of the descriptor, host software can add scratchpad which is
not modified by the hardware, but is used by the driver. So please don't
rename.

Murali
>
>	David
