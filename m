From: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Subject: Re: [OOPS] In __netif_receive_skb_core
Date: Tue, 12 Jan 2016 02:51:06 +0200
Message-ID: <56944DFA.4050002@gmail.com>
References: <568EA671.7000502@gmail.com> <56929985.3020502@gmail.com>
 <1452457610.16445.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <5694188F.80907@gmail.com>
 <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sebastian Reichel <sre@kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAO7SqHA9dNUDG+pYJoQvipE_ErM4Bgo0_o9er_OLxZLDgNVJ8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12.01.2016 00:11, Salam Noureddine wrote:
> Would you be able to disassemble your kernel so we could tell where
> the null pointer dereference happens?
>

Sure, but wouldn't it be better to provide the object file containing 
the debug symbols as well?

Otherwise, the null pointer dereference happens somewhere in:

(gdb) l *__netif_receive_skb_core+0x7c0
0x1318 is in __netif_receive_skb_core (include/linux/compiler.h:218).
213	})
214	
215	static __always_inline
216	void __read_once_size(const volatile void *p, void *res, int size)
217	{
218		__READ_ONCE_SIZE;
219	}
220	
221	#ifdef CONFIG_KASAN
222	/*

(gdb) l *__netif_receive_skb_core+0x7bc
0x1314 is in __netif_receive_skb_core (net/core/dev.c:3934).
3929		}
3930	
3931		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
3932				       &orig_dev->ptype_specific);
3933	
3934		if (unlikely(skb->dev != orig_dev)) {
3935			deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
3936					       &skb->dev->ptype_specific);
3937		}
3938	

(gdb) l *__netif_receive_skb_core+0x7c4
0x131c is in __netif_receive_skb_core (net/core/dev.c:3935).
3930	
3931		deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
3932				       &orig_dev->ptype_specific);
3933	
3934		if (unlikely(skb->dev != orig_dev)) {
3935			deliver_ptype_list_skb(skb, &pt_prev, orig_dev, type,
3936					       &skb->dev->ptype_specific);
3937		}
3938	
3939		if (pt_prev) {


0x00001300 <+1960>:	cmp	r10, r3
0x00001304 <+1964>:	bne	0x1284 <__netif_receive_skb_core+1836>
0x00001308 <+1968>:	ldr	r4, [sp, #12]
0x0000130c <+1972>:	ldr	r3, [r4, #20]
0x00001310 <+1976>:	cmp	r3, r6
0x00001314 <+1980>:	beq	0x13b0 <__netif_receive_skb_core+2136>

0x00001318 <+1984>:	ldr	r5, [r3, #92]	; 0x5c   <-FAULT

r3 seems to be skb->dev

0x0000131c <+1988>:	add	r10, r3, #92	; 0x5c
0x00001320 <+1992>:	add	r8, r4, #180	; 0xb4
0x00001324 <+1996>:	sub	r5, r5, #20
0x00001328 <+2000>:	b	0x13a4 <__netif_receive_skb_core+2124>
0x0000132c <+2004>:	ldrh	r3, [r5]
0x00001330 <+2008>:	cmp	r3, r7


I put some additional printks around that code, and it turned out that 
skb->dev is null, so "if (unlikely(skb->dev != orig_dev))" succeeds, but 
"&skb->dev->ptype_specific" oopses.

Thanks,
Ivo
