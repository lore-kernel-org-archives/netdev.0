From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: MQ performance on other cards (cxgb3)
Date: Tue, 16 Nov 2010 12:55:14 +0530
Message-ID: <OF81531A43.39EC6856-ON652577DD.001BBEB0-652577DD.002851D7@in.ibm.com>
References: <20101020085452.15579.76002.sendpatchset@krkumar2.in.ibm.com> <OF8735A2A4.74B4EE91-ON652577C5.0040D90B-652577C7.0056B99D@in.ibm.com> <20101026085709.GC23530@redhat.com> <OF529E89EE.84DB37B8-ON652577D6.001665CF-652577D6.00192784@in.ibm.com> <20101109132239.GF22705@redhat.com> <OF24E08752.2087FFA4-ON652577D6.00532DF1-652577D6.0054B291@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	eric.dumazet@gmail.com, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: davem@davemloft.net, Divy Le Ray <divy@chelsio.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <OF24E08752.2087FFA4-ON652577D6.00532DF1-652577D6.0054B291@LocalDomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had sent this mail to Michael last week - he agrees that I should
share this information on the list:

On latest net-next-2.6, virtio-net (guest->host) results are:
______________________________________________________________
                         SQ vs MQ (#txqs=8)
#      BW1      BW2 (%)          CPU1     CPU2 (%)   RCPU1   RCPU2 (%)
_______________________________________________________________
1      105774  112256 (6.1)   257      255 (-.7)     532     549 (3.1)
2      20842   30674 (47.1)   107      150 (40.1)    208     279 (34.1)
4      22500   31953 (42.0)   241      409 (69.7)    467     619 (32.5)
8      22416   44507 (98.5)   477      1039 (117.8)  960     1459 (51.9)
16     22605   45372 (100.7)  905      2060 (127.6)  1895    2962 (56.3)
24     23192   44201 (90.5)   1360     3028 (122.6)  2833    4437 (56.6)
32     23158   43394 (87.3)   1811     3957 (118.4)  3770    5936 (57.4)
40     23322   42550 (82.4)   2276     4986 (119.0)  4711    7417 (57.4)
48     23564   41931 (77.9)   2757     5966 (116.3)  5653    8896 (57.3)
64     23949   41092 (71.5)   3788     7898 (108.5)  7609    11826 (55.4)
80     23256   41343 (77.7)   4597     9887 (115.0)  9503    14801 (55.7)
96     23310   40645 (74.3)   5588     11758 (110.4) 11381   17761 (56.0)
128    24095   41082 (70.5)   7587     15574 (105.2) 15029   23716 (57.8)
______________________________________________________________
Avg:      BW: (58.3)      CPU: (110.8)      RCPU: (55.9)

It's true that average CPU% on guest is almost double that of the BW
improvement. But I don't think this is due to the patch (driver does no
synchronization, etc). To compare MQ vs SQ on a 10G card, I ran the
same test from host to remote host across cxgb3. The results are
somewhat similar:

(I changed cxgb_open on the client system to:
	netif_set_real_num_tx_queues(dev, 1);
	err = netif_set_real_num_rx_queues(dev, 1);
to simulate single queue (SQ))
_____________________________________
            cxgb3 SQ vs cxgb3 MQ
#     BW1      BW2 (%)      CPU1   CPU2 (%)
_____________________________________
1     8301    8315 (.1)        5         4.66 (-6.6)
2     9395    9380 (-.1)      16        16 (0)
4     9411    9414 (0)        33        26 (-21.2)
8     9411    9398 (-.1)      60        62 (3.3)
16   9412    9413 (0)        116      117 (.8)
24   9442    9963 (5.5)     179      198 (10.6)
32   10031  10025 (0)       230     249 (8.2)
40   9953    10024 (.7)      300     312 (4.0)
48   10002  10015 (.1)      351     376 (7.1)
64   10022  10024 (0)       494     515 (4.2)
80   8894    10011 (12.5)   537    630 (17.3)
96   8465    9907 (17.0)     612    749 (22.3)
128  7541   9617 (27.5)     760    989 (30.1)
_____________________________________
Avg:     BW: (3.8)     CPU: (14.8)

(Each case runs runs once for 60 secs)

The BW increased modestly but CPU increased much more. I assume
the change I made above to convert the driver from MQ to SQ is not
incorrect.

Thanks,

- KK

