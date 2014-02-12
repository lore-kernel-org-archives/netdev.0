From: Andrey Wagin <avagin@gmail.com>
Subject: The kmemleak detector reports about leaked "struct net"
Date: Wed, 12 Feb 2014 13:42:46 +0400
Message-ID: <CANaxB-x0wp2iC9Bp=xgH98MutQujvNMkUmZsobpxvWUc7H=SOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:45625 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbaBLJmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 04:42:47 -0500
Received: by mail-ve0-f169.google.com with SMTP id oy12so7106702veb.14
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 01:42:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A kernel is compiled from Linus' tree without additional changes.
[root@jenkins ~]# uname -a
Linux jenkins.criu.org 3.14.0-rc2 #162 SMP Tue Feb 11 01:09:33 MSK
2014 x86_64 x86_64 x86_64 GNU/Linux

Sometimes I have found reports from the kmemleak detector about leaked
"struct net".

Here is a script to reproduce these leaks:
[root@jenkins ~]# cat test_net_ns.sh
ip net add test &&
ip link add name veth0 type veth peer name veth1 &&
ip link set dev veth1 netns test &&
ip net exec test ip link set up dev veth1 &&
ip link set up dev veth0 &&
brctl addif br0 veth0 &&
ip net exec test dhclient -4 veth1 -pf test.dhcp.pid -lf test.dhcp.lease &&
ip net exec test ip a
ip net exec test dhclient -r -pf test.dhcp.pid -lf test.dhcp.lease &&
ip net delete test &&
true || echo FAIL

This script creates a network namespace and a veth pair. One veth
device is attached to a bridge, another one is moved in namespace. The
dhclient gets ip address for the veth device in the test network
namespace. The final action is destroying the test network namespace.

[root@jenkins ~]# echo clear > /sys/kernel/debug/kmemleak
[root@jenkins ~]# bash -x test_net_ns.sh
+ ip net add test
+ ip link add name veth0 type veth peer name veth1
+ ip link set dev veth1 netns test
+ ip net exec test ip link set up dev veth1
+ ip link set up dev veth0
+ brctl addif br0 veth0
+ ip net exec test dhclient -4 veth1 -pf test.dhcp.pid -lf test.dhcp.lease
+ ip net exec test ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
23: veth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether ae:f9:75:20:9c:92 brd ff:ff:ff:ff:ff:ff
    inet 10.30.24.229/16 brd 10.30.255.255 scope global dynamic veth1
       valid_lft 3558sec preferred_lft 3558sec
    inet6 fe80::acf9:75ff:fe20:9c92/64 scope link
       valid_lft forever preferred_lft forever
+ ip net exec test ip r
default via 10.30.0.1 dev veth1
10.30.0.0/16 dev veth1  proto kernel  scope link  src 10.30.24.229
+ ip net exec test dhclient -r -pf test.dhcp.pid -lf test.dhcp.lease
+ ip net delete test
+ true
[root@jenkins ~]# echo scan > /sys/kernel/debug/kmemleak
[root@jenkins ~]# cat /sys/kernel/debug/kmemleak
[root@jenkins ~]# echo scan > /sys/kernel/debug/kmemleak
[root@jenkins ~]# cat /sys/kernel/debug/kmemleak
unreferenced object 0xffff88009bfc3c80 (size 128):
  comm "ip", pid 25985, jiffies 4346037464 (age 4507.484s)
  hex dump (first 32 bytes):
    0d 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 b0 53 eb 0e 01 88 ff ff  .........S......
  backtrace:
    [<ffffffff8176858e>] kmemleak_alloc+0x5e/0xc0
    [<ffffffff811f6d3f>] __kmalloc+0x1bf/0x2e0
    [<ffffffff81636351>] net_alloc_generic+0x21/0x30
    [<ffffffff81636855>] copy_net_ns+0x45/0x160
    [<ffffffff810b4c91>] create_new_namespaces+0x101/0x1b0
    [<ffffffff810b4dc5>] unshare_nsproxy_namespaces+0x85/0xe0
    [<ffffffff810810eb>] SyS_unshare+0x1ab/0x350
    [<ffffffff8177bfe9>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88006b3a92c0 (size 4416):
  comm "ip", pid 25985, jiffies 4346037464 (age 4507.484s)
  hex dump (first 32 bytes):
    02 00 00 00 00 00 00 00 08 08 00 00 ad 4e ad de  .............N..
    ff ff ff ff 00 00 00 00 ff ff ff ff ff ff ff ff  ................
  backtrace:
    [<ffffffff8176858e>] kmemleak_alloc+0x5e/0xc0
    [<ffffffff811f5f47>] kmem_cache_alloc+0x217/0x2a0
    [<ffffffff81636875>] copy_net_ns+0x65/0x160
    [<ffffffff810b4c91>] create_new_namespaces+0x101/0x1b0
    [<ffffffff810b4dc5>] unshare_nsproxy_namespaces+0x85/0xe0
    [<ffffffff810810eb>] SyS_unshare+0x1ab/0x350
    [<ffffffff8177bfe9>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff

[root@jenkins ~]# lsmod
Module                  Size  Used by
veth                   13604  0
binfmt_misc            17392  0
ip6table_filter        12815  0
ip6_tables             26677  1 ip6table_filter
tun                    32328  0
netlink_diag           12658  0
af_packet_diag         12604  0
udp_diag               12794  0
tcp_diag               12591  0
inet_diag              18278  2 tcp_diag,udp_diag
unix_diag              12594  0
bridge                116990  0
stp                    12989  1 bridge
llc                    14094  2 stp,bridge
btrfs                 933081  1
xor                    21366  1 btrfs
raid6_pq               96781  1 btrfs
joydev                 17642  0
microcode              19962  0
i2c_piix4              22148  0
virtio_net             28194  0
i2c_core               38545  1 i2c_piix4
virtio_balloon         13451  0
pcspkr                 12718  0
virtio_blk             18030  6
virtio_pci             17713  0
virtio_ring            19923  4 virtio_blk,virtio_net,virtio_pci,virtio_balloon
virtio                 14207  4 virtio_blk,virtio_net,virtio_pci,virtio_balloon
floppy                 73436  0
