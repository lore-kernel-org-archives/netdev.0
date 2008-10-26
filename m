From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Sun, 26 Oct 2008 09:46:30 +0100
Message-ID: <1225010790.8566.22.camel@marge.simson.net>
References: <20081024.221653.23695396.davem@davemloft.net>
	 <1224914333.3822.18.camel@marge.simson.net>
	 <1224917623.4929.15.camel@marge.simson.net>
	 <20081025.002420.82739316.davem@davemloft.net>
	 <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rjw@sisk.pl,
	Ingo Molnar <mingo@elte.hu>, s0mbre@tservice.net.ru,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35415 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751806AbYJZIqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 04:46:37 -0400
In-Reply-To: <Pine.LNX.4.64.0810260055070.22126@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-10-26 at 01:10 +0200, Jiri Kosina wrote:
> On Sat, 25 Oct 2008, David Miller wrote:
> 
> > But note that tbench performance improved a bit in 2.6.25.
> > In my tests I noticed a similar effect, but from 2.6.23 to 2.6.24,
> > weird.
> > Just for the public record here are the numbers I got in my testing.
> 
> I have been currently looking at very similarly looking issue. For the 
> public record, here are the numbers we have been able to come up with so 
> far (measured with dbench, so the absolute values are slightly different, 
> but still shows similar pattern)
> 
> 208.4 MB/sec  -- vanilla 2.6.16.60
> 201.6 MB/sec  -- vanilla 2.6.20.1
> 172.9 MB/sec  -- vanilla 2.6.22.19
> 74.2 MB/sec   -- vanilla 2.6.23
>  46.1 MB/sec  -- vanilla 2.6.24.2
>  30.6 MB/sec  -- vanilla 2.6.26.1
> 
> I.e. huge drop for 2.6.23 (this was with default configs for each 
> respective kernel).
> 2.6.23-rc1 shows 80.5 MB/s, i.e. a few % better than final 2.6.23, but 
> still pretty bad. 
> 
> I have gone through the commits that went into -rc1 and tried to figure 
> out which one could be responsible. Here are the numbers:
> 
>  85.3 MB/s for 2ba2d00363 (just before on-deman readahead has been merged)
>  82.7 MB/s for 45426812d6 (before cond_resched() has been added into page 
> 187.7 MB/s for c1e4fe711a4 (just before CFS scheduler has been merged)
>                            invalidation code)
> 
> So the current bigest suspect is CFS, but I don't have enough numbers yet 
> to be able to point a finger to it with 100% certainity. Hopefully soon.

Hi,

High client count right?

I reproduced this on my Q6600 box.  However, I also reproduced it with
2.6.22.19.  What I think you're seeing is just dbench creating a massive
train wreck.  With CFS, it appears to be more likely to start->end
_sustain_, but the wreckage is present in O(1) scheduler runs as well,
and will start->end sustain there as well.

2.6.22.19-smp           Throughput 967.933 MB/sec 16 procs Throughput 147.879 MB/sec 160 procs
                        Throughput 950.325 MB/sec 16 procs Throughput 349.959 MB/sec 160 procs
                        Throughput 953.382 MB/sec 16 procs Throughput 126.821 MB/sec 160 procs <== massive jitter
2.6.22.19-cfs-v24.1-smp Throughput 978.047 MB/sec 16 procs Throughput 170.662 MB/sec 160 procs
                        Throughput 943.254 MB/sec 16 procs Throughput 39.388 MB/sec 160 procs <== sustained train wreck
                        Throughput 934.042 MB/sec 16 procs Throughput 239.574 MB/sec 160 procs
2.6.23.17-smp           Throughput 1173.97 MB/sec 16 procs Throughput 100.996 MB/sec 160 procs
                        Throughput 1122.85 MB/sec 16 procs Throughput 80.3747 MB/sec 160 procs
                        Throughput 1113.60 MB/sec 16 procs Throughput 99.3723 MB/sec 160 procs
2.6.24.7-smp            Throughput 1030.34 MB/sec 16 procs Throughput 256.419 MB/sec 160 procs
                        Throughput 970.602 MB/sec 16 procs Throughput 257.008 MB/sec 160 procs
                        Throughput 1056.48 MB/sec 16 procs Throughput 248.841 MB/sec 160 procs
