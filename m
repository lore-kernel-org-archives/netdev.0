From: "Tim Yardley" <liquid@haveheart.com>
Subject: Sendmsg receiving EPERM
Date: Wed, 6 Sep 2006 01:29:31 -0500
Message-ID: <006f01c6d17d$cff7ab70$0201a8c0@liquid>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:2431 "EHLO
	asav00.insightbb.com") by vger.kernel.org with ESMTP
	id S932090AbWIFG3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 02:29:32 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have an interesting situation in which a box is "heavily" loaded with
network traffic on a bridged interface.  The card in question is  the
silicom intel 2 port pci-x bypass card. The driver is pretty much just a
modified e1000 driver.  I am using a slightly older version of the driver
(5.6.11 I believe), but this is still very strange behavior.

During the heavy network load I get the following situation:

# ping -n google.com
PING google.com (64.233.167.99) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
ping: sendmsg: Operation not permitted
64 bytes from 64.233.167.99: icmp_seq=6 ttl=242 time=1023 ms
64 bytes from 64.233.167.99: icmp_seq=8 ttl=242 time=22.8 ms
64 bytes from 64.233.167.99: icmp_seq=9 ttl=242 time=22.0 ms
ping: sendmsg: Operation not permitted

Snip of the strace:

--------

sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("64.233.167.99")},
msg_iov(1)=[{"\10\0\211\321\225h\0m/\373\375D\270\25\10\0\10\t\n\v\f"...,
64}], msg_controllen=0, msg_flags=0}, MSG_CONFIRM) = -1 EPERM (Operation not
permitted)
recvmsg(3, 0xbfe96470, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource
temporarily unavailable)
dup(2)                                  = 4
fcntl64(4, F_GETFL)                     = 0x2 (flags O_RDWR)
fstat64(4, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 5), ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
0xb7e44000
_llseek(4, 0, 0xbfe96540, SEEK_CUR)     = -1 ESPIPE (Illegal seek)
write(4, "ping: sendmsg: Operation not per"..., 39) = 39
close(4)                                = 0
munmap(0xb7e44000, 4096)                = 0
recvmsg(3, 0xbfe96710, 0)               = -1 EAGAIN (Resource temporarily
unavailable)
gettimeofday({1157495600, 551997}, NULL) = 0
gettimeofday({1157495600, 552181}, NULL) = 0
sendmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(0),
sin_addr=inet_addr("64.233.167.99")},
msg_iov(1)=[{"\10\0Ky\225h\0n0\373\375D\365l\10\0\10\t\n\v\f\r\16\17"...,
64}], msg_controllen=0, msg_flags=0}, 0) = 64
recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(22759),
sin_addr=inet_addr("64.233.167.99")},
msg_iov(1)=[{"E\0\0T\0m@\0\363\1\0165@\351\247cD\264L\6\0\0Sy\225h\0"...,
192}], msg_controllen=20, {cmsg_len=20, cmsg_level=SOL_SOCKET,
cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, 0) = 84
write(1, "64 bytes from 64.233.167.99: icm"..., 63) = 63
gettimeofday({1157495600, 580525}, NULL) = 0
poll([{fd=3, events=POLLIN|POLLERR, revents=POLLIN}], 1, 972) = 1
recvmsg(3, {msg_name(16)={sa_family=AF_INET, sin_port=htons(46027),
sin_addr=inet_addr("68.180.76.6")},
msg_iov(1)=[{"E\300\0XaI\0\0@\1\367\'D\264L\6D\264L\6\3\1\34\303\0\0"...,
192}], msg_controllen=20, {cmsg_len=20, cmsg_level=SOL_SOCKET,
cmsg_type=0x1d /* SCM_??? */, ...}, msg_flags=0}, MSG_DONTWAIT) = 88
gettimeofday({1157495600, 851056}, NULL) = 0

----------------

Sysctl.conf:
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
kernel.sysrq=1
net.ipv4.ip_forward=1
kernel.sem=250 32000 100 128
# Adjust where the gc will leave arp table alone
net.ipv4.neigh.default.gc_thresh1=256
net.ipv4.neigh.default.gc_thresh2=1024
net.ipv4.neigh.default.gc_thresh3=2048
# Increase TCP
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen = 6
# Increase size of socket buffers
net.ipv4.tcp_rmem = 4096 98304 349520
net.ipv4.tcp_wmem = 4096 65535 262142
net.ipv4.tcp_mem = 98304 262142 393216
# Bump up TCP socket queue mechanism to help with syn floods
net.ipv4.tcp_max_syn_backlog = 2048
# Drop it so lack of FIN times out quicker
net.ipv4.tcp_fin_timeout = 30
# Increase number of incoming connections backlog
net.core.somaxconn = 512
# Bump optmem_max up
net.core.optmem_max = 20480
# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 1024
# Bump up default r/wmem to max
net.core.rmem_default = 262141
net.core.wmem_default = 262141
# Bump up max r/wmem
net.core.rmem_max = 262141
net.core.wmem_max = 262141
# Increase size of file handles and inode cache
fs.file-max = 209708

-----------------

Some proc relevance (eth1 and eth2 are the devices pushing the traffic):

# cat /proc/interrupts
           CPU0       CPU1
  0:  350401618          0    IO-APIC-edge  timer
  9:          0          0   IO-APIC-level  acpi
 14:   15736294          0    IO-APIC-edge  libata
 15:          0          0    IO-APIC-edge  libata
169:          0          0   IO-APIC-level  uhci_hcd:usb2
177: 1557943765          0   IO-APIC-level  uhci_hcd:usb3, eth0, eth2
185:         41          0   IO-APIC-level  HDA Intel, uhci_hcd:usb4
193:          0          0   IO-APIC-level  uhci_hcd:usb1, ehci_hcd:usb5
201: 1316369138          0   IO-APIC-level  eth1
NMI:          0          0
LOC:  349727026  349727025
ERR:          0
MIS:          0

# cat /proc/loadavg
1.33 0.90 1.16 2/159 28533

# cat /proc/version
Linux version 2.6.12-gentoo-r10 (root@meepmeep) (gcc version 3.3.5-20050130
(Gentoo 3.3.5.20050130-r1, ssp-3.3.5.20050130-1, pie-8.7.7.1)) #4 SMP Sun
Mar 26 23:00:57 CST 2006

Anyone have any ideas as to what this might be?  Interrupt overload?  Any
way to relieve this situation?  I've searched around but haven't found much
definitive.  Have I over/undertuned something?  Any help is definitely
appreciated.  Sysctl tweaks that will address this problem are very much
welcome as well. 

Thanks in advance.

/tmy
