From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Tue, 05 Sep 2006 15:34:40 +0200
Message-ID: <44FD7CF0.4030009@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060816115313.GC31810@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Andrey Savochkin <saw@sw.ru>,
	haveblue@us.ibm.com, clg@fr.ibm.com, herbert@13thfloor.at,
	sam@vilain.net, ebiederm@xmission.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:56100 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP id S965013AbWIENeo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 09:34:44 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k85DYhHA049232
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 13:34:43 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k85DammD1511622
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 14:36:48 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k85DYgCg024262
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 14:34:43 +0100
To: netdev@vger.kernel.org
In-Reply-To: <20060816115313.GC31810@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

>>   This complete separation of namespaces is very useful for at least two
>>   purposes:
>>    - allowing users to create and manage by their own various tunnels and
>>      VPNs, and
>>    - enabling easier and more straightforward live migration of groups of
>>      processes with their environment.
> 
> 
> I conceptually prefer this approach, but I seem to recall there were
> actual problems in using this for checkpoint/restart of lightweight
> (application) containers.  Performance aside, are there any reasons why
> this approach would be problematic for c/r?

I agree with this approach too, separated namespaces is the best way to 
identify the network ressources for a specific container.

> I'm afraid Daniel may be on vacation, and don't know who else other than
> Eric might have thoughts on this.

Yes, I was in "vacation", but I am back :)

>>2. People expressed concerns that complete separation of namespaces
>>   may introduce an undesired overhead in certain usage scenarios.
>>   The overhead comes from packets traversing input path, then output path,
>>   then input path again in the destination namespace if root namespace
>>   acts as a router.

Yes, performance is probably one issue.

My concerns was for layer 2 / layer 3 virtualization. I agree a layer 2 
isolation/virtualization is the best for the "system container".
But there is another family of container called "application container", 
it is not a system which is run inside a container but only the 
application. If you want to run a oracle database inside a container, 
you can run it inside an application container without launching <init> 
and all the services.

This family of containers are used too for HPC (high performance 
computing) and for distributed checkpoint/restart. The cluster runs 
hundred of jobs, spawning them on different hosts inside an application 
container. Usually the jobs communicates with broadcast and multicast.
Application containers does not care of having different MAC address and 
rely on a layer 3 approach.

Are application containers comfortable with a layer 2 virtualization ? I 
  don't think so, because several jobs running inside the same host 
communicate via broadcast/multicast between them and between other jobs 
running on different hosts. The IP consumption is a problem too: 1 
container == 2 IP (one for the root namespace/ one for the container), 
multiplicated with the number of jobs. Furthermore, lot of jobs == lot 
of virtual devices.

However, after a discussion with Kirill at the OLS, it appears we can 
merge the layer 2 and 3 approaches if the level of network 
virtualization is tunable and we can choose layer 2 or layer 3 when 
doing the "unshare". The determination of the namespace for the incoming 
traffic can be done with an specific iptable module as a first step. 
While looking at the network namespace patches, it appears that the 
TCP/UDP part is **very** similar at what is needed for a layer 3 approach.

Any thoughts ?

	Daniel
