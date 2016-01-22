From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 2/3] vhost: introduce vhost_vq_more_avail()
Date: Fri, 22 Jan 2016 13:43:14 +0800
Message-ID: <56A1C172.7070601@redhat.com>
References: <1448951985-12385-1-git-send-email-jasowang@redhat.com>
	<1448951985-12385-3-git-send-email-jasowang@redhat.com>
	<20160120160400-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160120160400-mutt-send-email-mst@redhat.com>
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



On 01/20/2016 10:09 PM, Michael S. Tsirkin wrote:
> On Tue, Dec 01, 2015 at 02:39:44PM +0800, Jason Wang wrote:
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Wow new API with no comments anywhere, and no
> commit log to say what it's good for.
> Want to know what it does and whether
> it's correct? You have to read the next patch.
>
> So what is the point of splitting it out?
> It's confusing, and in fact it made you
> miss a bug.

Ok, will add comments to explain the function.

>
>> ---
>>  drivers/vhost/vhost.c | 13 +++++++++++++
>>  drivers/vhost/vhost.h |  1 +
>>  2 files changed, 14 insertions(+)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 163b365..4f45a03 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -1633,6 +1633,19 @@ void vhost_add_used_and_signal_n(struct vhost_dev *dev,
>>  }
>>  EXPORT_SYMBOL_GPL(vhost_add_used_and_signal_n);
>>  
>> +bool vhost_vq_more_avail(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>> +{
>> +	__virtio16 avail_idx;
>> +	int r;
>> +
>> +	r = __get_user(avail_idx, &vq->avail->idx);
>> +	if (r)
>> +		return false;
> So the result is that if the page is not present,
> you return false (empty ring) and the
> caller will busy wait with preempt disabled.
> Nasty.
>
> So it should return something that breaks
> the loop, and this means it should have
> a different name for the return code
> to make sense.
>
> Maybe reverse the polarity: vhost_vq_avail_empty?
> And add a comment saying we can't be sure ring
> is empty so return false.

Sounds good, will do this.

>
>> +
>> +	return vhost16_to_cpu(vq, avail_idx) != vq->avail_idx;
>> +}
>> +EXPORT_SYMBOL_GPL(vhost_vq_more_avail);
>> +
>>  /* OK, now we need to know about added descriptors. */
>>  bool vhost_enable_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>>  {
>> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
>> index 43284ad..2f3c57c 100644
>> --- a/drivers/vhost/vhost.h
>> +++ b/drivers/vhost/vhost.h
>> @@ -159,6 +159,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
>>  			       struct vring_used_elem *heads, unsigned count);
>>  void vhost_signal(struct vhost_dev *, struct vhost_virtqueue *);
>>  void vhost_disable_notify(struct vhost_dev *, struct vhost_virtqueue *);
>> +bool vhost_vq_more_avail(struct vhost_dev *, struct vhost_virtqueue *);
>>  bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
>>  
>>  int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
>> -- 
>> 2.5.0
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
