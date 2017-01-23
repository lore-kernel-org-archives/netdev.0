From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: XDP offload to hypervisor
Date: Mon, 23 Jan 2017 23:40:29 +0200
Message-ID: <20170123230727-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44264 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750705AbdAWVk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 16:40:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been thinking about passing XDP programs from guest to the
hypervisor.  Basically, after getting an incoming packet, we could run
an XDP program in host kernel.

If the result is XDP_DROP or XDP_TX we don't need to wake up the guest at all!

When using tun for networking - especially with adjust_head - this
unfortunately probably means we need to do a data copy unless there is
enough headroom.  How much is enough though?

Another issue is around host/guest ABI. Guest BPF could add new features
at any point. What if hypervisor can not support it all?  I guess we
could try loading program into hypervisor and run it within guest on
failure to load, but this ignores question of cross-version
compatibility - someone might start guest on a new host
then try to move to an old one. So we will need an option
"behave like an older host" such that guest can start and then
move to an older host later. This will likely mean
implementing this validation of programs in qemu userspace unless linux
can supply something like this. Is this (disabling some features)
something that might be of interest to larger bpf community?

With a device such as macvtap there exist configurations where a single
guest is in control of the device (aka passthrough mode) in that case
there's a potential to run xdp on host before host skb is built, unless
host already has an xdp program attached.  If it does we could run the
program within guest, but what if a guest program got attached first?
Maybe we should pass a flag in the packet "xdp passed on this packet in
host". Then, guest can skip running it.  Unless we do a full reset
there's always a potential for packets to slip through, e.g. on xdp
program changes. Maybe a flush command is needed, or force queue or
device reset to make sure nothing is going on. Does this make sense?

Thanks!

-- 
MST
