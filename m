From: Willy Tarreau <w@1wt.eu>
Subject: Re: Major network performance regression in 3.7
Date: Sun, 6 Jan 2013 20:53:59 +0100
Message-ID: <20130106195359.GN16031@1wt.eu>
References: <1357490393.6919.267.camel@edumazet-glaptop> <20130106164416.GF16031@1wt.eu> <1357492255.6919.336.camel@edumazet-glaptop> <20130106173543.GB22432@1wt.eu> <1357497541.6919.519.camel@edumazet-glaptop> <1357497809.6919.529.camel@edumazet-glaptop> <1357498276.6919.547.camel@edumazet-glaptop> <1357498815.6919.570.camel@edumazet-glaptop> <20130106193410.GL16031@1wt.eu> <1357501171.6919.650.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357501171.6919.650.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 06, 2013 at 11:39:31AM -0800, Eric Dumazet wrote:
> On Sun, 2013-01-06 at 20:34 +0100, Willy Tarreau wrote:
> 
> > OK it works like a charm here now ! I can't break it anymore, so it
> > looks like you finally got it !
> > 
> > I noticed that the data rate was higher when the loopback's MTU
> > is exactly a multiple of 4096 (making the 64k choice optimal)
> > while I would have assumed that in order to efficiently splice
> > TCP segments, we'd need to have some space for IP/TCP headers
> > and n*4k for the payload.
> > 
> > I also got the transfer freezes again a few times when starting
> > tcpdump on the server, but this is not 100% reproducible I'm afraid.
> > So I'll bring this back when I manage to get some analysable pattern.
> > 
> > The spliced transfer through all the chain haproxy works fine again
> > at 10gig with your fix. The issue is closed for me. Feel free to add
> > my Tested-By if you want.
> > 
> 
> Good to know !
> 
> What is the max speed you get now ?

Line rate with 1500 MTU and LRO enabled :

#   time   eth1(ikb  ipk     okb      opk)    eth2(ikb   ipk      okb    opk) 

1357060023 19933.3 41527.7 9355538.2 62167.7  9757888.1 808701.1 19400.3 40417.7
1357060024 26124.1 54425.5 9290064.9 48804.4  9778294.0 810210.0 18068.8 37643.3
1357060025 27015.2 56281.1 9296115.3 46868.8  9797125.9 811271.1 8790.1 18312.2 
1357060026 27556.0 57408.8 9291701.4 46805.5  9805371.6 811410.0 3494.8 7280.0 
1357060027 27577.0 57452.2 9293606.8 46804.4  9806122.3 811314.4 2558.7 5330.0 
1357060028 27476.1 57242.2 9296885.4 46830.0  9794537.3 810527.7 2516.1 5242.2 
                           ^^^^^^^            ^^^^^^^
                           kbps out           kbps in
eth1=facing the client
eth2=facing the server

Top reports the following usage :

Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 31.7%id,  0.0%wa,  0.0%hi, 68.3%si,  0.0%st
Cpu1  :  1.0%us, 37.3%sy,  0.0%ni, 61.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st

(IRQ bound to cpu 0, haproxy to cpu 1)

This is a core2duo 2.66 GHz and the myris are 1st generation.

BTW I was very happy to see that the LRO->GRO conversion patches in 3.8-rc2
don't affect byte rate anymore (just a minor CPU usage increase but this is
not critical here), now I won't complain about it being slower anymore, you
won :-)


With the GRO patches backported, still at 1500 MTU but with GRO now :

Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 28.7%id,  0.0%wa,  0.0%hi, 71.3%si,  0.0%st
Cpu1  :  0.0%us, 37.6%sy,  0.0%ni, 62.4%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st

#   time   eth1(ikb  ipk     okb      opk)    eth2(ikb   ipk      okb    opk) 
1357058637 18319.3 38165.5 9401736.3 65159.9  9761613.4 808963.3 19403.6 40424.4
1357058638 20009.8 41687.7 9400903.7 62706.6  9770555.8 809522.2 18696.5 38951.1
1357058639 25439.5 52999.9 9301635.3 50267.7  9773666.7 809721.1 19174.1 39946.6
1357058640 26808.2 55850.0 9298301.4 46876.6  9790470.1 810843.3 12408.7 25851.1
1357058641 27110.9 56481.1 9297009.2 46832.2  9803308.4 811339.9 5692.5 11859.9
1357058642 27411.1 57106.6 9291419.2 46796.6  9806846.5 811378.8 2804.4 5842.2

This kernel is getting really good :-)

Cheers,
Willy
