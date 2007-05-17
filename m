From: linas@austin.ibm.com (Linas Vepstas)
Subject: Resending: RT patches expose netdev race [was Re: [RFC] [patch 2/2] powerpc 2.6.21-rt1: fix kernel hang and/or panic
Date: Wed, 16 May 2007 19:27:51 -0500
Message-ID: <20070517002751.GC4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@ozlabs.org, mingo@elte.hu, tglx@linutronix.de,
	Linas Vepstas <linas@austin.ibm.com>, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tsutomu OWA <tsutomu.owa@toshiba.co.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933012AbXEQA2W@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resending , Owa-san was cut from cc list!??)

Hi,

On Tue, May 15, 2007 at 08:09:02PM +1000, Benjamin Herrenschmidt wrote:
> On Tue, 2007-05-15 at 17:47 +0900, Tsutomu OWA wrote:
> >   I encountered the following error when doing netperf from other machine 
> > to Celleb running RT kernel.  PREEPT_NONE kernel works just fine as well.
> 
> Hrm... sounds a bit weird. I wonder if there's a locking bug in the
> driver in the first place.
> 
> Linas, what's your take ?

Heh. I almost deleted the entire email thread cause it
didn't say "spidernet" in the subject line. :-)
Seriously, I really almost did ....

Since this is a long email; let me put a summary up front:
I think the RT/premption patches are exposing some sort
of race in the ip header handling code. The rest of the 
note is forensics pointing to this.

----

Reading the patch, it looks like all it did was to move
around the locks, without changing the semantics. Two
comments about that:

-- The current spidernet locks are very fine-grained;
   this makes the whole thing function more smoothly.
   The patch would make them coarse-grained, I don't
   like that.

-- Moving around locks like that changes the timing
   completely, and changing the timing makes races
   come and go. The races seem to vanish, but that's
   only cause you are getting lucky.

Since I'm sick-n-tired of dealing with spidernet, I thought
I'd give this one a little extra attention.

The crash is a null pointer deref. The spidernet doesn't
use locks to protect null pointers. The spidernet mostly
doesn't play with pointers at all; they're mostly static.
So this crash is "unusual" from the get-go.

>> Instruction dump:
>> 60000000 81790088 901f000c 913f0018 913f0008 917f0004 48132e8d
>> 60000000
>> a019009e 2f800800 409e0038 e9390038 <88690009> 2f830006 419e0010
>> 2f830011

The crashing instruction is <88690009> which is very unique:
  lbz     r3,9(r9)

load byte ... at an offset of 9 bytes!? spidernet does
nothing with bytes, so its another reason its not spidernet.

Below follows a manual disassembly. The guilty party appears
to the the skb, and spcifically, skb->head has not been set.
You'll have to read the details below to see why.

I do not know why sk_buff->head would be null, or
would be set in a racy kind of way, or why the rt patches
would cause this. But the evidence implicates that.

--linas

Long stuff below. For the record:

