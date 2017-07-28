From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 3/3] tap: XDP support
Date: Fri, 28 Jul 2017 11:28:54 +0800
Message-ID: <7d1cb7bf-43c1-3993-be00-04e4676dd917@redhat.com>
References: <1501147533-12368-1-git-send-email-jasowang@redhat.com>
 <1501147533-12368-4-git-send-email-jasowang@redhat.com>
 <20170727201338.65d56b2a@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727201338.65d56b2a@cakuba.netronome.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年07月28日 11:13, Jakub Kicinski wrote:
> On Thu, 27 Jul 2017 17:25:33 +0800, Jason Wang wrote:
>> This patch tries to implement XDP for tun. The implementation was
>> split into two parts:
>>
>> - fast path: small and no gso packet. We try to do XDP at page level
>>    before build_skb(). For XDP_TX, since creating/destroying queues
>>    were completely under control of userspace, it was implemented
>>    through generic XDP helper after skb has been built. This could be
>>    optimized in the future.
>> - slow path: big or gso packet. We try to do it after skb was created
>>    through generic XDP helpers.
>>
>> XDP_REDIRECT was not implemented, it could be done on top.
>>
>> xdp1 test shows 47.6% improvement:
>>
>> Before: ~2.1Mpps
>> After:  ~3.1Mpps
>>
>> Suggested-by: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> @@ -1008,6 +1016,56 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>>   	stats->tx_dropped = tx_dropped;
>>   }
>>   
>> +static int tun_xdp_set(struct net_device *dev, struct bpf_prog *prog,
>> +		       struct netlink_ext_ack *extack)
>> +{
>> +	struct tun_struct *tun = netdev_priv(dev);
>> +	struct bpf_prog *old_prog;
>> +
>> +	/* We will shift the packet that can't be handled to generic
>> +	 * XDP layer.
>> +	 */
>> +
>> +	old_prog = rtnl_dereference(tun->xdp_prog);
>> +	if (old_prog)
>> +		bpf_prog_put(old_prog);
>> +	rcu_assign_pointer(tun->xdp_prog, prog);
> Is this OK?  Could this lead to the program getting freed and then
> datapath accessing a stale pointer?  I mean in the scenario where the
> process gets pre-empted between the bpf_prog_put() and
> rcu_assign_pointer()?

Will call bpf_prog_put() after rcu_assign_pointer().

>
>> +	if (prog) {
>> +		prog = bpf_prog_add(prog, 1);
>> +		if (IS_ERR(prog))
>> +			return PTR_ERR(prog);
>> +	}
> I don't think you need this extra reference here.  dev_change_xdp_fd()
> will call bpf_prog_get_type() which means driver gets the program with
> a reference already taken, drivers does have to free that reference when
> program is removed (or device is freed, as you correctly do).

I see, will drop this in next version.

Thanks.

>
>> +	return 0;
>> +}
>> +
