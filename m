From: Peter Bieringer <pb@bieringer.de>
Subject: Major deadlock: unregister_netdevice: waiting for <device> to
 become free. Usage count = 1
Date: Sun, 26 Dec 2004 10:14:10 +0100
Message-ID: <8A6334DE39BB61513FFBD614@t1mobil.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist USAGI-users <usagi-users@linux-ipv6.org>,
        Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

this happens to me now on 3 hosts :-((( which leaves the boxes in 
no-longer-able-to-remote-reboot state (except I trigger Alt-SysRq via 
serial console - which is not possible on all boxes).

All of them running newer kernels:

2 hosts: 2.6.9-1.681_FC3 (Fedora Core 3)
1 host : 2.6.9-1.6_FC2 (Fedora Core 2)


The reason in any of this 3 hosts was that on IPv6 the initscripts (or ppp 
down) cleanup IPv6 tunnels using e.g.

	/sbin/ip tunnel del sit_sixxs

(same happen on a created 6to4 device)

Kernel tells me each some seconds:

Dec 26 09:59:10 * kernel: unregister_netdevice: waiting for sit_sixxs to 
become free. Usage count = 1
Dec 26 09:59:50 * last message repeated 4 times
Dec 26 10:01:00 * last message repeated 7 times
Dec 26 10:02:10 * last message repeated 7 times
Dec 26 10:03:20 * last message repeated 7 times

There is no limit in kernel, means this problem locks the kernel infinite 
(even on normal reboot, which never succeeded in this case because shutdown 
is not successful).

This deadlock blocks all other netdevice related commands, so I can't 
execute any "ifconfig" or "ip" command successful.

It looks like that also some network related processes are blocked. I also 
can't kill any of that processes, most of them are in D state:

Here a part of a current process table on one deadlock box, with ISDN 
remote login access (otherwise, the box were already lost completly):

# ps -ax
Warning: bad syntax, perhaps a bogus '-'? See 
/usr/share/doc/procps-3.2.3/FAQ
  PID TTY      STAT   TIME COMMAND
    1 ?        S      0:03 init [3]
    2 ?        SN     0:49 [ksoftirqd/0]
    3 ?        S<     0:07 [events/0]
    4 ?        S<     0:00 [khelper]
    5 ?        S<     0:00 [kacpid]
    6 ?        S<     0:07 [kblockd/0]
    7 ?        S      0:00 [khubd]
   36 ?        S<     0:00 [aio/0]
   35 ?        S      1:03 [kswapd0]
  109 ?        S      0:00 [kseriod]
  195 ?        S      0:00 [scsi_eh_0]
  203 ?        S      2:43 [kjournald]
  739 ?        S<s    0:00 udevd
 1538 ?        S      1:46 [kjournald]
 1541 ?        S      0:02 [kjournald]
 1843 ?        S      4:17 /sbin/isdnlog /dev/isdnctrl0 -D -f 
/etc/isdn/isdnlog.
 2573 ?        Ss     0:09 syslogd -m 0 -r
 2622 ?        Ds     0:03 /usr/sbin/pppd pty /usr/sbin/pppoe -p 
/var/run/ifcfg-
 2627 ?        Ss     0:00 klogd -x
 2673 ?        Ss     0:01 rpc.statd
 2902 ?        Ssl    0:00 /usr/sbin/named -u named
 3985 ?        Ds     0:03 rpc.mountd
 4107 ?        Ss     0:01 /usr/libexec/postfix/master
 4117 ?        S      0:05 qmgr -l -t fifo -u
 4118 ?        Ss     0:05 /usr/sbin/privoxy --user privoxy privoxy 
--pidfile /v
 4208 ?        Ss     0:34 xfs -droppriv -daemon
 4225 ?        Ds     0:18 nmbd -D
 6117 tty2     Ss+    0:00 /sbin/mingetty tty2
 6118 tty3     Ss+    0:00 /sbin/mingetty tty3
 6119 tty4     Ss+    0:00 /sbin/mingetty tty4
 6120 tty5     Ss+    0:00 /sbin/mingetty tty5
 6121 tty6     Ss+    0:00 /sbin/mingetty tty6
 6123 ?        Ss     0:00 /sbin/mgetty ttyI20
 6124 ?        Ss     0:00 /sbin/mgetty ttyI21
 6125 ?        Ss     0:00 /sbin/mgetty ttyI22
11739 ?        Ss     0:00 /usr/bin/ssh-agent -s
11808 ?        S      0:50 /usr/libexec/gam_server
20818 ?        S      0:02 [kjournald]
 6648 ?        S      0:07 [pdflush]
 9253 ?        S      0:04 [pdflush]
 5393 ?        Zs     0:00 [ip-down] <defunct>
 5506 ?        R     43:49 /sbin/ip tunnel del sit_sixxs
 5534 ?        Z      0:00 [pppoe] <defunct>
29765 ?        Zl     0:00 [dig] <defunct>
12243 ?        D      0:00 /usr/sbin/sendmail -FCronDaemon -i -odi -oem -oi 
-t
12301 ?        Zl     0:00 [dig] <defunct>
12374 ?        Zl     0:00 [dig] <defunct>
12447 ?        Zl     0:00 [dig] <defunct>
12523 ?        Zl     0:00 [dig] <defunct>
12597 ?        Zl     0:00 [dig] <defunct>
12671 ?        Zl     0:00 [dig] <defunct>
12684 ?        D      0:00 pickup -l -t fifo -u
12747 ?        Zl     0:00 [dig] <defunct>
12821 ?        Zl     0:00 [dig] <defunct>
12894 ?        Zl     0:00 [dig] <defunct>
12969 ?        Zl     0:00 [dig] <defunct>
13043 ?        Zl     0:00 [dig] <defunct>
13116 ?        Zl     0:00 [dig] <defunct>
13189 ?        Zl     0:00 [dig] <defunct>
13263 ?        Zl     0:00 [dig] <defunct>
13336 ?        Zl     0:00 [dig] <defunct>
13411 ?        Zl     0:00 [dig] <defunct>
13485 ?        Zl     0:00 [dig] <defunct>
13559 ?        Zl     0:00 [dig] <defunct>
13632 ?        Zl     0:00 [dig] <defunct>
13706 ?        Zl     0:00 [dig] <defunct>
13779 ?        Zl     0:00 [dig] <defunct>
13854 ?        Zl     0:00 [dig] <defunct>
13927 ?        Zl     0:00 [dig] <defunct>
14001 ?        Zl     0:00 [dig] <defunct>
14074 ?        Zl     0:00 [dig] <defunct>
14147 ?        Zl     0:00 [dig] <defunct>
14221 ?        Zl     0:00 [dig] <defunct>
14296 ?        Zl     0:00 [dig] <defunct>
14370 ?        Zl     0:00 [dig] <defunct>
14429 ?        S      0:00 su -
14430 ?        S      0:00 -bash
14483 ?        D      0:00 ifconfig
14624 ?        D      0:00 /sbin/ifconfig ppp0
14675 ?        Zl     0:00 [dig] <defunct>
14752 ?        D      0:00 ip route list match 0/0
14783 ?        Ss     0:00 /sbin/mgetty ttyI2
14881 ?        D      0:00 /usr/sbin/postfix stop
15788 ttyI1    Ss     0:00 -bash
15814 ttyI1    S      0:00 su -
15815 ttyI1    S      0:00 -bash
15911 ttyI1    R+     0:00 ps -ax


the dig zomies were caused by a kill -9 to regular (but hanging cron jobs).

One of my major problems is now that I don't know how to issue a 
hard-boot-command via an ISDN tty.

	Peter, very unhappy
-- 
Dr. Peter Bieringer                        http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                  mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member     http://www.deepspace6.net/
