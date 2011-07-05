From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH v2 net-next af-packet 1/2] Enhance af-packet to provide
 (near zero)lossless packet capture functionality.
Date: Tue, 5 Jul 2011 10:53:26 -0400
Message-ID: <CAAsGZS5vvmb_qX+cG507=hU_+kwnowEEojXGNMt5ShEZ9+ZeAA@mail.gmail.com>
References: <1308708650-25509-1-git-send-email-loke.chetan@gmail.com>
	<1308708650-25509-2-git-send-email-loke.chetan@gmail.com>
	<20110701.153633.267893668051099806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110701.153633.267893668051099806.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 1, 2011 at 6:36 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Chetan Loke <loke.chetan@gmail.com>
> Date: Tue, 21 Jun 2011 22:10:49 -0400
>
>> +struct bd_v1 {
> =C2=A0-
>> + =C2=A0 =C2=A0 __u32 =C2=A0 block_status;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 num_pkts;
>> + =C2=A0 =C2=A0 __u32 =C2=A0 offset_to_first_pkt;
> =C2=A0-
>> + =C2=A0 =C2=A0 __u32 =C2=A0 blk_len;
> =C2=A0-
>> + =C2=A0 =C2=A0 __u64 =C2=A0 seq_num;
> =C2=A0...
>> + =C2=A0 =C2=A0 union {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __u32 =C2=A0 words[4];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __u64 =C2=A0 dword;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } __attribute__ ((__pack=
ed__));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bd_v1 bd1;
> =C2=A0...
>> +#define BLOCK_STATUS(x) =C2=A0 =C2=A0 =C2=A0((x)->words[0])
>> +#define BLOCK_NUM_PKTS(x) =C2=A0 =C2=A0((x)->words[1])
>> +#define BLOCK_O2FP(x) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((x)->words[2])
>> +#define BLOCK_LEN(x) =C2=A0 =C2=A0 =C2=A0 =C2=A0 ((x)->words[3])
>> +#define BLOCK_SNUM(x) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0((x)->dword)
>

Sorry, I was out on the long weekend. So couldn't get to this sooner.

> This BLOCK_SNUM definition is buggy. =C2=A0It modifies the
> first 64-bit word in the block descriptor.
>
> But the sequence number lives 16 bytes into the descriptor.

hmm? the words/dword are enveloped within a 'struct'. Can you please
double check?

>
> This value is only written to once and never used by anything.
> I would just remove it entirely.
>

It is used by the applications. Look at the code comments:
	/*
	 * Quite a few uses of sequence number:
	 * 1. Make sure cache flush etc worked.
	 *    Well, one can argue - why not use the increasing ts below?
	 *    But look at 2. below first.
	 * 2. When you pass around blocks to other user space decoders,
	 *    you can see which blk[s] is[are] outstanding etc.
	 * 3. Validate kernel code.
	 */


> Next, having this overlay thing is entirely pointless. =C2=A0Just ref=
er to

It is useful.
Also, future versions of the block-descriptor can append a new field.
When that happens,
none of the code needs to worry about the version etc for the unchanged=
 fields.
Look at setsockopt - I had to add an 'union' and pass that around to
avoid minimal code churn.
So the overlay may not be pointless.

> the block descriptor members directly! =C2=A0You certainly wouldn't h=
ave
> had this sequence number bug if you had done that.
>
Look at the sample app posted on:
git://lolpcap.git.sourceforge.net/gitroot/lolpcap/lolpcap

function - void validate_blk_seq_num(struct block_desc *pbd)

This function validates the block_sequence_number (which is
incremented sequentially).
The application attempts to validate the entire block layout.


Chetan Loke