> > Unable to handle kernel paging request for data at address 0x00000009
> > Faulting instruction address: 0xc000000000295434
> > Oops: Kernel access of bad area, sig: 11 [#1]
> > PREEMPT SMP NR_CPUS=2 NUMA 
> > Modules linked in:
> > NIP: C000000000295434 LR: C000000000295420 CTR: 0000000000000000
> > REGS: c0000000095d6e30 TRAP: 0300   Not tainted  (2.6.21-rc5-rt7)
> > MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24000482  XER: 20000000
> > DAR: 0000000000000009, DSISR: 0000000040000000
> > TASK = c000000001e7c440[626] 'netserver' THREAD: c0000000095d4000 CPU: 0
> > GPR00: 0000000000000800 C0000000095D70B0 C0000000005D77B8 0000000000000001 
> > GPR04: 0000000000000001 0000000000000000 C0000000095D7080 0000000000000000 
> > GPR08: C0000000095D7030 0000000000000000 C0000000095D7040 0000000000000000 
> > GPR12: FC69925300080D5D C0000000004DE680 0000000000000000 0000000000422208 
> > GPR16: 0000000000400000 0000000000420D10 0000000000000000 C0000000095D7C88 
> > GPR20: C000000001E7C440 0000000000000000 0000000000000001 C000000008ACEAE0 
> > GPR24: 0000000000000020 C000000000E50C80 0000000081F84C5E C000000001C00BE0 
> > GPR28: C000000001C05430 C000000001C00B80 C000000000570F30 C000000001FD1720 
> > NIP [C000000000295434] .spider_net_xmit+0x1dc/0x448
> > LR [C000000000295420] .spider_net_xmit+0x1c8/0x448
> > Call Trace:
> > [C0000000095D70B0] [C000000000295420] .spider_net_xmit+0x1c8/0x448 (unreliable)
> > [C0000000095D7160] [C000000000327EE8] .dev_hard_start_xmit+0x238/0x300
> > [C0000000095D7200] [C00000000033A7F4] .__qdisc_run+0xdc/0x2a4
> > [C0000000095D72B0] [C00000000032A948] .dev_queue_xmit+0x1b0/0x2fc
> > [C0000000095D7350] [C00000000034B470] .ip_output+0x280/0x2d8
> > [C0000000095D73F0] [C00000000034C6CC] .ip_queue_xmit+0x448/0x4d8
> > [C0000000095D74F0] [C00000000035F6D8] .tcp_transmit_skb+0x850/0x8c0
> > [C0000000095D75C0] [C00000000035C394] .__tcp_ack_snd_check+0x84/0xc0
> > [C0000000095D7650] [C00000000035E114] .tcp_rcv_established+0x4f0/0x8ac
> > [C0000000095D7700] [C000000000365B24] .tcp_v4_do_rcv+0x5c/0x448
> > [C0000000095D77D0] [C00000000031C2C4] .release_sock+0x94/0x11c
> > [C0000000095D7870] [C000000000354E7C] .tcp_recvmsg+0x374/0x8d8
> > [C0000000095D7960] [C00000000031B8A0] .sock_common_recvmsg+0x5c/0x84
> > [C0000000095D79F0] [C00000000031921C] .sock_recvmsg+0x110/0x15c
> > [C0000000095D7C00] [C00000000031AA50] .sys_recvfrom+0xf0/0x174
> > [C0000000095D7D90] [C000000000339368] .compat_sys_socketcall+0x178/0x214
> > [C0000000095D7E30] [C000000000008634] syscall_exit+0x0/0x40
> > Instruction dump:
> > 60000000 81790088 901f000c 913f0018 913f0008 917f0004 48132e8d 60000000 
> > a019009e 2f800800 409e0038 e9390038 <88690009> 2f830006 419e0010 2f830011 
> > 

spider_net.o:     file format elf64-powerpc
Disassembly of section .text:


Below is the full disassembly of spider_net_xmit()
Note that the compiler has inlined spider_net_prepare_tx_descr()
which makes it somewhat harder to read. Disassembly picks
up in the middle of spider_net_prepare_tx_descr(), below.

My compiler generated slightly different code than Tsutomu
so the offsets are a little off, but the crashing instruction 
is so unique, its easy to find. I got lucky :-)

