From: lx <lxlenovostar@gmail.com>
Subject: hi I'm confused with Implementation of RPS and RFS.
Date: Wed, 24 Dec 2014 14:34:30 +0800
Message-ID: <549A5E76.4060407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:55958 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbaLXGec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 01:34:32 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so9510824pad.1
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 22:34:31 -0800 (PST)
Received: from [192.168.34.109] ([120.36.156.171])
        by mx.google.com with ESMTPSA id vz3sm21885346pab.2.2014.12.23.22.34.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Dec 2014 22:34:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi all:
       I'm read the source code of RPS and RFS, I think the key function 
of RPS and RFS is get_rps_cpu(), and
It's codes is:
###############################################################
3079 static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
3080                struct rps_dev_flow **rflowp)
3081 {
3082     struct netdev_rx_queue *rxqueue;
3083     struct rps_map *map;
3084     struct rps_dev_flow_table *flow_table;
3085     struct rps_sock_flow_table *sock_flow_table;
3086     int cpu = -1;
3087     u16 tcpu;
3088     u32 hash;
3089
3090     if (skb_rx_queue_recorded(skb)) {
3091         u16 index = skb_get_rx_queue(skb);
3092         if (unlikely(index >= dev->real_num_rx_queues)) {
3093             WARN_ONCE(dev->real_num_rx_queues > 1,
3094                   "%s received packet on queue %u, but number "
3095                   "of RX queues is %u\n",
3096                   dev->name, index, dev->real_num_rx_queues);
3097             goto done;
3098         }
3099         rxqueue = dev->_rx + index;
3100     } else
3101         rxqueue = dev->_rx;
3102
3103     map = rcu_dereference(rxqueue->rps_map);
3104     if (map) {
3105         if (map->len == 1 &&
3106             !rcu_access_pointer(rxqueue->rps_flow_table)) {
3107             tcpu = map->cpus[0];
3108             if (cpu_online(tcpu))
3109                 cpu = tcpu;
3110             goto done;
3111         }
3112     } else if (!rcu_access_pointer(rxqueue->rps_flow_table)) {
3113         goto done;
3114     }
3115
3116     skb_reset_network_header(skb);
3117     hash = skb_get_hash(skb);
3118     if (!hash)
3119         goto done;
3120
3121     flow_table = rcu_dereference(rxqueue->rps_flow_table);
3122     sock_flow_table = rcu_dereference(rps_sock_flow_table);
3123     if (flow_table && sock_flow_table) {
3124         u16 next_cpu;
3125         struct rps_dev_flow *rflow;
3126
3127         rflow = &flow_table->flows[hash & flow_table->mask];
3128         tcpu = rflow->cpu;
3129
3130         next_cpu = sock_flow_table->ents[hash & sock_flow_table->mask];
3131
3132         /*
3133          * If the desired CPU (where last recvmsg was done) is
3134          * different from current CPU (one in the rx-queue flow
3135          * table entry), switch if one of the following holds:
3136          *   - Current CPU is unset (equal to RPS_NO_CPU).
3137          *   - Current CPU is offline.
3138          *   - The current CPU's queue tail has advanced beyond the
3139          *     last packet that was enqueued using this table entry.
3140          *     This guarantees that all previous packets for the flow
3141          *     have been dequeued, thus preserving in order delivery.
3142          */
3143         if (unlikely(tcpu != next_cpu) &&
3144             (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
3145              ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
3146               rflow->last_qtail)) >= 0)) {
3147             tcpu = next_cpu;
3148             rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
3149         }
3150
3151         if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
3152             *rflowp = rflow;
3153             cpu = tcpu;
3154             goto done;
3155         }
3156     }
3157
3158     if (map) {
3159         tcpu = map->cpus[reciprocal_scale(hash, map->len)];
3160         if (cpu_online(tcpu)) {
3161             cpu = tcpu;
3162             goto done;
3163         }
3164     }
3165
3166 done:
3167     return cpu;
3168 }
###############################################################
I know the RPS/RFS get the CPU id by this function.I think RPS can't work,
when RFS is active, beacuse the implementation of RPS is between 3158 
and 3163.
and the codes between 3123 and 3156 are used for RFS.

I think RPS is work just in this two  conditions:
1.  When the packet first arrived this host,  the value of tcpu and 
next_cpu are RPS_NO_CPU.
2. When the destination of packet is not this host, the value of tcpu 
and next_cpu always are RPS_NO_CPU.

My question is: If the RFS is enable, the RPS can't work?

Thank you.
