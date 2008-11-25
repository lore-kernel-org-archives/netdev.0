From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Is there any function similar to inet_ntoa() in Kernel or NetFilter ?
Date: Tue, 25 Nov 2008 11:44:11 -0500
Message-ID: <C57D5FEB-782D-4106-A447-8FBFDB1AB62B@oracle.com>
References: <192580.22596.qm@web111104.mail.gq1.yahoo.com> <49252F1A.4060304@tihlde.org> <43ca39800811211508i13b3073akfa48284f96eae69c@mail.gmail.com> <AAF075CA-ECF9-440C-AF33-3845544A284D@oracle.com> <1227592910.5511.38.camel@brick>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julius Volz <julius.volz@gmail.com>, netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet14.oracle.com ([141.146.126.236]:53577 "EHLO
	acsinet14.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbYKYQp2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 11:45:28 -0500
Received: from acsinet11.oracle.com (acsinet11.oracle.com [141.146.126.233])
	by acsinet14.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id mAPGlEC1017695
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 16:47:16 GMT
In-Reply-To: <1227592910.5511.38.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 25, 2008, at 1:01 AM, Harvey Harrison wrote:
> On Mon, 2008-11-24 at 21:03 -0500, Chuck Lever wrote:
>> On Nov 21, 2008, at Nov 21, 2008, 6:08 PM, Julius Volz wrote:
>>> On Thu, Nov 20, 2008 at 10:34 AM, Roar Bj=F8rgum Rotvik <roarbr@tih=
lde.org
>>>> wrote:
>>>> Kunsheng Chen wrote:
>>>>> I am doing a project similar to iptable using netfilter, currentl=
y
>>>>> I want
>>>>> to convert a IP address from 'long int' back to dotted address.
>>>>>
>>>>> I don't know whether there is some functions inside kernel or
>>>>> netfilter
>>>>> that could make that like using inet_ntoa() in <arpa/inet.h>
>>>>
>>>> How about NIPQUAD and NIPQUAD_FMT (for IPv4):
>>>> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L324
>>>> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L319
>>>
>>> In the latest tree, there are now "%pI4" and "%pI6" format options
>>> for printk.
>>>
>>> For example:
>>>
>>> printk(KERN_DEBUG "Address: %pI4\n", &v4_addr);
>>
>> I've been watching this with some interest.  Is this API stable now?
>>
>> Is there a way to pass a pointer to a sockaddr and get printk() to
>> figure out whether it's is an AF_INET or AF_INET6 address, and =20
>> display
>> it appropriately?
>
> Nope, they're fixed-format currently.  They are pretty simple format
> specifiers at this point.  I'm not sure if adding more dynamic =20
> behavior
> is a good idea.

In the NFS and RPC kernel implementation we often need to print an =20
address in debugging messages.

It would be so much easier to have a so-called dynamic formatter for =20
multiple address types.  Then you can avoid this kind of code in a =20
whole lot of places:

	switch (sap->sa_family) {
	case AF_INET:
		dprintk("NFS: connected to address %pI4\n",
			&((struct sockaddr_in *)sap)->sin_addr.s_addr);
		break;
	case AF_INET6:
		/* maybe add some logic here to recognize mapped IPv4
		 * and display it as dotted quad... */
		dprintk("NFS: connected to address %pI6\n",
			&((struct sockaddr_in6 *)sap)->sin6_addr);
		break;
	default:
		dprintk("NFS: bad address\n");
	}

Especially since there is a conditional inside the dprintk() macro =20
that skips all of the dprintk() logic if rpc_debug is not set.  This =20
could be reduced to:

	dprintk("NFS: connected to address %pS\n", sap);

What we end up doing to make printk() and sprintf() convenient is =20
generate the address strings in a buffer, and using "%s" to print =20
them.  It consumes memory to keep these buffers around, or a lot of =20
stack space to generate the presentation format addresses as needed.  =20
And, as mentioned above, for debugging messages, the additional buffer =
=20
and conversion logic isn't even needed until debugging is enabled.

>> Does it handle IPv6 scope IDs correctly?
>
> Define correctly? ;-)

The sin6_scope_id field is an unsigned value that specifies an index =20
into an array of network interfaces.

It can be converted to presentation format by appending '%' and the =20
integer to the IPv6 address.  The scope ID is important for link-local =
=20
addresses.  Without it, a link-local address cannot be used for =20
anything but display.

Having the ability to handle a scope ID formatter would be useful for =20
putting addresses in buffers too, but you may have only touched =20
printk() for now?

There are several places in the NFS client that handle an address =20
string -- usually these strings are put on the network or come from =20
the network.  The NFSv4 client ID string is composed of at least two =20
address strings.  NFSv4 referrals can arrive from a server as a =20
hostname or an address string.  Universal addresses, used by rpcbind =20
versions 3 and 4, are strings that contain an address and a port =20
number in a special format.  All of these things would benefit from =20
having the ability to use the address formatters with sprintf() and =20
friends.

>> Does it convert IPv6 mapped IPv4 addresses to dotted quad =20
>> automatically?
>
> Nope.

=46or systems built with modern kernels but running in legacy =20
distributions or with only IPv4 addresses configured, the sudden =20
appearance of an IPv6 presentation format address in the kernel log, =20
for example, might be pretty confusing.

> Quick summary:
> %pI4 prints 4 decimal separated decimal numbers
>
> %pI6 prints 8 16-bit hex numbers colon-separated
> %pi6 omits the colons.

It would also be handy if %pI6 could produce the double-colon format.  =
=20
I seem to recall there was some talk of having another format =20
specifier that could remove contiguous zeros and replace them with "::"=
=2E

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com