000000000000313c <.spider_net_xmit>:
    313c:	7c 08 02 a6 	mflr    r0
    3140:	fb 21 ff c8 	std     r25,-56(r1)
    3144:	fb 61 ff d8 	std     r27,-40(r1)
    3148:	fb a1 ff e8 	std     r29,-24(r1)
    314c:	fb c1 ff f0 	std     r30,-16(r1)
    3150:	fb e1 ff f8 	std     r31,-8(r1)
    3154:	fb 41 ff d0 	std     r26,-48(r1)
    3158:	f8 01 00 10 	std     r0,16(r1)
    315c:	fb 81 ff e0 	std     r28,-32(r1)
    3160:	f8 21 ff 51 	stdu    r1,-176(r1)
    3164:	eb c2 00 00 	ld      r30,0(r2)
    3168:	3b a4 07 80 	addi    r29,r4,1920
    316c:	7c 79 1b 78 	mr      r25,r3
    3170:	7c 9f 23 78 	mr      r31,r4
    3174:	7f a3 eb 78 	mr      r3,r29
    3178:	38 80 00 00 	li      r4,0
    317c:	3b 7f 07 e0 	addi    r27,r31,2016
    3180:	4b ff e1 d1 	bl      1350 <.spider_net_release_tx_chain>
    3184:	e8 1d 00 08 	ld      r0,8(r29)
    3188:	e8 99 00 b0 	ld      r4,176(r25)
    318c:	38 60 00 00 	li      r3,0
    3190:	80 b9 00 70 	lwz     r5,112(r25)
    3194:	2f a0 00 00 	cmpdi   cr7,r0,0
    3198:	41 9e 00 1c 	beq-    cr7,31b4 <.spider_net_xmit+0x78>
    319c:	34 60 00 70 	addic.  r3,r0,112
    31a0:	41 82 00 14 	beq-    31b4 <.spider_net_xmit+0x78>
    31a4:	e8 03 02 30 	ld      r0,560(r3)
    31a8:	2f a0 00 00 	cmpdi   cr7,r0,0
    31ac:	7c 09 03 78 	mr      r9,r0
    31b0:	40 9e 00 08 	bne-    cr7,31b8 <.spider_net_xmit+0x7c>
    31b4:	39 20 00 00 	li      r9,0
    31b8:	7d 20 00 74 	cntlzd  r0,r9
    31bc:	78 00 d1 82 	rldicl  r0,r0,58,6
    31c0:	0b 00 00 00 	tdnei   r0,0
    31c4:	e9 29 00 10 	ld      r9,16(r9)
    31c8:	38 c0 00 01 	li      r6,1
    31cc:	e8 09 00 00 	ld      r0,0(r9)
    31d0:	f8 41 00 28 	std     r2,40(r1)
    31d4:	7c 09 03 a6 	mtctr   r0
    31d8:	e9 69 00 10 	ld      r11,16(r9)
    31dc:	e8 49 00 08 	ld      r2,8(r9)
    31e0:	4e 80 04 21 	bctrl
    31e4:	e8 41 00 28 	ld      r2,40(r1)
    31e8:	2f a3 ff ff 	cmpdi   cr7,r3,-1
    31ec:	7c 7a 1b 78 	mr      r26,r3
    31f0:	40 9e 00 44 	bne-    cr7,3234 <.spider_net_xmit+0xf8>
    31f4:	e8 1d 01 82 	lwa     r0,384(r29)
    31f8:	78 09 cf e3 	rldicl. r9,r0,57,63
    31fc:	41 82 00 28 	beq-    3224 <.spider_net_xmit+0xe8>
    3200:	48 00 00 01 	bl      3200 <.spider_net_xmit+0xc4>
    3204:	60 00 00 00 	nop
    3208:	2f a3 00 00 	cmpdi   cr7,r3,0
    320c:	41 9e 00 18 	beq-    cr7,3224 <.spider_net_xmit+0xe8>
    3210:	e8 7e 82 80 	ld      r3,-32128(r30)
    3214:	80 b9 00 70 	lwz     r5,112(r25)
    3218:	e8 99 00 b0 	ld      r4,176(r25)
    321c:	48 00 00 01 	bl      321c <.spider_net_xmit+0xe0>
    3220:	60 00 00 00 	nop
    3224:	e9 3d 02 60 	ld      r9,608(r29)
    3228:	39 29 00 01 	addi    r9,r9,1
    322c:	f9 3d 02 60 	std     r9,608(r29)
    3230:	48 00 01 6c 	b       339c <.spider_net_xmit+0x260>
    3234:	7f 63 db 78 	mr      r3,r27
    3238:	48 00 00 01 	bl      3238 <.spider_net_xmit+0xfc>
    323c:	60 00 00 00 	nop
    3240:	eb 9d 00 68 	ld      r28,104(r29)
    3244:	e9 3b 00 10 	ld      r9,16(r27)
    3248:	7c 64 1b 78 	mr      r4,r3
    324c:	e9 7c 00 18 	ld      r11,24(r28)
    3250:	e8 09 00 20 	ld      r0,32(r9)
    3254:	7f ab 00 00 	cmpd    cr7,r11,r0
    3258:	40 9e 00 78 	bne-    cr7,32d0 <.spider_net_xmit+0x194>
    325c:	7f 63 db 78 	mr      r3,r27
    3260:	48 00 00 01 	bl      3260 <.spider_net_xmit+0x124>
    3264:	60 00 00 00 	nop
    3268:	e8 1d 00 08 	ld      r0,8(r29)
    326c:	80 b9 00 70 	lwz     r5,112(r25)
    3270:	38 60 00 00 	li      r3,0
    3274:	2f a0 00 00 	cmpdi   cr7,r0,0
    3278:	41 9e 00 1c 	beq-    cr7,3294 <.spider_net_xmit+0x158>
    327c:	34 60 00 70 	addic.  r3,r0,112
    3280:	41 82 00 14 	beq-    3294 <.spider_net_xmit+0x158>
    3284:	e8 03 02 30 	ld      r0,560(r3)
    3288:	2f a0 00 00 	cmpdi   cr7,r0,0
    328c:	7c 09 03 78 	mr      r9,r0
    3290:	40 9e 00 08 	bne-    cr7,3298 <.spider_net_xmit+0x15c>
    3294:	39 20 00 00 	li      r9,0
    3298:	7d 20 00 74 	cntlzd  r0,r9
    329c:	78 00 d1 82 	rldicl  r0,r0,58,6
    32a0:	0b 00 00 00 	tdnei   r0,0
    32a4:	e9 29 00 18 	ld      r9,24(r9)
    32a8:	7f 44 d3 78 	mr      r4,r26
    32ac:	38 c0 00 01 	li      r6,1
    32b0:	e8 09 00 00 	ld      r0,0(r9)
    32b4:	f8 41 00 28 	std     r2,40(r1)
    32b8:	7c 09 03 a6 	mtctr   r0
    32bc:	e9 69 00 10 	ld      r11,16(r9)
    32c0:	e8 49 00 08 	ld      r2,8(r9)
    32c4:	4e 80 04 21 	bctrl
    32c8:	e8 41 00 28 	ld      r2,40(r1)
    32cc:	48 00 00 d0 	b       339c <.spider_net_xmit+0x260>
    32d0:	eb fc 00 00 	ld      r31,0(r28)
    32d4:	f9 7b 00 08 	std     r11,8(r27)
    32d8:	3c 00 a0 04 	lis     r0,-24572
    32dc:	39 60 00 00 	li      r11,0
    32e0:	fb 3c 00 08 	std     r25,8(r28)
    32e4:	7f 63 db 78 	mr      r3,r27
    32e8:	93 5f 00 00 	stw     r26,0(r31)
    32ec:	60 00 00 00 	nop

