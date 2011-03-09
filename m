From: Shirley Ma <mashirle@us.ibm.com>
Subject: TX from KVM guest virtio_net to vhost issues
Date: Wed, 09 Mar 2011 13:46:36 -0800
Message-ID: <1299707197.25664.173.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <tahm@linux.vnet.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:46196 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977Ab1CIVqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 16:46:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have lots of performance discussions about virtio_net and vhost
communication. I think it's better to have a common understandings of
the code first, then we can seek the right directions to improve it. We
also need to collect more statistics data on both virtio and vhost.

Let's look at TX first: from virtio_net(guest) to vhost(host), send vq
is shared between guest virtio_net and host vhost, it uses memory
barriers to sync the changes.

In the start:

Guest virtio_net TX send completion interrupt (for freeing used skbs) is
disable. Guest virtio_net TX send completion interrupt is enabled only
when send vq is overrun, guest needs to wait vhost to consume more
available skbs. 

Host vhost notification is enabled in the beginning (for consuming
available skbs); It is disable whenever the send vq is not empty. Once
the send vq is empty, the notification is enabled by vhost.

In guest start_xmit(), it first frees used skbs, then send available
skbs to vhost, ideally guest never enables TX send completion interrupts
to free used skbs if vhost keeps posting used skbs in send vq.

In vhost handle_tx(), it wakes up by guest whenever the send vq has a
skb to send, once the send vq is not empty, vhost exits handle_tx()
without enabling notification. Ideally if guest keeps xmit skbs in send
vq, the notification is never enabled.

I don't see issues on this implementation.

However, in our TCP_STREAM small message size test, we found that
somehow guest couldn't see more used skbs to free, which caused
frequently TX send queue overrun.

In our TCP_RR small message size multiple streams test, we found that
vhost couldn't see more xmit skbs in send vq, thus it enabled
notification too often.

What's the possible cause here in xmit? How guest, vhost are being
scheduled? Whether it's possible, guest virtio_net cooperates with vhost
for ideal performance: both guest virtio_net and vhost can be in pace
with send vq without many notifications and exits?

Thanks
Shirley



