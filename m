From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nfnetlink: Improve input length sanitization
 in nfnetlink_rcv
Date: Wed, 07 Jun 2017 06:23:41 -0700
Message-ID: <1496841821.736.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170607123551.25075-1-mjurczyk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mateusz Jurczyk <mjurczyk@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607123551.25075-1-mjurczyk@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-06-07 at 14:35 +0200, Mateusz Jurczyk wrote:
> Verify that the length of the socket buffer is sufficient to cover the
> entire nlh->nlmsg_len field before accessing that field for further
> input sanitization. If the client only supplies 1-3 bytes of data in
> sk_buff, then nlh->nlmsg_len remains partially uninitialized and
> contains leftover memory from the corresponding kernel allocation.
> Operating on such data may result in indeterminate evaluation of the
> nlmsg_len < NLMSG_HDRLEN expression.
> 
> The bug was discovered by a runtime instrumentation designed to detect
> use of uninitialized memory in the kernel. The patch prevents this and
> other similar tools (e.g. KMSAN) from flagging this behavior in the future.
> 
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
> ---
>  net/netfilter/nfnetlink.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
> index 80f5ecf2c3d7..c634cfca40ec 100644
> --- a/net/netfilter/nfnetlink.c
> +++ b/net/netfilter/nfnetlink.c
> @@ -491,7 +491,8 @@ static void nfnetlink_rcv(struct sk_buff *skb)
>  {
>  	struct nlmsghdr *nlh = nlmsg_hdr(skb);
>  
> -	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
> +	if (skb->len < sizeof(nlh->nlmsg_len) ||

This assumes nlmsg_len is first field of the structure.

offsetofend() might be more descriptive, one does not have to check the
structure to make sure the code is correct.

Or simply use the more common form :

	if (skb->len < NLMSG_HDRLEN ||

> +	    nlh->nlmsg_len < NLMSG_HDRLEN ||
>  	    skb->len < nlh->nlmsg_len)
>  		return;
>  
