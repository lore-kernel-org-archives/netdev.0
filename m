From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net: remove busylock
Date: Fri, 20 May 2016 14:32:40 -0700
Message-ID: <1463779960.5939.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463677716.18194.203.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UfBxW=KpqJux+tjyNpHQUHhZ5Laiqnt5FPs=jpkBJWrHA@mail.gmail.com>
	 <20160520092903.38620c60@redhat.com>
	 <1463749909.18194.291.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463752069.18194.294.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463753815.18194.298.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160520194951.6354fba1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35437 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbcETVcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 17:32:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id b66so12435976pfb.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 14:32:43 -0700 (PDT)
In-Reply-To: <20160520194951.6354fba1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-20 at 19:49 +0200, Jesper Dangaard Brouer wrote:
> On Fri, 20 May 2016 07:16:55 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Since bonding pretends to be multiqueue, TCQ_F_ONETXQUEUE is not set
> > on sch->flags when HTB is installed at the bonding device root.
> 
> If would be cool if you could run a test with removed busylock and
> allow HTB to bulk dequeue.

I added a /sys/class/net/eth0/tx_bulk_limit to tune the number of
packets that we could bulk dequeue from a virtual device 
(no BQL on them)

200 TCP_RR through HTB on eth0 (bonding device)

1) busylock enabled
--------------------

With tx_bulk_limit set to 8, we get 12.7 % increase.

lpaa23:~# for f in `seq 1 16`; do echo $f|tee /sys/class/net/eth0/tx_bulk_limit; sar -n DEV 3 3|grep eth0|grep Average; done
1
Average:         eth0 868625.67 868487.44  57055.69  56826.37      0.00      0.00      0.56
2
Average:         eth0 927081.67 926920.78  60923.83  60649.90      0.00      0.00      0.44
3
Average:         eth0 957678.11 957554.00  62877.04  62653.89      0.00      0.00      0.56
4
Average:         eth0 966912.44 966747.33  63532.72  63255.51      0.00      0.00      0.56
5
Average:         eth0 973137.56 972950.44  63958.31  63661.39      0.00      0.00      0.44
6
Average:         eth0 958589.22 958449.44  62961.79  62712.56      0.00      0.00      0.67
7
Average:         eth0 960737.67 960672.22  62968.34  62857.97      0.00      0.00      0.44
8
Average:         eth0 979271.78 979201.67  64199.47  64070.84      0.00      0.00      0.56
9
Average:         eth0 982464.33 982390.33  64418.42  64278.93      0.00      0.00      0.56
10
Average:         eth0 982698.00 982578.22  64495.25  64291.28      0.00      0.00      0.44
11
Average:         eth0 981862.22 981746.00  64438.16  64236.31      0.00      0.00      0.56
12
Average:         eth0 983277.44 983096.33  64632.79  64327.79      0.00      0.00      0.44
13
Average:         eth0 981221.11 981018.00  64521.82  64189.26      0.00      0.00      0.67
14
Average:         eth0 981754.11 981555.89  64553.19  64224.39      0.00      0.00      0.44
15
Average:         eth0 982484.33 982301.67  64572.00  64273.38      0.00      0.00      0.44
16
Average:         eth0 978529.56 978326.67  64350.89  64013.39      0.00      0.00      0.67


2) busylock disabled
--------------------

Well, bulk dequeue helps, but does not close the gap. 
(busylock is needed)

lpaa23:~# for f in `seq 1 16`; do echo $f|tee /sys/class/net/eth0/tx_bulk_limit; sar -n DEV 3 3|grep eth0|grep Average; done
1
Average:         eth0 795408.44 795407.67  52044.66  52045.93      0.00      0.00      0.56
2
Average:         eth0 843411.78 843415.11  55185.23  55184.51      0.00      0.00      0.56
3
Average:         eth0 876175.89 876175.00  57329.50  57327.98      0.00      0.00      0.44
4
Average:         eth0 890631.22 890629.44  58274.58  58274.25      0.00      0.00      0.67
5
Average:         eth0 900672.00 900668.89  58931.29  58930.54      0.00      0.00      0.44
6
Average:         eth0 908325.78 908328.22  59432.97  59431.76      0.00      0.00      0.56
7
Average:         eth0 913895.33 913885.11  59796.89  59795.46      0.00      0.00      0.56
8
Average:         eth0 914429.11 914433.56  59832.26  59831.23      0.00      0.00      0.67
9
Average:         eth0 918701.11 918699.67  60110.68  60110.36      0.00      0.00      0.55
10
Average:         eth0 920382.33 920376.56  60223.31  60220.54      0.00      0.00      0.67
11
Average:         eth0 914341.67 914344.67  59826.25  59825.90      0.00      0.00      0.67
12
Average:         eth0 912697.00 912693.78  59718.77  59717.44      0.00      0.00      0.44
13
Average:         eth0 917392.56 917385.00  60025.79  60024.34      0.00      0.00      0.44
14
Average:         eth0 918232.89 918233.78  60081.04  60079.94      0.00      0.00      0.67
15
Average:         eth0 918377.11 918381.00  60091.14  60089.79      0.00      0.00      0.44
16
Average:         eth0 913817.56 913812.33  59792.09  59790.66      0.00      0.00      0.56
