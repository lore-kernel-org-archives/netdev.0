From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Question regarding netpoll_info != NULL check.
Date: Sat, 11 Oct 2014 20:36:21 +0900
Message-ID: <201410112036.CGG26070.FOHSFMtOQOVLFJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com, nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:11899 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752399AbaJKLgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 07:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

A 2.6.32-220.4.2.el6 system crashed at poll_one_napi() when the administrator
was updating network configuration and by error issued ifconfig command with
a wrong argument.

His system was using a bonding device as netconsole's the ethernet device to
send console messages out of, and poll_one_napi() was called due to printk()
by changing status of a bonding device.

---------- linux-2.6.32-220.4.2.el6.x86_64/net/core/netpoll.c ----------
128:static int poll_one_napi(struct netpoll_info *npinfo,
129:                     struct napi_struct *napi, int budget)
130:{
131:    int work;
132:
133:    /* net_rx_action's ->poll() invocations and our's are
134:     * synchronized by this test which is only made while
135:     * holding the napi->poll_lock.
136:     */
137:    if (!test_bit(NAPI_STATE_SCHED, &napi->state))
138:            return budget;
139:
140:    npinfo->rx_flags |= NETPOLL_RX_DROP;
141:    atomic_inc(&trapped);
142:    set_bit(NAPI_STATE_NPSVC, &napi->state);
143:
144:    work = napi->poll(napi, budget);
145:    trace_napi_poll(napi);
146:
147:    clear_bit(NAPI_STATE_NPSVC, &napi->state);
148:    atomic_dec(&trapped);
149:    npinfo->rx_flags &= ~NETPOLL_RX_DROP;
150:
151:    return budget - work;
152:}
153:
154:static void poll_napi(struct net_device *dev)
155:{
156:    struct napi_struct *napi;
157:    int budget = 16;
158:
159:    list_for_each_entry(napi, &dev->napi_list, dev_list) {
160:            if (napi->poll_owner != smp_processor_id() &&
161:                spin_trylock(&napi->poll_lock)) {
162:                    budget = poll_one_napi(dev->npinfo, napi, budget);
163:                    spin_unlock(&napi->poll_lock);
164:
165:                    if (!budget)
166:                            break;
167:            }
168:    }
169:}
170:
171:static void service_arp_queue(struct netpoll_info *npi)
172:{
173:    if (npi) {
174:            struct sk_buff *skb;
175:
176:            while ((skb = skb_dequeue(&npi->arp_tx)))
177:                    arp_reply(skb);
178:    }
179:}
180:
181:void netpoll_poll_dev(struct net_device *dev)
182:{
183:    const struct net_device_ops *ops;
184:
185:    if (!dev || !netif_running(dev))
186:            return;
187:
188:    ops = dev->netdev_ops;
189:    if (!ops->ndo_poll_controller)
190:            return;
191:
192:    /* Process pending work on NIC */
193:    ops->ndo_poll_controller(dev);
194:
195:    poll_napi(dev);
196:
197:    if (dev->priv_flags & IFF_SLAVE) {
198:            if (dev->npinfo) {
199:                    struct net_device *bond_dev = dev->master;
200:                    struct sk_buff *skb;
201:                    while ((skb = skb_dequeue(&dev->npinfo->arp_tx))) {
202:                            skb->dev = bond_dev;
203:                            skb_queue_tail(&bond_dev->npinfo->arp_tx, skb);
204:                    }
205:            }
206:    }
207:
208:    service_arp_queue(dev->npinfo);
209:
210:    zap_completion_queue();
211:}
---------- linux-2.6.32-220.4.2.el6.x86_64/net/core/netpoll.c ----------

We can see that while line 198 did dev->npinfo != NULL check, line 162 called
by line 195 did not do dev->npinfo != NULL check and thus npinfo was NULL at
line 140 called by line 162.

What is strange, we kept this dev->npinfo != NULL check until commit 18b37535
("netpoll: Consolidate neigh_tx processing in service_neigh_queue") and that
commit depends on dev->npinfo != NULL assumption which commit ca99ca14
("netpoll: protect napi_poll and poll_controller during dev_[open|close]")
is also assuming. But the above-mentioned system crashed due to
dev->npinfo == NULL. Why we don't do dev->npinfo != NULL check?

Excuse me, I didn't do a full-fledged study because the size of vmcore was
too huge to receive. Therefore I asked the administrator to do a superficial
analysis by feeding predefined commands to the crash utility. If the reason
we don't need dev->npinfo != NULL check is that dev->npinfo != NULL is always
true, how should I verify that dev->npinfo == NULL was a race condition?

Regards.
