From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 4/6] bpf: Add BPF_MAP_TYPE_LRU_HASH
Date: Mon, 14 Nov 2016 12:52:23 -0800
Message-ID: <20161114205222.GA1655@ast-mbp.thefacebook.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
 <1478890511-1346984-5-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33430 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932899AbcKNUw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 15:52:28 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so9803901pgd.0
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 12:52:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478890511-1346984-5-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 10:55:09AM -0800, Martin KaFai Lau wrote:
> Provide a LRU version of the existing BPF_MAP_TYPE_HASH.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
...
> +/* Instead of having one common LRU list in the
> + * BPF_MAP_TYPE_LRU_HASH map, use a percpu LRU list
> + * which can scale and perform better.
> + * Note, the LRU nodes (including free nodes) cannot be moved
> + * across different LRU lists.
> + */
> +#define BPF_F_NO_COMMON_LRU	(1U << 1)

I couldn't come up with better name, so I think it's good :)

> +	if (lru && !capable(CAP_SYS_ADMIN))
> +		/* LRU implementation is much complicated than other
> +		 * maps.  Hence, limit to CAP_SYS_ADMIN for now.
> +		 */
> +		return ERR_PTR(-EPERM);

+1
good call.

> +	if (!percpu && !lru) {
> +		/* lru itself can remove the least used element, so
> +		 * there is no need for an extra elem during map_update.
> +		 */

yeah. that's an important comment, otherwise
@@ -48,11 +52,19 @@ struct htab_elem {
 	union {
 		struct rcu_head rcu;
 		enum extra_elem_state state;
+		struct bpf_lru_node lru_node;
 	};
wouldn't be correct.

Acked-by: Alexei Starovoitov <ast@kernel.org>
