From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 16:32:32 +0200
Message-ID: <1492698752.3109.8.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
                                 (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>
                         <58F7FA6D.5030000@iogearbox.net>
                 <1492668065.3109.1.camel@sipsolutions.net>
         <58F8C160.6010905@iogearbox.net> <1492697865.3109.7.camel@sipsolutions.net>
         <58F8C59F.1040009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57418 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032747AbdDTOcn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 10:32:43 -0400
In-Reply-To: <58F8C59F.1040009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 16:28 +0200, Daniel Borkmann wrote:
> 
> I see what you mean now. Yes, that's fine. We already do something
> similar essentially with skb->ifindex access already (skb->dev +
> dev->ifindex), f.e.:
> 
> [...]
> 	case offsetof(struct __sk_buff, ifindex):
> 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex)
> != 4);
> 
> 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff,
> dev),
> 				      si->dst_reg, si->src_reg,
> 				      offsetof(struct sk_buff, dev));
> 		*insn++ = BPF_JMP_IMM(BPF_JEQ, si->dst_reg, 0, 1);
> 		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
> 				      offsetof(struct net_device,
> ifindex));
> 		break;
> [...]

Oh, right, good point.

> Which is not too different from the above. You'd probably need to
> populate the struct wifi_data each time if you place it onto the
> stack, but perhaps could be optimized by storing that somewhere
> else (e.g. somewhere via netdev, etc) and walking the pointer from
> there, which would also spare you the cb[] save/restore.

Hmm. I don't see what "somewhere else" I could possibly have though,
given that I want the (kernel-side) context to be "struct sk_buff *"
to allow the skb helpers?

johannes
