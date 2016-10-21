From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: fix a race between netvsc_send()
 and netvsc_init_buf()
Date: Fri, 21 Oct 2016 10:52:58 -0400 (EDT)
Message-ID: <20161021.105258.685851223067760389.davem@davemloft.net>
References: <8737jr1k07.fsf@vitty.brq.redhat.com>
 <20161020.140300.122827393647670926.davem@davemloft.net>
 <87d1iuymty.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: vkuznets@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87d1iuymty.fsf@vitty.brq.redhat.com>
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

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Fri, 21 Oct 2016 13:15:53 +0200

> David Miller <davem@davemloft.net> writes:
> 
>> From: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Date: Thu, 20 Oct 2016 10:51:04 +0200
>>
>>> Stephen Hemminger <sthemmin@microsoft.com> writes:
>>> 
>>>> Do we need ACCESS_ONCE() here to avoid check/use issues?
>>>>
>>> 
>>> I think we don't: this is the only place in the function where we read
>>> the variable so we'll get normal read. We're not trying to syncronize
>>> with netvsc_init_buf() as that would require locking, if we read stale
>>> NULL value after it was already updated on a different CPU we're fine,
>>> we'll just return -EAGAIN.
>>
>> The concern is if we race with netvsc_destroy_buf() and this pointer
>> becomes NULL after the test you are adding.
> 
> Thanks, this is interesting.
> 
> We may reach to netvsc_destroy_buf() by 3 pathes:
> 
> 1) cleanup path in netvsc_init_buf(). It is never called with
> send_section_map being not NULL so it seems we're safe.
> 
> 2) from netvsc_remove() when the device is being removed. As far as I
> understand we can't be on the transmit path after we call
> unregister_netdev() so we're safe.
> 
> 3) from netvsc_change_mtu() and netvsc_set_channels(). These pathes are
> specific to netvsc driver as basically we need to remove the device and
> add it back to change mtu/number of channels. The underligning 'struct
> net_device' stays but the rest is being removed and added back. On both
> pathes we first call netvsc_close() which does netif_tx_disable() and as
> far as I understand (I may be wrong) this guarantees that we won't be in
> netvsc_send().
> 
> So *I think* that we can't ever free send_section_map while in
> netvsc_send() and we can't even get to netvsc_send() after it is freed
> but I may have missed something.

Ok you may be right.

Can't the device be taken down by asynchronous events as well?  For example
if the peer end of the interface in the other guest disappears.
