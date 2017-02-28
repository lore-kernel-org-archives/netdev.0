From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 11:46:23 -0800
Message-ID: <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com> <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Linux API <linux-api@vger.kernel.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:33154 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdB1UNa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 15:13:30 -0500
Received: by mail-ua0-f172.google.com with SMTP id x24so26505008uab.0
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 12:13:17 -0800 (PST)
In-Reply-To: <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 10:57 AM, Michael Kerrisk
<mtk.manpages@gmail.com> wrote:
> [CC += linux-api@vger.kernel.org]
>
> Hi Willem
>

>> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
>> creates skbuff fragments directly from these pages. On tx completion,
>> it notifies the socket owner that it is safe to modify memory by
>> queuing a completion notification onto the socket error queue.

What happens if the user writes to the pages while it's not safe?

How about if you're writing to an interface or a route that has crypto
involved and a malicious user can make the data change in the middle
of a crypto operation, thus perhaps leaking the entire key?  (I
wouldn't be at all surprised if a lot of provably secure AEAD
constructions are entirely compromised if an attacker can get the
ciphertext and tag computed from a message that changed during the
computation.

I can see this working if you have a special type of skb that
indicates that the data might be concurrently written and have all the
normal skb APIs (including, especially, anything that clones it) make
a copy first.

--Andy
