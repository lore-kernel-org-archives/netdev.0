From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: netlink & rhashtable status
Date: Tue, 12 May 2015 22:30:36 -0700
Message-ID: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36877 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbEMFak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:30:40 -0400
Received: by igbsb11 with SMTP id sb11so35404316igb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 22:30:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


linux-3.17, 3.18, 3.19 and 4.0.2 have issues with netlink/rhashtable,
making things like getaddrinfo() not working after a while :

socket(PF_NETLINK, SOCK_RAW, NETLINK_ROUTE) = 3
bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
getsockname(3, {sa_family=AF_NETLINK, pid=24658, groups=00000000}, [12]) = 0
sendto(3, "\24\0\0\0\26\0\1\3)\320RU\0\0\0\0\0\0\0\0", 20, 0, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = -1 ECONNREFUSED (Connection refused)


lpaa23:~# tc qd
Cannot send dump request: Connection refused
lpaa23:~# ip ro ls
Cannot send dump request: Connection refused


Before the problem we have following visible sockets.
 
lpaa23:~# cat /proc/net/netlink 
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops     Inode
ffff883ff23e7400 0   0      00000000 0        0        0 2        0        3       
ffff883fff0f5800 4   0      00000000 0        0        0 2        0        13314   
ffff881ff0f41800 8   0      00000000 0        0        0 2        0        11308   
ffff883ff0902400 9   0      00000000 0        0        0 2        0        10241   
ffff883ff167c800 10  0      00000000 0        0        0 2        0        9719    
ffff881ff13cfc00 11  0      00000000 0        0        0 2        0        2051    
ffff881fde863800 15  7460   00000001 0        0        0 2        0        509     
ffff883fff055000 15  4294963199 00000001 0        0        0 2        0        30754   
ffff881ff2204c00 15  0      00000000 0        0        0 2        0        5       
ffff881ff13cf400 16  0      00000000 0        0        0 2        0        2054    
ffff881ff0a0f000 20  0      00000000 0        0        0 2        0        2084    


When problem happens we have : (note the first socket disappeared)

lpaa23:~# cat /proc/net/netlink 
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops     Inode
ffff883fff0f5800 4   0      00000000 0        0        0 2        0        13314   
ffff881ff0f41800 8   0      00000000 0        0        0 2        0        11308   
ffff883ff0902400 9   0      00000000 0        0        0 2        0        10241   
ffff883ff167c800 10  0      00000000 0        0        0 2        0        9719    
ffff881ff13cfc00 11  0      00000000 0        0        0 2        0        2051    
ffff881fde863800 15  7460   00000001 0        0        0 2        0        509     
ffff883fff055000 15  4294963199 00000001 0        0        0 2        0        30754   
ffff881ff2204c00 15  0      00000000 0        0        0 2        0        5       
ffff881ff13cf400 16  0      00000000 0        0        0 2        0        2054    
ffff881ff0a0f000 20  0      00000000 0        0        0 2        0        2084    


We probably need to find out what fixes are needed for stable kernels,
if not already done, sorry if I missed something.

Thanks
