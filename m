From: "cristian.bercaru@freescale.com" <cristian.bercaru@freescale.com>
Subject: atomic operations bottleneck in the IPv6 stack
Date: Wed, 10 Dec 2014 16:56:38 +0000
Message-ID: <SN2PR03MB079DA7799199CD98C52B5389E620@SN2PR03MB079.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "R89243@freescale.com" <R89243@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	"Razvan.Ungureanu@freescale.com" <Razvan.Ungureanu@freescale.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0108.outbound.protection.outlook.com ([207.46.100.108]:40192
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755924AbaLJRMR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 12:12:17 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello!

I am running IPv6 forwarding cases and I get worse performance with 24 cores than with 16 cores.

Test scenario:
10G --->[T4240]---> 10G
- platform: Freescale T4240, powerpc, 24 x e6500 64-bit cores (I can disable 8 of them from uboot)
- input type: raw IPv6 78-byte packets
- input rate: 10Gbps
- forwarding/output rate: 16 cores - 3.3 Gbps; 24 cores - 2.4 Gbps

Doing a perf with "record -C 1 -c 10000000 -a sleep 120" record I observe
- on 16 cores
# Overhead      Command      Shared Object       Symbol
    19.59%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_pol_route                      
    18.07%  ksoftirqd/1  [kernel.kallsyms]  [k] .dst_release                        
     5.09%  ksoftirqd/1  [kernel.kallsyms]  [k] .__netif_receive_skb_core           
- on 24 cores
    34.98%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_pol_route                      
    31.86%  ksoftirqd/1  [kernel.kallsyms]  [k] .dst_release                        
     3.76%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_finish_output2                 
     2.72%  ksoftirqd/1  [kernel.kallsyms]  [k] .__netif_receive_skb_core           

I de-inlined 'atomic_dec_return' and 'atomic_inc' that are used by 'ip6_pol_route' and 'dst_release' and I get
- on 16 cores
    17.26%  ksoftirqd/1  [kernel.kallsyms]  [k] .atomic_dec_return_noinline         
    13.45%  ksoftirqd/1  [kernel.kallsyms]  [k] .atomic_inc_noinline                
     5.53%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_pol_route                      
     5.02%  ksoftirqd/1  [kernel.kallsyms]  [k] .__netif_receive_skb_core           
- on 24 cores
    32.45%  ksoftirqd/1  [kernel.kallsyms]  [k] .atomic_dec_return_noinline         
    30.56%  ksoftirqd/1  [kernel.kallsyms]  [k] .atomic_inc_noinline                
     4.71%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_pol_route                      
     3.57%  ksoftirqd/1  [kernel.kallsyms]  [k] .ip6_finish_output2                 

It seems to me that the atomic operations on the IPv6 forwarding path are a bottleneck and they are not scalable with the number of cores. Am I right? What improvements can be brought to the IPv6 kernel code to make it less dependent of atomic operations/variables?

Thank you,
Cristian Bercaru
