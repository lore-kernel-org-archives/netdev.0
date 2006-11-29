From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Wed, 29 Nov 2006 23:10:39 +0100
Message-ID: <456E055F.8020100@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com>	<45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>	<456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com> <456DEBAC.4060106@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:2773 "EHLO
	mtagate2.de.ibm.com") by vger.kernel.org with ESMTP
	id S1758287AbWK2WLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 17:11:09 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id kATMAsmE043938
	for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 22:10:58 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kATMEW5F3063978
	for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 23:14:32 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kATMAqxR007188
	for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 23:10:53 +0100
To: devel@openvz.org
In-Reply-To: <456DEBAC.4060106@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley wrote:
> Eric W. Biederman wrote:
>> I think for cases across network socket namespaces it should
>> be a matter for the rules, to decide if the connection should
>> happen and what error code to return if the connection does not
>> happen.
>>
>> There is a potential in this to have an ambiguous case where two
>> applications can be listening for connections on the same socket
>> on the same port and both will allow the connection.  If that
>> is the case I believe the proper definition is the first socket
>> that we find that will accept the connection gets the connection.
No. If you try to connect, the destination IP address is assigned to a 
network namespace. This network namespace is used to leave the listening 
socket ambiguity.
> 
> Wouldn't you want to catch this at bind() and/or configuration time and
> fail?  Having overlapping namespaces/rules seems undesirable, since as
> Herbert said, can get you "unexpected behaviour".

Overlapping is not a problem, you can have several sockets binded on the 
same INADDR_ANY/port without ambiguity because the network namespace 
pointer is added as a new key for sockets lookup, (src addr, src port, 
dst addr, dst port, net ns pointer). The bind should not be forced to a 
specific address because you will not be able to connect via 127.0.0.1.

> 
>> I think with the appropriate set of rules it provides what is needed
>> for application migration.  I.e. 127.0.0.1 can be filtered so that
>> you can only connect to sockets in your current container.
>>
>> It does get a little odd because it does allow for the possibility
>> that you can have multiple connected sockets with same source ip,
>> source port, destination ip, destination port.  If the rules are
>> setup appropriately.  I don't see that peculiarity being visible on
>> the outside network so it shouldn't be a problem.
> 
> So if they're using the same protocol (eg TCP), how is it decided which
> one gets an incoming packet?  Maybe I'm missing something as I don't
> understand your inside/outside network reference - is that to the
> loopback address comment in the previous paragraph?

The sockets for l3 isolation are isolated like the l2 (this is common 
code). The difference is where the network namespace is found and used.
At the layer 2, it is at the network device level where the namespace is 
found. At the layer 3, from the IP destination. So when you arrive to 
sockets level, you have the network namespace packet destination 
information and you search for sockets related to the specific namespace.


   -- Daniel
