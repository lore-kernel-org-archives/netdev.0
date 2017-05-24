From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] netfilter: do not hold dev in ipt_CLUSTERIP
Date: Wed, 24 May 2017 16:53:55 +0800
Message-ID: <CADvbK_f72jTbXtK2R751o7L+oYBsuvWtFskNq1ciPwMtg5HKqg@mail.gmail.com>
References: <cc6ebc3f8784d8d537737a1e18b443a2e0c7313a.1495271286.git.lucien.xin@gmail.com>
 <20170523212607.GA8936@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
        fw@strlen.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35641 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933013AbdEXIx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 04:53:56 -0400
In-Reply-To: <20170523212607.GA8936@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 5:26 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Sat, May 20, 2017 at 05:08:06PM +0800, Xin Long wrote:
>> It's a terrible thing to hold dev in iptables target. When the dev is
>> being removed, unregister_netdevice has to wait for the dev to become
>> free. dmesg will keep logging the err:
>>
>>   kernel:unregister_netdevice: waiting for veth0_in to become free. \
>>   Usage count = 1
>>
>> until iptables rules with this target are removed manually.
>>
>> The worse thing is when deleting a netns, a virtual nic will be deleted
>> instead of reset to init_net in default_device_ops exit/exit_batch. As
>> it is earlier than to flush the iptables rules in iptable_filter_net_ops
>> exit, unregister_netdevice will block to wait for the nic to become free.
>>
>> As unregister_netdevice is actually waiting for iptables rules flushing
>> while iptables rules have to be flushed after unregister_netdevice. This
>> 'dead lock' will cause unregister_netdevice to block there forever. As
>> the netns is not available to operate at that moment, iptables rules can
>> not even be flushed manually either.
>>
>> The reproducer can be:
>>
>>   # ip netns add test
>>   # ip link add veth0_in type veth peer name veth0_out
>>   # ip link set veth0_in netns test
>>   # ip netns exec test ip link set lo up
>>   # ip netns exec test ip link set veth0_in up
>>   # ip netns exec test iptables -I INPUT -d 1.2.3.4 -i veth0_in -j \
>>     CLUSTERIP --new --clustermac 89:d4:47:eb:9a:fa --total-nodes 3 \
>>     --local-node 1 --hashmode sourceip-sourceport
>>   # ip netns del test
>>
>> This issue can be triggered by all virtual nics with ipt_CLUSTERIP.
>>
>> This patch is to fix it by not holding dev in ipt_CLUSTERIP, but only
>> save dev->ifindex instead of dev. When removing the mc from the dev,
>> it will get dev by c->ifindex through dev_get_by_index.
>>
>> Note that it doesn't save dev->name but dev->ifindex, as a dev->name
>> can be changed, it will confuse ipt_CLUSTERIP.
>>
>> Reported-by: Jianlin Shi <jishi@redhat.com>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>
> OK. Let's fix this finally... One comment below.
>
>>  net/ipv4/netfilter/ipt_CLUSTERIP.c | 31 ++++++++++++++++++-------------
>>  1 file changed, 18 insertions(+), 13 deletions(-)
>>
>> diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> index 038f293..d1adb2f 100644
>> --- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> +++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
>> @@ -47,7 +47,7 @@ struct clusterip_config {
>>
>>       __be32 clusterip;                       /* the IP address */
>>       u_int8_t clustermac[ETH_ALEN];          /* the MAC address */
>> -     struct net_device *dev;                 /* device */
>> +     int ifindex;                            /* device ifindex */
>>       u_int16_t num_total_nodes;              /* total number of nodes */
>>       unsigned long local_nodes;              /* node number array */
>>
>> @@ -98,19 +98,23 @@ clusterip_config_put(struct clusterip_config *c)
>>   * entry(rule) is removed, remove the config from lists, but don't free it
>>   * yet, since proc-files could still be holding references */
>>  static inline void
>> -clusterip_config_entry_put(struct clusterip_config *c)
>> +clusterip_config_entry_put(struct net *net, struct clusterip_config *c)
>>  {
>> -     struct net *net = dev_net(c->dev);
>>       struct clusterip_net *cn = net_generic(net, clusterip_net_id);
>>
>>       local_bh_disable();
>>       if (refcount_dec_and_lock(&c->entries, &cn->lock)) {
>> +             struct net_device *dev;
>> +
>>               list_del_rcu(&c->list);
>>               spin_unlock(&cn->lock);
>>               local_bh_enable();
>>
>> -             dev_mc_del(c->dev, c->clustermac);
>> -             dev_put(c->dev);
>> +             dev = dev_get_by_index(net, c->ifindex);
>> +             if (dev) {
>> +                     dev_mc_del(dev, c->clustermac);
>> +                     dev_put(dev);
>> +             }
>>
>>               /* In case anyone still accesses the file, the open/close
>>                * functions are also incrementing the refcount on their own,
>> @@ -182,7 +186,7 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
>>       if (!c)
>>               return ERR_PTR(-ENOMEM);
>>
>> -     c->dev = dev;
>> +     c->ifindex = dev->ifindex;
>>       c->clusterip = ip;
>>       memcpy(&c->clustermac, &i->clustermac, ETH_ALEN);
>>       c->num_total_nodes = i->num_total_nodes;
>> @@ -427,12 +431,14 @@ static int clusterip_tg_check(const struct xt_tgchk_param *par)
>>                       }
>>
>>                       config = clusterip_config_init(cipinfo,
>> -                                                     e->ip.dst.s_addr, dev);
>> +                                                    e->ip.dst.s_addr, dev);
>>                       if (IS_ERR(config)) {
>>                               dev_put(dev);
>>                               return PTR_ERR(config);
>>                       }
>> -                     dev_mc_add(config->dev, config->clustermac);
>> +
>> +                     dev_mc_add(dev, config->clustermac);
>> +                     dev_put(dev);
>>               }
>>       }
>>       cipinfo->config = config;
>> @@ -458,7 +464,7 @@ static void clusterip_tg_destroy(const struct xt_tgdtor_param *par)
>>
>>       /* if no more entries are referencing the config, remove it
>>        * from the list and destroy the proc entry */
>> -     clusterip_config_entry_put(cipinfo->config);
>> +     clusterip_config_entry_put(par->net, cipinfo->config);
>>
>>       clusterip_config_put(cipinfo->config);
>>
>> @@ -558,10 +564,9 @@ arp_mangle(void *priv,
>>        * addresses on different interfacs.  However, in the CLUSTERIP case
>>        * this wouldn't work, since we didn't subscribe the mcast group on
>>        * other interfaces */
>> -     if (c->dev != state->out) {
>> -             pr_debug("not mangling arp reply on different "
>> -                      "interface: cip'%s'-skb'%s'\n",
>> -                      c->dev->name, state->out->name);
>> +     if (c->ifindex != state->out->ifindex) {
>
> I'm missing the code to register_netdevice_notifier() so we can
> refresh c->ifindex.
>
> Just like we do in net/netfilter/xt_TEE.c
Yep, but clusterip would be more complicated, As config
can be shared by more than one targets, a config has
to have it's own notifier, and save the dev's name as well.

I didn't do it and just wanted to keep clusterip simple.
But after checking xt_TEE, notifier seems necessary, will
check more, and post v2 if it's doable for clusterip.  thanks.
