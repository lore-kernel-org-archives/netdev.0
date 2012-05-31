From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Thu, 31 May 2012 15:10:11 +0200
Message-ID: <1338469811.2760.1345.camel@edumazet-glaptop>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
	 <4FC53353.2050801@uclouvain.be> <1338367497.7747.72.camel@localhost>
	 <4FC5DFF4.1020604@uclouvain.be> <1338417630.7747.156.camel@localhost>
	 <1338468693.7747.162.camel@localhost>
	 <1338469100.2760.1341.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53085 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab2EaNKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 09:10:16 -0400
Received: by bkcji2 with SMTP id ji2so813455bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 06:10:15 -0700 (PDT)
In-Reply-To: <1338469100.2760.1341.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 14:58 +0200, Eric Dumazet wrote:

> 
> How many different IP addresses are used by your generator ?
> 
> Or maybe you disabled IP route cache ?

With no route cache problems, I sustain 4 us per SYN packet, if all load
serviced by one cpu only.

perf profile is : (I have CONFIG_DEBUG_PAGEALLOC=y)

+   9,55%  ksoftirqd/0  [kernel.kallsyms]  [k] sha_transform
+   3,56%  ksoftirqd/0  [kernel.kallsyms]  [k] ip_route_input_common
+   3,40%  ksoftirqd/0  [kernel.kallsyms]  [k] __ip_route_output_key
+   3,28%  ksoftirqd/0  [kernel.kallsyms]  [k] __inet_lookup_established
+   3,13%  ksoftirqd/0  [kernel.kallsyms]  [k] tg3_poll_work
+   2,68%  ksoftirqd/0  [kernel.kallsyms]  [k] tcp_make_synack
+   2,67%  ksoftirqd/0  [kernel.kallsyms]  [k] __netif_receive_skb
+   2,51%  ksoftirqd/0  [kernel.kallsyms]  [k] ipt_do_table
+   2,17%  ksoftirqd/0  [kernel.kallsyms]  [k] memcpy
+   1,99%  ksoftirqd/0  [kernel.kallsyms]  [k] kernel_map_pages
+   1,96%  ksoftirqd/0  [kernel.kallsyms]  [k] inet_csk_search_req
+   1,69%  ksoftirqd/0  [kernel.kallsyms]  [k] tg3_recycle_rx.isra.36
+   1,63%  ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_free
+   1,61%  ksoftirqd/0  [kernel.kallsyms]  [k] copy_user_generic_string
+   1,49%  ksoftirqd/0  [kernel.kallsyms]  [k] kmem_cache_alloc
+   1,47%  ksoftirqd/0  [kernel.kallsyms]  [k] ip_rcv
+   1,11%  ksoftirqd/0  [kernel.kallsyms]  [k] tcp_v4_conn_request
+   1,07%  ksoftirqd/0  [kernel.kallsyms]  [k] nf_iterate
+   1,07%      swapper  [kernel.kallsyms]  [k] sha_transform
+   1,05%  ksoftirqd/0  [kernel.kallsyms]  [k] kfree
+   1,05%  ksoftirqd/0  [kernel.kallsyms]  [k] skb_release_data
+   0,99%  ksoftirqd/0  [kernel.kallsyms]  [k] __alloc_skb
+   0,98%  ksoftirqd/0  [kernel.kallsyms]  [k] __kmalloc_node_track_caller
+   0,97%  ksoftirqd/0  [kernel.kallsyms]  [k] netdev_alloc_frag
+   0,96%  ksoftirqd/0  [kernel.kallsyms]  [k] dev_gro_receive
+   0,94%  ksoftirqd/0  [kernel.kallsyms]  [k] inet_gro_receive
+   0,85%  ksoftirqd/0  [kernel.kallsyms]  [k] build_skb
+   0,85%  ksoftirqd/0  [kernel.kallsyms]  [k] cookie_v4_init_sequence
+   0,85%  ksoftirqd/0  [kernel.kallsyms]  [k] ip_build_and_send_pkt
+   0,84%  ksoftirqd/0  [kernel.kallsyms]  [k] __copy_skb_header
+   0,82%  ksoftirqd/0  [kernel.kallsyms]  [k] nf_hook_slow
+   0,77%  ksoftirqd/0  [kernel.kallsyms]  [k] __skb_clone
+   0,73%  ksoftirqd/0  [kernel.kallsyms]  [k] tcp_v4_rcv
+   0,72%  ksoftirqd/0  [kernel.kallsyms]  [k] xfrm_lookup
+   0,69%  ksoftirqd/0  [kernel.kallsyms]  [k] dev_hard_start_xmit
+   0,68%  ksoftirqd/0  [kernel.kallsyms]  [k] local_bh_enable
+   0,67%  ksoftirqd/0  [kernel.kallsyms]  [k] tcp_gro_receive
+   0,67%  ksoftirqd/0  [kernel.kallsyms]  [k] kfree_skb
+   0,67%  ksoftirqd/0  [kernel.kallsyms]  [k] __probe_kernel_read
+   0,67%  ksoftirqd/0  [kernel.kallsyms]  [k] skb_release_head_state
+   0,66%  ksoftirqd/0  [kernel.kallsyms]  [k] __phys_addr
+   0,66%  ksoftirqd/0  [kernel.kallsyms]  [k] ip_finish_output
+   0,65%  ksoftirqd/0  [kernel.kallsyms]  [k] dst_release
+   0,64%  ksoftirqd/0  [kernel.kallsyms]  [k] __ip_local_out
+   0,61%  ksoftirqd/0  [kernel.kallsyms]  [k] packet_rcv_spkt
+   0,57%  ksoftirqd/0  [kernel.kallsyms]  [k] __kfree_skb
