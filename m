From: Jan Oravec <jan.oravec@6com.sk>
Subject: kernel bug: control message on AF_INET6 sockets strangely truncated on sparc64 platform
Date: Mon, 28 Jul 2003 17:18:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728151849.GA18408@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

while trying to setup IPv6-capable bind DNS server on UltraSparc II box,
i have found the following problem:


let's have the following program:

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>


int main()
{
  int fd;
  struct sockaddr_in6 sin;
  char buf0[1000];
  char buf1[1000];
  char buf2[1000];
  struct msghdr mhdr;
  struct iovec iov;
  int on=1;

  mhdr.msg_name=buf0;
  mhdr.msg_namelen=1000;
  mhdr.msg_iov=&iov;
  mhdr.msg_iovlen=1;
  mhdr.msg_control=buf1;
  mhdr.msg_controllen=CMSG_LEN(sizeof(struct in6_pktinfo));
  mhdr.msg_flags=0;
  iov.iov_base=buf2;
  iov.iov_len=1000;

  printf("clen_init=%d\n", mhdr.msg_controllen);

  fd=socket(AF_INET6, SOCK_DGRAM, 0);
  setsockopt(fd, IPPROTO_IPV6, IPV6_PKTINFO, &on, sizeof(on));
  sin.sin6_port=htons(4747);
  memset(&sin.sin6_addr, 0, 16);
  bind(fd, &sin, sizeof(struct sockaddr_in6));
  recvmsg(fd, &mhdr, 0);

  printf("clen=%d flags=%d\n", mhdr.msg_controllen, mhdr.msg_flags);

  return 0;
}


after running and sending any IPv6 UDP packet to port 4747, we get the
following result:

clen_init=32
clen=28 flags=8

when we change controllen to 33, we get:

clen_init=33
clen=32 flags=8

and finally to 36:

clen_init=36
clen=32 flags=0


this case is not so critical, it just truncates something what it should
not, but the following happened while debugging bind:

898             cc = recvmsg(sock->fd, &msghdr, 0);
(gdb) print msghdr
$37 = {msg_name = 0x15c2b4, msg_namelen = 28, msg_iov = 0xeffff658, msg_iovlen = 1, msg_control = 0xeffff600, msg_controllen = 52, msg_flags = 0}
(gdb) next
899             recv_errno = errno;
(gdb) print msghdr
$38 = {msg_name = 0x0, msg_namelen = 28, msg_iov = 0xeffff658, msg_iovlen = 1, msg_control = 0xeffff600, msg_controllen = 60, msg_flags = 8}
(gdb) x/13 msghdr->msg_control
0xeffff600:     0x00000014      0x0000ffff      0x0000001d      0x3f251d01
0xeffff610:     0x000bb770      0x00000010      0x00000029      0x00000002
0xeffff620:     0x3ffe80ee      0x00000018      0xeffff658      0x00000001
0xeffff630:     0xeffff600

msg_controllen was increased by kernel

the source address of packet was 3ffe:80ee:3bd:0:a00:20ff:fec9:3aad, not 3ffe:80ee:0000:0018:efff:f658:0000:0001

when tried on x86 platform, it worked fine


and once, when i compiled bind with -O0, kernel crashed


i am using:
Linux ns2 2.4.22-pre6 #2 Wed Jul 16 22:34:00 CEST 2003 sparc64 sun4u TI UltraSparc II  (BlackBird) GNU/Linux

(same results on stable 2.4.21)

dmesg output:

PROMLIB: Sun IEEE Boot Prom 3.23.1 1999/07/16 12:08
Linux version 2.4.22-pre6 (root@ns1) (gcc version egcs-2.92.11 19980921 (gcc2 ss-980609 experimental)) #2 Wed Jul 16 22:34:00 CEST 2003
ARCH: SUN4U
Ethernet address: 08:00:20:c9:3a:ad
On node 0 totalpages: 65080
zone(0): 65421 pages.
zone(1): 0 pages.
zone(2): 0 pages.
Found CPU 0 (node=f006d624,mid=0)
Found 1 CPU prom device tree node(s).
Kernel command line: root=/dev/sda2 sym53c8xx=excl:0x7d9
Calibrating delay loop... 897.84 BogoMIPS
Memory: 514456k available (1592k kernel code, 280k data, 128k init) [fffff80000000000,00000000bff1a000]
Dentry cache hash table entries: 65536 (order: 7, 1048576 bytes)
Inode cache hash table entries: 32768 (order: 6, 524288 bytes)
Mount cache hash table entries: 512 (order: 0, 8192 bytes)
Buffer cache hash table entries: 32768 (order: 5, 262144 bytes)
Page-cache hash table entries: 65536 (order: 6, 524288 bytes)
POSIX conformance testing by UNIFIX
PCI: Probing for controllers.
PCI: Found PSYCHO, control regs at 000001fe00000000
PSYCHO: Shared PCI config space at 000001fe01000000
PCI-IRQ: Routing bus[ 0] slot[ 1] map[0] to INO[21]
PCI-IRQ: Routing bus[ 0] slot[ 3] map[0] to INO[20]
PCI-IRQ: Routing bus[ 0] slot[ 3] map[0] to INO[26]
PCI-IRQ: Routing bus[ 0] slot[ 4] map[0] to INO[18]
PCI-IRQ: Routing bus[ 0] slot[ 4] map[0] to INO[19]
PCI0(PBMB): Bus running at 33MHz
PCI-IRQ: Routing bus[ 1] slot[ 1] map[0] to INO[00]
PCI0(PBMA): Bus running at 33MHz
ebus0: [auxio] [power] [SUNW,pll] [sc] [se] [su] [su] [ecpp] [fdthree] [eeprom] [flashprom]
PCIO serial driver version 1.54
su(mouse) at 0x1fff13062f8 (irq = 4,7ea) is a 16550A
Sun Mouse-Systems mouse driver version 1.00
su(kbd) at 0x1fff13083f8 (irq = 9,7e9) is a 16550A
keyboard: not present
power: Control reg at 000001fff1724000 ... not using powerd.
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
Starting kswapd
Journalled Block Device driver loaded
devfs: v1.12c (20020818) Richard Gooch (rgooch@atnf.csiro.au)
devfs: boot_options: 0x1
Console: switching to frame buffer device
fb0: Permedia2 PCI board (Permedia2), using 8192K of video memory.
rtc_init: no PC rtc found
Software Watchdog Timer: 0.05, timer margin: 60 sec
NET4: Frame Diverter 0.46
sunhme.c:v2.01 26/Mar/2002 David S. Miller (davem@redhat.com)
divert: allocating divert_blk for eth0
eth0: HAPPY MEAL (PCI/CheerIO) 10/100BaseT Ethernet 08:00:20:c9:3a:ad
SCSI subsystem driver Revision: 1.00
sym.0.3.0: setting PCI_COMMAND_INVALIDATE.
sym.0.3.1: setting PCI_COMMAND_PARITY...
sym.0.3.1: setting PCI_COMMAND_INVALIDATE.
sym.0.4.0: setting PCI_COMMAND_PARITY...
sym.0.4.0: setting PCI_COMMAND_INVALIDATE.
sym.0.4.1: setting PCI_COMMAND_PARITY...
sym.0.4.1: setting PCI_COMMAND_INVALIDATE.
sym0: <875> rev 0x14 on pci bus 0 device 3 function 0 irq 4,7e0
sym0: No NVRAM, ID 7, Fast-20, SE, parity checking
sym0: SCSI BUS has been reset.
sym1: <875> rev 0x14 on pci bus 0 device 3 function 1 irq 4,7e6
sym1: No NVRAM, ID 7, Fast-20, SE, parity checking
sym1: SCSI BUS has been reset.
sym2: <875> rev 0x14 on pci bus 0 device 4 function 0 irq 4,7d8
sym2: No NVRAM, ID 7, Fast-20, SE, parity checking
sym2: SCSI BUS has been reset.
sym3: <875> rev 0x14 on pci bus 0 device 4 function 1 irq 4,7d9
sym3: No NVRAM, ID 7, Fast-20, SE, parity checking
sym3: SCSI BUS has been reset.
scsi0 : sym-2.1.17a
scsi1 : sym-2.1.17a
scsi2 : sym-2.1.17a
scsi3 : sym-2.1.17a
  Vendor: SEAGATE   Model: ST318404LSUN18G   Rev: 4207
  Type:   Direct-Access                      ANSI SCSI revision: 03
  Vendor: TOSHIBA   Model: XM6201TASUN32XCD  Rev: 1103
  Type:   CD-ROM                             ANSI SCSI revision: 02
sym0:0:0: tagged command queuing enabled, command queue depth 16.
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
sym0:0: FAST-20 WIDE SCSI 40.0 MB/s ST (50.0 ns, offset 16)
SCSI device sda: 35378533 512-byte hdwr sectors (18114 MB)
Partition check:
 /dev/scsi/host0/bus0/target0/lun0: p1 p2 p3 p4 p5
Initializing Cryptographic API
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP, IGMP
IP: routing cache hash table of 8192 buckets, 64Kbytes
TCP: Hash tables configured (established 65536 bind 32768)
Linux IP multicast router 0.06 plus PIM-SM
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Mounted devfs on /dev
Warning: unable to open an initial console.
Adding Swap: 530080k swap-space (priority -1)
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,2), internal journal
IPv6 v0.8 for NET4.0
IPv6 over IPv4 tunneling driver
divert: not allocating divert_blk for non-ethernet device sit0
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.19, 19 August 2002 on sd(8,5), internal journal
EXT3-fs: mounted filesystem with ordered data mode.
divert: not allocating divert_blk for non-ethernet device xs26
eth0: Link is up using internal transceiver at 100Mb/s, Full Duplex.



Best Regards,

-- 
Jan Oravec                           XS26 coordinator
6COM s.r.o.                          'Access to IPv6'
http://www.6com.sk                   http://www.xs26.net