r25 points to struct sk_buff * skb 

    32f0:	81 39 00 70 	lwz     r9,112(r25)  skb->len
    32f4:	90 1f 00 0c 	stw     r0,12(r31)  dmac_cmd_status;
    32f8:	91 7f 00 18 	stw     r11,24(r31) data_status;
    32fc:	91 7f 00 08 	stw     r11,8(r31)  next_descr_addr;
    3300:	91 3f 00 04 	stw     r9,4(r31)  buf_size;

r31 is ptr to struct spider_net_hw_descr * hwdescr 
above insns are
   hwdescr->buf_addr = buf;
   hwdescr->buf_size = skb->len;
   hwdescr->next_descr_addr = 0;
   hwdescr->data_status = 0;


    3304:	48 00 00 01 	bl      3304 <.spider_net_xmit+0x1c8>
    3308:	60 00 00 00 	nop
bl to spin_unlock_irqrestore() ?!

r25 is skb and 128(skb) is ip_summed and the
next 7 insn's bit flag manipulation to pull this out.

    330c:	e8 19 00 80 	ld      r0,128(r25)
    3310:	3d 20 30 00 	lis     r9,12288
    3314:	61 29 08 00 	ori     r9,r9,2048
    3318:	78 00 23 02 	rldicl  r0,r0,36,12
    331c:	78 00 e0 a0 	rldicl  r0,r0,28,34
    3320:	7f a0 48 00 	cmpd    cr7,r0,r9
    3324:	40 9e 00 40 	bne-    cr7,3364 <.spider_net_xmit+0x228>

