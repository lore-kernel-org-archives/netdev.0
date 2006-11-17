From: "Steve Wise" <swise@opengridcomputing.com>
Subject: Re: [PATCH  09/13] Core WQE/CQE Types
Date: Fri, 17 Nov 2006 11:02:44 -0600
Message-ID: <1163782964.8457.35.camel@stevo-desktop>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
 <20061116035912.22635.21736.stgit@dell3.ogc.int>
 <adaveleof4f.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Roland Dreier" <rdreier@cisco.com>
In-Reply-To: <adaveleof4f.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-16 at 20:45 -0800, Roland Dreier wrote:
>  > +struct t3_send_wr {
>  > +	struct fw_riwrh wrh;	/* 0 */
>  > +	union t3_wrid wrid;	/* 1 */
>  > +
>  > +	enum t3_rdma_opcode rdmaop:8;
>  > +	u32 reserved:24;	/* 2 */
> 
> Does this do the right thing wrt endianness?  I'd be more comfortable
> with something like
> 
> 	u8 rdmaop;
>         u8 reserved[3];
> 
> (although the __attribute__((packed)) on enum t3_rdma_opcode does make
> it OK to use here, I guess)
> 
>  > +	u32 rem_stag;		/* 2 */
>  > +	u32 plen;		/* 3 */
>  > +	u32 num_sgle;
>  > +	struct t3_sge sgl[T3_MAX_SGE];	/* 4+ */
>  > +};


I don't really like the bit fields either. I inherited these structs and
I'm not adverse to changing them as you suggest to get rid of bit
fields.  But I think they are correct wrt endianness.  I wrote a test
program and on a LE machine it put the u8 first in memory followed by
the 24 bit reserved.  However, I think if you use bit fields less than 8
bits its not endian safe.

BTW:  I don't have a PPC system (yet) to test this code on BE...

Here's a dumb program that plays around with bit fields...

#include <sys/types.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

struct foo {
	uint32_t 	a:8;
	uint32_t 	b:24;
	uint32_t	c:16;
	uint32_t	d:8;
	uint32_t	e:8;
};

struct bar {
	uint8_t		a;
	uint8_t		b[3];
	uint16_t	c;
	uint8_t		d;
	uint8_t		e;
};

struct bits {
#if 0 /* BE */
	uint32_t	a:4;
	uint32_t	b:4;
#else /* LE */
	uint32_t	b:4;
	uint32_t	a:4;
#endif
	uint32_t	c:8;
	uint32_t	d:8;
	uint32_t	e:8;
};

main()
{
	struct foo foo;
	struct bar bar;
	struct bits bits;
	uint8_t *cp;
	int i;

	foo.a = 0x01;
	foo.b = 0x020304;
	foo.c = 0x0506;
	foo.d = 0x07;
	foo.e = 0x08;

	printf("foo cpu: 0x%" PRIx64 "\n", *(uint64_t *)&foo);
	printf("foo mem: ");
	cp = (uint8_t *)&foo;
	for (i=0; i<8; i++)
		printf("%02x", *cp++);
	printf("\n");

	bar.a = 0x01;
	bar.b[0] = 0x02;
	bar.b[1] = 0x03;
	bar.b[2] = 0x04;
	bar.c = 0x0506;
	bar.d = 0x07;
	bar.e = 0x08;

	printf("bar cpu: 0x%" PRIx64 "\n", *(uint64_t *)&bar);
	printf("bar mem: ");
	cp = (uint8_t *)&bar;
	for (i=0; i<8; i++)
		printf("%02x", *cp++);
	printf("\n");


	bits.a = 0x1;
	bits.b = 0x2;
	bits.c = 0x3;
	bits.d = 0x4;
	bits.e = 0x5;
	
	printf("bits cpu: 0x%08x\n", *(uint32_t *)&bits);
	printf("bar mem: ");
	cp = (uint8_t *)&bits;
	for (i=0; i<4; i++)
		printf("%02x", *cp++);
	printf("\n");
}
