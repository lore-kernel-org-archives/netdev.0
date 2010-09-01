From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: out-of-order tx objects - was Re: [MeeGo-Dev][PATCH] Topcliff: Update
	PCH_CAN driver to 2.6.35
Date: Wed, 01 Sep 2010 19:04:04 +0200
Message-ID: <4C7E8784.9060509@hartkopp.net>
References: <4C61EDE5.4030505@dsn.okisemi.com>
	<4C62981B.8050402@grandegger.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA26CC@shsmsx501.ccr.corp.intel.com>
	<4C63B6C9.5050804@grandegger.com>
	<D5AB6E638E5A3E4B8F4406B113A5A19A28EA29DF@shsmsx501.ccr.corp.intel.com>
	<000501cb49a9$9cd4bf00$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Chih Howe <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Qi <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, "Wang,
	Yong Y" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	ML linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <000501cb49a9$9cd4bf00$66f8800a-a06+6cuVnkTSQfdrb5gaxUEOCMrvLtNR@public.gmane.org>
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

Hello Ohtake,

i'm only picking up the out-of-order issue here ...

On 01.09.2010 09:45, Masayuki Ohtake wrote:

>>>>> - I see that the driver uses many TX and RX objects. How do you avoid
>>>>>   out-of-order transmission and reception?
>>>> What do you mean out-of-order RX and TX?
>>>> Atom processor only supports in-order execution, and PCIe-based peripherals
>>> can solve it with consumer-producer model. Actually IC designer will take care
>>> of out-of-order PCIe CPLD transaction.
>>>
>>> I mean out-of-order transmission to or from the CAN bus. This is handled
>>> by the CAN controller hardware. It has nothing to to with the processor.
> Cannot avoid occurring rx or tx our-of-order.

The CAN frames that are sent by the local system have to touch the wire in the
same order as you put them into the socket as user.

An example:

You send CAN-frames with CAN Identifiers via can-raw sockets

0x123
0x456
0x010

and of course you expect these frames sent in exactly this order.
This is easy to archive as you get each of these CAN frames out of the
netdevices tx-queue in this order.

The problems comes up when you use multiple "tx objects" of your CAN
controller. Some CAN controllers have a "magic intelligence" that leads to
some re-ordering according to the CAN-Identifiers priority.

E.g.

0x123
0x456
0x010

leads to

0x123
0x010
0x456

because you pushed these CAN-frames into different tx objects and the CAN
controller sorts them on its own by priority. For CAN newbies: A lower CAN-ID
value has a higher priority in arbitration on the *physical* layer.

In the example above the CAN controller checks after sending the 0x123 CAN
frame if there's a priority order in the tx objects that are ready to send,
and selects 0x010 ...

This behaviour might be interesting in single-user/single-application
environments - but it is just wrong in multi-user systems where several
different applications use the (same) CAN bus. Standard networking behaviour.

Please ensure that the CAN frame order given by the tx-queue of the Linux
kernel netdevice infrastructure is send on the wire in the same order.

This usually leads to the use of ONLY ONE tx object of your CAN controller.
Probably you can use two tx objects to increase the throughput if this does
not have any impact to the frame order. See your controllers documentation for
details about this tx object behaviour.

I hope this makes the question of Wolfgang a bit clearer :-)

Regards,
Oliver
