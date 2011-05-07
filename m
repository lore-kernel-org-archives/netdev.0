From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 19:24:11 +0100
Message-ID: <178E8895FB84C07251538EF7@Ximines.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:42698 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab1EGSYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 14:24:15 -0400
In-Reply-To: <1304785589.3207.5.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

--On 7 May 2011 18:26:29 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Here, on 2.6.38 kernel (Ubuntu 11.04 provided, on my 2 core laptop)
># time rmmod dummy
> real	0m0.111s
...
> On another machine with a very recent kernel :
> $ modprobe dummy numdummies=1
> $ ifconfig dummy0 192.168.46.46 up
> $ time rmmod dummy
>
> real	0m0.032s

I know it's different machines, but that's a pretty significant
difference. So I compiled from 2.6.39-rc6 head (i.e. a kernel
less than an hour old), with only your suggested change in,
so that (a) I could eliminate old kernels, and (b) I could
instrument it.

> synchronize_rcu() calls are not consuming cpu, they just _wait_
> rcu grace period.
>
> I suggest you read Documentation/RCU files if you really want to :)

I understand the basic point: it needs to wait for all readers
to drop their references. It's sort of hard to understand why
on a machine with an idle network there would be reader(s) holding
references for 250ms. And indeed the analysis below shows that
isn't the case (it's more like 44 ms).

> If you want to check how expensive it is, its quite easy:
> add a trace in synchronize_net()

At least for veth devices, I see the same on 2.6.39-rc6 - if anything
it's worse:

# ./ifseq -n 100
Sat May 7 17:50:53 UTC 2011 creating 100 interfaces
Sat May 7 17:50:54 UTC 2011 done

real	0m1.549s
user	0m0.060s
sys	0m0.990s
Sat May 7 17:50:54 UTC 2011 deleting 100 interfaces
Sat May 7 17:51:22 UTC 2011 done

real	0m27.917s
user	0m0.420s
sys	0m0.060s

Performing that operation produced exactly 200 calls to synchronize net.
The timestamps indicate that's 2 per veth pair deletion, and zero
per veth pair creation.

Analysing the resultant logs shows only 31% of the problem is
time spent within synchronize_net() (perl script below).

$ ./analyse.pl < syncnet | tail -2
Total 18.98515 Usage 199 Average 0.09540 elsewhere
Total 8.77581 Usage 200 Average 0.04388 synchronizing

So *something* is spending more than twice as much time as
synchronize_net().

I've attached the log below as well.

-- 
Alex Bligh


$ cat analyse.pl
#!/usr/bin/perl

use strict;
use warnings;

my $lastuptime;
my $uptime;
my $diff;
my $area;
my %time;
my %usage;

while (<>)
{
    chomp;
    if (m/\[\s*([0-9.]+)\].*synchronize_net/)
    {
	$uptime = $1;
	if (defined($lastuptime))
	{
	    $area = (m/end/)?"synchronizing":"elsewhere";
	    $diff = $uptime - $lastuptime;
	    printf "%5.5f $area\n", $diff;
	    $time{$area}+=$diff;
	    $usage{$area}++;
	}
	$lastuptime = $uptime;
    }
}

print "\n";

my $k;
foreach $k (sort keys %time)
{
    printf "Total %5.5f Usage %d Average %5.5f %s\n", $time{$k}, 
$usage{$k}, $time{$k}/$usage{$k}, $k;
}



