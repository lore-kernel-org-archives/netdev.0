From: wangyunjian <wangyunjian@huawei.com>
Subject: RE: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Thu, 1 Dec 2016 02:48:59 +0000
Message-ID: <34EFBCA9F01B0748BEB6B629CE643AE60B0A7B68@szxeml561-mbx.china.huawei.com>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
 <20161130152004-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jasowang@redhat.com" <jasowang@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        caihe <caihe@huawei.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130152004-mutt-send-email-mst@kernel.org>
Content-Language: zh-CN
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>-----Original Message-----
>From: Michael S. Tsirkin [mailto:mst@redhat.com] 
>Sent: Wednesday, November 30, 2016 9:41 PM
>To: wangyunjian
>Cc: jasowang@redhat.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; caihe
>Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when meet errors
>
>On Wed, Nov 30, 2016 at 08:10:57PM +0800, Yunjian Wang wrote:
>> When we meet an error(err=-EBADFD) recvmsg,
>
>How do you get EBADFD? Won't vhost_net_rx_peek_head_len
>return 0 in this case, breaking the loop?

We started many guest VMs while attaching/detaching some virtio-net nics for loop. 
The soft lockup might happened. The err is -EBADFD.

meesage log:
kernel:[609608.510180]BUG: soft lockup - CPU#18 stuck for 23s! [vhost-60898:126093]
call trace:
[<fffffffa0132967>]vhost_get_vq_desc+0x1e7/0x984 [vhost]
[<fffffffa02037e6>]handle_rx+0x226/0x810 [vhost_net]
[<fffffffa0203de5>]handle_rx_net+0x15/0x20 [vhost_net]
[<fffffffa013160b>]vhost_worker+0xfb/0x1e0 [vhost]
[<fffffffa0131510>]? vhost_dev_reset_owner+0x50/0x50 [vhost]
[<fffffff810a5c7f>]kthread+0xcf/0xe0
[<fffffff810a5bb0>]? kthread_create_on_node+0x140/0x140
[<fffffff81648898>]ret_from_fork+0x58/0x90
[<fffffff810a5bb0>]? kthread_create_on_node+0x140/0x140

>> the error handling in vhost
>> handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.
>> 
>> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
>> ---
>>  drivers/vhost/net.c | 3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 5dc128a..edc470b 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
>>  			pr_debug("Discarded rx packet: "
>>  				 " len %d, expected %zd\n", err, sock_len);
>>  			vhost_discard_vq_desc(vq, headcount);
>> +			/* Don't continue to do, when meet errors. */
>> +			if (err < 0)
>> +				goto out;
>
>You might get e.g. EAGAIN and I think you need to retry
>in this case.
>
>>  			continue;
>>  		}
>>  		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
>> -- 
>> 1.9.5.msysgit.1
>>
