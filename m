From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] sock_diag: invert socket destroy broadcast check
Date: Fri, 24 Jun 2016 18:22:50 -0400
Message-ID: <CAF=yD-Jc7JCJJhJ7kuJQzdgbEgmG8dM3szLKLsTOhhqje8G3Fw@mail.gmail.com>
References: <1466798630-40553-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <8737o2721q.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Craig Gallek <kraig@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:33467 "EHLO
	mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcFXWXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:23:30 -0400
Received: by mail-vk0-f45.google.com with SMTP id d185so168423912vkg.0
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:23:30 -0700 (PDT)
In-Reply-To: <8737o2721q.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 4:41 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> writes:
>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Socket destruction is only broadcast for a socket sk if a diag
>> listener is registered and sk is not a kernel socket.
>>
>> Invert the test to not even check for listeners for kernel sockets.
>>
>> The sock_diag_has_destroy_listeners invocation dereferences
>> sock_net(sk), which for kernel sockets can be invalid as they do not
>> take a reference on the network namespace.
>
> No.  That isn't so.  A kernel socket for a network namespace must be
> destroyed in the network namespace teardown.

The issue would be an skbuff with a reference to that sk and
sock_wfree as destructor escaping the network namespace with that
reference intact.

Both macvlan and veth scrub packets before passing them between
namespaces. That alone should prevent this.

I'll try to reproduce with a short dedicated test on the current net branch.

>> I observed skbs queued on a device queue in another namespace from
>> a kernel socket in SOCK_DEAD state with dangling sock_net(sk). Socket
>> refcnt is zero, but sk_wmem_alloc is not. (This was on an older
>> kernel, have not yet tried to reproduce on net).
