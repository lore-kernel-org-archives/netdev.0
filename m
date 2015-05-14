From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 21:38:41 -0700
Message-ID: <1431578321.27831.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150513062038.GA26944@gondor.apana.org.au>
	 <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514025333.GA3853@gondor.apana.org.au>
	 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514033448.GA5080@gondor.apana.org.au>
	 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150514041628.GA5428@gondor.apana.org.au>
	 <20150514042151.GA5482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35764 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbENEin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:38:43 -0400
Received: by iebpz10 with SMTP id pz10so51194581ieb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 21:38:43 -0700 (PDT)
In-Reply-To: <20150514042151.GA5482@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-14 at 12:21 +0800, Herbert Xu wrote:
> On Thu, May 14, 2015 at 12:16:28PM +0800, Herbert Xu wrote:
> > On Wed, May 13, 2015 at 09:13:38PM -0700, Eric Dumazet wrote:
> > >
> > > So it looks like we lost an skb or something....
> > 
> > OK that sounds reasonable.  So my plan is to disable dynamic
> > rehashing and then hunt down this lookup bug.
> 
> Oh wait this isn't even a lookup failure since that should return
> ECONNREFUSED.  Could it be that this hang is a separate bug that's
> not related to rhashtable?
> 
> If that was the case then we simply need to get rid of dynamic
> rehashing.

Well, /proc/net/netlink consistently show same socket twice when I get a
hang :

At this moment I have more than one process blocked :

lpaa23:~# ps aux|grep addrinfo
root     10597  0.0  0.0   3696   376 pts/0    S    21:20   0:00 /bin/bash ./getaddrinfo_many.sh
root     10601  0.0  0.0   1172     4 pts/0    S    21:20   0:00 ./getaddrinfo 500
root     11449  0.0  0.0   3700   384 pts/0    S    21:17   0:00 /bin/bash ./getaddrinfo_many.sh
root     11454  0.0  0.0   1172     4 pts/0    S    21:17   0:00 ./getaddrinfo 500
root     21424  0.0  0.0   3696   376 pts/0    S+   21:30   0:00 /bin/bash ./getaddrinfo_many.sh
root     21425  0.0  0.0   3696   376 pts/0    S+   21:30   0:00 /bin/bash ./getaddrinfo_many.sh
root     21426  0.0  0.0   3744  2236 pts/0    S+   21:30   0:00 /bin/bash ./getaddrinfo_many.sh
root     21470  0.0  0.0   3704   384 pts/0    S+   21:30   0:00 /bin/bash ./getaddrinfo_many.sh
root     21476  0.0  0.0   1172     4 pts/0    S+   21:30   0:00 ./getaddrinfo 500
root     22241  0.0  0.0   2604  1280 pts/1    S+   21:36   0:00 grep addrinfo
root     37231  0.0  0.0   3696   376 pts/0    S    21:19   0:00 /bin/bash ./getaddrinfo_many.sh
root     37235  0.0  0.0   1172     4 pts/0    S    21:19   0:00 ./getaddrinfo 500
root     48499  0.0  0.0   3696  2804 pts/0    S+   21:28   0:00 /bin/bash ./getaddrinfo_many.sh

And only one of the socket is listed twice (ffff881f6eceb000)

Apparently this is the one _after_ kernel socket.

Does it ring a bell ?

lpaa23:~# cat /proc/net/netlink 
sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks     Drops     Inode
ffff881f6eceb000 0   11454  00000000 0        0        0 2        0        61386380
ffff881fe08aa400 0   10601  00000000 0        0        0 2        0        69235237
ffff881fd3c80c00 0   37235  00000000 0        0        0 2        0        65612209
ffff881fd5356400 0   21476  00000000 0        0        0 2        0        116743320
ffff881fe1d98400 0   0      00000000 0        0        0 2        0        3       
ffff881f6eceb000 0   11454  00000000 0        0        0 2        0        61386380     << double >>
ffff881fe1066400 8   0      00000000 0        0        0 2        0        13355   
ffff881fe1066400 8   0      00000000 0        0        0 2        0        13355   
ffff883fe1204800 9   0      00000000 0        0        0 2        0        2056    
ffff883fe1204800 9   0      00000000 0        0        0 2        0        2056    
ffff883feecf6400 10  0      00000000 0        0        0 2        0        9602    
ffff883fe1208000 11  0      00000000 0        0        0 2        0        2051    
ffff883fe1208000 11  0      00000000 0        0        0 2        0        2051    
ffff881fe0f4ac00 16  0      00000000 0        0        0 2        0        2054    
ffff881fe0f4ac00 16  0      00000000 0        0        0 2        0        2054    