2.6.25.19-smp           Throughput 955.874 MB/sec 16 procs Throughput 40.5735 MB/sec 160 procs
                        Throughput 943.348 MB/sec 16 procs Throughput 62.3966 MB/sec 160 procs
			Throughput 937.595 MB/sec 16 procs Throughput 17.4639 MB/sec 160 procs
2.6.26.7-smp            Throughput 904.564 MB/sec 16 procs Throughput 118.364 MB/sec 160 procs
                        Throughput 891.824 MB/sec 16 procs Throughput 34.2193 MB/sec 160 procs
                        Throughput 880.850 MB/sec 16 procs Throughput 22.4938 MB/sec 160 procs
2.6.27.4-smp            Throughput 856.660 MB/sec 16 procs Throughput 168.243 MB/sec 160 procs
                        Throughput 880.121 MB/sec 16 procs Throughput 120.132 MB/sec 160 procs
                        Throughput 880.121 MB/sec 16 procs Throughput 142.105 MB/sec 160 procs

Check out fugliness:

2.6.22.19-smp  Throughput 35.5075 MB/sec 160 procs  (start->end sustained train wreck)

Full output from above run:

dbench version 3.04 - Copyright Andrew Tridgell 1999-2004

Running for 60 seconds with load '/usr/share/dbench/client.txt' and minimum warmup 12 secs
160 clients started
 160        54   310.43 MB/sec  warmup   1 sec   
 160        54   155.18 MB/sec  warmup   2 sec   
 160        54   103.46 MB/sec  warmup   3 sec   
 160        54    77.59 MB/sec  warmup   4 sec   
 160        56    64.81 MB/sec  warmup   5 sec   
 160        57    54.01 MB/sec  warmup   6 sec   
 160        57    46.29 MB/sec  warmup   7 sec   
 160       812   129.07 MB/sec  warmup   8 sec   
 160      1739   205.08 MB/sec  warmup   9 sec   
 160      2634   262.22 MB/sec  warmup  10 sec   
 160      3437   305.41 MB/sec  warmup  11 sec   
 160      3815   307.35 MB/sec  warmup  12 sec   
 160      4241   311.07 MB/sec  warmup  13 sec   
 160      5142   344.02 MB/sec  warmup  14 sec   
 160      5991   369.46 MB/sec  warmup  15 sec   
 160      6346   369.09 MB/sec  warmup  16 sec   
 160      6347   347.97 MB/sec  warmup  17 sec   
 160      6347   328.66 MB/sec  warmup  18 sec   
 160      6348   311.50 MB/sec  warmup  19 sec   
 160      6348     0.00 MB/sec  execute   1 sec   
 160      6348     2.08 MB/sec  execute   2 sec   
 160      6349     2.75 MB/sec  execute   3 sec   
 160      6356    16.25 MB/sec  execute   4 sec   
 160      6360    17.21 MB/sec  execute   5 sec   
 160      6574    45.07 MB/sec  execute   6 sec   
 160      6882    76.17 MB/sec  execute   7 sec   
 160      7006    86.37 MB/sec  execute   8 sec   
 160      7006    76.77 MB/sec  execute   9 sec   
 160      7006    69.09 MB/sec  execute  10 sec   
 160      7039    68.67 MB/sec  execute  11 sec   
 160      7043    64.71 MB/sec  execute  12 sec   
 160      7044    60.29 MB/sec  execute  13 sec   
 160      7044    55.98 MB/sec  execute  14 sec   
 160      7057    56.13 MB/sec  execute  15 sec   
 160      7057    52.63 MB/sec  execute  16 sec   
 160      7059    50.21 MB/sec  execute  17 sec   
 160      7083    49.73 MB/sec  execute  18 sec   
 160      7086    48.05 MB/sec  execute  19 sec   
 160      7088    46.40 MB/sec  execute  20 sec   
 160      7088    44.19 MB/sec  execute  21 sec   
 160      7094    43.59 MB/sec  execute  22 sec   
 160      7094    41.69 MB/sec  execute  23 sec   
 160      7094    39.96 MB/sec  execute  24 sec   
 160      7094    38.36 MB/sec  execute  25 sec   
 160      7094    36.88 MB/sec  execute  26 sec   
 160      7094    35.52 MB/sec  execute  27 sec   
 160      7098    34.91 MB/sec  execute  28 sec   
 160      7124    36.72 MB/sec  execute  29 sec   
 160      7124    35.50 MB/sec  execute  30 sec   
 160      7124    34.35 MB/sec  execute  31 sec   
 160      7124    33.28 MB/sec  execute  32 sec   
 160      7124    32.27 MB/sec  execute  33 sec   
 160      7124    31.32 MB/sec  execute  34 sec   
 160      7283    34.80 MB/sec  execute  35 sec   
 160      7681    44.95 MB/sec  execute  36 sec   
 160      7681    43.79 MB/sec  execute  37 sec   
 160      7681    42.64 MB/sec  execute  38 sec   
 160      7689    42.23 MB/sec  execute  39 sec   
 160      7691    41.48 MB/sec  execute  40 sec   
 160      7693    40.76 MB/sec  execute  41 sec   
 160      7703    40.54 MB/sec  execute  42 sec   
 160      7704    39.81 MB/sec  execute  43 sec   
 160      7704    38.91 MB/sec  execute  44 sec   
 160      7704    38.04 MB/sec  execute  45 sec   
 160      7704    37.21 MB/sec  execute  46 sec   
 160      7704    36.42 MB/sec  execute  47 sec   
 160      7704    35.66 MB/sec  execute  48 sec   
 160      7747    36.58 MB/sec  execute  49 sec   
 160      7854    38.00 MB/sec  execute  50 sec   
 160      7857    37.65 MB/sec  execute  51 sec   
 160      7861    37.29 MB/sec  execute  52 sec   
 160      7862    36.67 MB/sec  execute  53 sec   
 160      7864    36.21 MB/sec  execute  54 sec   
 160      7877    35.85 MB/sec  execute  55 sec   
 160      7877    35.21 MB/sec  execute  56 sec   
 160      8015    37.11 MB/sec  execute  57 sec   
 160      8019    36.57 MB/sec  execute  58 sec   
 160      8019    35.95 MB/sec  execute  59 sec   
 160      8019    35.36 MB/sec  cleanup  60 sec   
 160      8019    34.78 MB/sec  cleanup  61 sec   
 160      8019    34.23 MB/sec  cleanup  63 sec   
 160      8019    33.69 MB/sec  cleanup  64 sec   
 160      8019    33.16 MB/sec  cleanup  65 sec   
 160      8019    32.65 MB/sec  cleanup  66 sec   
 160      8019    32.21 MB/sec  cleanup  67 sec   
 160      8019    31.73 MB/sec  cleanup  68 sec   
 160      8019    31.27 MB/sec  cleanup  69 sec   
 160      8019    30.84 MB/sec  cleanup  70 sec   
 160      8019    30.40 MB/sec  cleanup  71 sec   
 160      8019    29.98 MB/sec  cleanup  72 sec   
 160      8019    29.58 MB/sec  cleanup  73 sec   
 160      8019    29.18 MB/sec  cleanup  74 sec   
 160      8019    29.03 MB/sec  cleanup  74 sec   

