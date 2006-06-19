From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: Re: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 11:58:06 -0400
Message-ID: <4496C98E.8030407@watson.ibm.com>
References: <1150724482.5815.48.camel@jzny2>	 <Pine.LNX.4.64.0606191057420.21114@d.namei> <1150730884.5384.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	Per Liden <per.liden@ericsson.com>,
	Jay Lan <jlan@engr.sgi.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:30436 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP id S932521AbWFSP6l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 11:58:41 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5JFwes7118136
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 15:58:40 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5JFxvHB124602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 16:59:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5JFwcgM004524
	for <netdev@vger.kernel.org>; Mon, 19 Jun 2006 16:58:39 +0100
To: hadi@cyberus.ca
In-Reply-To: <1150730884.5384.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-19-06 at 11:13 -0400, James Morris wrote:
> 
> 
>>It seems that TIPC is multiplexing all of it's commands through  
>>TIPC_GENL_CMD.
> 
> 
> 
> TIPC is a deviation; they had the 100 ioctls and therefore did a direct
> one-to-one mapping.
> 
> 
>>I wonder, if this is how other protocols are likely to utilize genl, then 
>>we could possibly drop the command registration code completely and one 
>>command op can be registered by the protocol during 
>>genl_register_family().
>>
> 
> 
> The intent is to have a handful of commands as in classical netlink
> (eg route or qdisc etc) where you are controlling data that sits in the
> kernel; i.e when you have an attribute or a vector of attributes, then
> the commands will be of the semantics: ADD/DEL/GET/DUMP only. 
> Other that TIPC the two other users i have seen use it in this manner.
> But, you are right if usage tends to lean in some other way we could get
> rid of it (I think TIPC is a bad example).

The taskstats interface, currently in -mm, is one user of genetlink
http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc6/2.6.17-rc6-mm2/broken-out/per-task-delay-accounting-taskstats-interface.patch

Based on Jamal's suggestions, we found it useful to have the "limited"
set of commands model and ended up with having to register just one GET
command. And in subsequent discussions, a SET command would also be handy.

But I'm not too clear about what are the advantages of trying to limit the
number of commands registered by a given exploiter of genetlink (say TIPC or taskstats),
other than the conventional usage of netlink.

e.g in the taskstats code, userspace needs to GET data on a per-pid and per-tgid basis
from the kernel and supplies the specific pid or tgid. We could either have registered
two commands (say GET_PID and GET_TGID) and then the parsing of the supplied uint32 would
be implicit in the command. But we went with the model where we have only one GET command
and the type of the parameter is specified via netlink attributes.

In our case, it didn't matter and since the type of data returned is very similar and so is
the parameter supplied (pid/tgid), one GET suffices. But I'm wondering if userspace should
consciously try and limit the commands or would it be better from a performance standpoint,
to permit a reasonably larger "fan-out" to happen at the genetlink command level (for each exploiter).
I guess this introduces more overhead for in-kernel structures (the linked list of command structures
that needs to be kept around) while saving time on doing a second level of parsing within the
exploiter-defined function that services the GET command.

The "small" set model looks like a good compromise. Reducing number of commands to one is not a good
idea IMHO....for reasons similar to why ioctl type syscalls aren't encouraged...since the genetlink
layer anyway has code for demultiplexing, might as well use it and avoid an extra level of indirection.

--Shailabh


>>This would both simplify the genl code and API, and help ensure 
>>consistency of users.
>>
> 
> 
> You are talking from an SELinux perspective i take it?
> My view: If you want to have ACLs against such commands
> then it becomes easier to say "can only do ADD but not DEL" for example
> (We need to resolve genl_rcv_msg() check on commands to be in sync with
> SELinux as was pointed by Thomas)
> 
> cheers,
> jamal
> 

