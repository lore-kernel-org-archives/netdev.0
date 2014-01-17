From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Multicast packets receiving problem on linux since version 3.10.1
Date: Fri, 17 Jan 2014 12:08:22 -0500
Message-ID: <52D96386.2020906@gmail.com>
References: <52D94803.1040406@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Yurij Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
To: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:40672 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbaAQRI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 12:08:28 -0500
Received: by mail-qe0-f44.google.com with SMTP id 1so4211662qee.3
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 09:08:27 -0800 (PST)
In-Reply-To: <52D94803.1040406@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 10:10 AM, Andrey Dmitrov wrote:
> Greetings,
> 
> there is a problem with receiving multicast packets on linux-3.10.1 and
> newer. It's reproducible with two hosts (host_A, host_B), with eth3@host_A
> directly connected to eth3@host_B. Two VLANs and one multicast group are
> used.
> Each side opens two sockets and binds them to different VLAN interfaces.
> host_A arranges both sockets to receive multicast packets of the group.
> Then the first socket is removed from the group. After this the second
> socket
> can no longer receive multicast packets of the group, which sent by the
> second host. See the example below.
> 


Thanks for the report.  Looks like a bug in dev_mc_sync().  The problem
appears to be that once an address is synched to eth3 from eth3.999, the
sync from eth3.1001 will fail with EEXIST and will not bump the refcount
on the address added to eth3.  Then when you leave the group, the group,
the address is removed from eth3.

Let me work up a patch.


Thanks
-vlad

> host_A:
> Two VLANs 999 and 1001 are added on eth3:
> eth3.999      10.208.14.1
> eth3.1001     10.208.15.1
> 
> 1. socket(SOCK_DGRAM) -> 3
> 2. setsockopt(3, SOL_SOCKET, SO_REUSEADDR, 1) -> 0
> 3. setsockopt(3, IPPROTO_IP, MCAST_JOIN_GROUP, {229.17.88.168,
> eth3.999}) -> 0
> 4. setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, eth3.999) -> 0
> 5. bind(3, 0.0.0.0:29214)->0
> 6. socket(SOCK_DGRAM) -> 4
> 7. setsockopt(4, SOL_SOCKET, SO_REUSEADDR, 1) -> 0
> 8. setsockopt(4, IPPROTO_IP, MCAST_JOIN_GROUP, {229.17.88.168,
> eth3.1001}) -> 0
> 9. setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, eth3.1001) -> 0
> 10. bind(4, 0.0.0.0:29214) -> 0
> 
> 11. poll({{3, POLLIN}, {4, POLLIN}}, 2, 30000) -> 2
> 12. recv(3, buf, 100) -> 100
> 13. recv(4, buf, 99) -> 99
> 14. setsockopt(3, IPPROTO_IP, MCAST_LEAVE_GROUP, {229.17.88.168,
> eth3.999}) -> 0
> 15. poll({{3, POLLIN}, {4, POLLIN}}, 2, 30000) -> 0
> 
> Socket 4 does not receive the multicast packet on linux 3.10 and newer. But
> it receives the packet with older linux versions. Probably the packet is
> filtered by NIC, tcpdump does not see it.
> 
> 
> host_B:
> Two VLANs 999 and 1001 are added on eth3:
> eth3.999      10.208.14.2
> eth3.1001     10.208.15.2
> 
> 16. socket(SOCK_DGRAM) -> 3
> 17. bind(3, 10.208.14.2:29219) -> 0
> 18. socket(SOCK_DGRAM) -> 4
> 19. bind(4, 10.208.15.2:29219) -> 0
> 20. sendto(3, 229.17.88.168:29214, buf, 100) -> 100
> 21. sendto(4, 229.17.88.168:29214, buf, 99) -> 99
> Continue when socket 3 on host_A will leave the group (line 14).
> 22. sendto(3, 229.17.88.168:29214, buf, 100) -> 100
> 23. sendto(4, 229.17.88.168:29214, buf, 99) -> 99
> 
> 
> Note, that if I replace step #14 with:
>> setsockopt(4, IPPROTO_IP, MCAST_LEAVE_GROUP, {229.17.88.168,
> eth3.1001}) -> 0
> and remove the second socket from the group (instead of the first one) -
> then
> the first socket will receive it's packet.
> 
> Find client and server C programs that reproduce the problem attached.
> The client
> logs received packets. As stated above in good case it will log 3
> packets and in
> bad one - only 2. Use the following command lines to start the client
> and server:
> host_A:
> sudo ip link add link eth3 name eth3.999 type vlan id 999
> sudo ifconfig eth3.999 10.208.14.1/24
> sudo ip link add link eth3 name eth3.1001 type vlan id 1001
> sudo ifconfig eth3.1001 10.208.15.1/24
> 
> gcc mcast_client.c -o cl
> sudo ./cl
> 
> host_B:
> sudo ip link add link eth3 name eth3.999 type vlan id 999
> sudo ifconfig eth3.999 10.208.14.2/24
> sudo ip link add link eth3 name eth3.1001 type vlan id 1001
> sudo ifconfig eth3.1001 10.208.15.2/24
> 
> gcc mcast_serv.c -o serv
> ./serv
> 
> Thanks in advance,
> Andrey Dmitrov
