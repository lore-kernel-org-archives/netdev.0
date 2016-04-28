From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] vhost_net: stop polling socket during rx processing
Date: Thu, 28 Apr 2016 14:19:39 +0800
Message-ID: <5721AB7B.8070806@redhat.com>
References: <1461656153-24074-1-git-send-email-jasowang@redhat.com>
	<20160427141317-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160427141317-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On 04/27/2016 07:28 PM, Michael S. Tsirkin wrote:
> On Tue, Apr 26, 2016 at 03:35:53AM -0400, Jason Wang wrote:
>> We don't stop polling socket during rx processing, this will lead
>> unnecessary wakeups from under layer net devices (E.g
>> sock_def_readable() form tun). Rx will be slowed down in this
>> way. This patch avoids this by stop polling socket during rx
>> processing. A small drawback is that this introduces some overheads in
>> light load case because of the extra start/stop polling, but single
>> netperf TCP_RR does not notice any change. In a super heavy load case,
>> e.g using pktgen to inject packet to guest, we get about ~17%
>> improvement on pps:
>>
>> before: ~1370000 pkt/s
>> after:  ~1500000 pkt/s
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>
> There is one other possible enhancement: we actually have the wait queue
> lock taken in _wake_up, but we give it up only to take it again in the
> handler.
>
> It would be nicer to just remove the entry when we wake
> the vhost thread. Re-add it if required.
> I think that something like the below would give you the necessary API.
> Pls feel free to use it if you are going to implement a patch on top
> doing this - that's not a reason not to include this simple patch
> though.

Thanks, this looks useful, will give it a try.

>
> --->
>
> wait: add API to drop a wait_queue_t entry from wake up handler
>
> A wake up handler might want to remove its own wait queue entry to avoid
> future wakeups.  In particular, vhost has such a need.  As wait queue
> lock is already taken, all we need is an API to remove the entry without
> wait_queue_head_t which isn't currently accessible to wake up handlers.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
> ---
>
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index 27d7a0a..9c6604b 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -191,11 +191,17 @@ __add_wait_queue_tail_exclusive(wait_queue_head_t *q, wait_queue_t *wait)
>  }
>  
>  static inline void
> -__remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
> +__remove_wait_queue_entry(wait_queue_t *old)
>  {
>  	list_del(&old->task_list);
>  }
>  
> +static inline void
> +__remove_wait_queue(wait_queue_head_t *head, wait_queue_t *old)
> +{
> +	__remove_wait_queue_entry(old);
> +}
> +
>  typedef int wait_bit_action_f(struct wait_bit_key *, int mode);
>  void __wake_up(wait_queue_head_t *q, unsigned int mode, int nr, void *key);
>  void __wake_up_locked_key(wait_queue_head_t *q, unsigned int mode, void *key);
