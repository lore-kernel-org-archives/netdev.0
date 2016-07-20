From: Paul Moore <paul@paul-moore.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 20 Jul 2016 16:13:25 -0400
Message-ID: <CAHC9VhQWBPA9qi_0=eY-xMTrqshujE5n7zP32ZjpDKLG5w7OuA@mail.gmail.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <7d833f59-c68f-f779-4de4-15bc0b26ac7c@cumulusnetworks.com>
 <66709b13-15a7-8d03-9e84-e4be9aab60b5@schaufler-ca.com> <9998a0da-b273-43d4-84ad-a0539e6a69ac@cumulusnetworks.com>
 <5de95a23-fd64-d911-d4b0-88de51ab12a4@schaufler-ca.com> <9cb32128-176b-85cf-8ea8-465704f667e7@cumulusnetworks.com>
 <6d1249a6-6176-414e-0df8-d7df8dac1cbd@schaufler-ca.com> <79be6a80-f8e4-c386-f877-2c0d52609892@cumulusnetworks.com>
 <5f0df0df-8542-2938-9d19-0bf49f4b12b7@schaufler-ca.com> <c2101773-754f-df08-06e1-62652c416a44@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34420 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755058AbcGTUN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 16:13:27 -0400
Received: by mail-oi0-f41.google.com with SMTP id l65so87707363oib.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 13:13:26 -0700 (PDT)
In-Reply-To: <c2101773-754f-df08-06e1-62652c416a44@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 7:37 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> Digging into this further I have determined that the
> circumstances leading to this issue are somewhat complex.
> The good news is that there seems to be a very limited
> circumstances under which the problem manifests.
>
> I have a socket, and change the Smack attributes on the
> socket (security_inode_setsecurity) before connecting to
> a server.

This is a minty fresh, disconnected socket, yes?

> The connect succeeds. The client sends a packet,
> also successfully. The response is received. Now here's
> where it gets interesting. I instrumented the code to print
> the Smack attributes on the socket both before and after
> the Smack access check.

I'm assuming that when you say "access check" you are talking about
the smk_access() call in smack_socket_sock_rcv_skb(), yes?

(as a totally unrelated side note, you really went nuts on the cpp
conditionals in there, was there a sale on #ifdefs that I missed? <g>)

> Before the check is made the Smack
> data reflects the initial values from when the socket was
> created. After the check, they reflect the explicit change
> made earlier.

It has been too long since I looked at how Smack handled network
packets, I assume this is not the intended behavior?

> The check reports failure based on the initial
> values. As a result, an attempt to notify the caller that
> the action failed is made (netlbl_skbuff_err) which results
> in a call to icmp_send that frees already freed memory.

What memory is being double freed?  The original skb?  I don't believe
netlbl_skbuff_err(), cipso_v4_error(), or icmp_send() frees the
original skb ... or rather it shouldn't, perhaps I'm missing
something.

I'm not arguing, you saw what you saw, I'm just trying to understand
and make sense of it.  Can you elaborate on what you saw, using very
small words, and concrete descriptions (I'm much more stupider than
everyone here so you have to make it easy for me to understand)?

> If the Smack attributes in the sk_security blob are not
> explicitly set the problem does not occur. I have the same
> result if I change the Smack attributes within the socket
> security blob as I do if I replace the security blob.

-- 
paul moore
www.paul-moore.com
