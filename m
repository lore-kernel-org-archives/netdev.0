From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Thu, 30 Nov 2006 17:38:16 +0100
Message-ID: <456F08F8.3060809@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com>	<45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>	<456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com> <456DEBAC.4060106@hp.com> <456E055F.8020100@fr.ibm.com> <456F038F.8090509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:10590 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1759264AbWK3Qif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 11:38:35 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAUGcURP027748
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 16:38:33 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUGcUAl2932882
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 16:38:30 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUGcTi1010687
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 16:38:29 GMT
To: Vlad Yasevich <vladislav.yasevich@hp.com>
In-Reply-To: <456F038F.8090509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich wrote:
> Daniel Lezcano wrote:
>> Brian Haley wrote:
>>> Eric W. Biederman wrote:
>>>> I think for cases across network socket namespaces it should
>>>> be a matter for the rules, to decide if the connection should
>>>> happen and what error code to return if the connection does not
>>>> happen.
>>>>
>>>> There is a potential in this to have an ambiguous case where two
>>>> applications can be listening for connections on the same socket
>>>> on the same port and both will allow the connection.  If that
>>>> is the case I believe the proper definition is the first socket
>>>> that we find that will accept the connection gets the connection.
>> No. If you try to connect, the destination IP address is assigned to a
>> network namespace. This network namespace is used to leave the listening
>> socket ambiguity.
>>> Wouldn't you want to catch this at bind() and/or configuration time and
>>> fail?  Having overlapping namespaces/rules seems undesirable, since as
>>> Herbert said, can get you "unexpected behaviour".
>> Overlapping is not a problem, you can have several sockets binded on the
>> same INADDR_ANY/port without ambiguity because the network namespace
>> pointer is added as a new key for sockets lookup, (src addr, src port,
>> dst addr, dst port, net ns pointer). The bind should not be forced to a
>> specific address because you will not be able to connect via 127.0.0.1.
> 
> So, all this leads to me ask, how to handle 127.0.0.1?
> 
> For L2 it seems easy.  Each namespace gets a tagged lo device.
> How do you propose to do it for L3, because disabling access to loopback is
> not a valid option, IMO.

There are 2 options:

1 - Dmitry Mishin proposed to use the l2 mechanism and reinstantiate a 
new loopback device, I didn't tested that yet, perhaps there are issues 
with non-127.0.0.1 loopback traffic and routes creation, I don't know.

2 - add the pointer of the network namespace who has originated the 
packet into the skbuff when the traffic is for 127.0.0.1, so when the 
packet arrive to IP, it has the namespace destination information 
because source == destination. I tested it and it works fine without 
noticeable overhead and this can be done with a very few lines of code.

   -- Daniel

