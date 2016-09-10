From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 17:01:43 -0700
Message-ID: <57D34D67.40804@gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
 <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        u9012063@gmail.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36304 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750976AbcIJAB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 20:01:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id id6so32771766pad.3
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 17:01:58 -0700 (PDT)
In-Reply-To: <CALx6S35VCq9yPjcuhtx6jEJ78-WugkQZ6GSsqkcTr0Fa7edkVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-09 04:44 PM, Tom Herbert wrote:
> On Fri, Sep 9, 2016 at 2:29 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>> e1000 supports a single TX queue so it is being shared with the stack
>> when XDP runs XDP_TX action. This requires taking the xmit lock to
>> ensure we don't corrupt the tx ring. To avoid taking and dropping the
>> lock per packet this patch adds a bundling implementation to submit
>> a bundle of packets to the xmit routine.
>>
>> I tested this patch running e1000 in a VM using KVM over a tap
>> device using pktgen to generate traffic along with 'ping -f -l 100'.
>>
> Hi John,
> 
> How does this interact with BQL on e1000?
> 
> Tom
> 

Let me check if I have the API correct. When we enqueue a packet to
be sent we must issue a netdev_sent_queue() call and then on actual
transmission issue a netdev_completed_queue().

The patch attached here missed a few things though.

But it looks like I just need to call netdev_sent_queue() from the
e1000_xmit_raw_frame() routine and then let the tx completion logic
kick in which will call netdev_completed_queue() correctly.

I'll need to add a check for the queue state as well. So if I do these
three things,

	check __QUEUE_STATE_XOFF before sending
	netdev_sent_queue() -> on XDP_TX
	netdev_completed_queue()

It should work agree? Now should we do this even when XDP owns the
queue? Or is this purely an issue with sharing the queue between
XDP and stack.

.John
