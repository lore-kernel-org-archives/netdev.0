From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC v3 5/6] j1939: rename NAME to UUID?
Date: Wed, 20 Apr 2011 12:59:32 +0200
Message-ID: <4DAEBC94.5020009@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org>
	<20110314135917.GF333@e-circ.dyndns.org>
	<4D8623BE.2080807@hartkopp.net>
	<20110413044928.GA289@kurt.e-circ.dyndns.org>
	<4DA88705.5040203@hartkopp.net>
	<20110420072439.GB332@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110420072439.GB332-ozGf4kBk5synFtIcQ8t7k3L8HoS0Hn3T@public.gmane.org>
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

On 20.04.2011 09:24, Kurt Van Dijck wrote:
> On Fri, Apr 15, 2011 at 07:57:25PM +0200, Oliver Hartkopp wrote:
>> On 13.04.2011 06:49, Kurt Van Dijck wrote:
>>> Oliver et.al.,
>>
>> Thinking about the approach to implement the j1939 address claiming (AC) in
>> userspace, i discovered two ways which could both be hidden inside some
>> easy-to-use helper functions:
>>
>> 1. implement a thread (e.g. within a library) which opens a CAN_RAW socket on
>> a specific CAN-interface and takes care of the AC procedure and monitors
>> ongoing AC procedures on the bus. In this case every j1939 application
>> requiring AC internally would monitor all the AC handling on itself (which
>> should be no general problem - written only once).
>>
>> 2. create j1939ac daemon(s) using PF_UNIX-sockets to be named e.g.
>> j1939ac_can0, j1939ac_can1, etc. - these daemons take care for all AC
>> requirements of the host it is running on. The PF_UNIX-sockets are used in
>> SOCK_DGRAM mode and only the j1939 processes that need AC can then register
>> their NAME by sending a request datagram, and get back the j1939-address once
>> it is claimed (and all the updates on changes). As the j1939ac daemons are
>> running on the same host as the j1939 application processes, optional the
>> process' PID could be provided to the daemon during the registering process,
>> so that the daemon can send a signal to a signal handler of the application
>> process (if you would like to omit the select() syscall to handle both the
>> j1939 and PF_UNIX sockets).
>>
>> ->   <Req><Name="A3B5667799332242" PID="12345">
>> <-   <Resp><ACState="claimed" Name="A3B5667799332242" Address="1B">
>> (some time)
>> <-   <Resp><ACState="changed" Name="A3B5667799332242" Address="1C">
>>
>> This is a sketch that could be put into simple C-structs that are sent via the
>> PF_UNIX DGRAM socket.
>>
>> In all suggested cases (using a thread, daemon with/without signal) the AC
>> procedure can be managed in userspace without real pain.
> I seriously doubt this statement.
> define 'real pain'.

The same pain as writing a DNS or DHCP daemon which is doing a similar job ...

>> But especially with
>> less pain than putting the AC process into kernelspace and provide your
>> suggested socket API with bind/connect/... in very different manners.
> * You're only counting LOC in kernel, and not in userspace.

Yes! Things that can be left out of the kernel, should be implemented and
maintained in userspace - at least to reduce complexity and potential security
issues.

> * The constructs you present create some kind of infrastructure. You will
>   need a torough documentation of the 'good practice' since that's crucial
>   to the correct operation of the stack. Did you ever consider the impact
>   on the userspace application side.

Yes.

>   Remember that userspace programs should be easy to write.
>   I found your proposals impact application development very hard.

define 'very hard' ;-)

> I still think my passive support in kernel performs better and gives an
> easier API to get things done with.

Kurt, the problem for me is, that you constantly state that your approach is
the best. For me it is not.

The major issue in your implementation is the lack of the possibility to
simulate several j1939 ECUs on one Linux host talking to each other via
virtual CAN busses to create a complete j1939 network. And so far you did not
address this request.

There are several j1939 implementations that are running (or can be made
running) completely in userspace using raw-sockets. Obviously many people are
convenient with these implementations.

I'm fine to place the j1939 data transfer part (supporting the segmented
transfer of long j1939 PDUs) into the kernel - but not all the address
claiming and the binding of j1939 addresses to network interfaces that also
kills the requested feature of simulating a complete j1939 network.

As an amicable approach i would suggest to proceed in two steps:

1. post and mainline the j1939 bits that deal with the data transfer only
   - no address claiming / j1939 name handling
   - no binding of j1939 addresses to CAN network devices
   - no extensions in the current af_can.c
   - etc.

2. discuss the implementation of the (optional) j1939 address claiming

For me this approach makes sense for j1939 newbies and also experienced j1939
users that may become interested in the Linux mainline implementation.

Then - discussing with a larger number of potential and real j1939 users - we
should face the address claiming and its possible implementation options.

Best regards,
Oliver
