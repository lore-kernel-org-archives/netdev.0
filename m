From: Jan Oravec <jan.oravec@6com.sk>
Subject: problem setting net.ipvX.conf.all.forwarding via sysctl() system call
Date: Sun, 3 Aug 2003 17:44:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803154427.GA12926@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


When net.ipvX.conf.all.forwarding is enabled via sysctl() system call,
forwarding is not enabled on all interfaces as it is when it is changed
using /proc filesystem.

For IPv6, it is obviously because sysctl 'strategy' handler is not defined.
For IPv4, it is because ipv4_sysctl_forward_strategy only copy new value to
check whether it has changed and does not update ipv4_devconf.forwarding
before calling inet_forward_change(). (it is copied internally by sysctl
after ipv4_sysctl_forward_strategy because we return positive number)

I am not good in kernel parallel computing strategy, whether it requires
some locking or it is safe to do:

--- sysctl_net_ipv4.c.old       2003-08-03 17:37:44.000000000 +0200
+++ sysctl_net_ipv4.c   2003-08-03 17:38:18.000000000 +0200
@@ -109,8 +109,9 @@ static int ipv4_sysctl_forward_strategy(
                 }
         }
  
+        ipv4_devconf.forwarding=new;
         inet_forward_change();
-        return 1;
+        return 0;
 }
  
 ctl_table ipv4_table[] = {



Best Regards,

-- 
Jan Oravec                           XS26 coordinator
6COM s.r.o.                          'Access to IPv6'
http://www.6com.sk                   http://www.xs26.net
