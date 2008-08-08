From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Fri, 08 Aug 2008 18:15:41 -0400
Message-ID: <489CC58D.4010606@pobox.com>
References: <200807300019.m6U0JkdY012558@localhost.localdomain> <aday73jxdfs.fsf@cisco.com> <200807311752.00911.divy@chelsio.com> <200808071145.03848.divy@chelsio.com> <489C8BEB.8060001@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, Roland Dreier <rdreier@cisco.com>,
	Karen Xie <kxie@chelsio.com>, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Mike Christie <michaelc@cs.wisc.edu>
To: Steve Wise <swise@opengridcomputing.com>, davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <489C8BEB.8060001@opengridcomputing.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> 
>> Hi Jeff,
>>
>> Mike Christie will not merge this code until he has an explicit 
>> acknowledgement from netdev.
>>
>> As you mentioned, the port stealing approach we've taken has its issues.
>> We consequently analyzed your suggestion to use a different IP/MAC 
>> address for iSCSI and it raises other tough issues (separate ARP and 
>> DHCP management, unavailability of common networking tools).
>> On these grounds, we believe our current approach is the most tolerable.
>> Would the stack provide a TCP port allocation service, we'd be glad to 
>> use it to solve the current concerns.
>> The cxgb3i driver is up and running here, its merge is pending our 
>> decision.
>>
>> Cheers,
>> Divy
>>   
> Hey Dave/Jeff,
> 
> I think we need some guidance here on how to proceed.   Is the approach 
> currently being reviewed ACKable?  Or is it DOA? If its DOA, then what 
> approach do you recommend?  I believe Jeff's opinion is a separate 
> ipaddr.  But Dave, what do you think?  Lets get some agreement on a high 
> level design here.
> Possible solutions seen to date include:
> 
> 1) reserving a socket to allocate the port.  This has been NAK'd in the 
> past and I assume is still a no go.
> 
> 2) creating a 4-tuple allocation service so the host stack, the rdma 
> stack, and the iscsi stack can share the same TCP 4-tuple space.  This 
> also has been NAK'd in the past and I assume is still a no go.
> 
> 3) the iscsi device allocates its own local ephemeral posts (port 
> stealing) and use the host's ip address for the iscsi offload device.  
> This is the current proposal and you can review the thread for the pros 
> and cons.  IMO it is the least objectionable (and I think we really 
> should be doing #2).
> 
> 4) the iscsi device will manage its own ip address thus ensuring 4-tuple 
> uniqueness.

Conceptually, it is a nasty business for the OS kernel to be forced to 
co-manage an IP address in conjunction with a remote, independent entity.

Hardware designers make the mistake of assuming that firmware management 
of a TCP port ("port stealing") successfully provides the illusion to 
the OS that that port is simply inactive, and the OS happily continues 
internetworking its merry way through life.

This is certainly not true, because of current netfilter and userland 
application behavior, which often depends on being able to allocate 
(bind) to random TCP ports.  Allocating a TCP port successfully within 
the OS, that then behaves different from all other TCP ports (because it 
is the magic iSCSI port) creates a cascading functional disconnect.  On 
that magic iSCSI port, strange errors will be returned instead of proper 
behavior.  Which, in turn, cascades through new (and inevitably 
under-utilized) error handling paths in the app.

So, of course, one must work around problems like this, which leads to 
one of two broad choices:

1) implement co-management (sharing) of IP address/port space, between 
the OS kernel and a remote entity.

2) come up with a solution in hardware that does not require the OS to 
co-manage the data it has so far been managing exclusively in software.

It should be obvious that we prefer path #2.

For, trudging down path #1 means

* one must give the user the ability to manage shared IP addresses IN A 
NON-HARDWARE-SPECIFIC manner.  Currently most vendors of "TCP port 
stealing" solutions seem to expect each user to learn a vendor-specific 
method of identifying and managing the "magic port".

Excuse my language, but, what a fucking security and management 
nightmare in a cross-vendor environment.  It is already a pain, with 
some [unnamed system/chipset vendors] management stealing TCP ports -- 
and admins only discover this fact when applications behave strangely on 
new hardware.

But...  its tough to notice because stumbling upon the magic TCP port 
won't happen often unless the server is heavily loaded.  Thus you have a 
security/application problem once in a blue moon, due to this magic TCP 
port mentioned in some obscure online documentation nobody has read.


* however, giving the user the ability to co-manage IP addresses means 
hacking up the kernel TCP code and userland tools for this new concept, 
something that I think DaveM would rightly be a bit reluctant to do? 
You are essentially adding a bunch of special case code whenever TCP 
ports are used:

	if (port in list of "magic" TCP ports with special,
	    hardware-specific behavior)
		...
	else
		do what we've been doing for decades

ISTR Roland(?) pointing out code that already does a bit of this in the 
IB space...  but the point is


Finally, this shared IP address/port co-management thing has several 
problems listed on the TOE page: http://www.linuxfoundation.org/en/Net:TOE

such as,

* security updates for TCP problems mean that a single IP address can be 
PARTIALLY SECURE, because security updates for kernel TCP stack and 
h/w's firmware are inevitably updated separately (even if distributed 
and compiled together).  Yay, we are introducing a wonderful new 
security problem here.

* from a security, network scanner and packet classifier point of view, 
a single IP address no longer behaves like Linux.  It behaves like 
Linux... sometime.  Depending on whether it is a magic TCP port or not.

Talk about security audit hell.

This should be plenty, so I'm stopping now.  But looking down the TOE 
wiki page I could easily come up with more reasons why "IP address 
remote co-management" is more complicated and costly than you think.

	Jeff


