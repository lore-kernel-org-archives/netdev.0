From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Thu, 12 Aug 2010 08:25:52 +0200
Message-ID: <4C6393F0.5090005@hartkopp.net>
References: <4C61EDE5.4030505@dsn.okisemi.com>
	<AANLkTinZ510_k2E5JFxa8jcuv8gRABFakyrcfzsg2vm1@mail.gmail.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26EB@shsmsx501.ccr.corp.intel.com>
	<20100812020414.GD14121@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Khor, Andrew Chih Howe" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, "Wang, Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	"meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org" <meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org>,
	"arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: "Wang, Qi" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100812020414.GD14121-l3A5Bk7waGM@public.gmane.org>
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

On 12.08.2010 04:04, Greg KH wrote:
> On Thu, Aug 12, 2010 at 09:42:27AM +0800, Wang, Qi wrote:

>>> 2. Why don't you use kernel existing kfifo infrastructure? ([2]).
>> Just take a look at kfifo.h. This structure has been changed. I
>> remembered there was a spin_lock from kfifo previously. Currently it's
>> been removed, good.
>> OKI-sans, would you please take a look at ./include/linux/kfifo.h, and try to use this structure and APIs?
>>
>> Daniel,
>>
>> We're anxious to integrate those codes now. Perhaps it'll take us
>> quite a long time to use kfifo. How about implementing it with the
>> next version?
> 
> What do you mean by this?  Code isn't merged into the tree unless it is
> correct.  Please fix this now, it's not that big of a deal.
> 

Hello Qi,

i generally wonder what this FIFO is used for??

For me it looks like a artifact from a former chardev implementation, as
several other code sniplets do (see comments from Wolfgang and Marc).

The network driver model is used for CAN drivers and therefore all the
infrastructure for queueing inbound and outbound network traffic should be
used from the Kernel like all other CAN drivers and all other ethernet drivers do.

Additionally there is a powerful infrastructure to support the special
functions of CAN netdevices (like setting of bittimings, listen-only modes, or
to produce CAN driver states etc.), that's part of the CAN drivers in
drivers/net/can/ since it has gone mainline.

CAN netdevices are intentionally dumb (like the original ethernet adapters).
This allows a simple driver interface between the kernel and the hardware
driver, e.g. for queueing CAN frames. CAN drivers don't use any hardware
rx-filtering(!) due to multiuser requirements and it's a vital requirement
that the frames are not re-ordered on sending (by the 'some magic' CAN
controller dealing with CAN-ID priorities, e.g. see tx-path in the MSCAN driver).

>From my perspective about 70% of your code is obsolete, as you implemented
tricky details (like FIFOs, bittiming tables or magic filter handlings),
that's not needed at all.

Please take a look at the SJA1000 driver (for a low complex CAN controller) or
at the TI driver (for a higher complex CAN controller) how these drivers
handle the specialties of each hardware. And read some documentation in
Documentation/networking/can.txt to get an impression about the concepts of
the CAN implementation in the Linux Kernel and the CAN netdevices.

I strongly assume that your driver would be about 30 kBytes of code fitting
into a single c-file like the ti_hecc.c does. And that's definitely easier for
us to review and easier for you to maintain in the future ...

Thanks & best regards,
Oliver
