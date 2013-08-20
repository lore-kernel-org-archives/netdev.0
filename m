From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: remove the max pending check
Date: Tue, 20 Aug 2013 10:48:18 +0800
Message-ID: <5212D8F2.10307@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-7-git-send-email-jasowang@redhat.com>
	<20130816100225.GD21821@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130816100225.GD21821@redhat.com>
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

On 08/16/2013 06:02 PM, Michael S. Tsirkin wrote:
> On Fri, Aug 16, 2013 at 01:16:30PM +0800, Jason Wang wrote:
>> We used to limit the max pending DMAs to prevent guest from pinning too many
>> pages. But this could be removed since:
>>
>> - We have the sk_wmem_alloc check in both tun/macvtap to do the same work
>> - This max pending check were almost useless since it was one done when there's
>>   no new buffers coming from guest. Guest can easily exceeds the limitation.
>> - We've already check upend_idx != done_idx and switch to non zerocopy then. So
>>   even if all vq->heads were used, we can still does the packet transmission.
> We can but performance will suffer.

The check were in fact only done when no new buffers submitted from
guest. So if guest keep sending, the check won't be done.

If we really want to do this, we should do it unconditionally. Anyway, I
will do test to see the result.
>
>> So remove this check completely.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/vhost/net.c |   13 -------------
>>  1 files changed, 0 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index a035a89..ed3f165 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -38,8 +38,6 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
>>   * Using this limit prevents one virtqueue from starving others. */
>>  #define VHOST_NET_WEIGHT 0x80000
>>  
>> -/* MAX number of TX used buffers for outstanding zerocopy */
>> -#define VHOST_MAX_PEND 128
>>  #define VHOST_GOODCOPY_LEN 256
>>  
>>  /*
>> @@ -372,17 +370,6 @@ static void handle_tx(struct vhost_net *net)
>>  			break;
>>  		/* Nothing new?  Wait for eventfd to tell us they refilled. */
>>  		if (head == vq->num) {
>> -			int num_pends;
>> -
>> -			/* If more outstanding DMAs, queue the work.
>> -			 * Handle upend_idx wrap around
>> -			 */
>> -			num_pends = likely(nvq->upend_idx >= nvq->done_idx) ?
>> -				    (nvq->upend_idx - nvq->done_idx) :
>> -				    (nvq->upend_idx + UIO_MAXIOV -
>> -				     nvq->done_idx);
>> -			if (unlikely(num_pends > VHOST_MAX_PEND))
>> -				break;
>>  			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
>>  				vhost_disable_notify(&net->dev, vq);
>>  				continue;
>> -- 
>> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
