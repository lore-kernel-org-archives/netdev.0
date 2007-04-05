From: Paolo Galtieri <pgaltieri@mvista.com>
Subject: Bug in SCTP with SCTP_BINDX_REM_ADDR
Date: Thu, 05 Apr 2007 06:34:30 -0700
Message-ID: <4614FAE6.3070409@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080000060701050705000805"
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:45525 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992688AbXDENeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 09:34:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080000060701050705000805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Folks,
  while doing some testing of SCTP recently I came across a scenario
where the behavior I see is not what I expect.  Here is the scenario:

I have 2 interfaces on a system, each has both an IPv4 and an IPv6
address, e.g.

eth0
  192.168.1.130
  ::ffff:192.168.1.130

eth1
  192.168.3.130
  ::ffff:192.168.3.130


I have a test program that creates an IPv6 socket and then does a
sctp_bindx() to add the first IPv6 address and a sctp_bindx() to
add the second IPv6 address using the SCTP_BINDX_ADD_ADDR option
to sctp_bindx().  I then call sctp_bindx() to remove the second
IPv6 address using the SCTP_BINDX_REM_ADDR option.  This call to
sctp_bindx() fails with EINVAL.  Since there is still 1 address
associated with the endpoint I would expect this call to succeed.

I traced what was going on and here is what I observed.

The sctp_bindx() call in user space eventually turns into a call to
sctp_bindx_add() in the kernel which in turn calls sctp_do_bind().
In sctp_do_bindx() there is the following code:

    /* PF specific bind() address verification. */
    if (!sp->pf->bind_verify(sp, addr))
        return -EADDRNOTAVAIL;

bind_verify() is a function pointer which resolves into a call to
sctp_inet6_bind_verify() since I'm dealing with an IPv6 socket.  This
function verifies that the sockaddr looks bindable.  After doing some
checks it calls sctp_v6_available() through another function pointer.
The 2 IPv6 addresses assigned to the 2 interfaces are IPv6 addresses
which are mapped to IPv4 addresses.  In sctp_v6_available() there is
the following code:

    if (type == IPV6_ADDR_MAPPED) {
        if (sp && !sp->v4mapped)
            return 0;
        if (sp && ipv6_only_sock(sctp_opt2sk(sp)))
            return 0;
        sctp_v6_map_v4(addr);
        return sctp_get_af_specific(AF_INET)->available(addr, sp);
    }

Since my IPv6 addresses are IPv4 mapped addresses sctp_v6_map_v4() gets
called which converts the IPv6 address to an IPv4 address.  So what
originally started as an IPv6 address in sctp_bindx_add() has now been
converted to an IPv4 address.  We then return back to sctp_do_bind().
We do some more checks and then we call sctp_add_bind_addr() to actually
complete the bind process.  sctp_add_bind_addr() adds the address we just
processed to the bind address list.  So at this point in time we have
2 entries on &bp->address_list (see net/sctp/bind_addr.c), each entry
contains an address family value of 2 (AF_INET), a port number and
an IPv4 address.

So far so good.

Mow we get to the core of the problem.  When we call sctp_bindx() with
the SCTP_BINDX_REM_ADDR option to remove the IPv6 address we call
sctp_bindx_rem(). This function does some validation and then calls
sctp_del_bind_addr() to remove the address from the bind address list.
sctp_del_bind_addr() walks the bind address list &bp->address_list
looking for a match.  Since we are processing an IPv6 address the
address family is 10 (AF_INET6).  The call to sctp_cmp_addr_exact() in
sctp_del_bind_addr() never finds a match and so sctp_del_bind_addr()
returns EINVAL.  sctp_cmp_addr_exact() fails on the compare of the
address family, what's on the list is AF_INET and what it's comparing
against is AF_INET6.

What is happening is that the check for IPV6_ADDR_MAPPED that occurs
during the add is missing when you do the remove and hence the IPv6
address is never mapped to the IPv4 address causing the lookup to
fail.  Below is the patch to add the necessary checks to do the
mapping.  This patch is against 2.6.21-rc5

Does this make sense?  Any comments are appreciated.

Thank you,
Paolo

I've attached the test program - compile as gcc -o bindx-test-ipv6 
bindx-test-ipv6.c -lsctp
================================ >8 
==========================================
--- net/sctp/socket.c.orig      2007-04-04 13:22:59.000000000 -0700
+++ net/sctp/socket.c   2007-04-04 13:25:35.000000000 -0700
@@ -627,6 +627,27 @@ int sctp_bindx_rem(struct sock *sk, stru
                        retval = -EINVAL;
                        goto err_bindx_rem;
                }
