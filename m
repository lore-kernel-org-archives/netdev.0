From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] sock_diag: invert socket destroy broadcast check
Date: Wed, 13 Jul 2016 13:48:54 -0400
Message-ID: <CAF=yD-+tvv=S3Grw8=UrD2m4w+_n7VGAbQgX9iruOppQnKCbEw@mail.gmail.com>
References: <1466798630-40553-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <8737o2721q.fsf@x220.int.ebiederm.org> <CAF=yD-Jc7JCJJhJ7kuJQzdgbEgmG8dM3szLKLsTOhhqje8G3Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Craig Gallek <kraig@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:36292 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbcGMRtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 13:49:36 -0400
Received: by mail-vk0-f43.google.com with SMTP id j126so21861401vkg.3
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 10:49:35 -0700 (PDT)
In-Reply-To: <CAF=yD-Jc7JCJJhJ7kuJQzdgbEgmG8dM3szLKLsTOhhqje8G3Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 6:22 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> On Fri, Jun 24, 2016 at 4:41 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Willem de Bruijn <willemdebruijn.kernel@gmail.com> writes:
>>
>>> From: Willem de Bruijn <willemb@google.com>
>>>
>>> Socket destruction is only broadcast for a socket sk if a diag
>>> listener is registered and sk is not a kernel socket.
>>>
>>> Invert the test to not even check for listeners for kernel sockets.
>>>
>>> The sock_diag_has_destroy_listeners invocation dereferences
>>> sock_net(sk), which for kernel sockets can be invalid as they do not
>>> take a reference on the network namespace.
>>
>> No.  That isn't so.  A kernel socket for a network namespace must be
>> destroyed in the network namespace teardown.

I spent some more time looking at this.

inet_ctl_sock_destroy does not destroy the socket if there are still
skbuff with a reference on it (or its sk_wmem_alloc). Skbs are
orphaned when they leave the namespace through dev_forward_skb, but
not when sent out a physical nic (correctly, that would break TSQ).

The bug happened with macvlan on top of bonding on top of a physical
nic. The macvlan lives in a temporary namespace. After the macvlan and
network namespace are destroyed, the physical device has a TCP RST skb
from net.ipv4->tcp_sk queued for tx completion.

I have not able to reproduce this exact scenario, likely because tx
completion handling is on the order of microseconds and not easily
slowed sufficiently for testing. Using a tap device with skb_orphan
commented out, I can cause the issue. Commenting out skb_orrphan is
clearly a gross hack. The point I wanted to verify is that underlying
device is not stopped --and its queues cleaned of skb-- when the
macvlan device is destroyed.

Network namespace teardown is complex. Am I missing a step that does
prevents the above, or does this indeed sound feasible in principle
(if very unlikely in practice)?
