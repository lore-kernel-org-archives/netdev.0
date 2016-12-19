From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio_net: reject XDP programs using header
 adjustment
Date: Mon, 19 Dec 2016 15:08:23 -0500 (EST)
Message-ID: <20161219.150823.1350925016886798319.davem@davemloft.net>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com>
        <58581E01.7070902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org, kafai@fb.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com, mst@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbcLSUIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 15:08:25 -0500
In-Reply-To: <58581E01.7070902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 19 Dec 2016 09:50:57 -0800

> On 16-12-19 07:05 AM, Jakub Kicinski wrote:
>> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
>> added a new XDP helper to prepend and remove data from a frame.
>> Make virtio_net reject programs making use of this helper until
>> proper support is added.
>> 
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> ---
>>  drivers/net/virtio_net.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>> 
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 08327e005ccc..db761f37783e 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -1677,6 +1677,11 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>  	u16 xdp_qp = 0, curr_qp;
>>  	int i, err;
>>  
>> +	if (prog && prog->xdp_adjust_head) {
>> +		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
>>  	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
>>  		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO first\n");
>> 
> 
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> 
> Thanks patch looks good. Alternatively we could push a "bug fix" to
> support the adjust header feature depending on how DaveM and MST feel
> about that. I don't have a strong opinion but I have the patch on my
> queue it just needs some more testing. The adjust header bits were
> merged in between some of the later versions of the patch which is how
> this check got missed.

I would like to avoid inconsistent XDP feature support amongst drivers
as much as possible.
