From: Ben Greear <greearb@candelatech.com>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 15:11:39 -0700
Message-ID: <46EB071B.9070308@candelatech.com>
References: <46DDDFFA.6090705@candelatech.com> <20070914.131225.78720330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:52984 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774AbXINWLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 18:11:47 -0400
In-Reply-To: <20070914.131225.78720330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 04 Sep 2007 15:45:14 -0700
> 
>> According to the comment in the net/core/sock.c code (in 2.6.20), I should be able to pass a zero
>> optlen to the setsockopt method for SO_BINDTODEVICE:
>  ...
>> However, earlier in that method it returns -EINVAL if optlen is < sizeof(int).
>>
>> The man page has comments similar to that in the code above.
>>
>> Also, even when I get the un-bind call working with code similar to:
>>
>> int z = 0;
>> setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, &z, sizeof(z));
>>
>> The app I'm working on (Xorp) does not appear to work.  Perhaps because
>> the kernel does not clean up the cached route when you un-bind
>> as it does in the (re)bind logic?
>>
>>                                  /* Remove any cached route for this socket. */
>>                                  sk_dst_reset(sk);
>>
> 
> Ok, the patch below is how I'm dealing with this.
> 
> Let me know if things work better now, and also I would appreciate
> it if you could contact the man page maintainers to remove the
> optlen==0 language.
> 
> Thanks.
> 
>>From 136f55cf4ad0a3b0185bfc97c68f9e4d74ddcfe7 Mon Sep 17 00:00:00 2001
> From: David S. Miller <davem@sunset.davemloft.net>
> Date: Fri, 14 Sep 2007 13:10:17 -0700
> Subject: [PATCH] [NET]: Fix two issues wrt. SO_BINDTODEVICE.
> 
> 1) Comments suggest that setting optlen to zero will unbind
>    the socket from whatever device it might be attached to.  This
>    hasn't been the case since at least 2.2.x because the first thing
>    this function does is return -EINVAL if 'optlen' is less than
>    sizeof(int).
> 
>    Furthermore, there are not "optlen == 0" tests in the
>    SO_BINDTODEVICE code either.
> 
>    This also means we can toss the "!valbool" code block because if
>    that is true we'll also see the first byte of the passed in name
>    buffer as '\0' and this will also unbind the socket.

 From user-space, does this imply that the 'empty string' we use to
unbind must be at least 4 bytes long, but with the first byte /0?

If so, I think it might be confusing for the comments to say use ""
to unbind, since that would not be a long enough chunk of memory.

Maybe something like "Use a character array of at least 4 bytes in
length with the first byte set to '/0'."

This brings up another issue as well:  What if the device name is "tr1",
to bind to it we'd have to pass in "tr1/0" and optlen of 4.  Not that this
is difficult to do, but it does seem like a weird thing to have to do.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

