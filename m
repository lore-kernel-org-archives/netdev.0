From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: [BUG][debian-2.6.20-1-686] bridging + vlans + "vconfig rem" == stuck kernel
Date: Wed, 9 May 2007 22:54:41 -0400
Message-ID: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML Kernel <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	OSDL Linux Bridging <bridge@osdl.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756577AbXEJCzD@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've managed to fairly reliably trigger a deadlock in some portion of  
the linux networking code on my Debian test box (using the debian  
kernel linux-image-2.6.20-1-686).  I'm pretty sure that it's a race  
condition of some sort as it doesn't trigger if I ifdown the  
interfaces one by one, but if I run "ifdown -a" then it triggers  
halfway through reliably (although not with the same reference count  
numbers, once it was 6, this time it was 2).

The message I get is: "unregister_netdevice: waiting for world0 to  
become free. Usage count = 2"

My /etc/network/interfaces file uses a couple custom-made if-pre-up.d  
and if-post-down.d scripts to set up the bridges and VLANs a little  
more cleanly than the standard debian scripts do, but the general  
configuration is as follows:

net0: Tigon-3 onboard gigabit NIC, hooked to managed switch, untagged  
packets
   wfi0: (net0.2 before renaming) WAP-connected VLAN 2 on the managed  
switch
   world0: (net0.4094 before renaming) Internet connection, runs DHCP

lan: Local Area Network bridge of "net0" and "wfi0" (current box has  
lowest STP priority)  This will eventually also have another untagged- 
only ethernet port attached to it.
   lan:0: Alias for acting as primary nameserver

world: pseudo-bridge of "world0" for highly-available DHCP client.

Just for a bit of background on why this is so complex:  When I get  
this networking problem sorted out I'm going to set up heartbeat and  
a dummy "world1" interface with a shared MAC which is added to the  
"world" bridge when the current system is the DHCP-client master.   
Hopefully that way I can have 3 systems act as a highly-available  
router.  Whichever one is currently the master will add the dummy  
world1 interface with shared MAC address to its "world" bridge and  
bring dhcp3-client up on the "world1" interface with the latest copy  
of the leases file from the previous master (even if the previous  
master mysteriously crashed.  This should keep my public IP from  
changing unnecessarily and should allow me to reboot any one of the 3  
router/firewall/mailserver/fileserver/etc systems without adversely  
affecting the internet connection or other critical services.

Eventually I plan to add ebtables to help filter traffic between wfi*  
interfaces and untagged VLAN-1 net* interfaces, but for now there's  
no filtering.

Anyways, after the unregister_netdevice messages start popping up all  
sorts of networking related things start to hang hard in the kernel;  
I can't "ip link set down" any interfaces, etc.  I've captured sysrq  
dumps of the process state on the system at the time with most  
processes.  See the attached syslog.bz2 file.

The important part is probably the stuck "vconfig" process, but I  
don't really understand enough about the timer stuff to interpret  
that backtrace.

vconfig       D 83CCD8CE     0 16564  16562                     (NOTLB)
        efdd7e7c 00000086 ee120afb 83ccd8ce 98f00788 b7083ffa  
5384b49a c76c0b05
        9ebaf791 00000004 efdd7e4e 00000007 f1468a90 2ab74174  
00000362 00000326
        f1468b9c c180e420 00000001 00000286 c012933c efdd7e8c  
df98a000 c180e468
Call Trace:
[<c012933c>] lock_timer_base+0x15/0x2f
[<c0129445>] __mod_timer+0x91/0x9b
[<c02988f5>] schedule_timeout+0x70/0x8d
[<f8b75209>] vlan_device_event+0x13/0xf8 [8021q]
[<c0128bfe>] process_timeout+0x0/0x5
[<c01295db>] msleep+0x1a/0x1f
[<c023e5a9>] netdev_run_todo+0x10f/0x203
[<f8b757d4>] vlan_ioctl_handler+0x4dc/0x594 [8021q]
[<c023398d>] sock_ioctl+0x145/0x1be
[<c0233848>] sock_ioctl+0x0/0x1be
[<c016c39f>] do_ioctl+0x1f/0x62
[<c016c626>] vfs_ioctl+0x244/0x256
[<c016c684>] sys_ioctl+0x4c/0x64
[<c0102d70>] syscall_call+0x7/0xb


There's also a whole bunch of processes stuck in netdev_run_todo()  
trying to lock a mutex.  This even frustratingly affects things like  
rndc which use netlink sockets:

rpc.mountd    D C9F2BD14     0  4351      1          4425  4229 (NOTLB)
        c9f2bd28 00000086 00000002 c9f2bd14 c9f2bd10 00000000  
000010ff 46422e36
        00000000 00000002 00000202 00000007 ed266030 495bcd12  
000003a5 00013461
        ed26613c c180e420 00000001 00000000 dffc8200 dfaeb580  
000010ff df99ce00
Call Trace:
[<c0298c09>] __mutex_lock_slowpath+0x48/0x77
[<c0298ac0>] mutex_lock+0xa/0xb
[<c023e4aa>] netdev_run_todo+0x10/0x203
[<c0251460>] netlink_run_queue+0x9f/0xbe
[<c0243ac9>] rtnetlink_rcv_msg+0x0/0x1d9
[<c0243a97>] rtnetlink_rcv+0x34/0x3d
[<c0251880>] netlink_data_ready+0x12/0x4c
[<c0250841>] netlink_sendskb+0x19/0x30
[<c0251862>] netlink_sendmsg+0x26a/0x276
[<c02341b9>] sock_sendmsg+0xd0/0xeb
[<c0131e95>] autoremove_wake_function+0x0/0x35
[<c020a2be>] extract_entropy+0x45/0x89
[<c011a485>] __wake_up+0x32/0x43
[<c0250aa6>] netlink_insert+0x10f/0x119
[<c02344e3>] sys_sendto+0x116/0x140
[<c014841a>] find_get_page+0x18/0x41
[<c014a736>] filemap_nopage+0x197/0x2f9
[<c0234ea9>] sys_getsockname+0x86/0xb0
[<c015341a>] __handle_mm_fault+0x2ee/0x7d4
[<c0235207>] sys_socketcall+0x15e/0x242
[<c0102d70>] syscall_call+0x7/0xb

The "zz-km-vlan" script is the bash if-post-down.d script in charge  
of disassembling VLAN interfaces.  There is an equivalent "zz-km- 
bridge" script for bridge interfaces, as well as if-pre-up.d scripts  
called "00-km-vlan" and "00-km-bridge" to create the interfaces.

If anyone has any suggestions, patches, or debugging tips I'm very  
interested to hear from you.  Thanks!

Cheers,
Kyle Moffett
