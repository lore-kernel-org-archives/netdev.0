From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Wed, 11 Oct 2017 18:40:26 +0800
Message-ID: <20171011104026.GE29971@leo.usersys.redhat.com>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
 <20171002103708.0572704b@xeon-e3>
 <20171009202525.GR32278@orbyte.nwl.cc>
 <20171010064117.ipyarf5ml7fwnzdv@unicorn.suse.cz>
 <20171010094743.6ae2baa8@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>, Phil Sutter <phil@nwl.cc>,
        netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52894 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdJKKkc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 06:40:32 -0400
Content-Disposition: inline
In-Reply-To: <20171010094743.6ae2baa8@shemminger-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,
On Tue, Oct 10, 2017 at 09:47:43AM -0700, Stephen Hemminger wrote:
> > Agreed. Current code is based on the assumption that we can estimate the
> > maximum reply length in advance and the reason for this series is that
> > this assumption turned out to be wrong. I'm afraid that if we replace
> > it by an assumption that we can estimate the maximum reply length for
> > most requests with only few exceptions, it's only matter of time for us
> > to be proven wrong again.
> > 
> > Michal Kubecek
> > 
> 
> For query responses, yes the response may be large. But for the common cases of
> add address or add route, the response should just be ack or error.

I tried to list 10 NIC links with ip cmd.

With unpatched ip cmd:
# time for i in `seq 100000`; do ip link show &> /dev/null; done

real    5m14.591s
user    0m58.134s
sys     4m21.104s


With patched ip cmd:
# time for i in `seq 100000`; do ./ip link show &> /dev/null; done

real    4m48.579s
user    0m8.570s
sys     4m43.460s


Then tested add 99,00 address via script
# cat add_addr.sh
#!/bin/bash
dev=$1
for vid in $(seq 99); do
        ip link add link $dev name ${dev}.$vid type vlan id $vid
        ip link set ${dev}.$vid up
        for n in $(seq 100); do
                ip addr add 20$vid::$n dev ${dev}.$vid
        done
done

with unpatched ip cmd:
# time ./add_addr.sh p7p1

real    0m13.456s
user    0m2.551s
sys     0m11.106s


With patched ip cmd:
# time ./add_addr.sh p7p1

real    0m13.700s
user    0m2.827s
sys     0m11.148s


The result don't have much difference and looks good. And I wonder if adding
thousands of address is a common case.

Thanks
Hangbin
