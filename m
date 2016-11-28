From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 3/5] virtio_net: Add XDP support
Date: Mon, 28 Nov 2016 15:26:53 -0800
Message-ID: <583CBD3D.1080808@gmail.com>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025033.19187.11082.stgit@john-Precision-Tower-5810>
 <20161122011638-mutt-send-email-mst@kernel.org> <58340157.8060103@gmail.com>
 <20161122165400-mutt-send-email-mst@kernel.org> <5838ABF3.8060308@gmail.com>
 <20161128052211-mutt-send-email-mst@kernel.org> <583BAAD9.4080408@gmail.com>
 <20161128060446-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, kubakici@wp.pl,
        shm@cumulusnetworks.com, davem@davemloft.net,
        alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, john.r.fastabend@intel.com,
        brouer@redhat.com, tgraf@suug.ch
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33508 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755967AbcK1X1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 18:27:10 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so7095934pfv.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 15:27:10 -0800 (PST)
In-Reply-To: <20161128060446-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> Perfect! hacking qemu for testing is no problem this helps a lot thanks
>> and saves me time trying to figure out how to get qemu to do this.
> 
> Pls note I didn't try this at all, so might not work, but should
> give you the idea.
> 
>>>
>>> diff --git a/hw/net/virtio-net.c b/hw/net/virtio-net.c
>>> index b68c69d..4866144 100644
>>> --- a/hw/net/virtio-net.c
>>> +++ b/hw/net/virtio-net.c
>>> @@ -1164,6 +1164,7 @@ static ssize_t virtio_net_receive(NetClientState *nc, const uint8_t *buf, size_t
>>>              offset = n->host_hdr_len;
>>>              total += n->guest_hdr_len;
>>>              guest_offset = n->guest_hdr_len;
>>> +            continue;
>>>          } else {
>>>              guest_offset = 0;
>>>          }
>>>
>>>
>>>
>>> here's one that should cap the 1st s/g to 100 bytes:
>>>
>>>
>>> diff --git a/hw/net/virtio-net.c b/hw/net/virtio-net.c
>>> index b68c69d..7943004 100644
>>> --- a/hw/net/virtio-net.c
>>> +++ b/hw/net/virtio-net.c
>>> @@ -1164,6 +1164,7 @@ static ssize_t virtio_net_receive(NetClientState *nc, const uint8_t *buf, size_t
>>>              offset = n->host_hdr_len;
>>>              total += n->guest_hdr_len;
>>>              guest_offset = n->guest_hdr_len;
>>> +            sg.iov_len = MIN(sg.iov_len, 100);
>>>          } else {
>>>              guest_offset = 0;
>>>          }
>>>

Here is the patch I went with, I'm using vhost=on:

--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1777,7 +1777,8 @@ static int translate_desc(struct vhost_virtqueue
*vq, u64

                _iov = iov + ret;
                size = node->size - addr + node->start;
-               _iov->iov_len = min((u64)len - s, size);
+               printk("%s: build 100 length headers!\n", __func__);
+               _iov->iov_len = min((u64)len - s, (u64)100);//size);
                _iov->iov_base = (void __user *)(unsigned long)
                        (node->userspace_addr + addr - node->start);
                s += size;


This seems to do the trick and with 100 I can use 'ping -s' to generate
as many bufs is needed up to MTU. The patch I have seems to be working
fine I'll let it run a bit and test it with some real traffic (not just
ping) then push out a v3 assuming I don't find any issues.

Thanks,
John
