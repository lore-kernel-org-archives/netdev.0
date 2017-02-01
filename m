From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Wed, 1 Feb 2017 18:29:56 -0500
Message-ID: <223ebf32-ba8b-a6be-2331-0644f9d347a0@oracle.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
 <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
 <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
 <1485803209.6360.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <07a315d6-7c97-6d11-fa18-548000107c2f@oracle.com>
 <10b1d554-b395-88fa-eee3-a77754ad14bd@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: jgross@suse.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vineethp@amazon.com, wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org, Ross Lagerwall <ross.lagerwall@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <10b1d554-b395-88fa-eee3-a77754ad14bd@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2017 12:47 PM, Boris Ostrovsky wrote:
> On 01/30/2017 02:31 PM, Boris Ostrovsky wrote:
>> On 01/30/2017 02:06 PM, Eric Dumazet wrote:
>>> On Mon, 2017-01-30 at 13:23 -0500, Boris Ostrovsky wrote:
>>>
>>>> We do netif_carrier_off() first thing in xennet_disconnect_backend() and
>>>> the only place where the timer is rearmed is xennet_alloc_rx_buffers(),
>>>> which is guarded by netif_carrier_ok() check.
>>> Oh well, testing netif_carrier_ok() in packet processing fast path looks
>>> unusual and a waste of cpu cycles. I've never seen that pattern before.
>>>
>>> If one day, we remove this netif_carrier_ok() test during a cleanup,
>>> then the race window will open again.
>> I don't know much about napi but I wonder whether I can indeed disable
>> it in xennet_disconnect_backend(). I don't see how anything can happen
>> after disconnect since it unmaps the rings. And then napi is re-enabled
>> during reconnection in xennet_create_queues(). In which case am not sure
>> there is any need for xennet_destroy_queues() as everything there could
>> be folded into xennet_disconnect_backend().
> While this does work, there was a reason why napi_disable() was not
> called in xennet_disconnect_backend() and it is explained in commit
> ce58725fec6e --- napi_disable() may sleep and that's why it is called in
> xennet_destroy_queues().
>
> OTOH, there is a napi_synchronize() call in xennet_destroy_queues().
> Will destroying the timer after it guarantee that all preceding RX have
> been completed? RX interrupt is disabled prior to napi_synchronize() so
> presumably nothing new can be received.


I could not convince myself that napi_synchronize() is sufficient here
(mostly because I am not familiar with napi flow). At the same time I
would rather not make changes in anticipation of possible disappearance
of netif_carrier_ok() in the future so I'd like this patch to go in as is.

Unless there are other problems with the patch or if Eric (or others)
feel strongly about usage of netif_carrier_ok() here.


-boris