Throughput 35.5075 MB/sec 160 procs

Throughput 180.934 MB/sec 160 procs (next run, non-sustained train wreck)

Full output of this run:

dbench version 3.04 - Copyright Andrew Tridgell 1999-2004

Running for 60 seconds with load '/usr/share/dbench/client.txt' and minimum warmup 12 secs
160 clients started
 160        67   321.43 MB/sec  warmup   1 sec   
 160        67   160.61 MB/sec  warmup   2 sec   
 160        67   107.04 MB/sec  warmup   3 sec   
 160        67    80.27 MB/sec  warmup   4 sec   
 160        67    64.21 MB/sec  warmup   5 sec   
 160       267    89.74 MB/sec  warmup   6 sec   
 160      1022   169.68 MB/sec  warmup   7 sec   
 160      1821   240.62 MB/sec  warmup   8 sec   
 160      2591   290.39 MB/sec  warmup   9 sec   
 160      3125   308.04 MB/sec  warmup  10 sec   
 160      3125   280.04 MB/sec  warmup  11 sec   
 160      3217   263.23 MB/sec  warmup  12 sec   
 160      3725   276.45 MB/sec  warmup  13 sec   
 160      4237   288.32 MB/sec  warmup  14 sec   
 160      4748   300.98 MB/sec  warmup  15 sec   
 160      4810   286.69 MB/sec  warmup  16 sec   
 160      4812   270.89 MB/sec  warmup  17 sec   
 160      4812   255.95 MB/sec  warmup  18 sec   
 160      4812   242.48 MB/sec  warmup  19 sec   
 160      4812   230.35 MB/sec  warmup  20 sec   
 160      4812   219.38 MB/sec  warmup  21 sec   
 160      4812   209.41 MB/sec  warmup  22 sec   
 160      4812   200.31 MB/sec  warmup  23 sec   
 160      4812   191.96 MB/sec  warmup  24 sec   
 160      4812   184.28 MB/sec  warmup  25 sec   
 160      4812   177.19 MB/sec  warmup  26 sec   
 160      4836   175.89 MB/sec  warmup  27 sec   
 160      4836   169.61 MB/sec  warmup  28 sec   
 160      4841   163.97 MB/sec  warmup  29 sec   
 160      5004   163.03 MB/sec  warmup  30 sec   
 160      5450   170.58 MB/sec  warmup  31 sec   
 160      5951   178.79 MB/sec  warmup  32 sec   
 160      6086   176.86 MB/sec  warmup  33 sec   
 160      6127   174.53 MB/sec  warmup  34 sec   
 160      6129   169.67 MB/sec  warmup  35 sec   
 160      6131   165.36 MB/sec  warmup  36 sec   
 160      6137   161.65 MB/sec  warmup  37 sec   
 160      6141   157.85 MB/sec  warmup  38 sec   
 160      6145   154.32 MB/sec  warmup  39 sec   
 160      6145   150.46 MB/sec  warmup  40 sec   
 160      6145   146.79 MB/sec  warmup  41 sec   
 160      6145   143.30 MB/sec  warmup  42 sec   
 160      6145   139.97 MB/sec  warmup  43 sec   
 160      6145   136.78 MB/sec  warmup  44 sec   
 160      6145   133.74 MB/sec  warmup  45 sec   
 160      6145   130.84 MB/sec  warmup  46 sec   
 160      6145   128.05 MB/sec  warmup  47 sec   
 160      6178   128.41 MB/sec  warmup  48 sec   
 160      6180   126.13 MB/sec  warmup  49 sec   
 160      6184   124.09 MB/sec  warmup  50 sec   
 160      6187   122.03 MB/sec  warmup  51 sec   
 160      6192   120.19 MB/sec  warmup  52 sec   
 160      6196   118.42 MB/sec  warmup  53 sec   
 160      6228   116.88 MB/sec  warmup  54 sec   
 160      6231   114.97 MB/sec  warmup  55 sec   
 160      6231   112.92 MB/sec  warmup  56 sec   
 160      6398   114.17 MB/sec  warmup  57 sec   
 160      6401   112.44 MB/sec  warmup  58 sec   
 160      6402   110.69 MB/sec  warmup  59 sec   
 160      6402   108.84 MB/sec  warmup  60 sec   
 160      6405   107.38 MB/sec  warmup  61 sec   
 160      6405   105.65 MB/sec  warmup  62 sec   
 160      6407   104.03 MB/sec  warmup  64 sec   
 160      6431   103.16 MB/sec  warmup  65 sec   
 160      6432   101.64 MB/sec  warmup  66 sec   
 160      6432   100.10 MB/sec  warmup  67 sec   
 160      6460    99.42 MB/sec  warmup  68 sec   
 160      6698   100.92 MB/sec  warmup  69 sec   
 160      7218   106.21 MB/sec  warmup  70 sec   
 160      7254    36.49 MB/sec  execute   1 sec   
 160      7254    18.24 MB/sec  execute   2 sec   
 160      7259    21.06 MB/sec  execute   3 sec   
 160      7359    37.80 MB/sec  execute   4 sec   
 160      7381    34.05 MB/sec  execute   5 sec   
 160      7381    28.37 MB/sec  execute   6 sec   
 160      7381    24.32 MB/sec  execute   7 sec   
 160      7381    21.28 MB/sec  execute   8 sec   
 160      7404    21.03 MB/sec  execute   9 sec   
 160      7647    43.24 MB/sec  execute  10 sec   
 160      7649    39.94 MB/sec  execute  11 sec   
 160      7672    38.48 MB/sec  execute  12 sec   
 160      7680    37.10 MB/sec  execute  13 sec   
 160      7856    46.09 MB/sec  execute  14 sec   
 160      7856    43.02 MB/sec  execute  15 sec   
 160      7856    40.33 MB/sec  execute  16 sec   
 160      7856    37.99 MB/sec  execute  17 sec   
 160      8561    71.30 MB/sec  execute  18 sec   
 160      9070    92.10 MB/sec  execute  19 sec   
 160      9080    88.86 MB/sec  execute  20 sec   
 160      9086    86.13 MB/sec  execute  21 sec   
 160      9089    82.70 MB/sec  execute  22 sec   
 160      9095    79.98 MB/sec  execute  23 sec   
 160      9098    77.32 MB/sec  execute  24 sec   
 160      9101    74.78 MB/sec  execute  25 sec   
 160      9105    72.70 MB/sec  execute  26 sec   
 160      9107    70.34 MB/sec  execute  27 sec   
 160      9110    68.40 MB/sec  execute  28 sec   
 160      9114    66.60 MB/sec  execute  29 sec   
 160      9114    64.38 MB/sec  execute  30 sec   
 160      9114    62.30 MB/sec  execute  31 sec   
 160      9146    61.31 MB/sec  execute  32 sec   
 160      9493    68.80 MB/sec  execute  33 sec   
 160     10040    80.50 MB/sec  execute  34 sec   
 160     10567    91.12 MB/sec  execute  35 sec   
 160     10908    96.72 MB/sec  execute  36 sec   
 160     11234   101.86 MB/sec  execute  37 sec   
 160     12062   118.23 MB/sec  execute  38 sec   
 160     12987   135.90 MB/sec  execute  39 sec   
 160     13883   152.07 MB/sec  execute  40 sec   
 160     14730   166.18 MB/sec  execute  41 sec   
 160     14829   165.26 MB/sec  execute  42 sec   
 160     14836   162.03 MB/sec  execute  43 sec   
 160     14851   158.64 MB/sec  execute  44 sec   
 160     14851   155.11 MB/sec  execute  45 sec   
 160     14851   151.74 MB/sec  execute  46 sec   
 160     15022   151.70 MB/sec  execute  47 sec   
 160     15292   153.38 MB/sec  execute  48 sec   
 160     15580   155.28 MB/sec  execute  49 sec   
 160     15846   156.73 MB/sec  execute  50 sec   
 160     16449   164.00 MB/sec  execute  51 sec   
 160     17097   171.56 MB/sec  execute  52 sec   
 160     17097   168.32 MB/sec  execute  53 sec   
 160     17310   168.62 MB/sec  execute  54 sec   
 160     18075   177.42 MB/sec  execute  55 sec   
 160     18828   186.31 MB/sec  execute  56 sec   
 160     18876   184.04 MB/sec  execute  57 sec   
 160     18876   180.87 MB/sec  execute  58 sec   
 160     18879   177.81 MB/sec  execute  59 sec   
 160     19294   180.80 MB/sec  cleanup  60 sec   
 160     19294   177.84 MB/sec  cleanup  61 sec   
 160     19294   174.97 MB/sec  cleanup  63 sec   
 160     19294   172.24 MB/sec  cleanup  64 sec   
 160     19294   169.55 MB/sec  cleanup  65 sec   
 160     19294   166.95 MB/sec  cleanup  66 sec   
 160     19294   164.42 MB/sec  cleanup  67 sec   
 160     19294   161.97 MB/sec  cleanup  68 sec   
 160     19294   159.59 MB/sec  cleanup  69 sec   
 160     19294   157.28 MB/sec  cleanup  70 sec   
 160     19294   155.03 MB/sec  cleanup  71 sec   
 160     19294   152.86 MB/sec  cleanup  72 sec   
 160     19294   150.76 MB/sec  cleanup  73 sec   
 160     19294   148.71 MB/sec  cleanup  74 sec   
 160     19294   146.70 MB/sec  cleanup  75 sec   
 160     19294   144.75 MB/sec  cleanup  76 sec   
 160     19294   142.85 MB/sec  cleanup  77 sec   
 160     19294   141.72 MB/sec  cleanup  77 sec   

Throughput 180.934 MB/sec 160 procs


