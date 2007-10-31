From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [RFC][BNX2X] .h files rewrite
Date: Wed, 31 Oct 2007 12:14:47 +0200
Message-ID: <1193825688.4836.134.camel@eliezer>
References: <1193602670.4836.25.camel@eliezer>
 <1193602875.4836.28.camel@eliezer>
 <20071029.013931.203090879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, jeff@garzik.org,
	netdev@vger.kernel.org, masbock@us.ibm.com,
	"eilong" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752969AbXJaKNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 06:13:18 -0400
In-Reply-To: <20071029.013931.203090879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Sorry It took so long to answer, I've had to go over a lot of stuff to
make sure I'm giving you accurate answers.)

On Mon, 2007-10-29 at 01:39 -0700, David Miller wrote:
> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Sun, 28 Oct 2007 22:21:14 +0200
> 
> Overall things look significantly better, thanks a lot!
> 
> However, there is still one set of magic constants in here
> which I hope you can clear up:
> 
> > +static const struct raw_op init_ops[] = {
> > +#define PRS_COMMON_START        0
> > +     {OP_WR, PRS_REG_INC_VALUE, 0xf},
> > +     {OP_WR, PRS_REG_EVENT_ID_1, 0x45},
> > +     {OP_WR, PRS_REG_EVENT_ID_2, 0x84},
> > +     {OP_WR, PRS_REG_EVENT_ID_3, 0x6},
> > +     {OP_WR, PRS_REG_NO_MATCH_EVENT_ID, 0x4},
> > +     {OP_WR, PRS_REG_CM_HDR_TYPE_0, 0x0},
> > +     {OP_WR, PRS_REG_CM_HDR_TYPE_1, 0x12170000},
> > +     {OP_WR, PRS_REG_CM_HDR_TYPE_2, 0x22170000},
> > +     {OP_WR, PRS_REG_CM_HDR_TYPE_3, 0x32170000},
> > +     {OP_ZR, PRS_REG_CM_HDR_TYPE_4, 0x5},
> > +     {OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_1, 0x12150000},
> > +     {OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_2, 0x22150000},
> > +     {OP_WR, PRS_REG_CM_HDR_LOOPBACK_TYPE_3, 0x32150000},
> > +     {OP_ZR, PRS_REG_CM_HDR_LOOPBACK_TYPE_4, 0x4},
>  etc. etc.

These are the steps performed to initialize the chip and load the
microcode.

Each element in the array is an operation in the form:
{operation, chip address, value}

Where the operation is one of:
OP_WR - write a value to the chip.
OP_RD - read a register (this is a read with a side effect, usually a
clear on read register).
OP_SW - string write to the chip (parts of the microcode).
OP_SI - string write using indirect write registers.
OP_ZR - clear a range of memory.
OP_ZP - unzip and copy using DMAE.
OP_WB - string copy using DMAE.

(I will add these explanations to bnx2x_init.h)

As you can see there are quite a lot of them, that is because most of
them are setting up the microcode internal structures.
Maybe it would have been better if the microcode were to do these things
but because of size issues it currently is not an option.

We will add comments to all register definitions explaining as much as
possible about each register.

All of the registers that are related to the driver flow are accessed
explicitly inside the driver code in the main .c file.

Writes to memories are simply parts of the microcode.

However, almost all of the registers written to here, are numeric values
not bit constants. The values are derived from HW definitions (and that
was the source of the extra-ugly generated code that we replaced).

In a perfect world almost all of these would have been the reset values
of the registers. 
#include "bitching_about_HW_guys.h"

The added documentation for each register in the register file will
provide all the info that I have about the values.
I feel bad about adding several hundred lines of defines that are only
used once, and do not add any real information about the values.

Your insights would be appreciated.

Thanks,
Eliezer