+               /*
+                * It's possible that we mapped an IPV6 addr to an IPV4 addr
+                * during the sctp_bindx_add() operation.  This will 
happen if
+                * the IPV6 address we assigned to an interface is a mapped
+                * address, e.g. ::ffff:192.0.2.128.  If we have mapped 
an IPV6
+                * address to an IPV4 address during the add we need to make
+                * sure we do the same thing during the remove, otherwise we
+                * wont find a match on the address_list.
+                */
+
+               if (af->sa_family == AF_INET6) {
+                       struct in6_addr *in6;
+                       int type;
+
+                       in6 = (struct in6_addr *)&sa_addr->v6.sin6_addr;
+                       type = ipv6_addr_type(in6);
+
+                       if (type == IPV6_ADDR_MAPPED)
+                               sctp_v6_map_v4(sa_addr);
+               }
+
                if (sa_addr->v4.sin_port != htons(bp->port)) {
                        retval = -EINVAL;
                        goto err_bindx_rem;


--------------080000060701050705000805
Content-Type: text/x-csrc;
 name="bindx-test-ipv6.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bindx-test-ipv6.c"

#include <unistd.h> 
#include <stdlib.h> 
#include <stdio.h> 
#include <errno.h> 
#include <netinet/ip.h> 
#include <netinet/sctp.h> 
 
/* Build: gcc -lrt -lsctp bindx.test.c -o bindxtest */ 
 
int 
main(int argc, char* argv[]) 
{ 
	int	rc; 
	int	len; 
	int	out; 
	int	val = 32 * 1024; 
	struct sockaddr_storage	client_addr; 
	struct sockaddr_in6		addrs[2]; 
	struct sctp_paddrparams	params; 
	 
	out = socket(AF_INET6, SOCK_SEQPACKET, IPPROTO_SCTP); 
	if (out == -1) { 
		printf("socket failed, out=%d, errno=%d, %s\n", out, errno, strerror(errno)); 
		exit(-1); 
	} 
	 
	printf("socket = %d\n",out); 
	rc = setsockopt(out, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val)); 
	if (rc < 0) { 
		printf("setsockopt SNDBUF failed rc=%d, %s\n", rc, strerror(errno)); 
		exit(-1); 
	} 
	 
	rc = setsockopt(out, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val)); 
	if (rc < 0) { 
		printf("setsockopt RCVBUF failed rc=%d, %s\n", rc, strerror(errno)); 
		exit(-1); 
	} 
 
	memset((void *)&addrs, 0, sizeof(addrs)); 
	if (inet_pton(AF_INET6, "::ffff:192.168.1.168", &addrs[0].sin6_addr) < 0) 
		printf("inet_pton(0) failed\n"); 
	addrs[0].sin6_family = AF_INET6; 
	addrs[0].sin6_port = htons(5060); 
	 
	if (inet_pton(AF_INET6, "::ffff:192.168.3.168", &addrs[1].sin6_addr) < 0) 
		printf("inet_pton(1) failed\n"); 
	addrs[1].sin6_family = AF_INET6; 
	addrs[1].sin6_port = htons(5060); 
 
//printf("sctp_bindx(SCTP_BINDX_ADD_ADDR)\n");

	rc = sctp_bindx(out, (struct sockaddr*)&addrs[0], 1, SCTP_BINDX_ADD_ADDR); 
	if (rc < 0) { 
		printf("sctp_bindx failed rc=%d, %s\n", rc, strerror(errno)); 
		exit(-1); 
	} 
	 
	rc = listen(out,2); 
	if (rc < 0) { 
		printf("listen failed rc=%d, %s\n", rc, strerror(errno)); 
		exit(-1); 
	} 
	 
	len = sizeof(client_addr); 
	if (getsockname(out, (struct sockaddr *)&client_addr, &len) < 0) { 
		printf("getsockname(%d) failed: %s\n", out, strerror(errno)); 
		exit(-1); 
	} 
	 
	system("cat /proc/net/sctp/eps"); 
	 
//printf("sctp_bindx(SCTP_BINDX_ADD_ADDR)\n");

	rc = sctp_bindx(out, (struct sockaddr *)&addrs[1], 1, SCTP_BINDX_ADD_ADDR); 
	if (rc == -1) { 
		printf("bind-1 failed, rc=%d, errno=%d, %s\n", rc, errno, strerror(errno)); 
		exit(-1); 
	} 
	 
	system("cat /proc/net/sctp/eps"); 
	 
//printf("sctp_bindx(SCTP_BINDX_REM_ADDR)\n");

	rc = sctp_bindx(out, (struct sockaddr *)&addrs[1], 1, SCTP_BINDX_REM_ADDR); 
	if (rc == -1) { 
		printf("bind-2 failed, rc=%d, errno=%d, %s\n", rc, errno, strerror(errno)); 
		exit(-1); 
	} 
	 
	system("cat /proc/net/sctp/eps"); 
	 
	exit(0); 
} 

--------------080000060701050705000805--
