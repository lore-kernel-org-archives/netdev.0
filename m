From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] xdp: implement xdp_redirect_map for generic
 XDP
Date: Wed, 06 Sep 2017 19:02:49 +0200
Message-ID: <59B02A39.4060603@iogearbox.net>
References: <150471158528.3727.12324542627400287360.stgit@firesoul> <59B02127.5020904@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36829 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754364AbdIFRCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 13:02:53 -0400
In-Reply-To: <59B02127.5020904@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2017 06:24 PM, Daniel Borkmann wrote:
[...]
> Otherwise it looks good, but note that it also doesn't really
> resolve the issue you mention wrt stale map pointers by the
> way. This would need a different way to clear out the pointers
> from redirect_info, I'm thinking when we have devmap dismantle
> time after RCU grace period we should check whether there are
> still stale pointers from this map around and clear them under
> disabled preemption, but need to brainstorm a bit more on that
> first.

Scratch that approach, doesn't work. So thinking bit more on
this, what we could do here is the following: verifier knows
we called bpf_xdp_redirect_map() helper, so it could do a small
insn rewrite in the sense that it fills R4 with a pointer to
the bpf_prog. We have that at verification time anyway and R4
is allowed to be populated since we scratch it per convention.
Then, the helper would store the prog pointer in struct redirect_info.
Later in xdp_do_*_redirect() we check whether the redirect_info's
prog pointer is the same as passed xdp_prog pointer, and if
that's the case then all good, since the prog holds a ref on
the map anyway, if they are not equal in the unlikely case, it
means stale pointer, so we bail out right there. That would
work imo, will see to code it up and check it out.
