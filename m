From: Simon Kirby <sim@netnation.com>
Subject: Route cache performance tests
Date: Tue, 10 Jun 2003 00:57:32 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610075732.GD23009@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com, Jamal Hadi <hadi@shell.cyberus.ca>,
	CIT/Paul <xerox@foonet.net>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Okay, I got a chance to run some first tests and have found some simple
results that might be worth a read.  The test setup is as follows
(I'll probably be using this setup for a number of other tests):

[ My work desktop, other test boxes on network ]
 |   |   |   |   |
[ 100 Mbit Switch ]
         |
         | (100 Mbit)
         |
[ Dual tg3 dual 1.4 GHz Opertron box, 1 GB RAM ]
         |
         | (1000 MBit)
         |
[ Single e1000 single 2.4 GHz Xeon box ]

I have a route added on the test boxes to stuff traffic destined for the
Xeon box through the Opertron box.  Forwarding is enabled on the Opertron
box, and it has a route for the Xeon box.

I am testing with Juno right now because it generates the (pseudo-)random
IP traffic which we is where the problem is right now.  We already know
Linux can do hundreds of thousands of pps of ip<->ip traffic, so we can
test that later.

Juno seems to be able to send about 150,000 pps from my Celery desktop. 

Running with vanilla 2.4.21-rc7 (for now), the kernel manages to forward
an amazing 39,000 packets per second.  Woohoo!  NAPI definitely kicks in
and seems to work even on SMP (blink?).  The output of "rtstat -i 1" is
somewhat interesting.  The "GC: tot" field seems to almost exactly match
the forwarded packet count, which is handy:

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
    8         4       4     0     0     0     0     0         0       0      0       0       0         0    0
    8         3       3     0     0     0     0     0         0       0      0       0       0         0    0
    8         5       6     0     0     0     0     0         0       0      0       0       0         0    0
    8         4       4     0     0     0     0     0         0       0      0       0       0         0    0
    8         5       5     0     0     0     0     0         0       0      0       0       0         0    0
    9         3       5     0     0     1     0     0         0       0      0       0       0         0    0
33549        11   65533     0     0     0     0     0         0       0      0   57347   57345         1    0
53499        13   65200     0     0     1     0     0         0       0      0   65196   65194         1    0
65536        19   65540     0     0     1     0     0         0       0      0   65538   64879         0    0
65536        11   33980     0     0     0     0     0         0       0      0   33978    6123         0    0
65536         9   37491     0     0     1     0     0         0       0      0   37489     930         0    0
65536        13   40487     0     0     0     0     0         0       0      0   40484     991         0    0
65536        13   39287     0     0     1     0     0         0       0      0   39284     933         0    0
65536        10   40790     0     0     1     0     0         0       0      0   40789    1006         0    0
65536        17   37783     0     0     0     0     0         0       0      0   37781     866         0    0
65536         8   38092     0     0     0     0     0         0       0      0   38090     880         0    0
65536        14   38086     0     0     1     0     0         0       0      0   38085     877         0    0
65536        13   39587     0     0     0     0     0         0       0      0   39586     922         0    0
65536        18   39882     0     0     1     0     0         0       0      0   39880     908         0    0
65536         8   39292     0     0     0     0     0         0       0      0   39290     894         0    0
65536        10   38390     0     0     4     0     0         0       0      0   38389     879         0    0
65536        13   38087     0     0     0     0     0         0       0      0   38086     830         0    0
65536        10   38692     0     0     0     0     0         0       0      0   38690     845         0    0
65536        16   38982     0     0     1     0     0         0       0      0   38981     899         0    0

The above is with stock settings.  Note how the table completely fills up
causing the forward rate to suffer.

In an attempt to improve performance, I tried "echo 0 > gc_min_interval":

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
65536        15   39585     0     0     0     0     0         0       0      0   39585     909         0    0
65535        13   39587     0     0     1     0     0         0       0      0   39587     877         0    0
32027        10   70044     0     0     0     0     0         0       0      0   70043       0         6    0
32013         8   71092     0     0     0     0     0         0       0      0   71091       0         0    0
31995        10   72290     0     0     1     0     0         0       0      0   72290       0         0    0
31969        13   71087     0     0     2     0     0         0       0      0   71083       0         0    0
31950         5   71695     0     0     0     0     0         0       0      0   71693       0         0    0
31937        10   71690     0     0     2     0     0         0       0      0   71690       0         0    0
31927        10   71390     0     0     0     0     0         0       0      0   71389       0         0    0
31915        18   71382     0     0     0     0     0         0       0      0   71381       0         0    0
31897         5   71395     0     0     0     0     0         0       0      0   71394       0         0    0
31881         7   70793     0     0     0     0     0         0       0      0   70793       0         0    0
31869         5   71095     0     0     0     0     0         0       0      0   71094       0         0    0
31863        16   71084     0     0     0     0     0         0       0      0   71082       0         0    0
31846        22   70778     0     0     0     0     0         0       0      0   70776       0         0    0
31825         5   70795     0     0     1     0     0         0       0      0   70795       0         0    0
31816        10   70490     0     0     0     0     0         0       0      0   70488       0         0    0

And then decided to try "ip route flush cache":

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
31768         8   70192     0     0     0     0     0         0       0      0   70190       0         0    0
31757        15   70185     0     0     1     0     0         0       0      0   70184       0         0    0
31743         5   70495     0     0     1     0     0         0       0      0   70491       0         0    0
 8204         2   83314     0     0     0     0     0         1       2      0   75524       0        89    0
 8204         2   88859     0     0     0     0     0         1       0      0   88449       0        84    0
 8203         3   85797     0     0     1     0     0         0       0      0   85795       0         0    0
 8203         0   86100     0     0     0     0     0         0       0      0   86098       0         0    0

...And then I tried reducing gc_thresh:

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc GC: tot ignored goal_miss ovrf
 8200         7   85793     0     0     1     0     0         0       0      0   85790       0         0    0
 8200         4   85796     0     0     1     0     0         0       0      0   85792       0         0    0
 8200        13   86087     0     0     0     0     0         0       0      0   86086       0         0    0
 8200         3   86097     0     0     0     0     0         0       0      0   86096       0         0    0
 1530         4   87896     0     0     0     0     0         0       0      0   87277       0       562    0
 1370         0  135832     0     0     0     0     0         0       0      0  135829       0       617    0
 1348         0  135952     0     0     2     0     0         0       0      0  135952       0       543    0
 1341         0  135740     0     0     0     0     0         0       0      0  135739       0       529    0
 1348         1  135817     0     0     1     0     0         0       0      0  135817       0       567    0

I tried fiddling with more settings, even setting gc_thresh to 1, but I
wasn't able to get the route cache much smaller than that or get it to
forward any more packets per second.

In any case, setting gc_min_interval to 0 definitely helped, but I
suspect Dave's patches will make a bigger difference.  Next up is
2.5.70-bk14 and 2.5.70-bk14+davem's stuff from yesterday.

Simon-
