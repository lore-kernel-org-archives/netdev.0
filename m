From: Hector Palacios <hector.palacios@digi.com>
Subject: Re: FEC performance degradation on iMX28 with forced link media
Date: Mon, 25 Nov 2013 09:56:04 +0100
Message-ID: <529310A4.70906@digi.com>
References: <528F50AE.3030804@digi.com> <201311240540.23813.marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta8.messagelabs.com ([216.82.243.209]:19983 "EHLO
	mail1.bemta8.messagelabs.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753788Ab3KYJDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 04:03:02 -0500
In-Reply-To: <201311240540.23813.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2013 05:40 AM, Marek Vasut wrote:
> Hi Hector,
>
>> Hello,
>>
>> When forcing the Ethernet PHY link media with ethtool/mii-tool on the
>> i.MX28 I've seen important performance degradation as the packet size
>> increases.
>>
>> On the target:
>> # mii-tool eth0 -F 10baseT-FD
>> # netpipe
>>
>> On the host:
>> # netpipe -h <target-ip> -n 1
>> ...
>> 44:    1024 bytes      1 times -->      6.56 Mbps in    1191.00 usec
>> 45:    1027 bytes      1 times -->      6.56 Mbps in    1193.52 usec
>> 46:    1533 bytes      1 times -->      0.60 Mbps in   19600.54 usec
>> 47:    1536 bytes      1 times -->      0.46 Mbps in   25262.52 usec
>> 48:    1539 bytes      1 times -->      0.57 Mbps in   20745.54 usec
>> 49:    2045 bytes      1 times -->      0.74 Mbps in   20971.95 usec
>> ...
>> On loop 46, as the packet size exceeds the MTU (1500) performance falls
>> from 6.56Mbps to 0.60Mbps.
>>
>> Going back to 100baseTX-FD, but still forced (autonegotiation off), the
>> same occurs: On the target:
>> # mii-tool eth0 -F 100baseTx-FD
>> # netpipe
>>
>> On the host:
>> # netpipe -h <target-ip> -n 1
>> ...
>> 58:    6141 bytes      1 times -->     39.74 Mbps in    1179.03 usec
>> 59:    6144 bytes      1 times -->     41.83 Mbps in    1120.51 usec
>> 60:    6147 bytes      1 times -->     41.39 Mbps in    1133.03 usec
>> 61:    8189 bytes      1 times -->      6.36 Mbps in    9823.94 usec
>> 62:    8192 bytes      1 times -->      6.56 Mbps in    9521.46 usec
>> 63:    8195 bytes      1 times -->      6.56 Mbps in    9532.99 usec
>> ...
>> only this time it happens with a larger packet size (8189 bytes).
>>
>> With autonegotiation on, performance is ok and does not suffer these drops.
>>
>> I've reproduced this on the mx28evk board but it also happens in my
>> hardware, with different PHY on v3.10.
>> I also tried on an old v2.6.35 kernel and the issue was reproducible as
>> well, though it happened with larger packet sizes than it happens with
>> v3.10:
>> ...
>> 75:   32771 bytes      1 times -->     49.64 Mbps in    5036.50 usec
>> 76:   49149 bytes      1 times -->     46.18 Mbps in    8120.48 usec
>> 77:   49152 bytes      1 times -->     43.30 Mbps in    8660.46 usec
>> 78:   49155 bytes      1 times -->     40.10 Mbps in    9351.46 usec
>> 79:   65533 bytes      1 times -->      2.03 Mbps in  246061.04 usec
>> 80:   65536 bytes      1 times -->      2.21 Mbps in  226516.50 usec
>> 81:   65539 bytes      1 times -->      1.45 Mbps in  344196.46 usec
>> ...
>>
>> Could there be any issue with packet fragmentation?
>> I tried the same on imx6sabresd but here the issue is not reproducible. I
>> don't know if the higher CPU frequency might be hiding the problem,
>> though.
>>
>> Any idea about what can make the difference between forcing media vs
>> autonegotiation?
>
> Let me ask, this might be unrelated, but I will still go ahead. Do you also
> observe packetloss? You can check with iperf:
>
> On host machine (PC): iperf -u -s -l 4M -i 60
> On target: iperf -u -c <hostip> -t 3600 -B 100M -i 60

Yes, with forced 100baseTX-FD there is a small packet loss:

[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-60.0 sec   339 MBytes  47.4 Mbits/sec   0.075 ms   61/242070 (0.025%)
[  3] 60.0-120.0 sec   339 MBytes  47.4 Mbits/sec   0.209 ms   45/242122 (0.019%)
[  3] 120.0-180.0 sec   339 MBytes  47.5 Mbits/sec   0.084 ms   70/242237 (0.029%)
[  3] 180.0-240.0 sec   339 MBytes  47.4 Mbits/sec   0.030 ms   80/241993 (0.033%)
[  3] 240.0-300.0 sec   340 MBytes  47.5 Mbits/sec   0.042 ms  111/242363 (0.046%)
[  3] 300.0-360.0 sec   339 MBytes  47.4 Mbits/sec   0.038 ms   93/241972 (0.038%)
[  3] 360.0-420.0 sec   339 MBytes  47.5 Mbits/sec   0.030 ms   78/242214 (0.032%)
[  3] 420.0-480.0 sec   339 MBytes  47.4 Mbits/sec   0.090 ms   77/241980 (0.032%)
[  3] 480.0-540.0 sec   339 MBytes  47.4 Mbits/sec   0.025 ms  125/242058 (0.052%)

With autonegotiated 100baseTX-FD, there is not:

[ ID] Interval       Transfer     Bandwidth        Jitter   Lost/Total Datagrams
[  3]  0.0-60.0 sec   336 MBytes  47.0 Mbits/sec   0.038 ms    0/239673 (0%)
[  3] 60.0-120.0 sec   337 MBytes  47.1 Mbits/sec   0.078 ms    0/240353 (0%)
[  3] 120.0-180.0 sec   337 MBytes  47.1 Mbits/sec   0.047 ms    0/240054 (0%)
[  3] 180.0-240.0 sec   337 MBytes  47.1 Mbits/sec   0.038 ms    0/240195 (0%)
[  3] 240.0-300.0 sec   337 MBytes  47.1 Mbits/sec   0.038 ms    0/240109 (0%)
[  3] 300.0-360.0 sec   337 MBytes  47.1 Mbits/sec   0.035 ms    0/240101 (0%)
[  3] 360.0-420.0 sec   337 MBytes  47.0 Mbits/sec   0.031 ms    0/240032 (0%)
[  3] 420.0-480.0 sec   336 MBytes  47.0 Mbits/sec   0.036 ms    0/239912 (0%)


Best regards,
--
Hector Palacios
