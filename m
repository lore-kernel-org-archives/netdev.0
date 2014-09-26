From: David Ahern <dsahern@gmail.com>
Subject: VRFs and the scalability of namespaces
Date: Fri, 26 Sep 2014 16:37:26 -0600
Message-ID: <5425EAA6.7040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44359 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbaIZWhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 18:37:31 -0400
Received: by mail-pd0-f171.google.com with SMTP id y13so13709970pdi.30
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 15:37:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric:

As you suggested [1] I am starting a new thread to discuss scalability 
problems using namespaces for VRFs.

Background
----------
Consider a single system that wants to provide VRF-based features with 
support for N VRFs. N could easily be 2048 (e.g., 6Wind, [2]), 4000 
(e.g., Cisco, [3]) or even higher.

The single system with support for N VRFs runs M services (e.g., quagga, 
cdp, lldp, stp, strongswan, some homegrown routing protocol) and 
includes standard system services like sshd. Furthermore, a system also 
includes monitoring programs like snmpd and tcollector. In short, M is 
easily 20 processes that need to have a presence across all VRFs.


Network Namespaces for VRFs
---------------------------
For the past 4 years or so the response to VRF questions is a drum beat 
of "use network namespaces". But namespaces are not a good match for VRFs.

1. Network namespaces are a complete separation of the networking stack 
from network devices up. VRFs are an L3 concept. Using namespaces forces 
an L3 separation concept onto L2 apps -- lldp, cdp, etc.

There are use cases when you want device level separation, use cases 
where you want only L3 and up separation, and cases where you want both 
(e.g., divy up the netdevices in a system across some small number of 
namespaces and then provide VRF based features within a namespace).


2. Scalability of apps providing service as namespaces are created. How 
do you create the presence for each service in a network namespace?

a. Spawn a new process for each namespace? brute force approach and 
extremely resource intensive. e.g., the quagga example [4]

b. spawn a thread for each namespace? Better than a full process but 
still a heavyweight solution

c. create a socket per namespace. Better but still this is a resource 
intensive solution -- N listen sockets per service and each service 
needs to be modified for namespace support. For opensource software that 
means each project has to agree that namespace awareness is relevant and 
agree to take the patches.


3. Just creating a network namespace consumes non-negligible amount of 
memory -- ~200kB for the 3.10 kernel. I believe the /proc entries are 
the bulk of that memory usage. 200kB/namespace is again a lot of wasted 
memory and overhead.


4. For a single process to straddle multiple namespaces it has to run 
with full root privileges -- CAP_SYS_ADMIN -- to use setns. Using 
network sockets does not require a process to run as root at all unless 
it wants privileged ports in which case CAP_NET_BIND_SERVICE is 
sufficient, not full root.


The Linux kernel needs proper VRF support -- as an L3 concept. A 
capability to run a process in a "VRF any" context provides a resource 
efficient solution where a single process with a single listen socket 
works across all VRFs in a namespace and then connected sockets have a 
specific VRF context.

Before droning on even more, does the above provide better context on 
the general problem?

Thanks,
David


[1] https://lkml.org/lkml/2014/9/26/840

[2] http://www.6wind.com/6windgate-performance/ip-forwarding

[3] 
http://www.cisco.com/c/en/us/td/docs/switches/datacenter/sw/verified_scalability/b_Cisco_Nexus_7000_Series_NX-OS_Verified_Scalability_Guide.html

[4] 
https://lists.quagga.net/pipermail/quagga-users/2010-February/011351.html
