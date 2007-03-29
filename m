From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 16:08:47 -0600
Message-ID: <460C38EF.1080509@nortel.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070801010902090709060205"
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, ctindel@users.sourceforge.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:59634 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422672AbXC2WJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 18:09:06 -0400
In-Reply-To: <20070329181617.GA25770@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070801010902090709060205
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andy Gospodarek wrote:

> Can you elaborate on what isn't going well with this driver/hardware?  

I have a ppc64 blade running a customized 2.6.10.  At init time, two of 
our gigE links (eth4 and eth5) are bonded together to form bond0.  This 
link has an MTU of 9000, and uses arp monitoring.  We're using an 
ethernet driver with a modified RX path for jumbo frames[1].  With the 
stock driver, it seems to work fine.

The problem is that eth5 seems to be bouncing up and down every 15 sec 
or so (see the attached log excerpt).  Also, "ifconfig" shows that only 
3 packets totalling 250 bytes have gone out eth5, when I know that the 
arp monitoring code from the bond layer is sending 10 arps/sec out the link.


eth5      Link encap:Ethernet  HWaddr 00:03:CC:51:01:3E
           inet6 addr: fe80::203:ccff:fe51:13e/64 Scope:Link
           UP BROADCAST RUNNING SLAVE MULTICAST  MTU:9000  Metric:1
           RX packets:119325 errors:90283 dropped:90283 overruns:90283 
frame:0
           TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:8978310 (8.5 MiB)  TX bytes:250 (250.0 b)
           Base address:0x3840 Memory:92220000-92240000


I had initially suspected that it might be due to the "u32 jiffies" 
stuff in bonding.h, but changing that doesn't seem to fix the issue.

If I boot the system and then log in and manually create the bond link 
(rather than it happening at init time) then I don't see the problem.

If it matters at all, normally the system boots from eth4.  I'm going to 
try booting from eth6 and see if the problem still occurs.


Chris




[1] I'm not sure if I'm supposed to mention the specific driver, as it 
hasn't been officially released yet, so I'll keep this high-level. 
Normally for jumbo frames you need to allocate a large physically 
contiguous buffer.  With the modified driver, rather than receiving into 
a contiguous buffer the incoming packet is split across multiple pages 
which are then reassembled into an sk_buff and passed up the link.

--------------070801010902090709060205
Content-Type: text/plain;
 name="bond_log.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bond_log.txt"

Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: ARP monitoring set to 100 ms with 2 target(s): 172.24.136.0 172.24.137.0
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: ARP monitoring set to 100 ms with 2 target(s): 172.25.136.0 172.25.137.0
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: Warning: failed to get speed/duplex from eth4, speed forced to 100Mbps, duplex forced to Full.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: enslaving eth4 as an active interface with an up link.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: Warning: failed to get speed/duplex from eth5, speed forced to 100Mbps, duplex forced to Full.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: enslaving eth5 as an active interface with an up link.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth4 to be reset in 30000 msec.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth4 is now down.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: now running without any active interface !
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: link status definitely up for interface eth5
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth4
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth4 is now up
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:54:08 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.
Mar 29 20:54:09 base0-0-0-5-0-11-1 kernel: bonding: interface eth4 reset delay set to 600 msec.
Mar 29 20:54:59 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
Mar 29 20:54:59 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now up
Mar 29 20:54:59 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:54:59 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.
Mar 29 20:55:15 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
Mar 29 20:55:15 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now up
Mar 29 20:55:15 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:55:15 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.
Mar 29 20:55:30 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
Mar 29 20:55:30 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now up
Mar 29 20:55:30 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:55:30 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.
Mar 29 20:55:45 base0-0-0-5-0-11-1 kernel: bonding: bond0: cancelled scheduled reset of interface eth5
Mar 29 20:55:45 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now up
Mar 29 20:55:46 base0-0-0-5-0-11-1 kernel: bonding: bond0: scheduling interface eth5 to be reset in 30000 msec.
Mar 29 20:55:46 base0-0-0-5-0-11-1 kernel: bonding: bond0: interface eth5 is now down.

--------------070801010902090709060205--
