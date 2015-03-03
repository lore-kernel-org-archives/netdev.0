From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 01/14] etherdevice: Add eth_<foo>_addr
 CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS code
Date: Tue, 03 Mar 2015 10:25:04 -0800
Message-ID: <1425407104.17273.27.camel@perches.com>
References: <cover.1425354527.git.joe@perches.com>
	 <cccde434d9a32d1b9fb3d7604083c05a2ef1fe0e.1425354528.git.joe@perches.com>
	 <1425388752.5130.164.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425388752.5130.164.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 05:19 -0800, Eric Dumazet wrote:
> On Mon, 2015-03-02 at 19:54 -0800, Joe Perches wrote:
> > Make the memset possibly more efficient with the appropriate
> > CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS #ifdef
[]
> > diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
[]
> > @@ -192,7 +192,12 @@ static inline void eth_random_addr(u8 *addr)
> >   */
> >  static inline void eth_broadcast_addr(u8 *addr)
> >  {
> > +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
> > +	*(u32 *)addr = 0xffffffff;
> > +	*(u16 *)(addr + 4) = 0xffff;
> > +#else
> >  	memset(addr, 0xff, ETH_ALEN);
> > +#endif
> >  }
> >  
> 
> I am pretty sure compiler already does an inline, and might chose to 
> emit equivalent instructions for :
>  *(u16 *) addr = 0xffff;
>  *(u32 *)(addr + 2) = 0xffffffff;
> 
> if (addr % 4) is known to be 2

(cross-compiled on x86)

At least for arm gcc 4.6.3, it emits different code
for net/l2tp/l2tp_eth.o

old:

-    1cc0:	e3a010ff 	mov	r1, #255	; 0xff
-    1cc4:	e3a02006 	mov	r2, #6
-    1cc8:	e3c33001 	bic	r3, r3, #1
-    1ccc:	e3833002 	orr	r3, r3, #2
-    1cd0:	e5c53000 	strb	r3, [r5]
-    1cd4:	ebfffffe 	bl	0 <memset>
-    1cc8:	e3c33001 	bic	r3, r3, #1

new:

+    1cc0:	e3a02f8a 	mov	r2, #552	; 0x228
+    1cc4:	e3c33001 	bic	r3, r3, #1
+    1cc8:	e3833002 	orr	r3, r3, #2
+    1ccc:	e5c53000 	strb	r3, [r5]
+    1cd0:	e3e03000 	mvn	r3, #0
+    1cd4:	e5843224 	str	r3, [r4, #548]	; 0x224
+    1cd8:	e18430b2 	strh	r3, [r4, r2]
