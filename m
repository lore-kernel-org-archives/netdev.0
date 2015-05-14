From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 21:13:38 -0700
Message-ID: <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513054037.GA26595@gondor.apana.org.au>
	 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514025333.GA3853@gondor.apana.org.au>
	 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514033448.GA5080@gondor.apana.org.au>
	 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33009 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbbENENk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:13:40 -0400
Received: by iebgx4 with SMTP id gx4so50523320ieb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 21:13:40 -0700 (PDT)
In-Reply-To: <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 20:58 -0700, Eric Dumazet wrote:
> On Thu, 2015-05-14 at 11:34 +0800, Herbert Xu wrote:
> > On Wed, May 13, 2015 at 08:17:43PM -0700, Eric Dumazet wrote:
> > >
> > > The initial bug report was on 3.18 for sure.
> > > 
> > > (Tester had to leave the program run ~8 hours to get the problem, on a 8
> > > vCPU VM)
> > > 
> > > I can reproduce the bug quite easily (in a few seconds) on 4.0.3, I did
> > > not spent lot of time trying 3.18, but it seems a bit harder.
> > 
> > No what I'm asking is on 3.18 was it permanent? I can imagine
> > there being a lookup bug in 3.18 that triggers during a rehash
> > but I cannot find any permanent corruption issues.
> 
> Let me try to reproduce this on 3.18.13. I'll give you an update.

OK I reproduced a hang after few minutes :

Out of my 200 processes, one of them is stuck in the recvmsg() system
call :

lpaa23:~# ps aux|grep addrinfo
root     33416  0.0  0.0   3692   376 pts/0    S+   21:09   0:00 /bin/bash ./getaddrinfo_many.sh
root     33417  0.0  0.0   3692   376 pts/0    S+   21:09   0:00 /bin/bash ./getaddrinfo_many.sh
root     33418  0.0  0.0   3744  2108 pts/0    S+   21:09   0:00 /bin/bash ./getaddrinfo_many.sh
root     33428  0.0  0.0   3696  1752 pts/0    S+   21:09   0:00 /bin/bash ./getaddrinfo_many.sh
root     33431  0.0  0.0   1172     4 pts/0    S+   21:09   0:00 ./getaddrinfo 500
root     34102  0.0  0.0   2600  1312 pts/1    S+   21:11   0:00 grep addrinfo
root     40236  0.0  0.0   3692  2920 pts/0    S+   21:09   0:00 /bin/bash ./getaddrinfo_many.sh
lpaa23:~# strace -p 33431
Process 33431 attached
recvmsg(3, ^CProcess 33431 detached
 <detached ...>

lpaa23:~# lsof -p 33431
COMMAND     PID USER   FD      TYPE DEVICE SIZE/OFF     NODE NAME
getaddrin 33431 root  cwd       DIR    8,1    12288    16394 /root
getaddrin 33431 root  rtd       DIR    8,1     4096        2 /
getaddrin 33431 root  txt       REG    8,1   978477       87 /root/getaddrinfo
getaddrin 33431 root    0r      CHR    1,3      0t0     2521 /dev/null
getaddrin 33431 root    1w      REG    8,1        0     6919 /root/5.out
getaddrin 33431 root    2w      REG    8,1        0     6919 /root/5.out
getaddrin 33431 root    3u  netlink             0t0 57052903 ROUTE

lpaa23:~# cat /proc/net/netlink 
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops     Inode
ffff881f6d8b8000 0   33431  00000000 0        0        0 2        0        57052903
ffff881fe1d98400 0   0      00000000 0        0        0 2        0        3       
ffff881f6d8b8000 0   33431  00000000 0        0        0 2        0        57052903
ffff881fe1066400 8   0      00000000 0        0        0 2        0        13355   
ffff881fe1066400 8   0      00000000 0        0        0 2        0        13355   
ffff883fe1204800 9   0      00000000 0        0        0 2        0        2056    
ffff883fe1204800 9   0      00000000 0        0        0 2        0        2056    
ffff883feecf6400 10  0      00000000 0        0        0 2        0        9602    
ffff883fe1208000 11  0      00000000 0        0        0 2        0        2051    
ffff883fe1208000 11  0      00000000 0        0        0 2        0        2051    
ffff881fe0f4ac00 16  0      00000000 0        0        0 2        0        2054    
ffff881fe0f4ac00 16  0      00000000 0        0        0 2        0        2054    

So it looks like we lost an skb or something....
