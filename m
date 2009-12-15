From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] net: sh_eth alignment fix for sh7724 using NET_IP_ALIGN
Date: Tue, 15 Dec 2009 16:13:47 +0900
Message-ID: <aec7e5c30912142313p111565d4mc0014c581cd431d4@mail.gmail.com>
References: <20091214103443.13082.84079.sendpatchset@rxone.opensource.se>
	 <20091214.215753.147971281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20091214.215753.147971281.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 2:57 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Magnus Damm <magnus.damm@gmail.com>
> Date: Mon, 14 Dec 2009 19:34:43 +0900
>
>> From: Magnus Damm <damm@opensource.se>
>>
>> Fix sh_eth for sh7724 by adding NET_IP_ALIGN support.
>> Without this patch the receive data is misaligned.
>>
>> Signed-off-by: Magnus Damm <damm@opensource.se>
>
> How does this interact with sh_eth_set_receive_align() and
> why isn't all of the skb_reserve() logic confined to one
> place?

It looks like the driver is written to support a few different
processors, and the alignment requirement varies from processor to
processor. I assume that the mdp->rx_buf_sz calculation takes care of
the alignment, but it all looks pretty messy to me.

Some processors support RPADIR and some do not. The processors that do
support RPADIR can tie in NET_IP_ALIGN support easily. The sh7763
hardware should support RPADIR, but only a partial software
implementation seems to be in place without this patch. And I can't
unfortunately test sh7763 support since I only have sh7724 hardware
available.

That aside, unifying the alignment code and doing a major cleanup
would be nice, yes.

> The sh7763 sh_eth_my_cpu_data sets rpadir unconditionally,
> yet your NET_IP_ALIGN behavior is controlled by the new
> setting of .rpadir for sh7724, is this ok or is it going
> to break sh7763 or cause it to misbehave?

Good point. It may be better to remove the .rpadir setting from sh7763
since it looks unused and broken at this point. OTOH, if RPADIR on
sh7763 does what I suspect then this patch will actually unbreak
sh7763 using the skb_reserve() hunk.

> Could you possibly generalize this so that you don't
> need the ifdefs and it doesn't matter what the NET_IP_ALIGN
> value actually is? =A0That is making this code more confusing
> than it needs to be.

Sorry about the confusion, but the #ifdef was actually intentional. =3D=
)
I can't find any description of the RPADIR register in the sh7724 data
sheet, but testing shows that the buffers are adjusted properly. So
since I don't know the register layout I prefer to optimize for the
known working combination of NET_IP_ALIGN =3D=3D 2 and simply disable
=2Erpadir usage for other NET_IP_ALIGN cases.

Thanks!

/ magnus
