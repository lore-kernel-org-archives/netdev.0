From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better sleep/wakeup
 efficiency
Date: Tue, 20 May 2014 14:03:34 +0800
Message-ID: <537AF036.7010005@redhat.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>		 <5379CE8D.2030405@redhat.com>	 <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <537ADD91.4000609@redhat.com> <1400562668.5367.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbaETGDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 02:03:42 -0400
In-Reply-To: <1400562668.5367.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2014 01:11 PM, Eric Dumazet wrote:
> On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:
>> On 05/19/2014 10:09 PM, Eric Dumazet wrote:
>>> About the sk_data_ready() and wake_up_all(), you missed the whole part
>>> of the patch I think.
>>>
>>> Check how sock_def_readable() does everything properly and efficiently,
>>> including the async part.
>> But this changes (sk_data_ready()) has nothing related to switching to
>> use __skb_recv_datagram()
>>
> This is totally related.
>
> I think you did not yet understood this patch

Sorry for being unclear, but I think you misunderstand my meaning.
>
> Compare wake_up_all() and sk_data_ready() speeds, you'll be surprised.
>
> You should ask to yourself : Why do we use wq_has_sleeper() in
> networking stacks ?

See my first reply, I don't have objection that uses sk_data_ready() in
tun_net_xmit(). My only concern is using sk_data_ready() in
tun_detach_all():

- It was only called during tun destroying, so I believe we don't care
about the performance in this condition.
- sk_data_ready() was usually called when there's something new to be
processed which is not case in tun_detach_all()
- Not sure it was a problem but sock_def_readable() will not wake up
uninterruptible task during tun destroying.
- If we make sock_fasync() works for tun in the future, it may send
SIGIO to user process during tun destroying which is not expected.

Thanks
