From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Tue, 20 Jan 2009 02:14:19 -0800
Message-ID: <20090120101418.13898.57172.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20709 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753175AbZATKOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 05:14:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Herbert,

I have tried the following patch as an attempt to eliminate the memcpy
seen on the previous oprofile. I'm now getting about 5.5 Gbs.
After that, I went through the output of opreport -d to figure out
the most expensive ops witnessed in my profiling.

Here is the patch:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2554,6 +2554,8 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
 	struct ethhdr *eth;
+	skb_frag_t *frag;
+	int i;

 	napi->skb = NULL;

@@ -2566,9 +2568,15 @@ struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
 	}

 	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
-	skb_shinfo(skb)->nr_frags = info->nr_frags;
-	memcpy(skb_shinfo(skb)->frags, info->frags, sizeof(info->frags));
+	frag = &info->frags[info->nr_frags - 1];

+	for (i = skb_shinfo(skb)->nr_frags; i < info->nr_frags; i++) {
+		skb_fill_page_desc(skb, i, frag->page, frag->page_offset,
+				   frag->size);
+		frag++;
+	}
+	skb_shinfo(skb)->nr_frags = info->nr_frags;
+
 	skb->data_len = info->len;
 	skb->len += info->len;
 	skb->truesize += info->len;

Here is the non detailed opreport output for the CPU managing the reception
of netperf traffic:

      38.815300  copy_user_generic_unrolled          vmlinux
       6.373900  process_responses                  cxgb3.ko
       4.957800  inet_gro_receive                    vmlinux
       4.908800  put_page                            vmlinux
       4.862100  refill_fl                          cxgb3.ko
       3.774900  dev_gro_receive                     vmlinux
       3.096000  tcp_gro_receive                     vmlinux
       2.764700  napi_fraginfo_skb                   vmlinux
       2.174400  free_hot_cold_page                  vmlinux
       2.006400  skb_copy_datagram_iovec             vmlinux
       1.511800  tcp_recvmsg                         vmlinux
       1.488500  get_page_from_freelist              vmlinux
       1.455800  irq_entries_start                   vmlinux
       1.453500  skb_gro_header                      vmlinux
       0.877200  get_pageblock_flags_group           vmlinux
       0.863200  memcpy_toiovec                      vmlinux
       0.856200  _raw_spin_lock                      vmlinux
       0.720900  memcpy                              vmlinux
       0.711600  skb_gro_receive                     vmlinux
       0.683600  kfree                               vmlinux

Here is a list of more detailed info sorted per GRO function as seen above:
- Relative % for the most expensive instructions
- gdb dissass'output for these instructions
- gdb list's output.

