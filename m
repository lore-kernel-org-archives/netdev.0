From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Fri, 15 Apr 2011 19:57:25 +0200
Message-ID: <4DA88705.5040203@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org>	<20110314135917.GF333@e-circ.dyndns.org>	<4D8623BE.2080807@hartkopp.net>
	<20110413044928.GA289@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110413044928.GA289-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
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

On 13.04.2011 06:49, Kurt Van Dijck wrote:
> Oliver et.al.,
> 
> On Sun, Mar 20, 2011 at 04:56:46PM +0100, Oliver Hartkopp wrote:
>> On 14.03.2011 14:59, Kurt Van Dijck wrote:
>>
>> Then you suggest to attach static and/or dynamic addresses to the interface.
>>
>>> +  Assigning addresses is done via
>>> +  $ ip addr add dev canX j1939 0xXX
>>> +  statically or
>>> +  $ ip addr add dev canX j1939 name 0xXX
>>> +  dynamically. In the latter case, address claiming must take place
>>> +  before other traffic can leave.
>>
>> like you would have using DHCP/DNS (adapted for j1939) ...
>>
> I suspect the confustion with DHCP/DNS comes free with the used terminology.
> 
> Specifications talk about a 64bit NAME, where is actually is a 64bit UUID.
> Calling this number a UUID may clarify things, but leaves the spec in the
> terminology.
> 
> one would then do:
> $ ip addr add dev canX j1939 uuid XXXX
> 
> Would that be a good way to progress?

Hello Kurt,

i don't know if it helps - at least for j1939 users - to rename the NAME for
j1939 address claiming to UUID which is usually 128 bit long an has a pretty
different understanding than the J1939 NAME which stands for

   1. Arbitrary address bit
   2. Industry group, length 3 bits
   3. Vehicle system instance, length 4 bits
   4. Vehicle system, length 7 bits
   5. Reserved bit
   6. Function, length 8 bits
   7. Function instance, length 5 bits
   8. ECU instance, length 3 bits
   9. Manufacturer code, length 11 bits
  10. Identity number, length 21 bits

(from http://www.kvaser.com/en/about-can/higher-layer-protocols/36.html)

This is not comparable to the ideas from RFC 4122 ...

Thinking about the approach to implement the j1939 address claiming (AC) in
userspace, i discovered two ways which could both be hidden inside some
easy-to-use helper functions:

1. implement a thread (e.g. within a library) which opens a CAN_RAW socket on
a specific CAN-interface and takes care of the AC procedure and monitors
ongoing AC procedures on the bus. In this case every j1939 application
requiring AC internally would monitor all the AC handling on itself (which
should be no general problem - written only once).

2. create j1939ac daemon(s) using PF_UNIX-sockets to be named e.g.
j1939ac_can0, j1939ac_can1, etc. - these daemons take care for all AC
requirements of the host it is running on. The PF_UNIX-sockets are used in
SOCK_DGRAM mode and only the j1939 processes that need AC can then register
their NAME by sending a request datagram, and get back the j1939-address once
it is claimed (and all the updates on changes). As the j1939ac daemons are
running on the same host as the j1939 application processes, optional the
process' PID could be provided to the daemon during the registering process,
so that the daemon can send a signal to a signal handler of the application
process (if you would like to omit the select() syscall to handle both the
j1939 and PF_UNIX sockets).

->   <Req><Name="A3B5667799332242" PID="12345">
<-   <Resp><ACState="claimed" Name="A3B5667799332242" Address="1B">
(some time)
<-   <Resp><ACState="changed" Name="A3B5667799332242" Address="1C">

This is a sketch that could be put into simple C-structs that are sent via the
PF_UNIX DGRAM socket.

In all suggested cases (using a thread, daemon with/without signal) the AC
procedure can be managed in userspace without real pain. But especially with
less pain than putting the AC process into kernelspace and provide your
suggested socket API with bind/connect/... in very different manners.

Regards,
Oliver
