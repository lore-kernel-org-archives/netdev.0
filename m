From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 15:43:23 -0500
Message-ID: <CAF=yD-K_0zO3pMeXf-UKGTsD4sNOdyN9KJkUb5MnCO_J5pisrA@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com> <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Kerrisk <mtk.manpages@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36556 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdB1Uwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 15:52:44 -0500
Received: by mail-wr0-f193.google.com with SMTP id l37so3042600wrc.3
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 12:52:43 -0800 (PST)
In-Reply-To: <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 2:46 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Feb 27, 2017 at 10:57 AM, Michael Kerrisk
> <mtk.manpages@gmail.com> wrote:
>> [CC += linux-api@vger.kernel.org]
>>
>> Hi Willem
>>
>
>>> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
>>> creates skbuff fragments directly from these pages. On tx completion,
>>> it notifies the socket owner that it is safe to modify memory by
>>> queuing a completion notification onto the socket error queue.
>
> What happens if the user writes to the pages while it's not safe?
>
> How about if you're writing to an interface or a route that has crypto
> involved and a malicious user can make the data change in the middle
> of a crypto operation, thus perhaps leaking the entire key?  (I
> wouldn't be at all surprised if a lot of provably secure AEAD
> constructions are entirely compromised if an attacker can get the
> ciphertext and tag computed from a message that changed during the
> computation.

Operations that read or write payload, such as this crypto example,
but also ebpf in tc or iptables, for instance, demand a deep copy using
skb_copy_ubufs before the operation.

This blacklist approach requires caution, but these paths should be
few and countable. It is not possible to predict at the socket layer
whether a packet will encounter any such operation, so white-listing
a subset of end-to-end paths is not practical.

> I can see this working if you have a special type of skb that
> indicates that the data might be concurrently written and have all the
> normal skb APIs (including, especially, anything that clones it) make
> a copy first.

Support for cloned skbs is required for TCP, both at tcp_transmit_skb
and segmentation offload. Patch 4 especially adds reference counting
of shared pages across clones and other sk_buff operations like
pskb_expand_head. This still allows for deep copy (skb_copy_ubufs)
on clones in specific datapaths like the above.
