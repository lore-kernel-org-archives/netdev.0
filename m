From: Eran Mann <emann@mrv.com>
Subject: [patch 2.4] kernel oops on VLAN removal
Date: Tue, 19 Aug 2003 18:36:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F424405.6020002@mrv.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050402020401080606060404"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050402020401080606060404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch against 2.4.21 (applies cleanly to 2.4.22-rc2) fixes
an oops in the VLAN code.
The current code attempts to add a proc entry for each vlan device,
however there is no check whether this attempt succeeded. When a device
is unregistered it tries to remove the proc entry, if none was added
the oops follows...

ksymoops 2.4.4 on i686 2.4.21.  Options used
        -V (default)
        -k /proc/ksyms (default)
        -l /proc/modules (default)
        -o /lib/modules/2.4.21/ (default)
        -m /boot/System.map-2.4.21 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

cpu: 0, clocks: 1329900, slice: 664950
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
Unable to handle kernel NULL pointer dereference at virtual address 00000004
d4e62cfc
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<d4e62cfc>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00210202
eax: 00000000   ebx: c1bfb400   ecx: cc9e5000   edx: 00000002
esi: c20c0004   edi: 00000ffa   ebp: 00003fe8   esp: c19f1eb4
ds: 0018   es: 0018   ss: 0018
Process vconfig (pid: 5398, stackpage=c19f1000)
Stack: c8c92e74 cc9e5000 d4e622a6 c1bfb400 00000000 c20c0000 00000010
00200286
          00000003 00000000 c1bfb400 ffffffea c19f1f60 ffffffe7 d4e623ba
cc9e5000
          00000ffa c12c7354 000001f0 3e60e0c4 c0288d44 c19f1f28 c02745c4
c12ca200
Call Trace:    [<d4e622a6>] [<d4e623ba>] [<c02745c4>] [<d4e62aea>]
[<c0259520>]
     [<c02202ee>] [<c013fec7>] [<c0108913>]
Code: 8b 48 04 51 e8 eb b6 2e eb 8b 43 68 c7 40 74 00 00 00 00 31

   >>EIP; d4e62cfc <[8021q]vlan_proc_rem_dev+5c/80>   <=====
Trace; d4e622a6 <[8021q]unregister_vlan_dev+86/160>
Trace; d4e623ba <[8021q]unregister_vlan_device+3a/a0>
Trace; c02745c4 <sprintf+14/20>
Trace; d4e62aea <[8021q]vlan_ioctl_handler+13a/170>
Trace; c0259520 <inet_ioctl+190/200>
Trace; c02202ee <sock_ioctl+1e/30>
Trace; c013fec7 <sys_ioctl+177/190>
Trace; c0108913 <system_call+33/38>
Code;  d4e62cfc <[8021q]vlan_proc_rem_dev+5c/80>
00000000 <_EIP>:
Code;  d4e62cfc <[8021q]vlan_proc_rem_dev+5c/80>   <=====
      0:   8b 48 04                  mov    0x4(%eax),%ecx   <=====
Code;  d4e62cff <[8021q]vlan_proc_rem_dev+5f/80>
      3:   51                        push   %ecx
Code;  d4e62d00 <[8021q]vlan_proc_rem_dev+60/80>
      4:   e8 eb b6 2e eb            call   eb2eb6f4 <_EIP+0xeb2eb6f4>
c014e3f0 <remove_proc_entry+0/110>
Code;  d4e62d05 <[8021q]vlan_proc_rem_dev+65/80>
      9:   8b 43 68                  mov    0x68(%ebx),%eax
Code;  d4e62d08 <[8021q]vlan_proc_rem_dev+68/80>
      c:   c7 40 74 00 00 00 00      movl   $0x0,0x74(%eax)
Code;  d4e62d0f <[8021q]vlan_proc_rem_dev+6f/80>
     13:   31 00                     xor    %eax,(%eax)


1 warning issued.  Results may not be reliable.

-- 
Eran Mann
MRV International
Tel: 972-4-9936297
Fax: 972-4-9890430
www.mrv.com



--------------050402020401080606060404
Content-Type: text/plain;
 name="linux-2.4.21-vlan-proc.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-vlan-proc.diff"

diff -ruN linux-2.4.21/net/8021q/vlan.c linux-2.4.21.fixed/net/8021q/vlan.c
--- linux-2.4.21/net/8021q/vlan.c	Fri Jun 13 17:51:39 2003
+++ linux-2.4.21.fixed/net/8021q/vlan.c	Tue Aug 19 17:38:22 2003
@@ -533,7 +533,9 @@
 	    
 	grp->vlan_devices[VLAN_ID] = new_dev;
 
-	vlan_proc_add_dev(new_dev); /* create it's proc entry */
+	if (vlan_proc_add_dev(new_dev)<0)/* create it's proc entry */
+            	printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
+					                 new_dev->name);
 
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
diff -ruN linux-2.4.21/net/8021q/vlanproc.c linux-2.4.21.fixed/net/8021q/vlanproc.c
--- linux-2.4.21/net/8021q/vlanproc.c	Fri Jun 13 17:51:39 2003
+++ linux-2.4.21.fixed/net/8021q/vlanproc.c	Tue Aug 19 17:38:22 2003
@@ -204,8 +204,10 @@
 #endif
 
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
-	remove_proc_entry(VLAN_DEV_INFO(vlandev)->dent->name, proc_vlan_dir);
-	VLAN_DEV_INFO(vlandev)->dent = NULL;
+	if (VLAN_DEV_INFO(vlandev)->dent) {
+		remove_proc_entry(VLAN_DEV_INFO(vlandev)->dent->name, proc_vlan_dir);
+		VLAN_DEV_INFO(vlandev)->dent = NULL;
+	}
 
 	return 0;
 }

--------------050402020401080606060404--
