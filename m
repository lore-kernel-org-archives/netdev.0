From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 17:31:35 -0800
Message-ID: <565F9B77.60102@hpe.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Sowmini Varadhan' <sowmini.varadhan@oracle.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/02/2015 03:56 AM, David Laight wrote:
> From: Sowmini Varadhan
>> Sent: 01 December 2015 18:37
> ...
>> I was using esp-null merely to not have the crypto itself perturb
>> the numbers (i.e., just focus on the s/w overhead for now), but here
>> are the numbers for the stock linux kernel stack
>>                  Gbps  peak cpu util
>> esp-null         1.8   71%
>> aes-gcm-c-256    1.6   79%
>> aes-ccm-a-128    0.7   96%
>>
>> That trend made me think that if we can get esp-null to be as close
>> as possible to GSO/GRO, the rest will follow closely behind.
>
> That's not how I read those figures.
> They imply to me that there is a massive cost for the actual encryption
> (particularly for aes-ccm-a-128) - so whatever you do to the esp-null
> case won't help.
>

To build on the whole "importance of normalizing throughput and CPU 
utilization in some way" theme, the following are some non-IPSec netperf 
TCP_STREAM runs between a pair of 2xIntel E5-2603 v3 systems using 
Broadcom BCM57810-based NICs, 4.2.0-19 kernel, 7.10.72 firmware and 
bnx2x driver version 1.710.51-0:


root@htx-scale300-258:~# ./take_numbers.sh
Baseline
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
10.12.49.1 () port 0 AF_INET : +/-2.500% @ 99% conf.  : demo : cpu bind
Throughput Local Local   Local   Remote Remote  Remote  Throughput Local 
      Remote
            CPU   Service Peak    CPU    Service Peak    Confidence CPU 
        CPU
            Util  Demand  Per CPU Util   Demand  Per CPU Width (%) 
Confidence Confidence
            %             Util %  %              Util % 
Width (%)  Width (%)
9414.11    1.87  0.195   26.54   3.70   0.387   45.42   0.002      7.073 
      1.276
Disable TSO/GSO
5651.25    8.36  1.454   100.00  2.46   0.428   30.35   1.093      1.101 
      4.889
Disable tx CKO
5287.69    8.46  1.573   100.00  2.34   0.435   29.66   0.428      7.710 
      3.518
Disable remote LRO/GRO
4148.76    8.32  1.971   99.97   5.95   1.409   71.98   3.656      0.735 
      3.491
Disable remote rx CKO
4204.49    8.31  1.942   100.00  6.68   1.563   82.05   2.015      0.437 
      4.921

You can see that as the offloads are disabled, the service demands (usec 
of CPU time consumed systemwide per KB of data transferred) go up, and 
until one hits a bottleneck (eg one of the CPUs pegs at 100%), go up 
faster than the throughputs go down.

To aid in reproducibility those tests were with irqbalance disabled, all 
the IRQs for the NICs pointed at CPU 0, netperf/netserver bound to CPU 
0, and the power management set to static high performance.

Assuming I've created a "matching" ipsec.conf, here is what I see with 
esp=null-null on the TCP_STREAM test - again, keeping all the binding in 
place etc:

3077.37    8.01  2.560   97.78   8.21   2.625   99.41   4.869      1.876 
      0.955

You can see that even with the null-null, there is a rather large 
increase in service demand.

And this is what I see when I run netperf TCP_RR (first is without 
ipsec, second is with. I didn't ask for confidence intervals this time 
around and I didn't try to tweak interrupt coalescing settings)

# HDR="-P 1";for i in 10.12.49.1 192.168.0.2; do ./netperf -H $i -t 
TCP_RR -c -C -l 30 -T 0 $HDR; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to 10.12.49.1 () port 0 AF_INET : demo : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      30.00   30419.75  1.72   1.68   6.783   6.617
16384  87380
16384  87380  1       1      30.00   20711.39  2.15   2.05   12.450  11.882
16384  87380

The service demand increases ~83% on the netperf side and almost 80% on 
the netserver side.  That is pure "effective" path-length increase.

happy benchmarking,

rick jones

PS - the netperf commands were varations on this theme:
./netperf -P 0 -T 0 -H 10.12.49.1 -c -C -l 30 -i 30,3 -- -O 
throughput,local_cpu_util,local_sd,local_cpu_peak_util,remote_cpu_util,remote_sd,remote_cpu_peak_util,throughput_confid,local_cpu_confid,remote_cpu_confid
altering IP address or test as appropriate.  -P 0 disables printing the 
test banner/headers.  -T 0 binds netperf and netserver to CPU0 on their 
respective systems.  -H sets the destination, -c and -C ask for local 
and remote CPU measurements respectively.  -l 30 says each test 
iteration should be 30 seconds long and -i 30,3 says to run at least 
three iterations and no more than 30 when trying to hit the confidence 
interval - by default 99% confident the average reported is within +/- 
2.5% of the "actual" average.  The -O stuff is selecting specific values 
to be emitted.
