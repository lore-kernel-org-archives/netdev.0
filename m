From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Mon, 23 May 2011 08:21:48 +0200
Message-ID: <4DD9FCFC.10803@hartkopp.net>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<4DCB88A4.2010901@grandegger.com> <4DCBF1B6.6000104@hartkopp.net>
	<201105221230.56243.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	m-watkins-l0cyMroinI0@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201105221230.56243.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 22.05.2011 12:30, Arnd Bergmann wrote:
> On Thursday 12 May 2011 16:41:58 Oliver Hartkopp wrote:
>> E.g. assume you need the CAN-IDs 0x100, 0x200 and 0x300 in your application
>> and for that reason you configure these IDs in the pruss CAN driver.
>>
>> What if someone generates a 100% CAN busload exactly on CAN-ID 0x100 then?
>>
>> Worst case (1MBit/s, DLC=0) you would need to handle about 21.000 irqs/s for
>> the correctly received CAN frames with the filtered CAN-ID 0x100 ...
> 
> Then I guess the main thing that a "smart" CAN implementation like pruss
> should do is interrupt mitigation. When you have a constant flow of
> packets coming in, the hardware should be able to DMA a lot of
> them into kernel memory before the driver is required to pick them up,
> and only get into interrupt driven mode when the kernel has managed
> to process all outstanding packets.
> 
>> This all depends heavily on Linux networking (skb handling, caching, etc) and
>> is pretty fast and optimized!! That was also the reason why it ran on the old
>> PowerPC that smoothly. The mostly seen effect if anything drops is when the
>> application (holding the socket) was not fast enough to handle the incoming
>> data. NB: For that reason we implemented a CAN content filter (CAN_BCM) that
>> is able to do content filtering and timeout monitoring in Kernelspace - all
>> performed in the SoftIRQ.
> 
> Right, dropping packets that no process is waiting for should be done as
> early as possible. In pruss-can, the idea was to do it in hardware, which
> doesn't really work all that well for the reasons discussed before.
> Dropping the frames in the NAPI poll function (softirq time) seems like a
> logical choice.

In 'real world' CAN setups you'll never see 21.000 CAN frames per second (and
therefore 21.000 irqs/s) - you are usually designing CAN network traffic with
less than 60% busload. So interrupt rates somewhere below 1000 irqs/s can be
assumed.

>From what i've seen so far a 3-4 messages rx FIFO and NAPI support just make it.

@Marc/Wolfgang: Would this be also your recommendation for a CAN controller
design that supports SocketCAN in the best way?

As the Linux network stack supports hardware timestamps too, this could be an
additional (optional!) feature.

Regards,
Oliver

>> Having 'Mailboxes' bound to CAN-IDs is something that's useful for 8/16 bit
>> CPUs where an application is tightly bound to the embedded ECUs functionality.
> 
> Makes sense.
> 
> 	Arnd
