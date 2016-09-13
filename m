From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Tue, 13 Sep 2016 13:56:27 +0200
Message-ID: <20160913115627.GA4898@salvia>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36016 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751044AbcIML4h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 07:56:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B075B12A690
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 13:56:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A14E6100795
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 13:56:34 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5A8911150D3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 13:56:32 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1473696735-11269-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Sep 12, 2016 at 06:12:09PM +0200, Daniel Mack wrote:
> This is v5 of the patch set to allow eBPF programs for network
> filtering and accounting to be attached to cgroups, so that they apply
> to all sockets of all tasks placed in that cgroup. The logic also
> allows to be extendeded for other cgroup based eBPF logic.

1) This infrastructure can only be useful to systemd, or any similar
   orchestration daemon. Look, you can only apply filtering policies
   to processes that are launched by systemd, so this only works
   for server processes. For client processes this infrastructure is
   *racy*, you have to add new processes in runtime to the cgroup,
   thus there will be time some little time where no filtering policy
   will be applied. For quality of service, this may be an acceptable
   race, but this is aiming to deploy a filtering policy.

2) This aproach looks uninfrastructured to me. This provides a hook
   to push a bpf blob at a place in the stack that deploys a filtering
   policy that is not visible to others. We have interfaces that allows
   us to dump the filtering policy that is being applied, report events
   to enable cooperation between several processes with similar
   capabilities and so on.  For the XDP thing, this ability to push
   blobs may be fine as long as it will not interfer with the stack so
   we can provide an alternative to DPDK in Linux. For tracing, that's
   fine too since it is innocuous. And likely for other applications is
   a good fit. But I don't think this is the case.

> After chatting with Daniel Borkmann and Alexei off-list, we concluded
> that __dev_queue_xmit() is the place where the egress hooks should live
> when eBPF programs need access to the L2 bits of the skb.

3) This egress hook is coming very late, the only reason I find to
   place it at __dev_queue_xmit() is that bpf naturally works with
   layer 2 information in place. But this new hook is placed in
   _everyone's output ath_ that only works for the very specific
   usecase I exposed above.

The main concern during the workshop was that a hook only for cgroups
is too specific, but this is actually even more specific than this.

I have nothing against systemd or the needs for more
programmability/flexibility in the stack, but I think this needs to
fulfill some requirements to fit into the infrastructure that we have
in the right way.