inet_gro_receive 4.9578 ffffffff805468c0
  ffffffff80546a49 11.1059%
    0xffffffff80546a49 <inet_gro_receive+393>:      jne    0xffffffff805469e5 <inet_gro_receive+293>
    0xffffffff80546a49 is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1285).
      1280                    if (!NAPI_GRO_CB(p)->same_flow)
      1281                            continue;
      1282
      1283                    iph2 = ip_hdr(p);
      1284
      1285                    if (iph->protocol != iph2->protocol ||
      1286                        iph->tos != iph2->tos ||
      1287                        memcmp(&iph->saddr, &iph2->saddr, 8)) {
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;

  ffffffff80546a61 10.4000%
    0xffffffff80546a61 <inet_gro_receive+417>:      je     0xffffffff80546abb <inet_gro_receive+507>
    0xffffffff80546a61 is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1293).
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;
      1290                    }
      1291
      1292                    /* All fields must match except length and checksum. */
      1293                    NAPI_GRO_CB(p)->flush |=
      1294                            memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
      1295                            (u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;

  ffffffff80546a58 8.2353%
    0xffffffff80546a58 <inet_gro_receive+408>:      mov    %rdx,%rcx
    0xffffffff80546a58 is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1293).
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;
      1290                    }
      1291
      1292                    /* All fields must match except length and checksum. */
      1293                    NAPI_GRO_CB(p)->flush |=
      1294                            memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
      1295                            (u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
      1296
      1297                    NAPI_GRO_CB(p)->flush |= flush;

  ffffffff80546abb 8.2353%
    0xffffffff80546abb <inet_gro_receive+507>:      movzwl 0x4(%r10),%eax
      (gdb) list *(0xffffffff80546abb)
      0xffffffff80546abb is in inet_gro_receive (/mnt/net-2.6/include/linux/swab.h:51).
      46      static inline __attribute_const__ __u16 __fswab16(__u16 val)
      47      {
      48      #ifdef __arch_swab16
      49              return __arch_swab16(val);
      50      #else
      51              return ___constant_swab16(val);
      52      #endif
      53      }
      54
      55      static inline __attribute_const__ __u32 __fswab32(__u32 val)

  ffffffff80546a4b 8.1882%
    0xffffffff80546a4b is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1293).
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;
      1290                    }
      1291
      1292                    /* All fields must match except length and checksum. */
      1293                    NAPI_GRO_CB(p)->flush |=
      1294                            memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
      1295                            (u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
      1296
      1297                    NAPI_GRO_CB(p)->flush |= flush;

  ffffffff80546a47 7.5765%
    0xffffffff80546a47 <inet_gro_receive+391>:      repz cmpsb %es:(%rdi),%ds:(%rsi)
    0xffffffff80546a47 is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1285).
      1280                    if (!NAPI_GRO_CB(p)->same_flow)
      1281                            continue;
      1282
      1283                    iph2 = ip_hdr(p);
      1284
      1285                    if (iph->protocol != iph2->protocol ||
      1286                        iph->tos != iph2->tos ||
      1287                        memcmp(&iph->saddr, &iph2->saddr, 8)) {
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;

  ffffffff80546a44 7.1529%
    0xffffffff80546a44 is in inet_gro_receive (/mnt/net-2.6/net/ipv4/af_inet.c:1285).
      1280                    if (!NAPI_GRO_CB(p)->same_flow)
      1281                            continue;
      1282
      1283                    iph2 = ip_hdr(p);
      1284
      1285                    if (iph->protocol != iph2->protocol ||
      1286                        iph->tos != iph2->tos ||
      1287                        memcmp(&iph->saddr, &iph2->saddr, 8)) {
      1288                            NAPI_GRO_CB(p)->same_flow = 0;
      1289                            continue;


dev_gro_receive 3.7749 ffffffff805024b0
  ffffffff805026a2 18.7268%
    0xffffffff805026a2 <dev_gro_receive+498>:       repz cmpsb %es:(%rdi),%ds:(%rsi)
    0xffffffff805026a2 is in dev_gro_receive (/mnt/net-2.6/net/core/dev.c:2450).
      2445                            count++;
      2446
      2447                            if (!NAPI_GRO_CB(p)->same_flow)
      2448                                    continue;
      2449
      2450                            if (p->mac_len != mac_len ||
      2451                                memcmp(skb_mac_header(p), mac, mac_len))
      2452                                    NAPI_GRO_CB(p)->same_flow = 0;
      2453                    }
      2454

  ffffffff805026a4 13.4734%
    0xffffffff805026a4 <dev_gro_receive+500>:       je     0xffffffff805025c8 <dev_gro_receive+280>
      (gdb) list *(0xffffffff805026a4)
      0xffffffff805026a4 is in dev_gro_receive (/mnt/net-2.6/net/core/dev.c:2450).
      2445                            count++;
      2446
      2447                            if (!NAPI_GRO_CB(p)->same_flow)
      2448                                    continue;
      2449
      2450                            if (p->mac_len != mac_len ||
      2451                                memcmp(skb_mac_header(p), mac, mac_len))
      2452                                    NAPI_GRO_CB(p)->same_flow = 0;

  ffffffff805025c8 9.3943%
    0xffffffff805025c8 <dev_gro_receive+280>:       mov    (%r9),%r9
    0xffffffff805025c8 is in dev_gro_receive (/mnt/net-2.6/net/core/dev.c:2444).
      2439                    skb->mac_len = mac_len;
      2440                    NAPI_GRO_CB(skb)->same_flow = 0;
      2441                    NAPI_GRO_CB(skb)->flush = 0;
      2442                    NAPI_GRO_CB(skb)->free = 0;
      2443
      2444                    for (p = napi->gro_list; p; p = p->next) {
      2445                            count++;
      2446
      2447                            if (!NAPI_GRO_CB(p)->same_flow)
      2448                                    continue;

  ffffffff805025f9 7.3548%
    0xffffffff805025f9 <dev_gro_receive+329>:       je     0xffffffff80502614 <dev_gro_receive+356>
    0xffffffff805025f9 is in dev_gro_receive (/mnt/net-2.6/net/core/dev.c:2466).
      2461                    goto normal;
      2462
      2463            same_flow = NAPI_GRO_CB(skb)->same_flow;
      2464            ret = NAPI_GRO_CB(skb)->free ? GRO_MERGED_FREE : GRO_MERGED;
      2465
      2466            if (pp) {
      2467                    struct sk_buff *nskb = *pp;
      2468
      2469                    *pp = nskb->next;
      2470                    nskb->next = NULL;


tcp_gro_receive 3.0960 ffffffff80528df0
  ffffffff80528f2b 16.3527%
    0xffffffff80528f2b <tcp_gro_receive+315>:       repz cmpsb %es:(%rdi),%ds:(%rsi)
    0xffffffff80528f2b is in tcp_gro_receive (/mnt/net-2.6/net/ipv4/tcp.c:2521).
      2516            flush = NAPI_GRO_CB(p)->flush;
      2517            flush |= flags & TCP_FLAG_CWR;
      2518            flush |= (flags ^ tcp_flag_word(th2)) &
      2519                      ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
      2520            flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
      2521            flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
      2522
      2523            total = skb_gro_len(p);
      2524            mss = skb_shinfo(p)->gso_size;

  ffffffff80528f2d 15.9759%
    0xffffffff80528f2d <tcp_gro_receive+317>:       mov    0x60(%r8),%edi
      0xffffffff80528f2d is in tcp_gro_receive (/mnt/net-2.6/include/linux/netdevice.h:1101).
      1096            return NAPI_GRO_CB(skb)->data_offset;
      1097    }
      1098
      1099    static inline unsigned int skb_gro_len(const struct sk_buff *skb)
      1100    {
      1101            return skb->len - NAPI_GRO_CB(skb)->data_offset;
      1102    }
      1103
      1104    static inline void skb_gro_pull(struct sk_buff *skb, unsigned int len)
      1105    {

  ffffffff80528f31 13.7905%
    0xffffffff80528f31 <tcp_gro_receive+321>:       setb   %al
    0xffffffff80528f31 is in tcp_gro_receive (/mnt/net-2.6/net/ipv4/tcp.c:2521).
      2516            flush = NAPI_GRO_CB(p)->flush;
      2517            flush |= flags & TCP_FLAG_CWR;
      2518            flush |= (flags ^ tcp_flag_word(th2)) &
      2519                      ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
      2520            flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
      2521            flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
      2522
      2523            total = skb_gro_len(p);
      2524            mss = skb_shinfo(p)->gso_size;

napi_fraginfo_skb 2.7647 ffffffff80501dd0
  ffffffff80501f16 65.2321%
    0xffffffff80501f16 <napi_fraginfo_skb+326>:     mov    %eax,0x6c(%rbx)
    0xffffffff80501f16 is in napi_fraginfo_skb (/mnt/net-2.6/net/core/dev.c:2606).
      2601             * special handling.  We'll fix it up properly at the end.
      2602             */
      2603            skb->protocol = eth->h_proto;
      2604
      2605            skb->ip_summed = info->ip_summed;
      2606            skb->csum = info->csum;
      2607
      2608    out:
      2609            return skb;
      2610    }

Cheers,
Divy
