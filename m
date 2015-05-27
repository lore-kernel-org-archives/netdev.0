From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: __inet_hash_connect port_offset parameter
Date: Wed, 27 May 2015 09:18:18 -0700
Message-ID: <1432743498.4060.399.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5565E202.8010202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36456 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbbE0QSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 12:18:22 -0400
Received: by iepj10 with SMTP id j10so17414153iep.3
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 09:18:22 -0700 (PDT)
In-Reply-To: <5565E202.8010202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 18:25 +0300, Crestez Dan Leonard wrote:
> Hello,
> 
> I'm confused about the port_offset parameter to __inet_hash_connect.
> 
> When allocating the local port for an outgoing TCP connection the port
> search looks something like this:
> 
>     static u32 hint;
>     u32 offset = hint + port_offset;
> 
>     inet_get_local_port_range(net, &low, &high);
>     remaining = (high - low) + 1;
> 
>     for (i = 1; i <= remaining; i++) {
>         port = low + (i + offset) % remaining;
>         /* check port is free */
> 
> The port_offset is calculated for v4 and v6 based on a hash of src/dst
> addresses, presumably in order to improve security.
> 
> I see a few issues with this:
>  - The port_offset is calculated even if the local port was already
> assigned via bind. This wastes a few cycles.

OK. Not a big deal I guess.

>  - Keeping the last searched port as a static variable is a bad idea
> on multicore cpus. Starting a lot of connections to the same target
> will result in lock contention in the bind hash. This is probably only
> visible in highly synthetic tests.

Not really. This is a hint only.

I have one patch adding an array of hints, but this does not change
behavior if connecting to same target.

u32 key = port_offset % HINTS_SZ;

>  - When doing a port search at bind() time the search starts from
> "prandom_32()". Is this "less secure" for port allocation? I bet most
> applications are not aware of this difference.

I am afraid we need to keep a sequential search for ephemeral port
selection.

This known behavior is described in RFC 6056

> 
> Wouldn't it be better to use the same local port search mechanism at
> both bind (inet_csk_get_port) and connect (__inet_hash_connect) time,
> based on starting from a random point? It would also make connecting
> slightly faster.

Nope, bind() and connect() have different semantics.

The randomization is only good for bind(port=0) users.

Have you seen my proposal ?

https://patchwork.ozlabs.org/patch/476002/
