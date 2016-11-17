From: Jason Wang <jasowang@redhat.com>
Subject: Re: Virtio_net support vxlan encapsulation package TSO offload
 discuss
Date: Thu, 17 Nov 2016 15:27:40 +0800
Message-ID: <0438366c-8b0e-270e-cbd1-334c1d655428@redhat.com>
References: <DBCD2614ECF3FF4087A2C27CA80E34DD5401AC8B@SZXEMA501-MBX.china.huawei.com>
 <c2f735e4-eddf-f737-2afe-35a93289f8d4@redhat.com>
 <3a0b8f10-f479-3ed5-dd10-5b92de3eb593@redhat.com>
 <DBCD2614ECF3FF4087A2C27CA80E34DD5401ADA8@SZXEMA501-MBX.china.huawei.com>
 <53d0322b-4ce1-d0db-4b53-f9e860ece2c5@redhat.com>
 <DBCD2614ECF3FF4087A2C27CA80E34DD5401BE13@SZXEMA501-MBX.china.huawei.com>
 <6db6b2a1-edbc-0068-d7d4-e8e15d18edc6@redhat.com>
 <DBCD2614ECF3FF4087A2C27CA80E34DD54027936@SZXEMA501-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Vlad Yasevic <vyasevic@redhat.com>,
        Amnon Ilan <ailan@redhat.com>
