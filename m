From: Ben Pfaff <blp@nicira.com>
Subject: tc: RTM_GETQDISC causes kernel OOPS
Date: Fri, 21 May 2010 15:42:43 -0700
Message-ID: <20100521224243.GD10247@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail148109.authsmtp.co.uk ([62.13.148.109]:62094 "EHLO
	outmail148109.authsmtp.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758612Ab0EUXNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 19:13:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.  While working on some library code for working with qdiscs and
classes I came upon a kernel OOPS.  Originally I came across it with a
2.6.26 kernel, but I can also reproduce it with unmodified v2.6.34 from
kernel.org.

At the end of this mail I'm appending both an example of the OOPS and a
simple test program that reliably reproduces the problem for me when I
invoke it with "lo" as argument.  The program does not need to be run as
root.

After the OOPS, a lot of networking and other system functions stop
working, so it seems to me a serious issue.

The null pointer dereference that causes the OOPS is the dereference of
the return value of qdisc_dev() in tc_fill_qdisc() in
net/sched/sch_api.c line 1163:

    1161	tcm->tcm__pad1 = 0;
    1162	tcm->tcm__pad2 = 0;
    1163	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
    1164	tcm->tcm_parent = clid;
    1165	tcm->tcm_handle = q->handle;

I am pretty sure about that, because if I add "WARN_ON(!qdisc_dev(q));"
just before line 1163 then that warning triggers.

Thanks,

Ben.

----------------------------------------------------------------------

BUG: unable to handle kernel NULL pointer dereference at 00000050
IP: [<c12280c0>] tc_fill_qdisc+0x68/0x1e5
*pde = 00000000 
Oops: 0000 [#1] SMP 
last sysfs file: 
Modules linked in:

Pid: 600, comm: qdisc Not tainted 2.6.34 #16 /
EIP: 0060:[<c12280c0>] EFLAGS: 00010282 CPU: 0
EIP is at tc_fill_qdisc+0x68/0x1e5
EAX: 00000000 EBX: ffffffff ECX: 00000000 EDX: c7222070
ESI: c14576e0 EDI: c7115200 EBP: c7239ca0 ESP: c7239c3c
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process qdisc (pid: 600, ti=c7239000 task=c720b700 task.ti=c7239000)
Stack:
 00000024 00000014 00000000 c14323a0 c7222060 c7222060 c10a7abd 00001030
<0> 000000d0 c7222060 000000d0 c1228329 000000d0 00000fc4 000000d0 c7115200
<0> 000000d0 00000ec0 c7239cac c12104b1 00000ec0 c1457a98 c7115200 00000258
Call Trace:
 [<c10a7abd>] ? __kmalloc_track_caller+0x122/0x131
 [<c1228329>] ? qdisc_notify+0x2a/0xc8
 [<c12104b1>] ? __alloc_skb+0x4e/0x115
 [<c122838a>] ? qdisc_notify+0x8b/0xc8
 [<c12287ea>] ? tc_get_qdisc+0x143/0x15d
 [<c12286a7>] ? tc_get_qdisc+0x0/0x15d
 [<c1220c28>] ? rtnetlink_rcv_msg+0x195/0x1af
 [<c1220a93>] ? rtnetlink_rcv_msg+0x0/0x1af
 [<c12329e2>] ? netlink_rcv_skb+0x30/0x75
 [<c1220a8b>] ? rtnetlink_rcv+0x1e/0x26
 [<c123281b>] ? netlink_unicast+0xc4/0x11a
 [<c1232eda>] ? netlink_sendmsg+0x223/0x230
 [<c120978c>] ? sock_sendmsg+0xa8/0xbf
 [<c10514fc>] ? print_lock_contention_bug+0x14/0xd7
 [<c101ebe4>] ? __wake_up+0x15/0x3b
 [<c101ebe4>] ? __wake_up+0x15/0x3b
 [<c101ec00>] ? __wake_up+0x31/0x3b
 [<c10acda4>] ? fget_light+0x2d/0xaf
 [<c109488d>] ? might_fault+0x47/0x81
 [<c120acf9>] ? sys_sendto+0xa4/0xc0
 [<c116b82c>] ? _copy_from_user+0x2e/0x108
 [<c120ad92>] ? sys_connect+0x63/0x6e
 [<c120ad2d>] ? sys_send+0x18/0x1a
 [<c120aedb>] ? sys_socketcall+0xd4/0x1a5
 [<c12ca931>] ? syscall_call+0x7/0xb
Code: 50 8b 55 08 89 f8 6a 14 ff 75 14 e8 49 fa ff ff 89 c2 83 c2 10 89 45 ac c6 42 01 00 66 c7 42 02 00 00 c6 40 10 00 8b 46 40 8b 00 <8b> 40 50 89 5a 0c 89 42 04 8b 46 20 89 42 08 8b 46 28 89 42 10 
EIP: [<c12280c0>] tc_fill_qdisc+0x68/0x1e5 SS:ESP 0068:c7239c3c
CR2: 0000000000000050
---[ end trace 6fb85bbc66de8f42 ]---

----------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <linux/rtnetlink.h>
#include <linux/pkt_sched.h>
#include <net/if.h>

int
main(int argc, char *argv[])
{
    struct {
        struct nlmsghdr nlmsg;
        struct tcmsg tcmsg;
    } msg;

    struct sockaddr_nl local, remote;
    int ifindex;
    int fd;

    if (argc != 2) {
        fprintf(stderr,
                "usage: %s <netdev>\n"
                "where <netdev> is a network device, e.g. \"lo\"\n",
                argv[0]);
        return EXIT_FAILURE;
    }

    /* Get ifindex. */
    ifindex = if_nametoindex(argv[1]);
    if (!ifindex) {
        fprintf(stderr, "no network device named \"%s\"", argv[1]);
        return EXIT_FAILURE;
    }

    /* Make rtnetlink socket. */
    fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
    if (fd < 0) {
        perror("socket");
        return EXIT_FAILURE;
    }

    /* Bind local address as our selected pid. */
    memset(&local, 0, sizeof local);
    local.nl_family = AF_NETLINK;
    local.nl_pid = getpid();
    if (bind(fd, (struct sockaddr *) &local, sizeof local) < 0) {
        perror("bind");
        return EXIT_FAILURE;
    }

    /* Bind remote address as the kernel (pid 0). */
    memset(&remote, 0, sizeof remote);
    remote.nl_family = AF_NETLINK;
    remote.nl_pid = 0;
    if (connect(fd, (struct sockaddr *) &remote, sizeof remote) < 0) {
        perror("connect");
        return EXIT_FAILURE;
    }

    /* Send "get" request. */
    memset(&msg, 0, sizeof msg);
    msg.nlmsg.nlmsg_len = sizeof msg;
    msg.nlmsg.nlmsg_type = RTM_GETQDISC;
    msg.nlmsg.nlmsg_flags = NLM_F_REQUEST | NLM_F_ECHO | NLM_F_ACK;
    msg.nlmsg.nlmsg_seq = 1;
    msg.nlmsg.nlmsg_pid = getpid();
    msg.tcmsg.tcm_family = AF_UNSPEC;
    msg.tcmsg.tcm_ifindex = ifindex;
    msg.tcmsg.tcm_handle = 0;
    msg.tcmsg.tcm_parent = TC_H_ROOT;
    if (send(fd, &msg, sizeof msg, 0) < 0) {
        perror("send");
        return EXIT_FAILURE;
    }

    return 0;
}
