From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC] virtio_net: multicast address list never sent to host
Date: Fri, 06 Dec 2013 20:37:01 -0500
Message-ID: <52A27BBD.7050203@redhat.com>
References: <20131205152052.064319c9@nehalam.linuxnetplumber.net>	<52A1E16B.8050507@redhat.com> <20131206145145.29d204f9@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab3LGBhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 20:37:06 -0500
In-Reply-To: <20131206145145.29d204f9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[fixed alex's address to stop bounces]

On 12/06/2013 05:51 PM, Stephen Hemminger wrote:
> On Fri, 06 Dec 2013 09:38:35 -0500
> Vlad Yasevich <vyasevic@redhat.com> wrote:
> 
>>> -		sgs[out_num++] = out;
>>> -	if (in)
>>> -		sgs[out_num + in_num++] = in;
>>> +	while (out_cnt-- > 0)
>>> +		sgs[out_num++] = out++;  
>>
>> I think we can skip sg_count and just use
>>         while ((sg = sg_next(out)) != NULL)
>>                 sgs[out_num++] = sg;
>>
>> And we can probably do this loop for both 'in' and 'out' pointers.
>>
>> -vlad
> 
> 
> That won't work because callers pass a list with a single element,
> as in:

Ok, then how about:

    for (sg = out; sg; sg = sg_next(sg))
         sgs[out_num++] = sg;

    for (sg = in; sg; sg = sg_next(sg))
         sgs[in_num++] = sg;

since even a list of 1 element can be iterated using sg_next().

This makes it generic and will not require this function to change
if we ever had more then 2 elements to set, or even more then 1 element
to receive.

-vlad

>   
>> static int virtnet_set_mac_address(struct net_device *dev, void *p)
>> {
>> 	struct virtnet_info *vi = netdev_priv(dev);
>> 	struct virtio_device *vdev = vi->vdev;
>> 	int ret;
>> 	struct sockaddr *addr = p;
>> 	struct scatterlist sg;
>>
>> 	ret = eth_prepare_mac_addr_change(dev, p);
>> 	if (ret)
>> 		return ret;
>>
>> 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
>> 		sg_init_one(&sg, addr->sa_data, dev->addr_len);
>> 		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
>> 					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
>> 					  &sg, NULL)) {
>> 			dev_warn(&vdev->dev,
