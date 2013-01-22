From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net 2/3] net: cdc_mbim: send ZLP after max sized NTBs
Date: Tue, 22 Jan 2013 10:54:20 +0100
Message-ID: <87zk01a6gj.fsf@nemi.mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-3-git-send-email-bjorn@mork.no>
	<2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D57@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D57-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
	(Alexey ORISHKO's message of "Mon, 21 Jan 2013 17:31:37 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org> writes:

> If you add ZLP for NTBs of dwNtbOutMaxSize, you are heavily affecting=
 CPU
> load, increasing interrupt load by factor of 2 in high load traffic
> scenario and possibly decreasing throughput for all other devices
> which behaves correctly.=20

Hello Alexey,

Still trying to understand the mechanisms involved here. I must
apologize for my lack of knowledge of the hardware restrictions
involved.

The current cdc_ncm/cdc_mbim drivers will pad a NTB to the full
dwNtbOutMaxSize whenever it reaches at least 512 bytes.  The reason is
that this allows more efficient device DMA operation.  This is somethin=
g
we do to adapt to device hardware restrictions even though there is no
such recommendations in the NCM/MBIM specs.  The penalty on the host an=
d
bus should be obvious: Even with a quite small dwNtbOutMaxSize of 4096,
we end up sending 8 x 512-byte data packets instead of the 2 we could
have managed with.

Now you claim that sending 9 packets, where the last one is a zero
length packet, increaes the interrupt load by factor of 2?  How is that=
?

This is where my lack of hardware knowledge shows up, but I assumed
based on the device DMA argument that the device USB engine would do th=
e
actual packet reception and assembly and DMA the complete 4096-byte dat=
a
transfer to the device memory. Won't the device USB engine also handle
the ZLP?  Won't it just collect 9 packets instead of 8 and assemble the=
m
to the 4096-byte data transfer which is DMAed away the same way it woul=
d
if there were just 8 packets in the transfer?  The only differences
being that the ZLP variant works even if the device stack for some
reason requests more than dwNtbOutMaxSize bytes (which of course could
be claimed to be stupid, but the spec allows it), and of course that we
waste even more USB bus bandwidth.  But if USB bandwidth is a factor we
consider here then I am going to question the padding to dwNtbOutMaxSiz=
e
based on some devices having DMA restrictions making that more efficien=
t.

Why is the device DMA restrictions not a fault, while the device ZLP
requirement is?  Both seem like reasonable device hardware/firmware
implementation imposed restrictions to me.  Something we'll just have t=
o
accept.

Note that the problem with the ZLP on the Sierra devices is made much
worse than necessary by the padding.  Without this we would rarely have
hit the dwNtbOutMaxSize limit, and would have been able to work around
it by simply using tx_max =3D dwNtbOutMaxSize - 1 if=20
(dwNtbOutMaxSize % wMaxPacketSize =3D=3D 0).

Maybe that is what Windows does?

But we cannot do that due to other devices having issues with transfers
less than dwNtbOutMaxSize..


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
