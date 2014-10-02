From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_core: Disable BF when write combining
 is not available
Date: Thu, 2 Oct 2014 17:37:58 +0300
Message-ID: <542D6346.7070702@mellanox.com>
References: <1412175282-25212-1-git-send-email-ogerlitz@mellanox.com>	<1412175282-25212-3-git-send-email-ogerlitz@mellanox.com> <CAADnVQJ7uGj1TjV=Bv107TEWmVRodnff1sKFROEdpZJrZ5+R4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moshe Lazer <moshel@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Ancel <amira@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:35634 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753540AbaJBOiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:38:05 -0400
In-Reply-To: <CAADnVQJ7uGj1TjV=Bv107TEWmVRodnff1sKFROEdpZJrZ5+R4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/1/2014 7:52 PM, Alexei Starovoitov wrote:
> On Wed, Oct 1, 2014 at 7:54 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> From: Moshe Lazer <moshel@mellanox.com>
>>
>> In mlx4 for better latency, we write send descriptors to a write-combining
>> (WC) mapped buffer instead of ringing a doorbell and having the HW fetch
>> the descriptor from system memory.
>>
>> However, if write-combining is not supported on the host, then we
>> obtain better latency by using the doorbell-ring/HW fetch mechanism.
>>
>> The mechanism that uses WC is called Blue-Flame (BF). BF is beneficial
>> only when the system supports write combining. When the BF buffer is
>> mapped as a write-combine buffer, the HCA receives data in multi-word
>> bursts. However, if the BF buffer is mapped only as non-cached, the
>> HCA receives data in individual dword chunks, which harms performance.
>>
>> Therefore, disable blueflame when write combining is not available.
> curious, what numbers you're seeing:
> - [1] bf=on with wc
> - [2] bf=on without wc
> - [3] bf=off and doorbell
> they will help to justify this change.

Sure, see below:

The 1st set of results was obtained from running latency test
with the HCA being passthrough-ed into VM running over KVM
host -- so WC isn't available.

The problematic range is 32-128B, for example with 128 bytes
message, using BF has latency of 1.47us and no usage of BF
only 1us. When WC isn't really available every write of 64B
would actually translate into 8 writes of 8 bytes which obviously
hurts the latency.

# /usr/bin/taskset -c 0 ib_write_lat -d mlx4_0 -i 1  -F -a -n 1000000

[2] BF on without WC
  #bytes #iterations    t_min[usec]    t_max[usec] t_typical[usec]
  2       1000000          0.74           186.16       0.79
  4       1000000          0.70           103.62       0.78
  8       1000000          0.74           77.02        0.78
  16      1000000          0.65           640.75       0.86
  32      1000000          0.90           134.63       0.96
  64      1000000          1.05           808.52       1.11
  128     1000000          1.05           405.58       1.47

[3] BF off and using doorbell
  #bytes #iterations    t_min[usec]    t_max[usec] t_typical[usec]
  2       1000000          0.85           107.29       0.89
  4       1000000          0.84           705.90       0.89
  8       1000000          0.85           457.72       0.89
  16      1000000          0.85           1041.43      0.90
  32      1000000          0.88           773.67       0.92
  64      1000000          0.90           82.70        0.93
  128     1000000          0.96           78.20        1.00


The 2nd set of results was obtained from running latency test
over bare-metal host where WC is available. Clearly we gain
better latency when BF is used vs. the doorbell base (around 300ns
of improvement, where there are systems which this climbs to 500ns).

# /usr/bin/taskset -c 0 ib_write_lat -d mlx4_0 -i 1  -F -a -n 1000000

[1] BF on, WC available
#bytes #iterations    t_min[usec]    t_max[usec] t_typical[usec]
2       1000000          0.74           131.62       0.79
4       1000000          0.74           134.51       0.79
8       1000000          0.74           154.30       0.79
16      1000000          0.74           1437.57      0.79
32      1000000          0.79           138.23       0.83
64      1000000          0.82           135.86       0.85
128     1000000          0.94           131.11       0.98

[3] BF off and using doorbell
#bytes #iterations    t_min[usec]    t_max[usec] t_typical[usec]
2       1000000          1.05           137.55       1.10
4       1000000          1.04           422.50       1.10
8       1000000          1.05           141.26       1.10
16      1000000          1.06           1261.99      1.11
32      1000000          1.09           141.47       1.14
64      1000000          1.11           435.44       1.16
128     1000000          1.22           212.19       1.27
