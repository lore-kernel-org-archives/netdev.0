From: vdb128@picaros.org
Subject: [prop 2.4.23] tracepath to other iface + traversing SNAT
Date: Mon, 17 May 2004 19:04:48 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405171704.i4HH4m13027519@picaros.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear ipv4 maintainers,

The patch below allows to tracepath from an internal interface, via a 
remote source NAT, to a public interface.  A disadvantage is however 
that it opens a possibility for IP spoofing.  Nevertheless, it might
be useful in some circumstances.  Perhaps add an additional setting
in /proc/sys/net/ipv4/ to enable ?

Yours sincerely,
Servaas Vandenberghe

-------------------------------------------------------------------------
Setup: eth1=195.162.202.41 eth2=10.67.56.137.  Without the proposed patch 
reply packets 195.->NAT->10. are dropped (martian source):

stargate:~$ ip route get 10.67.56.137 from 195.162.202.41 iif eth2
RTNETLINK answers: Invalid argument

With the patch:

stargate:~$ ip route get 10.67.56.137 from 195.162.202.41 iif eth2
local 10.67.56.137 from 195.162.202.41 dev lo  src 10.67.56.137 
    cache <local>  iif eth2

stargate:~# tracepath -I eth2 195.162.202.41
 1?: [LOCALHOST]     pmtu 1500
 1:  10.66.254.198 (10.66.254.198)                          6.167ms (0) 
 2:  scotty2-int.kuleuven.net (134.58.253.188)             65.267ms 
 3:  134.58.253.254 (134.58.253.254)                        7.394ms (0) 
 4:  be-bru02a-ra1-vl-402.aorta.net (195.162.203.233)      31.534ms (0) 
 5:  be-bru02a-ra2-vl-3.aorta.net (195.162.196.188)        23.540ms asym  4 (0) 
 6:  ns1.picaros.org (195.162.202.41)                      27.901ms asym  5 reached
     Resume: pmtu 1500 hops 6 back 5 

http://picaros.org/ftp/key/tracepath.diff (diff to ss020927)

--- linux-2.4.23/net/ipv4/fib_frontend-dist.c   Mon Aug 25 13:44:44 2003
+++ linux-2.4.23/net/ipv4/fib_frontend.c        Mon Mar 22 22:56:10 2004
@@ -233,7 +233,8 @@ int fib_validate_source(u32 src, u32 dst
 
        if (fib_lookup(&key, &res))
                goto last_resort;
-       if (res.type != RTN_UNICAST)
+       if (res.type != RTN_UNICAST 
+           && !(res.type == RTN_LOCAL && oif == loopback_dev.ifindex))
                goto e_inval_res;
        *spec_dst = FIB_RES_PREFSRC(res);
        fib_combine_itag(itag, &res);
