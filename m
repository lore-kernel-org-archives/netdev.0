From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: validate features during probe
Date: Thu, 20 Nov 2014 13:28:59 +0800
Message-ID: <546D7C1B.7040502@redhat.com>
References: <1416378939-28821-1-git-send-email-jasowang@redhat.com>
	<20141119085939.GB24827@redhat.com> <546C63E6.7040600@redhat.com>
	<20141119093901.GB26119@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141119093901.GB26119@redhat.com>
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

On 11/19/2014 05:39 PM, Michael S. Tsirkin wrote:
> On Wed, Nov 19, 2014 at 05:33:26PM +0800, Jason Wang wrote:
>> On 11/19/2014 04:59 PM, Michael S. Tsirkin wrote:
>>> On Wed, Nov 19, 2014 at 02:35:39PM +0800, Jason Wang wrote:
>>>> This patch validates feature dependencies during probe and fail the probing
>>>> if a dependency is missed. This fixes the issues of hitting BUG()
>>>> when qemu fails to advertise features correctly. One example is booting
>>>> guest with ctrl_vq=off through qemu.
>>>>
>>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
>>>> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> ---
>>>>  drivers/net/virtio_net.c | 93 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>>  1 file changed, 93 insertions(+)
>>>>
>>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>>> index ec2a8b4..4a0ad46 100644
>>>> --- a/drivers/net/virtio_net.c
>>>> +++ b/drivers/net/virtio_net.c
>>>> @@ -1673,6 +1673,95 @@ static const struct attribute_group virtio_net_mrg_rx_group = {
>>>>  };
>>>>  #endif
>>>>  
>>>> +static int virtnet_validate_features(struct virtio_device *dev,
>>>> +				     unsigned int *table,
>>>> +				     int table_size,
>>>> +				     unsigned int feature)
>>>> +{
>>>> +	int i;
>>>> +
>>>> +	if (!virtio_has_feature(dev, feature)) {
>>>> +		for (i = 0; i < table_size; i++) {
>>>> +			unsigned int f = table[i];
>>>> +
>>>> +			if (virtio_has_feature(dev, f)) {
>>>> +				dev_err(&dev->dev,
>>>> +					"buggy hyperviser: feature 0x%x was advertised but its dependency 0x%x was not",
>>> This line's way too long.
>> Yes. (Anyway it pass checkpatch.pl since it forbids quoted string to be
>> split)
[...]
>>>> +
>>>>  static int virtnet_probe(struct virtio_device *vdev)
>>>>  {
>>>>  	int i, err;
>>>> @@ -1680,6 +1769,10 @@ static int virtnet_probe(struct virtio_device *vdev)
>>>>  	struct virtnet_info *vi;
>>>>  	u16 max_queue_pairs;
>>>>  
>>>> +	err = virtnet_check_features(vdev);
>>>> +	if (err)
>>>> +		return -EINVAL;
>>>> +
>>>>  	/* Find if host supports multiqueue virtio_net device */
>>>>  	err = virtio_cread_feature(vdev, VIRTIO_NET_F_MQ,
>>>>  				   struct virtio_net_config,
>>> The API seems too complex, and you still had to open-code ECN logic.
>>> Just open-code most of it. 
>> Yes, the ECN could be done through the same way as ctrl_vq did.
>>
>> How about move those checking into virtio core by just letting device
>> export its dependency table?
> So far we only have this for net, let's not add
> one-off APIs.
>
>>>  You can use a helper macro to output a
>>> friendly message without code duplication.
>>> For example like the below (completely untested)?
>>>
>>>
>>> I would also like to split things: dependencies on
>>> VIRTIO_NET_F_CTRL_VQ might go into this kernel,
>>> since they help fix BUG.
>>>
>>> Others should wait since they don't fix any crashes, and there's a small
>>> chance of a regression for some hypervisor in the field.
>> Probably ok but not sure, since the rest features are all related to
>> csum and offloading, we are in fact depends on network core to fix them.
> Well it does fix them so ... there's no bug, is there?
>

No.
>>> -->
>>>
>>> virtio-net: friendlier handling of misconfigured hypervisors
>>>
>>> We currently trigger BUG when VIRTIO_NET_F_CTRL_VQ
>>> is not set but one of features depending on it is.
>>> That's not a friendly way to report errors to
>>> hypervisors.
>>> Let's check, and fail probe instead.
>>>
>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>>
>>> ---
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index 26e1330..7a7d1a3 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -1673,6 +1673,21 @@ static const struct attribute_group virtio_net_mrg_rx_group = {
>>>  };
>>>  #endif
>>>  
>>> +bool __virtnet_fail_on_feature(struct virtio_device *vdev, unsigned int fbit,
>>> +			       const char *fname)
>>> +{
>>> +	if (!virtio_has_feature(vdev, fbit))
>>> +		return false;
>>> +
>>> +        dev_err(&dev->dev, "missing requirements for feature bit %d: %s\n",
>>> +		fbit, fname);
>>> +
>>> +	return true;
>>> +}
>>> +
>>> +#define VIRTNET_FAIL_ON(vdev, fbit) \
>>> +	__virtnet_fail_on_feature(vdev, fbit, #fbit)
>>> +
>>>  static int virtnet_probe(struct virtio_device *vdev)
>>>  {
>>>  	int i, err;
>>> @@ -1680,6 +1695,14 @@ static int virtnet_probe(struct virtio_device *vdev)
>>>  	struct virtnet_info *vi;
>>>  	u16 max_queue_pairs;
>>>  
>>> +	if (!virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ) &&
>>> +		(VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_RX) ||
>>> +		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_VLAN) ||
>>> +		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE) ||
>>> +		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_MQ) ||
>>> +		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)))
>>> +		return -EINVAL;
>>> +
>>>  	/* Find if host supports multiqueue virtio_net device */
>>>  	err = virtio_cread_feature(vdev, VIRTIO_NET_F_MQ,
>>>  				   struct virtio_net_config,
>>>
>> Patch looks good, but consider we may check more dependencies in the
>> future, may need a helper instead. Or just use this and switch to
>> dependency table in 3.19. 
> Pls note this is just pseudo-code - I didn't even compile it.
> If you want something like this merged, go ahead and
> post it, probably addressing Cornelia's request to
> print the dependency too. Maybe:

Ok, will post v3.
>
>>> 		(VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_RX, "ctrl_vq") ||
>>> 		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_VLAN, "ctrl_vq") ||
>>> 		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE, "ctrl_vq") ||
>>> 		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_MQ, "ctrl_vq") ||
>>> 		 VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR, "ctrl_vq")))
