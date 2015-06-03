From: Ivan Mikhaylov <ivan@ru.ibm.com>
Subject: Re: [PATCH] ethtool: changes of emac_regs structure accordingly
 within driver emac_regs structure.
Date: Wed, 3 Jun 2015 18:28:37 +0400
Message-ID: <20150603182837.33a81a08@fr-ThinkPad-W520>
References: <20150521190917.6971eb09@fr-ThinkPad-W520>
	<20150601163057.01717aef@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:56119 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbbFCPZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 11:25:58 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ivan@ru.ibm.com>;
	Wed, 3 Jun 2015 16:25:56 +0100
In-Reply-To: <20150601163057.01717aef@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Jun 2015 22:11:00 +0400
Ben Hutchings <ben@decadent.org.uk> wrote:

>On Mon, 2015-06-01 at 16:30 +0400, Ivan Mikhaylov wrote:
>> On Mon, 1 June 2015 12:57 +0400
>> Ben Hutchings <ben@decadent.org.uk> wrote:
>> 
>> >On Thu, 2015-05-21 at 19:09 +0400, Ivan Mikhaylov wrote:
>> >> In ibm_emac.c in ethtool size of emac structure which passing
>> >> through to driver is nailed down and not correlating with current
>> >> emac_regs structure.
>> >> 
>> >> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
>> >[...]
>> >
>> >This is not backward-compatible.  It ought to be possible to mix and
>> >match old and new ethtool and driver, except for the EMAC4SYNC case
>> >which has been broken up until now.
>> >
>> >Using the new definition of struct emac_regs, I think the driver and
>> >ethtool need to agree that the MAC register dump sizes are:
>> >
>> >EMAC:      offsetof(struct emac_regs, u1)
>> >EMAC4:     offsetof(struct emac_regs, u1.emac4) + sizeof(p->u1.emac4)
>> >EMAC4SYNC: offsetof(struct emac_regs, u1.emac4sync) +
>> >sizeof(p->u1.emac4sync)
>> >
>> >Ben.
>> >
>> >-- 
>> >Ben Hutchings
>> >Reality is just a crutch for people who can't handle science fiction.
>> 
>> Actually it is backward-compatible because we don't care about size
>> which is coming from driver side, only what we doing is map of driver
>> structure to ethtool structure and results will be same
>> for emac and emac4.
>> 
>>  struct emac_regs *p = (struct emac_regs *)(hdr + 1);
>
>The following registers won't be printed correctly.

But they will, how can I prove it? May be some examples you need?
I can show you 4 case for emac4sync that I've :
1. old ethtool old driver
2. patched ethtool old driver
3. patched ethtool patched driver
4. old ethtool patched driver

First 112 byte for emac and emac4 are same so part of this patch is wrong,
I admit it.

Should be something like :
+	} else if (hdr->version == EMAC4_VERSION || hdr->version == EMAC_VERSION) {
+		printf("IAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.iaht1, p->u0.emac4.iaht2,
+			p->u0.emac4.iaht3, p->u0.emac4.iaht4);
+
+		printf("GAHT  = 0x%04x 0x%04x 0x%04x 0x%04x\n",
+			p->u0.emac4.gaht1, p->u0.emac4.gaht2,
+			p->u0.emac4.gaht3, p->u0.emac4.gaht4);
+
+		printf(" IPCR = 0x%08x\n\n", p->u1.emac4.ipcr);
 	}

Size of this struct equals 
struct emac_regs {
	u32 mr0;
	u32 mr1;
	u32 tmr0;
	u32 tmr1;
	u32 rmr;
	u32 isr;
	u32 iser;
	u32 iahr;
	u32 ialr;
	u32 vtpid;
	u32 vtci;
	u32 ptr;
	u32 iaht1;
	u32 iaht2;
	u32 iaht3;
	u32 iaht4;
	u32 gaht1;
	u32 gaht2;
	u32 gaht3;
	u32 gaht4;
	u32 lsah;
	u32 lsal;
	u32 ipgvr;
	u32 stacr;
	u32 trtr;
	u32 rwmr;
	u32 octx;
	u32 ocrx;
	u32 ipcr;
};

this struct 

struct emac_regs {
	/* Common registers across all EMAC implementations. */
	u32 mr0;			/* Special 	*/
	u32 mr1;			/* Reset 	*/
	u32 tmr0;			/* Special 	*/
	u32 tmr1;			/* Special 	*/
	u32 rmr;			/* Reset 	*/
	u32 isr;			/* Always 	*/
	u32 iser;			/* Reset 	*/
	u32 iahr;			/* Reset, R, T 	*/
	u32 ialr;			/* Reset, R, T 	*/
	u32 vtpid;			/* Reset, R, T 	*/
	u32 vtci;			/* Reset, R, T 	*/
	u32 ptr;			/* Reset,    T 	*/
	union {
		/* Registers unique to EMAC4 implementations */
		struct {
			u32 iaht1;	/* Reset, R	*/
			u32 iaht2;	/* Reset, R	*/
			u32 iaht3;	/* Reset, R	*/
			u32 iaht4;	/* Reset, R	*/
			u32 gaht1;	/* Reset, R	*/
			u32 gaht2;	/* Reset, R	*/
			u32 gaht3;	/* Reset, R	*/
			u32 gaht4;	/* Reset, R	*/
		} emac4;
		/* Registers unique to EMAC4SYNC implementations */
		//struct {
		//	u32 mahr;	/* Reset, R, T  */
		//	u32 malr;	/* Reset, R, T  */
		//	u32 mmahr;	/* Reset, R, T  */
		//	u32 mmalr;	/* Reset, R, T  */
		//	u32 rsvd0[4];
		//} emac4sync;
	} u0;
	/* Common registers across all EMAC implementations. */
	u32 lsah;
	u32 lsal;
	u32 ipgvr;			/* Reset,    T 	*/
	u32 stacr;			/* Special 	*/
	u32 trtr;			/* Special 	*/
	u32 rwmr;			/* Reset 	*/
	u32 octx;
	u32 ocrx;
	union {
		/* Registers unique to EMAC4 implementations */
		struct {
			u32 ipcr;
		} emac4;
		/* Registers unique to EMAC4SYNC implementations */
	//	struct {
	//		u32 rsvd1;
	//		u32 revid;
	//		u32 rsvd2[2];
	//		u32 iaht1;	/* Reset, R     */
	//		u32 iaht2;	/* Reset, R     */
	//		u32 iaht3;	/* Reset, R     */
	//		u32 iaht4;	/* Reset, R     */
	//		u32 iaht5;	/* Reset, R     */
	//		u32 iaht6;	/* Reset, R     */
	//		u32 iaht7;	/* Reset, R     */
	//		u32 iaht8;	/* Reset, R     */
	//		u32 gaht1;	/* Reset, R     */
	//		u32 gaht2;	/* Reset, R     */
	//		u32 gaht3;	/* Reset, R     */
	//		u32 gaht4;	/* Reset, R     */
	//		u32 gaht5;	/* Reset, R     */
	//		u32 gaht6;	/* Reset, R     */
	//		u32 gaht7;	/* Reset, R     */
	//		u32 gaht8;	/* Reset, R     */
	//		u32 tpc;	/* Reset, T     */
	//	} emac4sync;
	} u1;
};

Structs emac4 and emac4sync same on size for u0 union.
With emac4sync there is will be 196 because of emac4sync structure in union u1.
All other parts will be same as was even for emac/emac4. So with any updates
memory area for emac/emac4 still same... Even with old drivers for emac/emac4.
