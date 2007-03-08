From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: [Bugme-new] [Bug 8151] New: Established connections not
 displayed in /proc/tcp/netstat
Date: Thu, 8 Mar 2007 10:19:47 -0800
Message-ID: <20070308101947.f77ab27f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, getitupsidelines@yahoo.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56878 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282AbXCHST7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 13:19:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 8 Mar 2007 07:53:57 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 8151] New: Established connections not displayed in /proc/tcp/netstat


http://bugzilla.kernel.org/show_bug.cgi?id=8151

           Summary: Established connections not displayed in
                    /proc/tcp/netstat
    Kernel Version: 2.6.17-rt7-default #3 PREEMPT
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: getitupsidelines@yahoo.com
                CC: getitupsidelines@yahoo.com


Most recent kernel where this bug did *NOT* occur: Unknown

Distribution: SUSE 10 Pro

Hardware Environment: Intel(R) Pentium(R) 4 CPU 2.80GHz, 32 bit, 512 Megs of RAM

Software Environment: SUSE 10, 2.6.17-rt7-default with ingo molnar RT patch

Problem Description: 

 

Established tcp network connections are not shown in /proc/net/tcp (not
displayed in netstat).

 

I began to notice this when I would use netstat to display all established
connections. There were a few connections not shown as ESTABLISHED by netstat,
yet my application did not report a connection broken with the remote device. I
logged into the remote device and observed the connection was ESTABLISHED on the
remote side. In addition, I verified the transfer of data to the remote device.
I searched through the proc file system to find out more info and it seems that
my application still held the socket file descriptor as opened. 

 

 

#### LOCAL MACHINE WITH BUG

# 10.1.2.71 is IP of remote device note connection not established

local:/ # netstat -a | grep 10.1.2.71

## NOTE IP of local device

local:/ # ifconfig eth1

eth1      Link encap:Ethernet  HWaddr 00:03:2D:09:0E:6F

          inet addr:10.1.2.10  Bcast:10.1.2.255  Mask:255.255.255.0

          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

          RX packets:558434 errors:0 dropped:0 overruns:0 frame:0

          TX packets:264478 errors:0 dropped:0 overruns:0 carrier:0

          collisions:0 txqueuelen:1000

          RX bytes:37082257 (35.3 Mb)  TX bytes:19489061 (18.5 Mb)

          Interrupt:18

 

# ##telnet into remote machine

local:/ # telnet 10.1.2.71

Trying 10.1.2.71...

Connected to 10.1.2.71.

Escape character is '^]'.

 

MontaVista(R) Linux(R) Professional Edition 3.1

Linux/ppc 2.4.20_mvl31-405gp_eval

 

 

(none) login: root

Password:

Linux (none) 2.4.20_mvl31-405gp_eval #474 Tue Dec 27 16:37:25 PST 2005 ppc unknown

 

MontaVista(R) Linux(R) Professional Edition 3.1

 

 

 

BusyBox v0.60.3 (2004.01.09-22:55+0000) Built-in shell (ash)

Enter 'help' for a list of built-in commands.

######## Remote machine. Note connection established on port 1400 with local machine

# netstat -a | grep 10.1.2.10

tcp        0      0 10.1.2.71:telnet        10.1.2.10:51555         ESTABLISHED

tcp        0      0 10.1.2.71:1400          10.1.2.10:60380         ESTABLISHED

 

 

###### Back on LOCAL machine with bug

### Note established connection to IP 10.1.2.71 on port 1400 not shown. However,
other established connections shown to other devices running the same remote
server software. 

local:/proc/2774/fd # grep 0A02010A /proc/net/tcp | more

  64: 0A02010A:EBDC 4702010A:0578 01 00000000:00000000 00:00000000 00000000    
0        0 7477 1 d8ba1980 201 40 10 2 100

  70: 0A02010A:A547 4802010A:0578 01 00000000:00000000 00:00000000 00000000    
0        0 7478 1 d8ba1400 201 40 10 2 100

 

#### Display open inodes

### I grep for the inode of the established connections from above. My
application will open the sockets to the remote devices sequentially.

ml_alc10:/proc/2774/fd # ls -l | grep socket | grep 747[0-9]

lrwx------  1 root root 64 Mar  7 10:37 154 -> socket:[7471]

lrwx------  1 root root 64 Mar  7 10:37 155 -> socket:[7472]

lrwx------  1 root root 64 Mar  7 10:37 158 -> socket:[7473]

lrwx------  1 root root 64 Mar  7 10:37 159 -> socket:[7474]

lrwx------  1 root root 64 Mar  7 10:37 160 -> socket:[7475]

lrwx------  1 root root 64 Mar  7 10:37 161 -> socket:[7476]

lrwx------  1 root root 64 Mar  7 10:37 162 -> socket:[7477]

lrwx------  1 root root 64 Mar  7 10:37 163 -> socket:[7478]

lrwx------  1 root root 64 Mar  7 10:37 164 -> socket:[7479]

 

## Check if socket inode 7479 exists in /proc/net/tcp

local:/proc/2774/fd # grep 7479 /proc/net/tcp | more

local:/proc/2774/fd # ls -l | grep 7479

lrwx------  1 root root 64 Mar  7 10:37 164 -> socket:[7479]

local:/proc/2774/fd # grep 7479 /proc/net/tcp | more

local:/proc/2774/fd # 

 

#### NOTE Very Strange behavior. The connection will intermittently be shown in
/proc/net/tcp with the same local port number and inode. This leads me to
believe that the connection persists throughout and that the kernel is failing
to accurately display all established socket connections.

 

Please advise on how display all ESTABLISHED connections correctly. 

 

Thanks.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
