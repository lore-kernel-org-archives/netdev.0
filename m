From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Wed, 4 Dec 2013 01:30:09 +0200
Message-ID: <CAJZOPZKg0UMmdknLJCgNo3cTFmszASLPYYJnB7g9h4M64xMy8w@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35768 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab3LCXaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 18:30:10 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so21148687pde.14
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 15:30:09 -0800 (PST)
In-Reply-To: <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 4, 2013 at 1:10 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Dec 3, 2013 at 11:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2013-12-03 at 16:50 -0500, David Miller wrote:
>>
>>> At this point I would use drop monitor to figure out in what context
>>> packets are being dropped on the floor.  There are scripts provided
>>> with the perf tool to utilize it.
>>
>> Most easy way is to do :
>>
>> perf record -e skb:kfree_skb -a -g sleep 10
>> perf report
>
> $ ./perf record -e skb:kfree_skb -g -a sleep 10
> $ ./perf report -i perf.data
>
>
> Samples: 883K of event 'skb:kfree_skb', Event count (approx.): 883406
> +  97.13%          swapper  [kernel.kallsyms]  [k] net_tx_action
> +   1.53%            iperf  [kernel.kallsyms]  [k] net_tx_action
> +   1.03%             perf  [kernel.kallsyms]  [k] net_tx_action
> +   0.27%      ksoftirqd/7  [kernel.kallsyms]  [k] net_tx_action
> +   0.03%      kworker/7:1  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%          rpcbind  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%          swapper  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%            sleep  [kernel.kallsyms]  [k] net_tx_action
> +   0.00%  hald-addon-acpi  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%            iperf  [kernel.kallsyms]  [k] kfree_skb
> +   0.00%             perf  [kernel.kallsyms]  [k] kfree_skb

I added proper sorting (thanks Rick), here's the passive side report

-  99.99%  [kernel.kallsyms]  [k] net_tx_action

                    ?
   - net_tx_action

                    ?
      - 59.20% __libc_recv

                    ?
           100.00% 0

                    ?
      - 35.61% __write_nocancel

                    ?
         - 100.00% run_builtin

                    ?
              main

                    ?
              __libc_start_main

                    ?
      - 2.60% __poll

                    ?
         - 92.62% run_builtin

                    ?
              main

                    ?
              __libc_start_main

                    ?
         - 7.38% 0x7f2d4c4adfd4

                    ?
              0x626370523a32333a

                    ?
      - 1.86% cmd_record

                    ?
           run_builtin

                    ?
           main

                    ?
           __libc_start_main

                    ?
-   0.01%  [kernel.kallsyms]  [k] kfree_skb

                    ?
   - kfree_skb

                    ?
      - 50.00% __connect_nocancel

                    ?
           0x64697063612f6e75

                    ?
      - 33.33% __libc_recv

                    ?
           0

                    ?
      - 16.67% __write_nocancel

                    ?
           run_builtin

                    ?
           main

                    ?
           __libc_start_main

and the active side report


100.00%  [kernel.kallsyms]  [k] net_tx_action

                  ?
   - net_tx_action

                    ?
      - 76.91% __write_nocancel

                    ?
         - 100.00% run_builtin

                    ?
              main

                    ?
              __libc_start_main

                    ?
        15.92% 0x37cc60e4ed

                    ?
      - 2.69% __poll

                    ?
           run_builtin

                    ?
           main

                    ?
           __libc_start_main

                    ?
      - 1.92% cmd_record

                    ?
           run_builtin

                    ?
           main

                    ?
           __libc_start_main

                    ?
      - 1.66% pthread_cond_signal@@GLIBC_2.
3.2

                    ?
           0x10000

                    ?
      - 0.52% perf_header__has_feat

                    ?
         - 73.28% run_builtin

                    ?
              main

                    ?
              __libc_start_main

                    ?
         - 26.72% cmd_record

                    ?
              run_builtin

                    ?
              main

                    ?
              __libc_start_main

                    ?
-   0.00%  [kernel.kallsyms]  [k] kfree_skb

                    ?
   - kfree_skb

                    ?
      - 100.00% __GI___connect_internal

                    ?
         - 50.00% get_mapping

                    ?
              __nscd_get_map_ref

                    ?
           50.00% __nscd_open_socket




>
>
>
>>
>>
>>