Now the case statement, which is several inlines:
switch (ip_hdr(skb)->protocol) {

static inline struct iphdr *ip_hdr(const struct sk_buff *skb)
{
   return (struct iphdr *)skb_network_header(skb);
}
static inline unsigned char *skb_network_header(const struct sk_buff
*skb)
{
   return skb->head + skb->network_header;
}

    3328:	80 19 00 98 	lwz     r0,152(r25) skb->network_header
    332c:	e9 39 00 a8 	ld      r9,168(r25) skb->head
    3330:	7d 29 02 14 	add     r9,r9,r0    skb->head + skb->network_header;
    3334:	88 69 00 09 	lbz     r3,9(r9)   struct iphdr ->protocol

crash here , r9 is null

 __u8  protocol; is exactly 9 bytes into struct iphdr 


switch (ip_hdr(skb)->protocol) {
    3338:	2f 83 00 06 	cmpwi   cr7,r3,6
    333c:	41 9e 00 10 	beq-    cr7,334c <.spider_net_xmit+0x210>
    3340:	2f 83 00 11 	cmpwi   cr7,r3,17

    3344:	40 9e 00 20 	bne-    cr7,3364 <.spider_net_xmit+0x228>
    3348:	48 00 00 10 	b       3358 <.spider_net_xmit+0x21c>

case IPPROTO_TCP:
    334c:	80 1f 00 0c 	lwz     r0,12(r31)

hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
    3350:	64 00 00 02 	oris    r0,r0,2
    3354:	48 00 00 0c 	b       3360 <.spider_net_xmit+0x224>
case IPPROTO_UDP:
    3358:	80 1f 00 0c 	lwz     r0,12(r31)
hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_UDP;
    335c:	64 00 00 03 	oris    r0,r0,3
    3360:	90 1f 00 0c 	stw     r0,12(r31)
wmb()
    3364:	7c 00 04 ac 	sync    

    3368:	e9 3c 00 20 	ld      r9,32(r28)
    336c:	80 1c 00 10 	lwz     r0,16(r28)
    3370:	3b 80 00 00 	li      r28,0
    3374:	e9 7e 80 78 	ld      r11,-32648(r30)
    3378:	e9 29 00 00 	ld      r9,0(r9)
    337c:	90 09 00 08 	stw     r0,8(r9)
    3380:	60 00 00 00 	nop
    3384:	e8 0b 00 00 	ld      r0,0(r11)
    3388:	e9 3d 00 00 	ld      r9,0(r29)
    338c:	f8 09 03 18 	std     r0,792(r9)
    3390:	60 00 00 00 	nop
    3394:	e9 7d 00 70 	ld      r11,112(r29)
    3398:	48 00 00 5c 	b       33f4 <.spider_net_xmit+0x2b8>
    339c:	e9 7d 01 c0 	ld      r11,448(r29)
    33a0:	39 3f 00 40 	addi    r9,r31,64
    33a4:	38 00 00 01 	li      r0,1
    33a8:	39 6b 00 01 	addi    r11,r11,1
    33ac:	f9 7d 01 c0 	std     r11,448(r29)
    33b0:	60 00 00 00 	nop
    33b4:	60 00 00 00 	nop
    33b8:	60 00 00 00 	nop
    33bc:	7d 60 48 a8 	ldarx   r11,0,r9
    33c0:	7d 6b 03 78 	or      r11,r11,r0
    33c4:	7d 60 49 ad 	stdcx.  r11,0,r9
    33c8:	40 a2 ff f4 	bne-    33bc <.spider_net_xmit+0x280>
    33cc:	38 60 00 01 	li      r3,1
    33d0:	48 00 01 a0 	b       3570 <.spider_net_xmit+0x434>
    33d4:	e9 2b 00 00 	ld      r9,0(r11)
    33d8:	80 09 00 0c 	lwz     r0,12(r9)
    33dc:	3d 20 f0 00 	lis     r9,-4096
    33e0:	54 00 00 06 	rlwinm  r0,r0,0,0,3
    33e4:	7f 80 48 00 	cmpw    cr7,r0,r9
    33e8:	41 9e 00 1c 	beq-    cr7,3404 <.spider_net_xmit+0x2c8>
    33ec:	e9 6b 00 18 	ld      r11,24(r11)
    33f0:	7d 5c 07 b4 	extsw   r28,r10
    33f4:	e8 1d 00 68 	ld      r0,104(r29)
    33f8:	39 5c 00 01 	addi    r10,r28,1
    33fc:	7f ab 00 00 	cmpd    cr7,r11,r0
    3400:	40 9e ff d4 	bne+    cr7,33d4 <.spider_net_xmit+0x298>
    3404:	80 1d 00 80 	lwz     r0,128(r29)
    3408:	7c 00 16 70 	srawi   r0,r0,2
    340c:	7c 00 01 94 	addze   r0,r0
    3410:	7f 80 e0 00 	cmpw    cr7,r0,r28
    3414:	41 9d 00 a4 	bgt-    cr7,34b8 <.spider_net_xmit+0x37c>
    3418:	1c 1c 00 03 	mulli   r0,r28,3
    341c:	eb fd 00 70 	ld      r31,112(r29)
    3420:	7c 00 16 70 	srawi   r0,r0,2
    3424:	7c 00 01 94 	addze   r0,r0
    3428:	7c 1c 07 b4 	extsw   r28,r0
    342c:	2f 9c 00 00 	cmpwi   cr7,r28,0
    3430:	7b 89 00 20 	clrldi  r9,r28,32
    3434:	39 29 00 01 	addi    r9,r9,1
    3438:	7d 29 03 a6 	mtctr   r9
    343c:	41 9c 00 10 	blt-    cr7,344c <.spider_net_xmit+0x310>
    3440:	3c 00 80 00 	lis     r0,-32768
    3444:	7f 9c 00 00 	cmpw    cr7,r28,r0
    3448:	40 be 00 14 	bne+    cr7,345c <.spider_net_xmit+0x320>
    344c:	38 00 00 01 	li      r0,1
    3450:	7c 09 03 a6 	mtctr   r0
    3454:	48 00 00 08 	b       345c <.spider_net_xmit+0x320>
    3458:	eb ff 00 18 	ld      r31,24(r31)
    345c:	42 00 ff fc 	bdnz+   3458 <.spider_net_xmit+0x31c>
    3460:	38 7d 00 60 	addi    r3,r29,96
    3464:	48 00 00 01 	bl      3464 <.spider_net_xmit+0x328>
    3468:	60 00 00 00 	nop
    346c:	e9 3f 00 00 	ld      r9,0(r31)
    3470:	80 09 00 0c 	lwz     r0,12(r9)
    3474:	64 00 00 80 	oris    r0,r0,128
    3478:	90 09 00 0c 	stw     r0,12(r9)
    347c:	e9 3d 00 d0 	ld      r9,208(r29)
    3480:	2f a9 00 00 	cmpdi   cr7,r9,0
    3484:	41 9e 00 20 	beq-    cr7,34a4 <.spider_net_xmit+0x368>
    3488:	7f a9 f8 00 	cmpd    cr7,r9,r31
    348c:	41 9e 00 18 	beq-    cr7,34a4 <.spider_net_xmit+0x368>
    3490:	e9 29 00 00 	ld      r9,0(r9)
    3494:	80 09 00 0c 	lwz     r0,12(r9)
    3498:	78 00 40 42 	rldicl  r0,r0,40,1
    349c:	78 00 c0 20 	rldicl  r0,r0,24,32
    34a0:	90 09 00 0c 	stw     r0,12(r9)
    34a4:	fb fd 00 d0 	std     r31,208(r29)
    34a8:	7c 64 1b 78 	mr      r4,r3
    34ac:	38 7d 00 60 	addi    r3,r29,96
    34b0:	48 00 00 01 	bl      34b0 <.spider_net_xmit+0x374>
    34b4:	60 00 00 00 	nop
    34b8:	2f 9c 00 04 	cmpwi   cr7,r28,4
    34bc:	38 60 00 00 	li      r3,0
    34c0:	41 9d 00 b0 	bgt-    cr7,3570 <.spider_net_xmit+0x434>
    34c4:	48 00 00 40 	b       3504 <.spider_net_xmit+0x3c8>
    34c8:	e9 7d 00 58 	ld      r11,88(r29)
    34cc:	81 2a 00 10 	lwz     r9,16(r10)
    34d0:	38 0b 0e 00 	addi    r0,r11,3584
    34d4:	7c 00 04 ac 	sync    
    34d8:	91 2b 0e 00 	stw     r9,3584(r11)
    34dc:	39 00 00 01 	li      r8,1
    34e0:	3d 20 80 00 	lis     r9,-32768
    34e4:	99 0d 01 dc 	stb     r8,476(r13)
    34e8:	61 29 03 00 	ori     r9,r9,768
    34ec:	e9 7d 00 58 	ld      r11,88(r29)
    34f0:	38 0b 0e 04 	addi    r0,r11,3588
    34f4:	7c 00 04 ac 	sync    
    34f8:	91 2b 0e 04 	stw     r9,3588(r11)
    34fc:	99 0d 01 dc 	stb     r8,476(r13)
    3500:	48 00 00 54 	b       3554 <.spider_net_xmit+0x418>
    3504:	e9 3d 00 58 	ld      r9,88(r29)
    3508:	38 09 0e 04 	addi    r0,r9,3588
    350c:	7c 00 04 ac 	sync    
    3510:	80 09 0e 04 	lwz     r0,3588(r9)
    3514:	0c 00 00 00 	twi     0,r0,0
    3518:	4c 00 01 2c 	isync
    351c:	2f 80 00 00 	cmpwi   cr7,r0,0
    3520:	41 9c 00 34 	blt-    cr7,3554 <.spider_net_xmit+0x418>
    3524:	e9 5d 00 70 	ld      r10,112(r29)
    3528:	3d 60 a0 00 	lis     r11,-24576
    352c:	e9 2a 00 00 	ld      r9,0(r10)
    3530:	80 09 00 0c 	lwz     r0,12(r9)
    3534:	54 00 00 06 	rlwinm  r0,r0,0,0,3
    3538:	7f 80 58 00 	cmpw    cr7,r0,r11
    353c:	41 9e ff 8c 	beq+    cr7,34c8 <.spider_net_xmit+0x38c>
    3540:	e8 1d 00 68 	ld      r0,104(r29)
    3544:	7f aa 00 00 	cmpd    cr7,r10,r0
    3548:	41 9e 00 0c 	beq-    cr7,3554 <.spider_net_xmit+0x418>
    354c:	e9 4a 00 18 	ld      r10,24(r10)
    3550:	4b ff ff dc 	b       352c <.spider_net_xmit+0x3f0>
    3554:	e9 3e 80 78 	ld      r9,-32648(r30)
    3558:	38 7d 01 10 	addi    r3,r29,272
    355c:	e8 89 00 00 	ld      r4,0(r9)
    3560:	38 84 00 32 	addi    r4,r4,50
    3564:	48 00 00 01 	bl      3564 <.spider_net_xmit+0x428>
    3568:	60 00 00 00 	nop
    356c:	38 60 00 00 	li      r3,0
    3570:	38 21 00 b0 	addi    r1,r1,176
    3574:	e8 01 00 10 	ld      r0,16(r1)
    3578:	eb 21 ff c8 	ld      r25,-56(r1)
    357c:	eb 41 ff d0 	ld      r26,-48(r1)
    3580:	eb 61 ff d8 	ld      r27,-40(r1)
    3584:	eb 81 ff e0 	ld      r28,-32(r1)
    3588:	eb a1 ff e8 	ld      r29,-24(r1)
    358c:	eb c1 ff f0 	ld      r30,-16(r1)
    3590:	eb e1 ff f8 	ld      r31,-8(r1)
    3594:	7c 08 03 a6 	mtlr    r0
    3598:	4e 80 00 20 	blr
_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev

----- End forwarded message -----
