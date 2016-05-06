From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: Re: [REGRESSION] asix: Lots of asix_rx_fixup() errors and slow
 transmissions
Date: Fri, 6 May 2016 17:54:39 +0100
Message-ID: <572CCC4F.8000808@mentor.com>
References: <CALAqxLUj+-yUGTNviHu4+KE9=JTxjZyHBv4pdUob=xndAr8ZmA@mail.gmail.com>
 <57286E15.2080900@mentor.com>
 <CAFGCpxx0f7g7rXyZ-P0EF7QVX7Z0ziK+7VMPKK7pQteBowkw3Q@mail.gmail.com>
 <5728837D.60702@mentor.com>
 <CALAqxLXbMuK3Sj45vbf_r4GYQR=8bGUrhDz9-7+S2pbO_dJZ4A@mail.gmail.com>
 <572B0023.9060505@mentor.com>
 <CAFGCpxyeXkbQXW6Dm9ZpUXpVDWgaQziPnsC9GcZPqeg5jnbJUA@mail.gmail.com>
 <572CB188.7050203@mentor.com> <20160506152732.GA23647@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guodong Xu <guodong.xu@linaro.org>,
	John Stultz <john.stultz@linaro.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Mark Craske <Mark_Craske@mentor.com>,
	"David S. Miller" <davem@davemloft.net>,
	YongQin Liu <yongqin.liu@linaro.org>,
	<linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
	Ivan Vecera <ivecera@redhat.com>,
	"David B. Robins" <linux@davidrobins.net>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160506152732.GA23647@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/16 16:27, Andrew Lunn wrote:
>> In other words, the full-speed hub is restricting the USB to
>> Ethernet Adaptor to a 12Mbps (half-duplex) bandwidth to support
>> Ethernet 100Mbps (full-duplex) traffic. That is not going to work
>> very well because Ethernet frames (perhaps partial Ethernet frames)
>> need to be discarded within the USB link.
> If that really is true, the design is broken. I would expect the
> adaptor to reliably transfer whole frames over USB, and drop whole
> frames from its receive queue when the USB is congested. TCP is also
> going to see the USB bottleneck as just like any bottleneck in the
> network and back off. So TCP streams should not cause major congestion
> on the USB link.
The host's USB host controller polls the USB to Ethernet adaptor for 
more data. The USB to Ethernet adaptor cannot predict when the next poll 
request comes. The AX88772B can span Ethernet frames across multiple 
poll requests. This means it is possible get a partial Ethernet frame 
received in the USB host controller on one poll and it is assumed that 
the next poll (sometime in the near future) will get the remaining part 
of the Ethernet frame.

However, the USB to Ethernet adaptor does not contain an infinitely 
sized RX Ethernet buffer for the incoming Ethernet frames. I believe the 
USB to Ethernet adaptor is just a pipe and does not directly implement 
flow control for Ethernet frames so the RX buffer is going to overflow 
causing loss of whole Ethernet frames. I suspect the IP stack in the 
host computer implements flow control for Ethernet frames.

Because the AX88772B can span Ethernet frames across multiple poll 
requests there is a risk that the designers of the device could of 
implemented a solution to discard the remaining part of the Ethernet 
frame before the next poll arrives due to the RX buffer overflowing. I 
don't know the algorithm used in the AX88772B but there will be loss of 
data due to the mismatch in bandwidths. I agree that dropping whole 
Ethernet frames would be preferable to dropping partial Ethernet frames 
which would corrupt the data stream.

My suspicion is that the URB buffers are containing discontinues in the 
data stream because of lost data due to insufficient bandwidth on the 
USB link.

> Going over a 12Mbps USB link should be no different
> to hitting an old Ethernet hub which can only do 10/Half.
Not exactly, because USB is a transport link which is agnostic to the 
type of data that is flowing. It is up to the layers above USB to manage 
the data content.

In other words, the USB speed needs to be higher than the Ethernet speed 
to avoid mismatches in bandwidth.
>> Therefore please retest with a working high-speed USB hub or remove
>> the full-speed USB hub from the test environment and directly
>> connect the USB to Ethernet Adaptor to the root hub of the USB port.
>> Then repeat the tests to see whether anything improved.
>>
>> In other words, you need to eliminate the dmesg messages saying "not
>> running at top speed; connect to a high speed hub".
> I would also suggest testing with the Ethernet at 10/half. You should
> be able to use Ethtool to set that up. Your USB and Ethernet bandwidth
> become more equal. If you still see errors, it suggests a protocol
> implementation error somewhere.
I agree with the suggestion but I hope USB high speed (480Mbps) 
operation was the intended environment rather than the useless USB full 
speed (12Mbps) operation.

Let's hope that not using the USB hub improves things.

Regards,
Dean
>
> 	 Andrew

-- 
Dean Jenkins
Embedded Software Engineer
Linux Transportation Solutions
Mentor Embedded Software Division
Mentor Graphics (UK) Ltd.
