From: "dada1" <dada1@cosmosbay.com>
Subject: Re: Performance problem with route cache ?
Date: Fri, 21 Nov 2003 08:53:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <037d01c3b004$86b78e00$890010ac@edumazet>
References: <02da01c3af54$c1f37f20$890010ac@edumazet> <16316.46493.7576.116171@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Robert Olsson" <Robert.Olsson@data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "Robert Olsson" <Robert.Olsson@data.slu.se>
>  Does the copybreak help? I tested copybreak long time ago and saw no gain
>  from it. Do you have pointer to the patch?

This is a patch kindly given to me by Scott Feldmann, that just copy the skb
to a new shorter one.
In my case, this is indeed usefull, because the server receives a lot of
small tcp messages, from a lot of clients.
Instead of using 2K or 4K buffers to store the data into socket, we end up
using 64 bytes size buffers... quite a huge difference indeed.
In case of a spike in network, the machine no longer consume 200 MB of
lowmem and stay alive.
In a router context, copybreak should not be used, because the extra copy is
CPU intensive, and the data should not live long enough on memory.

>
>  > It seems the route cache may/should be tuned, but I dont know how.
>
>  Tuning is not an easy task and not necessarily you will gain anything,
>  It fully depends on your input traffic but it seems your system has a
>  lot of dst entries. Which would cause a lot linear search. Packets per
>  flow and no of parallel flows should be of interest for you. rtstat can
>  give you a better feeling of incoming routing load.
>
>  Is 10kpkts/s the max performance?

Well,  the machine is not network bounded... We dont want to increase the
trafic.
The machine just receives a lot of frames from a lot of different IP. That
is not a DOS attack.

Some rtstat samples :

rtstat -i 1
 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot
mc GC: tot ignored goal_miss ovrf HASH: in
_search out_search
279536      1490   11719     0     0     0     0     0       231     843
0   12562   12560         2    0
   97100       6853
282928      1732    9705     0     0     0     0     0       275     800
0   10505   10503         2    0
   80811       6774
278436      1211   10609     0     0     0     0     0       166     551
0   11160   11158         2    0
   87831       4550
280942      1195    8996     0     0     0     0     0       299    1128
0   10124   10122         2    0
   75815       9523
281774      1994   12201     0     0     0     0     0       295    1070
0   13271   13269         2    0
  102299       8864
274220      1514   11692     0     0     0     0     0       252     929
0   12621   12619         2    0
   96551       7743
274248      1271   10805     0     0     0     0     0       273    1094
0   11899   11897         2    0
   88822       9013
278905      1157    9942     0     0     0     0     0        85     308
0   10250   10248         2    0
   82651       2569
283423      1509    8471     0     0     0     0     0       176     631
0    9102    9100         2    0
   71805       5286
288620      1530    7685     0     0     0     0     0        74     299
0    7984    7982         2    0
   66499       2505
293264      1666    7432     0     0     0     0     0       174     552
0    7984    7982         2    0
   65642       4785
296831      1840    7570     0     0     0     0     0       129     371
0    7941    7939         2    0
   67687       3257
297902      2214    9863     0     0     0     0     0       346    1192
0   11055   11053         2    0
   88987      10566
300225      2192    8136     0     0     0     0     0       308     877
0    9013    9011         2    0
   74096       8029

size-32              931   1008     32  112    1 : tunables  120   60    8 :
slabdata      9      9      0
size-64            18477  51566     64   59    1 : tunables  120   60    8 :
slabdata    874    874    480
size-128            2013   2040    128   30    1 : tunables  120   60    8 :
slabdata     68     68      0
size-256              90     90    256   15    1 : tunables  120   60    8 :
slabdata      6      6      0
size-512           17569  37680    512    8    1 : tunables   54   27    8 :
slabdata   4710   4710     27
size-1024            348    348   1024    4    1 : tunables   54   27    8 :
slabdata     87     87     54
size-2048          13414  17306   2048    2    1 : tunables   24   12    8 :
slabdata   8653   8653     96
size-4096           3970   3970   4096    1    1 : tunables   24   12    8 :
slabdata   3970   3970      0
size-8192            139    139   8192    1    2 : tunables    8    4    0 :
slabdata    139    139      0
ip_dst_cache      280165 386208    320   12    1 : tunables   54   27    8 :
slabdata  32184  32184      0
skbuff_head_cache  35060 110200    192   20    1 : tunables  120   60    8 :
slabdata   5510   5510     60


Thanks
Eric Dumazet
