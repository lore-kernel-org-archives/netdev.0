From: <rongqing.li@windriver.com>
Subject: [v2 PATCH 0/6] Export the sock's security context to proc
Date: Tue, 9 Aug 2011 15:28:24 +0800
Message-ID: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>, <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode seclabel                                            
   0: 00000000:05FE 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 4723 1 ffff88001b7f8c00 100 0 0 10 -1 system_u:system_r:initrc_t:s0-s15:c0.c1023
   1: 0100007F:024B 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 5070 1 ffff88001b7f9e00 100 0 0 10 -1 system_u:system_r:sendmail_t:s0-s15:c0.c1023
     
root@qemu-host:/root> head -n 3 /proc/net/udp 
   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops seclabel                           
   54: 00000000:03F2 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4540 2 ffff88001ba30340 0 system_u:system_r:rpcbind_t:s0-s15:c0.c1023
  133: 00000000:B641 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4601 2 ffff88001ba30d00 0 system_u:system_r:rpcd_t:s0-s15:c0.c1023         

root@qemu-host:/root> head -n 3 /proc/net/unix
Num       RefCount Protocol Flags    Type St Inode Path  SecLabel
ffff88001ea1cc00: 00000002 00000000 00000000 0002 01   972 @/org/kernel/udev/udevd                 system_u:system_r:udev_t:s0-s15:c0.c1023
ffff88001ea1d500: 00000002 00000000 00010000 0001 01  4371 /var/evlog/evlconfsoc                   system_u:system_r:initrc_t:s0-s15:c0.c1023
root@qemu-host:/root> 

root@qemu-host:/root> tail -n 3 /proc/net/unix
ffff88001e0e2300: 00000003 00000000 00000000 0001 03  4706  -                                      system_u:system_r:rpcd_t:s0-s15:c0.c1023
ffff88001ea1d200: 00000003 00000000 00000000 0002 01   979  -                                      system_u:system_r:udev_t:s0-s15:c0.c1023
ffff88001ea1cf00: 00000003 00000000 00000000 0002 01   978  -                                      system_u:system_r:udev_t:s0-s15:c0.c1023
root@qemu-host:/root> 

root@qemu-host:/root> head -n 3 /proc/net/raw  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt uid  timeout inode ref pointer drops   seclabel
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



2. When SElinux is disabled, output - on seclabel column

root@qemu-host:/root> head -n 3 /proc/net/raw  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops  seclabel

root@qemu-host:/root> head -n 3 /proc/net/unix
Num       RefCount Protocol Flags    Type St Inode Path  SecLabel
ffff88001e118000: 0000000A 00000000 00000000 0002 01  2647 /dev/log                              -
ffff88001ea1cc00: 00000002 00000000 00000000 0002 01   897 @/org/kernel/udev/udevd               -
      

root@qemu-host:/root> head -n 3 /proc/net/tcp  
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode seclabel                                            
   0: 00000000:05FE 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 2935 1 ffff88001d598c00 100 0 0 10 -1 -                   
   1: 0100007F:024B 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 3201 1 ffff88001d599e00 100 0 0 10 -1 -                     

root@qemu-host:/root> head -n 3 /proc/net/udp 
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops seclabel                           
   42: 00000000:03E6 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 2754 2 ffff88001da38340 0 -                               
   56: 00000000:B5F4 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 2810 2 ffff88001da389c0 0 -                            
root@qemu-host:/root>


3. Disable security module configuration, no compiling error.


