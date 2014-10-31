From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] virtio_net: fix use after free
Date: Fri, 31 Oct 2014 14:07:11 +0800
Message-ID: <5453270F.3090300@redhat.com>
References: <1413378878-28118-1-git-send-email-mst@redhat.com>
	<1414726609.499.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414726609.499.6.camel@edumazet-glaptop2.roam.corp.google.com>
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

On 10/31/2014 11:36 AM, Eric Dumazet wrote:
> On Wed, 2014-10-15 at 16:23 +0300, Michael S. Tsirkin wrote:
>> commit 0b725a2ca61bedc33a2a63d0451d528b268cf975
>>     net: Remove ndo_xmit_flush netdev operation, use signalling instead.
>>
>> added code that looks at skb->xmit_more after the skb has
>> been put in TX VQ. Since some paths process the ring and free the skb
>> immediately, this can cause use after free.
>>
>> Fix by storing xmit_more in a local variable.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>
>> David, am I using the API correctly?
>> Seems to work for me.
>> You used __netif_subqueue_stopped but that seems to use
>> a slightly more expensive test_bit internally.
>> The reason I added a variable for the txq here is because it's handy for
>> BQL patch later on.
>>
>>
>>  drivers/net/virtio_net.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 3d0ce44..13d0a8b 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -920,6 +920,8 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>>  	int qnum = skb_get_queue_mapping(skb);
>>  	struct send_queue *sq = &vi->sq[qnum];
>>  	int err;
>> +	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
>> +	bool kick = !skb->xmit_more;
>>  
>>  	/* Free up any pending old buffers before queueing new ones. */
>>  	free_old_xmit_skbs(sq);
>> @@ -956,7 +958,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>>  		}
>>  	}
>>  
>> -	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
>> +	if (kick || netif_xmit_stopped(txq))
>>  		virtqueue_kick(sq->vq);
>>  
>>  	return NETDEV_TX_OK;
> I must say I am kind of confused by this patch.
>
> Why the skb_orphan(skb) & nf_reset(skb) do not have the same issue ?
>

Since they are called before the possible free_old_xmit_skbs(), skb
won't get freed at this time.
