From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Fri, 8 Apr 2016 09:48:55 -0700
Message-ID: <20160408164854.GB28353@gmail.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <20160408123614.2a15a346@redhat.com>
 <5707916A.2030305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32874 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbcDHQs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:48:59 -0400
Received: by mail-pa0-f41.google.com with SMTP id zm5so77820320pac.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:48:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5707916A.2030305@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2016 at 01:09:30PM +0200, Daniel Borkmann wrote:
> On 04/08/2016 12:36 PM, Jesper Dangaard Brouer wrote:
> >On Thu,  7 Apr 2016 21:48:46 -0700
> >Brenden Blanco <bblanco@plumgrid.com> wrote:
> >
> >>Add a new bpf prog type that is intended to run in early stages of the
> >>packet rx path. Only minimal packet metadata will be available, hence a
> >>new context type, struct bpf_phys_dev_md, is exposed to userspace. So
> >>far only expose the readable packet length, and only in read mode.
> >>
> >>The PHYS_DEV name is chosen to represent that the program is meant only
> >>for physical adapters, rather than all netdevs.
> >>
> >>While the user visible struct is new, the underlying context must be
> >>implemented as a minimal skb in order for the packet load_* instructions
> >>to work. The skb filled in by the driver must have skb->len, skb->head,
> >>and skb->data set, and skb->data_len == 0.
> >>
> >>Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> >>---
> >>  include/uapi/linux/bpf.h | 14 ++++++++++
> >>  kernel/bpf/verifier.c    |  1 +
> >>  net/core/filter.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++++++
> >>  3 files changed, 83 insertions(+)
> >>
> >>diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> >>index 70eda5a..3018d83 100644
> >>--- a/include/uapi/linux/bpf.h
> >>+++ b/include/uapi/linux/bpf.h
> >>@@ -93,6 +93,7 @@ enum bpf_prog_type {
> >>  	BPF_PROG_TYPE_SCHED_CLS,
> >>  	BPF_PROG_TYPE_SCHED_ACT,
> >>  	BPF_PROG_TYPE_TRACEPOINT,
> >>+	BPF_PROG_TYPE_PHYS_DEV,
> >>  };
> >>
> >>  #define BPF_PSEUDO_MAP_FD	1
> >>@@ -368,6 +369,19 @@ struct __sk_buff {
> >>  	__u32 tc_classid;
> >>  };
> >>
> >>+/* user return codes for PHYS_DEV prog type */
> >>+enum bpf_phys_dev_action {
> >>+	BPF_PHYS_DEV_DROP,
> >>+	BPF_PHYS_DEV_OK,
> >>+};
> >
> >I can imagine these extra return codes:
> >
> >  BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
> >  BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
> >  BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
> >
> >The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
> >which we can look at when we get that far...
> 
> I'd probably let the tcpdump case be handled by the rest of the stack.
> Forwarding could be to some txqueue or perhaps directly to a virtual net
> device e.g. the veth end sitting in a container (where fake skb would
> need to be promoted to a real one). Or, perhaps instead of veth end,
> directly demuxed into a target socket queue in that container ...
> Alternatively for tcpdump use-case, you could also do sampling on the
> bpf_phy_dev with eBPF maps.
+1, there is plenty of infrastructure to deal with this already.
> 
> >For the "MODIFIED" case, people caring about checksumming, might want
> >to voice their concern if we want additional info or return codes,
> >indicating if software need to recalc CSUM (or e.g. if only IP-pseudo
> >hdr was modified).
> >
> >>+/* user accessible metadata for PHYS_DEV packet hook
> >>+ * new fields must be added to the end of this structure
> >>+ */
> >>+struct bpf_phys_dev_md {
> >>+	__u32 len;
> >>+};
> >
> >This is userspace visible.  I can easily imagine this structure will get
> >extended.  How does a userspace eBPF program know that the struct got
> >extended? (bet you got some scheme, normally I would add a "version" as
> >first elem).
Since fields are only ever added to the end, programs that access beyond
the struct as understood by the running kernel will be rejected. The
struct ordering is a hard requirement. We've gone through quite a few
upgrades of this style of struct and not had any issues that I am aware.
> >
> >BTW, how and where is this "struct bpf_phys_dev_md" allocated?
> 
> It isn't, see bpf_phys_dev_convert_ctx_access(). At load time the verifier
> will convert/rewrite this based on offsetof() to a real access of the per
> cpu sk_buff, that's the only purpose.
> 
> Cheers,
> Daniel
