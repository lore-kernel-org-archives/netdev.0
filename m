From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [PATCH] drivers: staging: lustre: lustre: include: add
 "__attribute__((packed))" for the related union
Date: Mon, 3 Feb 2014 11:02:58 +0000
Message-ID: <52EF7762.2060809@imgtec.com>
References: <20140118142404.GT7444@mwanda> <52DBA3D4.3090308@gmail.com>
 <52DD0EFF.2010305@imgtec.com> <20140120123045.GV7444@mwanda>
 <52DD18A5.1090308@imgtec.com> <20140120125603.GD4815@mwanda>
 <20140120211356.GG4815@mwanda> <52DE4DA3.7090301@imgtec.com>
 <52E3A642.7010307@gmail.com> <52ECFD53.7010401@gmail.com>
 <20140203085855.GA26722@mwanda>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B772B@AcuExch.aculab.com>
 <52EF6DCC.6040807@imgtec.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B777A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "andreas.dilger@intel.com" <andreas.dilger@intel.com>,
 Chen Gang <gang.chen.5i5j@gmail.com>, Greg KH <gregkh@linuxfoundation.org>,
 "bergwolf@gmail.com" <bergwolf@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>,
 "oleg.drokin@intel.com" <oleg.drokin@intel.com>,
 "jacques-charles.lafoucriere@cea.fr" <jacques-charles.lafoucriere@cea.fr>,
 Antonio Quartulli <antonio@meshcoding.com>, netdev <netdev@vger.kernel.org>,
 "jinshan.xiong@intel.com" <jinshan.xiong@intel.com>,
 David Miller <davem@davemloft.net>, 'Dan Carpenter' <dan.carpenter@oracle.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6B777A@AcuExch.aculab.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 03/02/14 10:35, David Laight wrote:
> From: James Hogan 
>> On 03/02/14 10:05, David Laight wrote:
>>> Architectures that define such alignment rules are a right PITA.
>>> You either need to get the size to 2 without using 'packed', or
>>> just not define such structures.
>>> It is worth seeing if adding aligned(2) will change the size - I'm
>>> not sure.
>>
>> __aligned(2) alone doesn't seem to have any effect on sizeof() or
>> __alignof__() unless it is accompanied by __packed. x86_64 is similar in
>> that respect (it just packs sanely in the first place).
>>
>> Combining __packed with __aligned(2) does the trick though (__packed
>> alone sets __aligned(1) which is obviously going to be suboptimal).
> 
> Compile some code for a cpu that doesn't support misaligned transfers
> (probably one of sparc, arm, ppc) and see if the compiler generates a
> single 16bit request or two 8 bits ones.
> You don't want the compiler generating multiple byte-sized memory transfers.

Meta is also one of those arches, and according to my quick tests,
__packed alone does correctly make it fall back to byte loads/stores,
but with __packed __aligned(2) it uses 16bit loads/stores. I've also
confirmed that with an ARM toolchain (see below for example).

Cheers
James

input:

#define __aligned(x)			__attribute__((aligned(x)))
#define __packed			__attribute__((packed))

union a {
	short x, y;
} __aligned(2) __packed;

struct b {
	short x;
} __aligned(2) __packed;

unsigned int soa = sizeof(union a);
unsigned int aoa = __alignof__(union a);
unsigned int sob = sizeof(struct b);
unsigned int aob = __alignof__(struct b);

void t(struct b *x, union a *y)
{
	++x->x;
	++y->x;
}

ARM output (-O2):

	.cpu arm10tdmi
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 2
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"alignment4.c"
	.text
	.align	2
	.global	t
	.type	t, %function
t:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldrh	r3, [r0, #0]
	add	r3, r3, #1
	strh	r3, [r0, #0]	@ movhi
	ldrh	r3, [r1, #0]
	add	r3, r3, #1
	strh	r3, [r1, #0]	@ movhi
	bx	lr
	.size	t, .-t
	.global	aob
	.global	sob
	.global	aoa
	.global	soa
	.data
	.align	2
	.type	aob, %object
	.size	aob, 4
aob:
	.word	2
	.type	sob, %object
	.size	sob, 4
sob:
	.word	2
	.type	aoa, %object
	.size	aoa, 4
aoa:
	.word	2
	.type	soa, %object
	.size	soa, 4
soa:
	.word	2
	.ident	"GCC: (GNU) 4.7.1 20120606 (Red Hat 4.7.1-0.1.20120606)"
	.section	.note.GNU-stack,"",%progbits
