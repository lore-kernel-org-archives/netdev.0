From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: don't poll on -EFAULT
Date: Tue, 17 Apr 2012 18:46:25 +0800
Message-ID: <4F8D4A01.9040901@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416060833.14140.28139.stgit@intel-e5620-16-2.englab.nay.redhat.com> <20120416071646.GB25396@redhat.com> <4F8BD81A.7010507@redhat.com> <20120416133859.GB13190@redhat.com> <4F8CE305.9090100@redhat.com> <20120417045736.GA31278@redhat.com> <4F8D05AF.4000309@redhat.com> <20120417060752.GB20674@redhat.com> <4F8D0E03.7030105@redhat.com> <20120417101820.GB20905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120417101820.GB20905@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2012 06:18 PM, Michael S. Tsirkin wrote:
> On Tue, Apr 17, 2012 at 02:30:27PM +0800, Jason Wang wrote:
>> >  On 04/17/2012 02:07 PM, Michael S. Tsirkin wrote:
>>> >  >On Tue, Apr 17, 2012 at 01:54:55PM +0800, Jason Wang wrote:
>>>> >  >>On 04/17/2012 12:57 PM, Michael S. Tsirkin wrote:
>>>>> >  >>>On Tue, Apr 17, 2012 at 11:27:01AM +0800, Jason Wang wrote:
>>>>>> >  >>>>On 04/16/2012 09:39 PM, Michael S. Tsirkin wrote:
>>>>>>> >  >>>>>On Mon, Apr 16, 2012 at 04:28:10PM +0800, Jason Wang wrote:
>>>>>>>>> >  >>>>>>>    On 04/16/2012 03:16 PM, Michael S. Tsirkin wrote:
>>>>>>>>>> >  >>>>>>>>    >On Mon, Apr 16, 2012 at 02:08:33PM +0800, Jason Wang wrote:
>>>>>>>>>>> >  >>>>>>>>>    >>Currently, we restart tx polling unconditionally when sendmsg()
>>>>>>>>>>> >  >>>>>>>>>    >>fails. This would cause unnecessary wakeups of vhost wokers as it's
>>>>>>>>>>> >  >>>>>>>>>    >>only needed when the socket send buffer were exceeded.
>>>>>>>>>> >  >>>>>>>>    >Why is this a problem?
>>>>>>>>> >  >>>>>>>    >     This issue is when guest driver is able to hit the
>>>>>>>> >  >>>>>>-EFAULT, vhost
>>>>>>>>> >  >>>>>>>    discard the the descriptor and restart the polling. This would wake
>>>>>>>>> >  >>>>>>>    vhost thread and repeat the loop again which waste cpu.
>>>>>>> >  >>>>>Does same thing happen if we get an error from copy from user?
>>>>>>> >  >>>>>
>>>>>> >  >>>>Right, so do you think it makes sense that we only restart polling
>>>>>> >  >>>>on -EAGAIN or -ENOBUFS?
>>>>> >  >>>Sounds OK. BTW how do you test this?
>>>>> >  >>>
>>>> >  >>Not very hard, w/o this patch, we can see almost 100% cpu
>>>> >  >>utilization for vhost thread if guest hit EFAULT or EINVAL. With
>>>> >  >>this patch, the cpu utilization should be very low I think.
>>> >  >Yes but do you have a test that makes guest hit EFAULT or EINVAL?
>> >  
>> >  Looks like we can do this by supplying an invalid hdr_len in vnet
>> >  header as tap does the check for this.
> Ah so you patched qemu to do this? Cool. Can you post the patch for testing pls?
>
No, I mean patch the guest driver like this:

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 019da01..6e2f487 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -582,7 +582,7 @@ static int xmit_skb(struct virtnet_info *vi, struct 
sk_buff *skb)
         }

         if (skb_is_gso(skb)) {
-               hdr->hdr.hdr_len = skb_headlen(skb);
+               hdr->hdr.hdr_len = 65535;
                 hdr->hdr.gso_size = skb_shinfo(skb)->gso_size;
                 if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
                         hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;

btw, If we still choose to drop the packet, we can hit -EFAULT by send a 
descriptor with a large number of pages.
