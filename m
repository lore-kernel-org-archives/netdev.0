From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Wed, 26 Oct 2016 21:59:33 +0200
Message-ID: <20161026195933.GA2031@salvia>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44674 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934533AbcJZT7m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Oct 2016 15:59:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 5D011C882D
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 21:59:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4DEA3DA849
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 21:59:37 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F06B1DA853
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 21:59:34 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1477390454-12553-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 25, 2016 at 12:14:08PM +0200, Daniel Mack wrote:
[...]
>   Dumping programs once they are installed is problematic because of
>   the internal optimizations done to the eBPF program during its
>   lifetime. Also, the references to maps etc. would need to be
>   restored during the dump.
> 
>   Just exposing whether or not a program is attached would be
>   trivial to do, however, most easily through another bpf(2)
>   command. That can be added later on though.

I don't know if anyone told you, but during last netconf, this topic
took a bit of time of discussion and it was controversial, I would say
1/3 of netdev hackers there showed their concerns, and that's
something that should not be skipped IMO.

While xdp is pushing bpf programs at the very early packet path, not
interfering with the stack, before even entering the generic ingress
path. But this is adding hooks to push bpf programs in the middle of
our generic stack, this is way different domain.

I would really like to explore way earlier filtering, by extending
socket lookup facilities. So far the problem seems to be that we need
to lookup for broadcast/multicast UDP sockets and those cannot be
attach via the usual skb->sk. I think it would be possible to wrap
around this socket code in functions so we can invoke it. I guess
filtering of UDP and TCP should be good for you at this stage. This
would require more work though, but this would come with no hooks in
the stack and packets will not have to consume *lots of cycles* just
to be dropped before entering the socket queue.

How useful can be to drop lots of unwanted traffic at such a late
stage? How would the performance numbers to drop packets would look
like? Extremely bad, I predict.
