From: <rongqing.li@windriver.com>
Subject: [PATCH 0/5] Export the sock's security context to proc
Date: Fri, 5 Aug 2011 16:58:01 +0800
Message-ID: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34181 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756046Ab1HEI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 04:58:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-------
    Any review would be much appreciated.
 
Comments:
--------
    Export the sock's security context to proc.
    
    The element sk_security of struct sock represents the socket
    security context ID, which is inheriting from the process when
    creates this socket on most of the time.
    
    but when SELinux type_transition rule is applied to socket, or
    application sets /proc/xxx/attr/createsock, the socket security
    context would be different from the creating process. on this
    condition, the "netstat -Z" will return wrong value, since
    "netstat -Z" only returns the process security context as socket
    process security.
    
    Export the raw sock's security context to proc, so that "netstat -Z"
    could be fixed by reading procfs.

Test:
--------
1. When Enable SELinux.


1.1 check the socket security context has been exported in procfs

root@qemu-host:/root> head -n 3 /proc/net/tcp 
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode   scontext                                          
   0: 00000000:05FE 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0        0 5029 1 ffff88001b8ecc00 100 0 0 10 -1 system_u:system_r:initrc_t:s0-s15:c0.c1023                                                                
   1: 00000000:DBE2 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0        0 4915 1 ffff88001b8ec600 100 0 0 10 -1 system_u:system_r:rpcd_t:s0-s15:c0.c1023                                                              


root@qemu-host:/root> head -n 3 /proc/net/udp 
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode ref pointer drops  scontext                          
   53: 00000000:89F1 00000000:0000 07 00000000:00000000 00:00000000 00000000 0        0 4912 2 ffff88001e3b49c0 0 system_u:system_r:rpcd_t:s0-s15:c0.c1023        
  172: 00000000:0268 00000000:0000 07 00000000:00000000 00:00000000 00000000 0        0 4851 2 ffff88001e3b4340 0 system_u:system_r:rpcbind_t:s0-s15:c0.c1023           


root@qemu-host:/root> head -n 3 /proc/net/unix 
Num       RefCount Protocol Flags    Type St Inode Path      scontext
ffff88001ea1cc00: 00000002 00000000 00000000 0002 01   976 @/org/kernel/udev/udevd               system_u:system_r:udev_t:s0-s15:c0.c1023
ffff88001bbe6600: 0000000A 00000000 00000000 0002 01  4740 /dev/log                              system_u:system_r:syslogd_s_t:s15:c0.c1023
root@qemu-host:/root> 


root@qemu-host:/root> head -n 3 /proc/net/raw  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode ref pointer drops   scontext
root@qemu-host:/root> 

1.2 check these patches do not affect the netstat, it can still work
root@qemu-host:/root> netstat -a
Active Internet connections (servers and established) Proto Recv-Q Send-Q Local Address               Foreign Address State      
tcp        0      0 *:1534                      *:* LISTEN      
tcp        0      0 *:56290                     *:* LISTEN      
tcp        0      0 localhost:submission        *:* LISTEN      
tcp        0      0 *:sunrpc                    *:* LISTEN
...

1.3 When syslog creates socket, and type transition has been applied on them, the security context of
socket would be syslogd_s_t, not same as its own process security context
syslogd_t, the "netstat -Z" returns wrong value, but the security context in procfs is correct

root@qemu-host:/etc> cat /proc/net/unix |grep syslog
ffff88001f856000: 00000002 00000000 00010000 0001 01  6385 /var/lib/syslog-ng/syslog-ng.ctl      system_u:system_r:syslogd_t:s15:c0.c1023
ffff88001f856300: 00000002 00000000 00000000 0002 01  6383 /dev/log                              system_u:system_r:syslogd_s_t:s15:c0.c1023
root@qemu-host:/etc> 

root@qemu-host:/etc> netstat -aZ|grep 6383
unix  2      [ ]         DGRAM                    6383   793/syslog-ng
system_u:system_r:syslogd_t:s15:c0.c1023          /dev/log
root@qemu-host:/etc> 



2. When SElinux is disabled

2.1 check the /proc/net/udp information are same as no these patches

root@qemu-host:/root> head -n 3 /proc/net/raw  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode ref pointer drops 

root@qemu-host:/root> head -n 3 /proc/net/unix 
Num       RefCount Protocol Flags    Type St Inode Path    
ffff88001d226000: 0000000A 00000000 00000000 0002 01  2661 /dev/log                              
ffff88001ea1cc00: 00000002 00000000 00000000 0002 01   897 @/org/kernel/udev/udevd               

root@qemu-host:/root> head -n 3 /proc/net/tcp  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode                                                     
   0: 00000000:05FE 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0        0 2950 1 ffff88001d294c00 100 0 0 10 -1                     
   1: 0100007F:024B 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0        0 3217 1 ffff88001d295e00 100 0 0 10 -1                     

root@qemu-host:/root> head -n 3 /proc/net/udp 
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode ref pointer drops                                    
   57: 00000000:03F5 00000000:0000 07 00000000:00000000 00:00000000 00000000 0        0 2772 2 ffff88001d2ac340 0                                 
  122: 00000000:D936 00000000:0000 07 00000000:00000000 00:00000000 00000000 0        0 2831 2 ffff88001d2acd00 0                                 
root@qemu-host:/root>