May  7 17:50:55 nattytest kernel: [  127.490142] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.560084] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.610350] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.610932] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.740078] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.820071] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.870300] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  127.871050] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.000079] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.070070] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.140085] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.140960] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.260082] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.380072] end synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.430296] begin synchronize_net()
May  7 17:50:55 nattytest kernel: [  128.431135] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.550087] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.640057] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.710191] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.730085] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.880074] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  128.990123] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.060087] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.070128] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.220079] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.310070] end synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.370280] begin synchronize_net()
May  7 17:50:56 nattytest kernel: [  129.390099] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.540174] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.620063] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.690196] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.710098] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.850084] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.930070] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.980314] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  129.990225] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  130.110086] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  130.200078] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  130.270187] begin synchronize_net()
May  7 17:50:57 nattytest kernel: [  130.280159] end synchronize_net()
May  7 17:50:57 nattytest kernel: [  130.420133] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.500075] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.550344] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.550998] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.680075] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.750071] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.800333] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.801105] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  130.930071] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.010064] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.080171] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.090129] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.240078] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.320068] end synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.390216] begin synchronize_net()
May  7 17:50:58 nattytest kernel: [  131.403088] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.540081] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.610072] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.660314] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.661094] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.790076] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.860082] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.910294] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  131.911061] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.030075] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.110079] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.160319] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.161101] end synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.280075] begin synchronize_net()
May  7 17:50:59 nattytest kernel: [  132.400066] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.450321] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.451134] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.570078] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.650080] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.700288] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.701073] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.830066] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.910069] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.990128] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  132.990893] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  133.120076] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  133.200071] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  133.250313] begin synchronize_net()
May  7 17:51:00 nattytest kernel: [  133.251088] end synchronize_net()
May  7 17:51:00 nattytest kernel: [  133.370082] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.450147] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.500354] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.505508] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.630085] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.710090] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.760399] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.770396] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  133.920090] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.010083] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.060292] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.080082] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.220082] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.310064] end synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.380176] begin synchronize_net()
May  7 17:51:01 nattytest kernel: [  134.390127] end synchronize_net()
May  7 17:51:02 nattytest kernel: [  134.550205] begin synchronize_net()
May  7 17:51:02 nattytest kernel: [  134.630133] end synchronize_net()
May  7 17:51:02 nattytest kernel: [  134.830065] begin synchronize_net()
May  7 17:51:02 nattytest kernel: [  134.880091] end synchronize_net()
May  7 17:51:02 nattytest kernel: [  135.040194] begin synchronize_net()
May  7 17:51:02 nattytest kernel: [  135.120072] end synchronize_net()
May  7 17:51:02 nattytest kernel: [  135.190202] begin synchronize_net()
May  7 17:51:02 nattytest kernel: [  135.210084] end synchronize_net()
May  7 17:51:02 nattytest kernel: [  135.370081] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.440076] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.490331] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.491147] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.620079] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.700064] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.757709] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.770095] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.920101] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  135.990068] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.050068] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.050825] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.160081] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.240067] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.290431] begin synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.291020] end synchronize_net()
May  7 17:51:03 nattytest kernel: [  136.420094] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.500062] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.550388] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.550988] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.670101] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.750063] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.800297] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.801081] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  136.920070] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.000069] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.050252] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.051042] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.180076] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.260065] end synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.320191] begin synchronize_net()
May  7 17:51:04 nattytest kernel: [  137.340087] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.490082] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.570071] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.620314] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.621084] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.740083] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.830071] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.890264] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  137.910087] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.060074] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.140070] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.210094] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.210940] end synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.340089] begin synchronize_net()
May  7 17:51:05 nattytest kernel: [  138.410088] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.470306] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.471080] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.590082] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.670131] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.720268] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.721034] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.850077] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.920071] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.970305] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  138.971074] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  139.090082] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  139.170068] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  139.230297] begin synchronize_net()
May  7 17:51:06 nattytest kernel: [  139.231115] end synchronize_net()
May  7 17:51:06 nattytest kernel: [  139.350083] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.440057] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.510174] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.520124] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.680077] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.750087] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.840093] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.840867] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  139.970079] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.080094] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.130284] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.131056] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.260076] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.330076] end synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.380332] begin synchronize_net()
May  7 17:51:07 nattytest kernel: [  140.381364] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.510081] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.590074] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.650289] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.670086] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.800064] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.880073] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.930267] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  140.931048] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.050072] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.140067] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.190328] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.200119] end synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.360077] begin synchronize_net()
May  7 17:51:08 nattytest kernel: [  141.430074] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.480312] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.481110] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.600080] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.680081] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.730335] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.731136] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.860079] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.930070] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.980317] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  141.981114] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.110097] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.180074] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.230335] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.231113] end synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.350080] begin synchronize_net()
May  7 17:51:09 nattytest kernel: [  142.430087] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.480310] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.481084] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.600090] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.720091] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.770310] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.771130] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.900080] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  142.980070] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.060109] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.080079] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.230095] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.300044] end synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.350319] begin synchronize_net()
May  7 17:51:10 nattytest kernel: [  143.351119] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.470076] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.560083] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.620209] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.640090] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.780078] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.860076] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.910284] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  143.911142] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.030075] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.110085] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.160313] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.161104] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.280080] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.360074] end synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.410294] begin synchronize_net()
May  7 17:51:11 nattytest kernel: [  144.411096] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.530092] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.620072] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.680355] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.700081] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.860073] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.930075] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.980325] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  144.981155] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.110079] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.180084] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.230324] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.231098] end synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.350077] begin synchronize_net()
May  7 17:51:12 nattytest kernel: [  145.430081] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.480300] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.481050] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.610079] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.690071] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.750370] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.760378] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.900074] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  145.970077] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.020298] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.021548] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.150081] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.230073] end synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.299959] begin synchronize_net()
May  7 17:51:13 nattytest kernel: [  146.310076] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.440080] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.520065] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.580285] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.590266] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.750063] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.830084] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.890233] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  146.910088] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  147.060081] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  147.140061] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  147.200277] begin synchronize_net()
May  7 17:51:14 nattytest kernel: [  147.220089] end synchronize_net()
May  7 17:51:14 nattytest kernel: [  147.360081] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.450084] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.510283] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.530135] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.680075] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.760066] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.830172] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  147.870065] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.000075] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.070065] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.120327] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.121099] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.240073] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.320061] end synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.370253] begin synchronize_net()
May  7 17:51:15 nattytest kernel: [  148.371001] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.500082] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.580073] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.650192] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.670095] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.820077] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.910058] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.980223] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  148.990280] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  149.130076] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  149.220104] end synchronize_net()
May  7 17:51:16 nattytest kernel: [  149.270373] begin synchronize_net()
May  7 17:51:16 nattytest kernel: [  149.300076] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.450078] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.530063] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.580337] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.581173] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.700072] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.780071] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.830307] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.831075] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  149.960083] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.030067] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.080323] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.081113] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.200076] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.280065] end synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.330341] begin synchronize_net()
May  7 17:51:17 nattytest kernel: [  150.331164] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.460081] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.540064] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.600267] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.620084] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.780067] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.850065] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.900315] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  150.901093] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.020083] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.100069] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.150282] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.151067] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.280079] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.360070] end synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.410316] begin synchronize_net()
May  7 17:51:18 nattytest kernel: [  151.411133] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.540178] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.610071] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.660313] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.661125] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.780072] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.860074] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.910295] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  151.911124] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.040109] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.110066] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.160295] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.161049] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.280073] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.360085] end synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.410306] begin synchronize_net()
May  7 17:51:19 nattytest kernel: [  152.411060] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.530075] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.610064] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.660270] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.661284] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.830095] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.910065] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.960314] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  152.961131] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.090076] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.160083] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.210293] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.211113] end synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.340081] begin synchronize_net()
May  7 17:51:20 nattytest kernel: [  153.420067] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.470317] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.471164] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.590082] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.680063] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.740238] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.750127] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.900077] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  153.980077] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.080091] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.080872] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.210077] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.290061] end synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.340327] begin synchronize_net()
May  7 17:51:21 nattytest kernel: [  154.360089] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.510085] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.580075] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.630300] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.631065] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.770074] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.880081] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.940349] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  154.960085] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  155.130080] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  155.200079] end synchronize_net()
May  7 17:51:22 nattytest kernel: [  155.250334] begin synchronize_net()
May  7 17:51:22 nattytest kernel: [  155.251105] end synchronize_net()




