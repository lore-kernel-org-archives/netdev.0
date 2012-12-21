From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Fri, 21 Dec 2012 12:21:00 +0100
Message-ID: <1609010645.20121221122100@eikelenboom.it>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop> <1797374383.20121220135139@eikelenboom.it> <1356017968.21834.2859.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:36812
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab2LULVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 06:21:10 -0500
In-Reply-To: <1356017968.21834.2859.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thursday, December 20, 2012, 4:39:28 PM, you wrote:

> On Thu, 2012-12-20 at 13:51 +0100, Sander Eikelenboom wrote:

>> Eric:
>>      From the warn_on_once, delta should be smaller than len, but probably they should be as close together as possible.
>>      When you say "accurate estimation", what would be a acceptable difference between DELTA and LEN ?

> I would use the most exact value, which is :

>    skb->truesize += nr_frags * PAGE_SIZE;

> Then, if we can spot later a regression in some stacks, adapt the
> limiting parameters. I did a lot of work in GRO and TCP stack to reduce
> the memory, and further changes are possible.

> We really want to account memory, because we want to control how memory
> is used on our machines and don't let some users use more than the
> amount that was allowed to them.

Hi Eric and Ian,

I have ran some perfnet tests (although i'm not an expert, so i'm not sure i have done the right tests).
I you have better tests, please do say so ..


"current" is with netfront as is        (skb->truesize += skb->data_len - RX_COPY_THRESHOLD;)
"patched" is with IanC's latest patch   (skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;)

Tested between domU and dom0 (bridged) on a system with only one guest. The results don't seem to differ very much.

+ netperf -H 192.168.1.1 -t TCP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2
        Recv   Send    Send                          
        Socket Socket  Message  Elapsed              
        Size   Size    Size     Time     Throughput  
        bytes  bytes   bytes    secs.    KBytes/sec  

current  87380  16384  16384    60.00    954438.38   
patched  87380  16384  16384    60.00    975236.19  


+ netperf -H 192.168.1.1 -t TCP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 50
        Recv   Send    Send                          
        Socket Socket  Message  Elapsed              
        Size   Size    Size     Time     Throughput  
        bytes  bytes   bytes    secs.    KBytes/sec  
        
current  87380   2048   2048    60.00    17614.79   
patched  87380   2048   2048    60.00    17207.46 


+ netperf -H 192.168.1.1 -t TCP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 50 -M 1432 -m 1432
        Recv   Send    Send                          
        Socket Socket  Message  Elapsed              
        Size   Size    Size     Time     Throughput  
        bytes  bytes   bytes    secs.    KBytes/sec  
        
current  87380   2048   1432    60.00      35.28   
patched  87380   2048   1432    60.00      35.28 


+ netperf -H 192.168.1.1 -t TCP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 9000
        Recv   Send    Send                          
        Socket Socket  Message  Elapsed              
        Size   Size    Size     Time     Throughput  
        bytes  bytes   bytes    secs.    KBytes/sec  
        
current  87380  18000  18000    60.00    157762.45   
patched  87380  18000  18000    60.00    158606.02


+ netperf -H 192.168.1.1 -t TCP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 9000 -M 1432 -m 1432
        Recv   Send    Send                          
        Socket Socket  Message  Elapsed              
        Size   Size    Size     Time     Throughput  
        bytes  bytes   bytes    secs.    KBytes/sec  
        
current  87380  18000   1432    60.00    78567.39   
patched  87380  18000   1432    60.00    78329.98


+ netperf -H 192.168.1.1 -t UDP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2
        Socket  Message  Elapsed      Messages                
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec
        
current 212992   65507   60.00      248771      0    265238.24
current 212992           60.00      214267           228450.01
patched 212992   65507   60.00      251188      0    267814.90
patched 212992           60.00      235101           250662.67


+ netperf -H 192.168.1.1 -t UDP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 50
        Socket  Message  Elapsed      Messages                
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec
        
current   2048    2048   60.00     1329653      0    44321.73
current 212992           60.00     1329650           44321.62
patched   2048    2048   60.00     1363257      0    45441.68
patched 212992           60.00     1363253           45441.57


+ netperf -H 192.168.1.1 -t UDP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 50 -M 1432 -m 1432
        Socket  Message  Elapsed      Messages                
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec
        
current   2048    1432   60.00     1516249      0    35339.61
current 212992           60.00     1516247           35339.56
patched   2048    1432   60.00     1483705      0    34581.11
patched 212992           60.00     1483701           34581.01


+ netperf -H 192.168.1.1 -t UDP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 9000
        Socket  Message  Elapsed      Messages                
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec
        
current  18000   18000   60.00      540410     26    158322.98
current 212992           60.00      540349           158305.24
patched  18000   18000   60.00      555449     32    162728.98
patched 212992           60.00      555392           162712.28


+ netperf -H 192.168.1.1 -t UDP_STREAM -fK -i10,5 -l 60 -I95,5 -P1 -v2 -- -s 9000 -M 1432 -m 1432
        Socket  Message  Elapsed      Messages                
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec
        
current  18000    1432   60.00     5144189      0    119896.95
current 212992           60.00     5138354           119760.96
patched  18000    1432   60.00     5104540      0    118972.85
patched 212992           60.00     5099802           118862.44
