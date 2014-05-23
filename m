From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 09:07:56 +0200
Message-ID: <87ppj5vupf.fsf@nemi.mork.no>
References: <537E4AFD.20304@mentor.com>
	<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140522.171033.1040508444998374401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, jim_baxter@mentor.com,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com,
	bhutchings@solarflare.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140522.171033.1040508444998374401.davem@davemloft.net> (David
	Miller's message of "Thu, 22 May 2014 17:10:33 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 May 2014 14:03:21 -0700
>
>> On Thu, 2014-05-22 at 13:58 -0700, Eric Dumazet wrote:
>>=20
>>> I would set rx_max (rx_urb_size) to SKB_MAX_HEAD(0) so that you do =
not
>>> use high order allocations.
>>=20
>> Correction, that would need SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN)=
,
>> because drivers/net/usb/usbnet.c calls __netdev_alloc_skb_ip_align()=
=2E
>
> I seem to recall that this driver has a lot of strange buffering
> restrictions and that Bjorn Mork was talking a lot about this
> recently.

Yes, I have been following this discussion with great interest, learnin=
g
a lot.

But although the problem is the same, I believe the driver in question
isn't the one I have been looking at recently.  The posted code snippet
was from the NCM gadget driver (drivers/usb/gadget/f_ncm.c), isn't that
right Jim?

That driver implements the same protocol with the same inherent issues,
but for the device side.  The implementations are independent for
historical reasons.  This happened before I started looking at these
things so I don't know exactly why.  In an ideal world they should have
shared pretty much everything except setup.

> Bjorn people are getting really burnt because the driver ends up
> having a skb->truesize of 32K for the buffers it allocates on receive
> and this chokes up TCP and SCTP because the socket memory limits
> are hitting earlier than they should.
>
> We've just in the past few postings been discussing whether the just
> copy every packet into a more appropriately sized buffer, and it isn'=
t
> clear if that's a good idea of the data rates handled here.

Yes, judging by this discussion I guess we should unconditionally copy
instead of cloning in these drivers.  We'll always have bad
payload/truesize ratio for cloned skbs, often less than 1/10 even for
max size payload.

Actually, I thought we already did copy in the host cdc_ncm driver.  Bu=
t
I was wrong.  I was thinking of the cdc_mbim driver (which is different
enough to have its own implementation of this part of the rx code). The
cdc_ncm driver is cloning and the cdc_mbim driver is copying.  So we're
not even consistent...

I'll create and test a patch for the cdc_ncm host driver unless someone
else wants to do that. I haven't really played with the gadget driver
before, so I'd prefer if someone knowing it (Jim maybe?) could take car=
e
of it.  If not, then I can always make an attempt using dummy_hcd to
test it.

BTW, wrt the data rates: These drivers are USB class drivers and we
should really think of *all* possible rates, even future ones. This is
not limited to 480 Mbps USB2. AFAICS, there isn't anything preventing
the gadget driver from being used with e.g. a USB3380 controller to
create a 5 Gbps NCM device.  I'm sure the future will bring us even
faster USB devices.  The drivers will be the same.  Which is sort of
beautiful and scaring at the same time :-)

But I assume the bad payload/truesize ratio is the most important facto=
r
here, so we should still copy?


Bj=C3=B8rn
