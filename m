From: Pascal Brisset <pascal.brisset-ml@wanadoo.fr>
Subject: Bonding driver unreliable under high CPU load
Date: Sat, 14 Sep 2002 18:38:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15747.26107.382619.200566@pcg.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I would like to confirm the problem reported by Tony Cureington at
http://sourceforge.net/mailarchive/forum.php?thread_id=1015008&forum_id=2094

Problem: In MII-monitoring mode, when the CPU load is high,
the ethernet bonding driver silently fails to detect dead links.

How to reproduce:
i686, 2.4.19; "modprobe bonding mode=1 miimon=100"; ifenslave two
interfaces; ping while you plug/unplug cables. Bonding will
switch to the available interface, as expected. Now load the CPU
with "while(1) { }", and failover will not work at all anymore.

Explanation:
The bonding driver monitors the state of its slave interfaces by
calling their dev->do_ioctl(SIOCGMIIREG|ETHTOOL_GLINK) from a
timer callback function. Whenever this occurs during a user task,
the get_user() in the ioctl handling code of the slave fails with
-EFAULT because the ifreq struct is allocated in the stack of the
timer function, above 0xC0000000. In that case, the bonding driver
considers the link up by default.

This problem went unnoticed because for most applications, when the
active link dies, the host becomes idle and the monitoring function
gets a chance to run during a kernel thread (in which case it works).
The active-backup switchover is just slower than it should be.
Serious trouble only happens when the active link dies during a long,
CPU-intensive job.

Is anyone working on a fix ? Maybe running the monitoring stuff in
a dedicated task ?

-- Pascal
