From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fixed zero copy GSO without orphaning the fragments
Date: Tue, 20 May 2014 07:28:56 -0700
Message-ID: <1400596136.5367.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400585062-13580-1-git-send-email-igorr@swortex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Simon Horman <horms@verge.net.au>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Westphal <fw@strlen.de>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Anton Nayshtut <anton@swortex.com>
To: Igor Royzis <igorr@swortex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400585062-13580-1-git-send-email-igorr@swortex.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-20 at 14:24 +0300, Igor Royzis wrote:
> Fix accessing GSO fragments memory (and a possible corruption therefore) after
> reporting completion in a zero copy callback. The previous fix in the commit 1fd819ec
> orphaned frags which eliminates zero copy advantages. The fix makes the completion
> called after all the fragments were processed avoiding unnecessary orphaning/copying
> from userspace.
> 
> The GSO fragments corruption issue was observed in a typical QEMU/KVM VM setup that
> hosts a Windows guest (since QEMU virtio-net Windows driver doesn't support GRO).
> The fix has been verified by running the HCK OffloadLSO test.
> 
> Signed-off-by: Igor Royzis <igorr@swortex.com>
> Signed-off-by: Anton Nayshtut <anton@swortex.com>
> ---
>  include/linux/skbuff.h |    1 +
>  net/core/skbuff.c      |   18 +++++++++++++-----
>  2 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 08074a8..8c49edc 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -287,6 +287,7 @@ struct skb_shared_info {
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
>  	__be32          ip6_frag_id;
> +	struct sk_buff  *zcopy_src;
>  

Before your patch :

sizeof(struct skb_shared_info)=0x140
offsetof(struct skb_shared_info, frags[1])=0x40

SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) -> 0x140

After your patch :

sizeof(struct skb_shared_info)=0x148
offsetof(struct skb_shared_info, frags[1])=0x48

SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) -> 0x180

Thats a serious bump, because it increases all skb truesizes, and
typical skb with one fragment will use 2 cache lines instead of one in
struct skb_shared_info, so this adds memory pressure in fast path.

So while this patch might increase performance for some workloads,
it generally decreases performance on many others.
