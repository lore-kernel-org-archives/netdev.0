From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Question regarding netpoll_info != NULL check.
Date: Sat, 11 Oct 2014 14:39:55 -0700
Message-ID: <87zjd28evo.fsf@x220.int.ebiederm.org>
References: <201410112036.CGG26070.FOHSFMtOQOVLFJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nhorman@tuxdriver.com, davem@davemloft.net, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40155 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaJKVkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 17:40:32 -0400
In-Reply-To: <201410112036.CGG26070.FOHSFMtOQOVLFJ@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Sat, 11 Oct 2014 20:36:21 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Hello.
>
> A 2.6.32-220.4.2.el6 system crashed at poll_one_napi() when the administrator
> was updating network configuration and by error issued ifconfig command with
> a wrong argument.
>
> His system was using a bonding device as netconsole's the ethernet device to
> send console messages out of, and poll_one_napi() was called due to printk()
> by changing status of a bonding device.
>
> ---------- linux-2.6.32-220.4.2.el6.x86_64/net/core/netpoll.c ----------
> 128:static int poll_one_napi(struct netpoll_info *npinfo,
> 129:                     struct napi_struct *napi, int budget)
> 130:{
> 131:    int work;
> 132:
> 133:    /* net_rx_action's ->poll() invocations and our's are
> 134:     * synchronized by this test which is only made while
> 135:     * holding the napi->poll_lock.
> 136:     */
> 137:    if (!test_bit(NAPI_STATE_SCHED, &napi->state))
> 138:            return budget;
> 139:
> 140:    npinfo->rx_flags |= NETPOLL_RX_DROP;
> 141:    atomic_inc(&trapped);
> 142:    set_bit(NAPI_STATE_NPSVC, &napi->state);
> 143:
> 144:    work = napi->poll(napi, budget);
> 145:    trace_napi_poll(napi);
> 146:
> 147:    clear_bit(NAPI_STATE_NPSVC, &napi->state);
> 148:    atomic_dec(&trapped);
> 149:    npinfo->rx_flags &= ~NETPOLL_RX_DROP;
> 150:
> 151:    return budget - work;
> 152:}
> 153:
> 154:static void poll_napi(struct net_device *dev)
> 155:{
> 156:    struct napi_struct *napi;
> 157:    int budget = 16;
> 158:
> 159:    list_for_each_entry(napi, &dev->napi_list, dev_list) {
> 160:            if (napi->poll_owner != smp_processor_id() &&
> 161:                spin_trylock(&napi->poll_lock)) {
> 162:                    budget = poll_one_napi(dev->npinfo, napi, budget);
> 163:                    spin_unlock(&napi->poll_lock);
> 164:
> 165:                    if (!budget)
> 166:                            break;
> 167:            }
> 168:    }
> 169:}
> 170:
> 171:static void service_arp_queue(struct netpoll_info *npi)
> 172:{
> 173:    if (npi) {
> 174:            struct sk_buff *skb;
> 175:
> 176:            while ((skb = skb_dequeue(&npi->arp_tx)))
> 177:                    arp_reply(skb);
> 178:    }
> 179:}
> 180:
> 181:void netpoll_poll_dev(struct net_device *dev)
> 182:{
> 183:    const struct net_device_ops *ops;
> 184:
> 185:    if (!dev || !netif_running(dev))
> 186:            return;
> 187:
> 188:    ops = dev->netdev_ops;
> 189:    if (!ops->ndo_poll_controller)
> 190:            return;
> 191:
> 192:    /* Process pending work on NIC */
> 193:    ops->ndo_poll_controller(dev);
> 194:
> 195:    poll_napi(dev);
> 196:
> 197:    if (dev->priv_flags & IFF_SLAVE) {
> 198:            if (dev->npinfo) {
> 199:                    struct net_device *bond_dev = dev->master;
> 200:                    struct sk_buff *skb;
> 201:                    while ((skb = skb_dequeue(&dev->npinfo->arp_tx))) {
> 202:                            skb->dev = bond_dev;
> 203:                            skb_queue_tail(&bond_dev->npinfo->arp_tx, skb);
> 204:                    }
> 205:            }
> 206:    }
> 207:
> 208:    service_arp_queue(dev->npinfo);
> 209:
> 210:    zap_completion_queue();
> 211:}
> ---------- linux-2.6.32-220.4.2.el6.x86_64/net/core/netpoll.c ----------
>
> We can see that while line 198 did dev->npinfo != NULL check, line 162 called
> by line 195 did not do dev->npinfo != NULL check and thus npinfo was NULL at
> line 140 called by line 162.
>
> What is strange, we kept this dev->npinfo != NULL check until commit 18b37535
> ("netpoll: Consolidate neigh_tx processing in service_neigh_queue") and that
> commit depends on dev->npinfo != NULL assumption which commit ca99ca14
> ("netpoll: protect napi_poll and poll_controller during dev_[open|close]")
> is also assuming. But the above-mentioned system crashed due to
> dev->npinfo == NULL. Why we don't do dev->npinfo != NULL check?

The short version is that netpoll methods are not supposed to be called
on network devices where npinfo is NULL, and that check at line 198 has
always been dody.   The poll_napi check started dereferencing
dev->npinfo in 2.6.13.  While the IFF_SLAVE code came in in 2.6.39.

The current code in netpoll_poll_dev does the exclusion against races
that was happening in poll_napi at the begining of netpoll_poll_dev.

In the current code and I expect el6 is similar the code flow of all
of this starts with netpoll_send_udp.  netpoll_send_udp is passed a
netpoll structure.  The device we send to is obtained from that netpoll
structure.

That npinfo structure should be allocated in __netpoll_setup,
and freed in netpoll_cleanup.

I would recommend looking at where your bonding driver calls
netpoll_setup and netpoll_cleanup and the current exclusing in the
netpoll driver against races.

> Excuse me, I didn't do a full-fledged study because the size of vmcore was
> too huge to receive. Therefore I asked the administrator to do a superficial
> analysis by feeding predefined commands to the crash utility. If the reason
> we don't need dev->npinfo != NULL check is that dev->npinfo != NULL is always
> true, how should I verify that dev->npinfo == NULL was a race
> condition?

If possible look at the bonding event that was happening and see how
that interacts with the rest of the code.

There really isn't a lot of netpoll code.  So it should be too hard to
read through all of the relevant bits and understand what is going on.

Eric
