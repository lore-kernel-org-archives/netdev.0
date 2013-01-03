From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Thu, 3 Jan 2013 21:40:30 +0100
Message-ID: <561084196.20130103214030@eikelenboom.it>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com> <1355843525.9380.18.camel@edumazet-glaptop> <1355844398.14620.254.camel@zakaz.uk.xensource.com> <55633610.20121219123427@eikelenboom.it> <1355933869.21834.13.camel@edumazet-glaptop> <1797374383.20121220135139@eikelenboom.it> <1356017968.21834.2859.camel@edumazet-glaptop> <1609010645.20121221122100@eikelenboom.it> <50D4AB87.8050601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:45342
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830Ab3ACUkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 15:40:35 -0500
In-Reply-To: <50D4AB87.8050601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Friday, December 21, 2012, 7:33:43 PM, you wrote:

> I'm guessing that trusize checks matter more on the "inbound" path than 
> the outbound path?  If that is indeed the case, then instead of, or in 
> addition to using the -s option to set the local (netperf side) socket 
> buffer size, you should use a -S option to set the remote (netserver 
> side) socket buffer size.

> happy benchmarking,

> rick jones


OK, ran them with -S as well:

"current" is with netfront as is        (skb->truesize += skb->data_len - RX_COPY_THRESHOLD;)
"patched" is with IanC's latest patch   (skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;)

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current 87380  16384  16384    60.00    963213.91
patched 87380  16384  16384    60.00    965904.01

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo

        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current  2280  16384  16384    60.00    10029.44
patched  2280  16384  16384    60.00    10453.63


TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current  2280  16384   1432    60.00    10085.23
patched  2280  16384   1432    60.00    10089.98

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current 18000  16384  16384    60.00    53644.35
patched 18000  16384  16384    60.00    51892.59

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current 18000  16384   1432    60.00    37559.94
patched 18000  16384   1432    60.00    40630.66

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current 28000  16384  16384    60.00    103766.68
patched 28000  16384  16384    60.00    93277.98

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Recv   Send    Send
        Socket Socket  Message  Elapsed
        Size   Size    Size     Time     Throughput
        bytes  bytes   bytes    secs.    KBytes/sec

current 28000  16384   1432    60.00    73494.97
patched 28000  16384   1432    60.00    65312.94

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Socket  Message  Elapsed      Messages
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec

current 212992   65507   60.00      252087      0    268773.83
current 212992           60.00      237435           253151.28
patched 212992   65507   60.00      254997      0    271876.61
patched 212992           60.00      226636           241637.51

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Socket  Message  Elapsed      Messages
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec

current 212992   65507   60.00      252586      0    269305.73
current   2280           60.00      229371           244553.96
patched 212992   65507   60.00      256209      0    273168.32
patched   2280           60.00      201670           215019.54

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
        Socket  Message  Elapsed      Messages
        Size    Size     Time         Okay Errors   Throughput
        bytes   bytes    secs            #      #   KBytes/sec

current 212992    1432   60.00     5474009      0    127583.97
current   2280           60.00     4282184           99805.83
patched 212992    1432   60.00     5521903      0    128700.40
patched   2280           60.00     4522227           105400.70

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
       Socket  Message  Elapsed      Messages
       Size    Size     Time         Okay Errors   Throughput
       bytes   bytes    secs            #      #   KBytes/sec

current 212992   65507   60.00      251315      0    267950.39
current  18000           60.00      227856           242938.94
patched 212992   65507   60.00      256529      0    273509.57
patched  18000           60.00      224780           239658.47

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
       Socket  Message  Elapsed      Messages
       Size    Size     Time         Okay Errors   Throughput
       bytes   bytes    secs            #      #   KBytes/sec

current 212992    1432   60.00     5484882      0    127837.39
current  18000           60.00     5458678           127226.64
patched 212992    1432   60.00     5585209      0    130175.81
patched  18000           60.00     5560244           129593.94

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
       Socket  Message  Elapsed      Messages
       Size    Size     Time         Okay Errors   Throughput
       bytes   bytes    secs            #      #   KBytes/sec

current 212992   65507   60.00      250322      0    266891.35
current  28000           60.00      191711           204401.50
patched 212992   65507   60.00      257466      0    274508.96
patched  28000           60.00      241620           257613.85

UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.1.1 (192.168.1.1) port 0 AF_INET : +/-2.500% @ 95% conf.  : demo
       Socket  Message  Elapsed      Messages
       Size    Size     Time         Okay Errors   Throughput
       bytes   bytes    secs            #      #   KBytes/sec

current 212992    1432   60.00     5532780      0    128953.85
current  28000           60.00     5507094           128355.17
patched 212992    1432   60.00     5576824      0    129980.46
patched  28000           60.00     5555917           129493.16
