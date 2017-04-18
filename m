From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: XDP question: best API for returning/setting egress port?
Date: Tue, 18 Apr 2017 21:58:56 +0200
Message-ID: <20170418215856.5fda7127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48236 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755272AbdDRT7D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 15:59:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I argued in NetConf presentation[1] (from slide #9) we need a port
mapping table (instead of using ifindex'es).  Both for supporting
other "port" types than net_devices (think sockets), and for
sandboxing what XDP can bypass.

I want to create a new XDP action called XDP_REDIRECT, that instruct
XDP to send the xdp_buff to another "port" (get translated into a
net_device, or something else depending on internal port type).

Looking at the userspace/eBPF interface, I'm wondering what is the
best API for "returning" this port number from eBPF?

The options I see is:

1) Split-up the u32 action code, and e.g let the high-16-bit be the
   port number and lower-16bit the (existing) action verdict.

 Pros: Simple API
 Cons: Number of ports limited to 64K

2) Extend both xdp_buff + xdp_md to contain a (u32) port number, allow
   eBPF to update xdp_md->port.

 Pros: Larger number of ports.
 Cons: This require some ebpf translation steps between xdp_buff <-> xdp_md.
       (see xdp_convert_ctx_access)

3) Extend only xdp_buff and create bpf_helper that set port in xdp_buff.

 Pros: Hides impl details, and allows helper to give eBPF code feedback
       (on e.g. if port doesn't exist any longer)
 Cons: Helper function call likely slower?


(Cc'ed xdp-newbies as end-users might have an opinion on UAPI?)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[1] http://people.netfilter.org/hawk/presentations/NetConf2017/xdp_work_ahead_NetConf_April_2017.pdf
