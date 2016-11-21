From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 4/5] virtio_net: add dedicated XDP transmit
 queues
Date: Mon, 21 Nov 2016 07:56:50 -0800
Message-ID: <58331942.1010009@gmail.com>
References: <20161120024710.19187.31037.stgit@john-Precision-Tower-5810>
 <20161120025104.19187.54400.stgit@john-Precision-Tower-5810>
 <5832DE60.4000200@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bblanco@plumgrid.com,
        john.r.fastabend@intel.com, brouer@redhat.com, tgraf@suug.ch
To: Daniel Borkmann <daniel@iogearbox.net>, eric.dumazet@gmail.com,
        mst@redhat.com, kubakici@wp.pl, shm@cumulusnetworks.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34668 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbcKUP5N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 10:57:13 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so28548023pgc.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 07:57:13 -0800 (PST)
In-Reply-To: <5832DE60.4000200@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-21 03:45 AM, Daniel Borkmann wrote:
> On 11/20/2016 03:51 AM, John Fastabend wrote:
>> XDP requires using isolated transmit queues to avoid interference
>> with normal networking stack (BQL, NETDEV_TX_BUSY, etc). This patch
>> adds a XDP queue per cpu when a XDP program is loaded and does not
>> expose the queues to the OS via the normal API call to
>> netif_set_real_num_tx_queues(). This way the stack will never push
>> an skb to these queues.
>>
>> However virtio/vhost/qemu implementation only allows for creating
>> TX/RX queue pairs at this time so creating only TX queues was not
>> possible. And because the associated RX queues are being created I
>> went ahead and exposed these to the stack and let the backend use
>> them. This creates more RX queues visible to the network stack than
>> TX queues which is worth mentioning but does not cause any issues as
>> far as I can tell.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

>>       }
>>
>> +    curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
>> +    if (prog)
>> +        xdp_qp = nr_cpu_ids;
>> +
>> +    /* XDP requires extra queues for XDP_TX */
>> +    if (curr_qp + xdp_qp > vi->max_queue_pairs) {
>> +        netdev_warn(dev, "request %i queues but max is %i\n",
>> +                curr_qp + xdp_qp, vi->max_queue_pairs);
>> +        return -ENOMEM;
>> +    }
>> +
>> +    err = virtnet_set_queues(vi, curr_qp + xdp_qp);
>> +    if (err) {
>> +        dev_warn(&dev->dev, "XDP Device queue allocation failure.\n");
>> +        return err;
>> +    }
>> +
>>       if (prog) {
>> -        prog = bpf_prog_add(prog, vi->max_queue_pairs - 1);
>> -        if (IS_ERR(prog))
>> +        prog = bpf_prog_add(prog, vi->max_queue_pairs);
> 
> I think this change is not correct, it would be off by one now.
> The previous 'vi->max_queue_pairs - 1' was actually correct here.
> dev_change_xdp_fd() already gives you a reference (see the doc on
> enum xdp_netdev_command in netdevice.h).


Right, this was an error thanks for checking it I'll send a v3. And
maybe draft a test for XDP ref counting to test it in the future.

.John
