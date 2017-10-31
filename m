From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 2/4] hv_netvsc: protect nvdev->extension with RCU
Date: Tue, 31 Oct 2017 18:13:58 +0100
Message-ID: <87shdzw889.fsf@vitty.brq.redhat.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
 <20171031134204.15287-3-vkuznets@redhat.com>
 <20171031174451.096978cd@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171031174451.096978cd@shemminger-XPS-13-9360> (Stephen
 Hemminger's message of "Tue, 31 Oct 2017 17:44:51 +0100")
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 31 Oct 2017 14:42:02 +0100
> Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
>> @@ -2002,7 +2002,9 @@ static int netvsc_probe(struct hv_device *dev,
>>  	device_info.recv_sections = NETVSC_DEFAULT_RX;
>>  	device_info.recv_section_size = NETVSC_RECV_SECTION_SIZE;
>>  
>> +	rtnl_lock();
>>  	nvdev = rndis_filter_device_add(dev, &device_info);
>> +	rtnl_unlock();
>
> rtnl is not necessary here. probe can not be bothered by other changes.
>

Yes, this is only to support rtnl_dereference() down the stack.

>> --- a/drivers/net/hyperv/rndis_filter.c
>> +++ b/drivers/net/hyperv/rndis_filter.c
>> @@ -402,20 +402,27 @@ int rndis_filter_receive(struct net_device *ndev,
>>  			 void *data, u32 buflen)
>>  {
>>  	struct net_device_context *net_device_ctx = netdev_priv(ndev);
>> -	struct rndis_device *rndis_dev = net_dev->extension;
>> +	struct rndis_device *rndis_dev;
>>  	struct rndis_message *rndis_msg = data;
>> +	int ret = 0;
>> +
>> +	rcu_read_lock_bh();
>> +
>> +	rndis_dev = rcu_dereference_bh(net_dev->extension);
>
> filter_receive is already called only from NAPI only and has RCU lock and soft
> irq disabled. This is not necessary.
>
>> -	net_dev->extension = NULL;
>> +	rcu_assign_pointer(net_dev->extension, NULL);
>> +
>> +	synchronize_rcu();
>
> rcu_assign_pointer with NULL is never a good idea.
> And synchronize_rcu is slow. Since net_device is already protected
> by RCU (for deletion) it should not be necessary.
>

I thought we don't care that much about the speed of this patch as
rndis_filter_device_remove() is only called on device remove/mtu
change/... and we need to interact with the host -- and this is already
slow.

> Thank you for trying to address these races. But it should be
> done carefully not by just slapping RCU everywhere.

Ok, I may have missed something. I'll try reproducing the crash and
finding a better fine-grained solution.

Thanks for the feedback!

-- 
  Vitaly
