From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Fri, 2 Mar 2012 15:01:12 +0800
Message-ID: <4F507038.7070104@windriver.com>
References: <A1249B08688639468D1CB181445EE79D5A61B30431@ESESSCMS0355.eemea.ericsson.se> <1330622294.5373.8.camel@megeve>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>,
	"David.Laight@ACULAB.COM" <David.Laight@aculab.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"javier@collabora.co.uk" <javier@collabora.co.uk>,
	"lennart@poettering.net" <lennart@poettering.net>,
	"kay.sievers@vrfy.org" <kay.sievers@vrfy.org>,
	"alban.crequy@collabora.co.uk" <alban.crequy@collabora.co.uk>,
	"bart.cerneels@collabora.co.uk" <bart.cerneels@collabora.co.uk>,
	"sjoerd.simons@collabora.co.uk" <sjoerd.simons@collabora.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330622294.5373.8.camel@megeve>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rodrigo,

I try to answer your questions about TIPC, please look at comments inline.


Rodrigo Moya wrote:
> Hi Erik
>
> On Thu, 2012-03-01 at 15:25 +0100, Erik Hugne wrote:
>   
>> Hi
>> Have you considered using TIPC instead?
>> It already provides multicast messaging with guaranteed ordering, and reliable delivery  (SOCK _RDM)
>>
>>     
> I didn't know about TIPC, so have been having a quick look over it, and
> have some questions about it:
>
> * since it's for cluster use, I guess it's based on AF_INET sockets? if
> so, see the messages from Luis Augusto and Javier about this breaking
> current D-Bus apps, that use fd passing, for out-of-band data
>
>   

No, TIPC doesn't depend on AF_INET socket, instead it uses a separate 
address family(AF_TIPC).

> * D-Bus works locally, with all processes on the same machine, but there
> are 2 buses (daemons), one for system-related interfaces, and one per
> user, so how would this work with TIPC. Can you create several
> clusters/networks (as in TIPC addressing semantics) on the same machine
> on the loopback device?
>   

TIPC can both support two modes: single node mode and network mode.
If we hope all application can easily talk each other locally, let TIPC 
just work under single node mode.
Of course, it is in network mode, it also supports single node.

How to let TIPC in the single node mode?
It's very easy, and no any specific configuration is needed. After 
insert TIPC module, it enters into the mode by default.

As Erik specified, TIPC multicast mechanism is very useful for D-Bus. It 
has several cool and powerful special features:
1. It can guarantee multicast messages are reliably delivered in order.
2. It can support one-to-many and many-to-many real-time communication 
within node or network.
3. It also can support functional addressing which means location 
transparent addressing allows a client application to access a server 
without having to know its precise location in the node or the network. 
The basic unit of functional addressing within TIPC is the port name, 
which is typically denoted as {type,instance}. A port name consists of a 
32-bit type field and a 32-bit instance field, both of which are chosen 
by the application. Often, the type field indicates the class of service 
provided by the port, while the instance field can be used as a 
sub-class indicator.
Further support for service partitioning is provided by an address type 
called port name sequence. This is a three-integer structure defining a 
range of port names, i.e., a name type plus the lower and upper boundary 
of the instance range. This addressing schema is very useful for 
multicast communication. For instance, as you mentioned, for D-Bus may 
need two different buses, one for system, another for user. In this 
case, when using TIPC, it's very easy to meet its requirement. We can 
assign one name type to system bus, and another name type is to user 
bus. Under one bus, we also can divide it into many different sub-buses 
with lower and upper. For example, once one application publishes one 
service/port name like {1000, 0, 1000} as system bus channel, any 
application can send messages to {1000, 0, 100} simultaneously. Of 
course, for example, one application can publish {1000, 0, 500} as 
sub-bus of the system bus, another can publish {1000, 501, 1000} as 
another system sub-bus. At the moment, one application can send a 
message to {1000, 0, 1000} port, it means the two applications including 
published {1000, 0, 500} and {1000, 501, 1000} all can receive the message.

If D-Bus uses this schema, I believe the central D-Bus daemons is not 
necessary any more. Any application can directly talk each other by 
one-to-one, one-to-many, and many-to-many way.

4. TIPC also has another important and useful feature which allows 
client applications to subscribe one service port name by receiving 
information about what port name exist within node or network. For 
example, if one application publishes one system bus service like {1000, 
0, 500}, any client applications which subscribe the service can 
automatically detect its death in time once the application publishing 
{1000, 0, 500} is crashed accidentally.

In all, it also have other useful features, about more detailed 
information, please refer its official web site: 
http://tipc.sourceforge.net/

> * I installed tipcutils on my machine, and it asked me if I wanted to
> setup the machine as a TIPC node. Does this mean every machine needs to
> be setup as a TIPC node before any app makes use of it? That is, can I
> just create a AF_TIPC socket on this machine and just make it work
> without any further setup?
>
>   

No, as I indicate before, it's no extra configuration if you expect it 
just works in single node mode.
Actually there has several demos in tipcutils package, you can further 
learn about its functions and how to work etc.

> * I guess it is easy to prevent any TIPC-enabled machine to get into the
> local communication channel, right? That is, what's the security
> mechanism for allowing local-only communications?
>
>   

When publishing service name, you can specify the level of visibility, 
or scope, that the name has within the TIPC network: either node scope, 
cluster scope, or zone scope.
So if you want it is just valid locally, you can designated it as node 
scope, which TIPC then ensures that only applications within  the same 
node can access the port using that name.

Regards,
Ying

> I'll stop asking questions and have a deeper look at it :)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
