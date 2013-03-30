From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Sat, 30 Mar 2013 07:44:34 -0700
Message-ID: <1364654674.5113.87.camel@edumazet-glaptop>
References: <CD7BAAE6.79D5%blourdel@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benoit Lourdelet <blourdel@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:49920 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab3C3Oog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 10:44:36 -0400
Received: by mail-pb0-f42.google.com with SMTP id xb4so599670pbc.29
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 07:44:36 -0700 (PDT)
In-Reply-To: <CD7BAAE6.79D5%blourdel@juniper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-30 at 10:09 +0000, Benoit Lourdelet wrote:
> Hello,
> 
> Here are my tests  of the last patches on 3 different platforms all
> running 3.8.5 :
> 
> Time are in seconds :
> 
> 8x 3.7Ghz virtual cores
> 
> # veth 	create 	delete
> 1000 	14 	18
> 2000 	39 	56
> 5000 	256 	161
> 10000 	1200 	399
> 
> 
> 8x 3.2Ghz virtual cores
> 
> # veth 	create 	delete
> 
> 1000 	19 	40
> 2000 	118 	66
> 5000 	305 	251
> 
> 
> 
> 32x 2Ghz virtual cores , 2 sockets
> # veth 	create 	delete
> 1000 	35 	86
> 
> 2000 	120 	90
> 
> 5000 	724 	245
> 
> 
> Compared to initial iproute2 performance on this 32 virtual core  system :
> 5000 1143  1185
> 
> 
> 
> "perf record" for creation of 5000 veth on the 32 core system :
> 
> # captured on: Fri Mar 29 14:03:35 2013
> # hostname : ieng-serv06
> # os release : 3.8.5
> # perf version : 3.8.5
> # arch : x86_64
> # nrcpus online : 32
> # nrcpus avail : 32
> # cpudesc : Intel(R) Xeon(R) CPU E5-2650 0 @ 2.00GHz
> # cpuid : GenuineIntel,6,45,7
> # total memory : 264124548 kB
> # cmdline : /usr/src/linux-3.8.5/tools/perf/perf record -a ./test3.script
> # event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 =
> 0x0, excl_usr = 0, excl_kern = 0, excl_host = 0, excl_guest = 1,
> precise_ip = 0, id = { 36, 37, 38, 39, 40, 41, 42,
> # HEADER_CPU_TOPOLOGY info available, use -I to display
> # HEADER_NUMA_TOPOLOGY info available, use -I to display
> # pmu mappings: cpu = 4, software = 1, uncore_pcu = 15, tracepoint = 2,
> uncore_imc_0 = 17, uncore_imc_1 = 18, uncore_imc_2 = 19, uncore_imc_3 =
> 20, uncore_qpi_0 = 21, uncore_qpi_1 = 22, unco
> # ========
> #
> # Samples: 9M of event 'cycles'
> # Event count (approx.): 2894480238483
> #
> # Overhead          Command                  Shared Object
>                           Symbol
> # ........  ...............  .............................
> ...............................................
> #
>     15.17%             sudo  [kernel.kallsyms]              [k]
> snmp_fold_field    
>      5.94%             sudo  libc-2.15.so                   [.]
> 0x00000000000802cd 
>      5.64%             sudo  [kernel.kallsyms]              [k]
> find_next_bit      
>      3.21%             init  libnih.so.1.0.0                [.]
> nih_list_add_after 
>      2.12%          swapper  [kernel.kallsyms]              [k] intel_idle
>                    
>      1.94%             init  [kernel.kallsyms]              [k] page_fault
>                    
>      1.93%              sed  libc-2.15.so                   [.]
> 0x00000000000a1368 
>      1.93%             sudo  [kernel.kallsyms]              [k]
> rtnl_fill_ifinfo   
>      1.92%             sudo  [veth]                         [k]
> veth_get_stats64   
>      1.78%             sudo  [kernel.kallsyms]              [k] memcpy
>                    
>      1.53%          ifquery  libc-2.15.so                   [.]
> 0x000000000007f52b 
>      1.24%             init  libc-2.15.so                   [.]
> 0x000000000008918f 
>      1.05%             sudo  [kernel.kallsyms]              [k]
> inet6_fill_ifla6_attrs
>      0.98%             init  [kernel.kallsyms]              [k]
> copy_pte_range     
>      0.88%       irqbalance  libc-2.15.so                   [.]
> 0x00000000000802cd 
>      0.85%             sudo  [kernel.kallsyms]              [k] memset
>                    
>      0.72%              sed  ld-2.15.so                     [.]
> 0x000000000000a226 
>      0.68%          ifquery  ld-2.15.so                     [.]
> 0x00000000000165a0 
>      0.64%             init  libnih.so.1.0.0                [.]
> nih_tree_next_post_full
>      0.61%  bridge-network-  libc-2.15.so                   [.]
> 0x0000000000131e2a 
>      0.59%             init  [kernel.kallsyms]              [k] do_wp_page
>                    
>      0.59%          ifquery  [kernel.kallsyms]              [k] page_fault
>                    
>      0.54%              sed  [kernel.kallsyms]              [k] page_fault
>                    
> 
> 
> 
> 
> Regards
> 
> Benoit
> 
> 
> 
> 

This means lxc-start does the same thing than ip :

It fetches the whole device list.

You could strace it to have a confirmation.
