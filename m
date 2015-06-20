From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2] bpf: BPF based latency tracing
Date: Sat, 20 Jun 2015 10:14:19 +0200
Message-ID: <558520DB.6000904@iogearbox.net>
References: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434722444-10200-1-git-send-email-daniel.wagner@bmw-carit.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2015 04:00 PM, Daniel Wagner wrote:
> BPF offers another way to generate latency histograms. We attach
> kprobes at trace_preempt_off and trace_preempt_on and calculate the
> time it takes to from seeing the off/on transition.
>
> The first array is used to store the start time stamp. The key is the
> CPU id. The second array stores the log2(time diff). We need to use
> static allocation here (array and not hash tables). The kprobes
> hooking into trace_preempt_on|off should not calling any dynamic
> memory allocation or free path. We need to avoid recursivly
> getting called. Besides that, it reduces jitter in the measurement.
>
> CPU 0
>        latency        : count     distribution
>         1 -> 1        : 0        |                                        |
>         2 -> 3        : 0        |                                        |
>         4 -> 7        : 0        |                                        |
>         8 -> 15       : 0        |                                        |
>        16 -> 31       : 0        |                                        |
>        32 -> 63       : 0        |                                        |
>        64 -> 127      : 0        |                                        |
>       128 -> 255      : 0        |                                        |
>       256 -> 511      : 0        |                                        |
>       512 -> 1023     : 0        |                                        |
>      1024 -> 2047     : 0        |                                        |
>      2048 -> 4095     : 166723   |*************************************** |
>      4096 -> 8191     : 19870    |***                                     |
>      8192 -> 16383    : 6324     |                                        |
>     16384 -> 32767    : 1098     |                                        |
>     32768 -> 65535    : 190      |                                        |
>     65536 -> 131071   : 179      |                                        |
>    131072 -> 262143   : 18       |                                        |
>    262144 -> 524287   : 4        |                                        |
>    524288 -> 1048575  : 1363     |                                        |
> CPU 1
>        latency        : count     distribution
>         1 -> 1        : 0        |                                        |
>         2 -> 3        : 0        |                                        |
>         4 -> 7        : 0        |                                        |
>         8 -> 15       : 0        |                                        |
>        16 -> 31       : 0        |                                        |
>        32 -> 63       : 0        |                                        |
>        64 -> 127      : 0        |                                        |
>       128 -> 255      : 0        |                                        |
>       256 -> 511      : 0        |                                        |
>       512 -> 1023     : 0        |                                        |
>      1024 -> 2047     : 0        |                                        |
>      2048 -> 4095     : 114042   |*************************************** |
>      4096 -> 8191     : 9587     |**                                      |
>      8192 -> 16383    : 4140     |                                        |
>     16384 -> 32767    : 673      |                                        |
>     32768 -> 65535    : 179      |                                        |
>     65536 -> 131071   : 29       |                                        |
>    131072 -> 262143   : 4        |                                        |
>    262144 -> 524287   : 1        |                                        |
>    524288 -> 1048575  : 364      |                                        |
> CPU 2
>        latency        : count     distribution
>         1 -> 1        : 0        |                                        |
>         2 -> 3        : 0        |                                        |
>         4 -> 7        : 0        |                                        |
>         8 -> 15       : 0        |                                        |
>        16 -> 31       : 0        |                                        |
>        32 -> 63       : 0        |                                        |
>        64 -> 127      : 0        |                                        |
>       128 -> 255      : 0        |                                        |
>       256 -> 511      : 0        |                                        |
>       512 -> 1023     : 0        |                                        |
>      1024 -> 2047     : 0        |                                        |
>      2048 -> 4095     : 40147    |*************************************** |
>      4096 -> 8191     : 2300     |*                                       |
>      8192 -> 16383    : 828      |                                        |
>     16384 -> 32767    : 178      |                                        |
>     32768 -> 65535    : 59       |                                        |
>     65536 -> 131071   : 2        |                                        |
>    131072 -> 262143   : 0        |                                        |
>    262144 -> 524287   : 1        |                                        |
>    524288 -> 1048575  : 174      |                                        |
> CPU 3
>        latency        : count     distribution
>         1 -> 1        : 0        |                                        |
>         2 -> 3        : 0        |                                        |
>         4 -> 7        : 0        |                                        |
>         8 -> 15       : 0        |                                        |
>        16 -> 31       : 0        |                                        |
>        32 -> 63       : 0        |                                        |
>        64 -> 127      : 0        |                                        |
>       128 -> 255      : 0        |                                        |
>       256 -> 511      : 0        |                                        |
>       512 -> 1023     : 0        |                                        |
>      1024 -> 2047     : 0        |                                        |
>      2048 -> 4095     : 29626    |*************************************** |
>      4096 -> 8191     : 2704     |**                                      |
>      8192 -> 16383    : 1090     |                                        |
>     16384 -> 32767    : 160      |                                        |
>     32768 -> 65535    : 72       |                                        |
>     65536 -> 131071   : 32       |                                        |
>    131072 -> 262143   : 26       |                                        |
>    262144 -> 524287   : 12       |                                        |
>    524288 -> 1048575  : 298      |                                        |
>
> All this is based on the trace3 examples written by
> Alexei Starovoitov <ast@plumgrid.com>.
>
> Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>

I think it would be useful to perhaps have two options:

1) User specifies a specific CPU and gets one such an output above.
2) Summary view, i.e. to have the samples of each CPU for comparison
    next to each other in columns and maybe the histogram view a bit
    more compressed (perhaps summary of all CPUs).

Anyway, it's sample code people can go with and modify individually.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