To: "Zhangming (James, Euler)" <james.zhangming@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60970 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750785AbcKQH1r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 02:27:47 -0500
In-Reply-To: <DBCD2614ECF3FF4087A2C27CA80E34DD54027936@SZXEMA501-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月17日 09:31, Zhangming (James, Euler) wrote:
> On 2016年11月15日 11:28, Jason Wang wrote:
>> On 2016年11月10日 14:19, Zhangming (James, Euler) wrote:
>>> On 2016年11月09日 15:14, Jason Wang wrote:
>>>> On 2016年11月08日 19:58, Zhangming (James, Euler) wrote:
>>>>> On 2016年11月08日 19:17, Jason Wang wrote:
>>>>>
>>>>>> On 2016年11月08日 19:13, Jason Wang wrote:
>>>>>>> Cc Michael
>>>>>>>
>>>>>>> On 2016年11月08日 16:34, Zhangming (James, Euler) wrote:
>>>>>>>> In container scenario, OVS is installed in the Virtual machine,
>>>>>>>> and all the containers connected to the OVS will communicated
>>>>>>>> through VXLAN encapsulation.
>>>>>>>>
>>>>>>>> By now, virtio_net does not support TSO offload for VXLAN
>>>>>>>> encapsulated TSO package. In this condition, the performance is
>>>>>>>> not good, sender is bottleneck
>>>>>>>>
>>>>>>>> I googled this scenario, but I didn’t find any information. Will
>>>>>>>> virtio_net support VXLAN encapsulation package TSO offload later?
>>>>>>>>
>>>>>>> Yes and for both sender and receiver.
>>>>>>>
>>>>>>>> My idea is virtio_net open encapsulated TSO offload, and
>>>>>>>> transport encapsulation info to TUN, TUN will parse the info and
>>>>>>>> build skb with encapsulation info.
>>>>>>>>
>>>>>>>> OVS or kernel on the host should be modified to support this.
>>>>>>>> Using this method, the TCP performance aremore than 2x as before.
>>>>>>>>
>>>>>>>> Any advice and suggestions for this idea or new idea will be
>>>>>>>> greatly appreciated!
>>>>>>>>
>>>>>>>> Best regards,
>>>>>>>>
>>>>>>>>       James zhang
>>>>>>>>
>>>>>>> Sounds very good. And we may also need features bits
>>>>>>> (VIRTIO_NET_F_GUEST|HOST_GSO_X) for this.
>>>>>>>
>>>>>>> This is in fact one of items in networking todo list. (See
>>>>>>> http://www.linux-kvm.org/page/NetworkingTodo). While at it, we'd
>>>>>>> better support not only VXLAN but also other tunnels.
>>>>>> Cc Vlad who is working on extending virtio-net headers.
>>>>>>
>>>>>>> We can start with the spec work, or if you've already had some
>>>>>>> bits you can post them as RFC for early review.
>>>>>>>
>>>>>>> Thanks
>>>>> Below is my demo code
>>>>> Virtio_net.c
>>>>> static int virtnet_probe(struct virtio_device *vdev), add belows codes:
>>>>>            if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF) ||				// avoid gso segment, it should be negotiation later, because in the demo I reuse num_buffers.
>>>>>                virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
>>>>>                    dev->hw_enc_features |= NETIF_F_TSO;
>>>>>                    dev->hw_enc_features |= NETIF_F_ALL_CSUM;
>>>>>                    dev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
>>>>>                    dev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
>>>>>                    dev->hw_enc_features |=
>>>>> NETIF_F_GSO_TUNNEL_REMCSUM;
>>>>>
>>>>>                    dev->features |= NETIF_F_GSO_UDP_TUNNEL;
>>>>>                    dev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
>>>>>                    dev->features |= NETIF_F_GSO_TUNNEL_REMCSUM;
>>>>>            }
>>>>>
>>>>> static int xmit_skb(struct send_queue *sq, struct sk_buff *skb), add
>>>>> below to pieces of codes
>>>>>
>>>>>                    if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
>>>>>                            hdr->hdr.gso_type |= VIRTIO_NET_HDR_GSO_TUNNEL;
>>>>>                    if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)
>>>>>                            hdr->hdr.gso_type |= VIRTIO_NET_HDR_GSO_TUNNEL_CSUM;
>>>>>                    if (skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM)
>>>>>                            hdr->hdr.gso_type |=
>>>>> VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM;
>>>>>
>>>>>            if (skb->encapsulation && skb_is_gso(skb)) {
>>>>>                    inner_mac_len = skb_inner_network_header(skb) - skb_inner_mac_header(skb);
>>>>>                    tnl_len = skb_inner_mac_header(skb) - skb_mac_header(skb);
>>>>>                    if ( !(inner_mac_len >> DATA_LEN_SHIFT) && !(tnl_len >> DATA_LEN_SHIFT) ) {
>>>>>                            hdr->hdr.flags |= VIRTIO_NET_HDR_F_ENCAPSULATION;
>>>>>                            hdr->num_buffers = (__virtio16)((inner_mac_len << DATA_LEN_SHIFT) | tnl_len);		//we reuse num_buffers for simple , we should add extend member for later.
>>>>>                    }  else
>>>>>                            hdr->num_buffers = 0;
>>>>>            }
>>>>>
>>>>> Tun.c
>>>>>                    if (memcpy_fromiovecend((void *)&hdr, iv, offset, tun->vnet_hdr_sz))		//read header with negotiation length
>>>>>                            return -EFAULT;
>>>>>
>>>>>                    if (hdr.gso_type & VIRTIO_NET_HDR_GSO_TUNNEL)					//set tunnel gso info
>>>>>                            skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
>>>>>                    if (hdr.gso_type & VIRTIO_NET_HDR_GSO_TUNNEL_CSUM)
>>>>>                            skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL_CSUM;
>>>>>                    if (hdr.gso_type & VIRTIO_NET_HDR_GSO_TUNNEL_REMCSUM)
>>>>>                            skb_shinfo(skb)->gso_type |=
>>>>> SKB_GSO_TUNNEL_REMCSUM;
>>>>>
>>>>>            if (hdr.flags & VIRTIO_NET_HDR_F_ENCAPSULATION) {						//read tunnel info from header and set to built skb.
>>>>>                    tnl_len = tun16_to_cpu(tun, hdr.num_buffers) & TUN_TNL_LEN_MASK;
>>>>>                    payload_mac_len = tun16_to_cpu(tun, hdr.num_buffers) >> TUN_DATA_LEN_SHIFT;
>>>>>                    mac_len = skb_network_header(skb) - skb_mac_header(skb);
>>>>>                    skb_set_inner_mac_header(skb, tnl_len - mac_len);
>>>>>                    skb_set_inner_network_header(skb, tnl_len + payload_mac_len - mac_len);
>>>>>                    skb->encapsulation = 1;
>>>>>            }
>>>>>
>>>>>
>>>> Something like this, and you probably need do something more:
>>>>
>>>> - use net-next.git to generate the patch (for the latest code)
>>>> - add feature negotiation
>>>> - tun/macvtap/qemu patches for this, you can start with tun/macvtap
>>>> patches
>>>> - support for all other SKB_GSO_* types which is not supported
>>>> - use a new field instead of num_buffers
>>>> - a virtio spec patch to describe the support for encapsulation
>>>> offload
>>>>
>>>> Thanks
>>> Thank you for your advice, I will start it right now.
>>>
>>> Thanks
>> Cool, one more question: while at it, I think you may want to add support for dpdk too?
>>
>> Thanks
> Do you mean that the patch should be compatible with virtio pmd, or give virtio pmd patch?
>
> Thanks

I mean it's better to prepare patches for both virtio pmd and dpdk.

Thanks
