From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net 2/3] bpf, mlx5: fix various refcount/prog issues in
 mlx5e_xdp_set
Date: Mon, 14 Nov 2016 09:35:27 -0800
Message-ID: <20161114173525.GA98186@ast-mbp.thefacebook.com>
References: <cover.1479080215.git.daniel@iogearbox.net>
 <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net>
 <20161114024908.GB94347@ast-mbp.thefacebook.com>
 <58297AAD.8060003@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, bblanco@plumgrid.com, tariqt@mellanox.com,
        zhiyisun@gmail.com, ranas@mellanox.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36197 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752812AbcKNRfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 12:35:32 -0500
Received: by mail-pf0-f193.google.com with SMTP id c4so3922089pfb.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 09:35:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <58297AAD.8060003@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 09:49:49AM +0100, Daniel Borkmann wrote:
> On 11/14/2016 03:49 AM, Alexei Starovoitov wrote:
> >On Mon, Nov 14, 2016 at 01:43:41AM +0100, Daniel Borkmann wrote:
> [...]
> >>diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> >>index 751e806..a0fca9f 100644
> >>--- a/kernel/bpf/syscall.c
> >>+++ b/kernel/bpf/syscall.c
> >>@@ -682,6 +682,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
> >>  }
> >>  EXPORT_SYMBOL_GPL(bpf_prog_add);
> >>
> >>+void bpf_prog_sub(struct bpf_prog *prog, int i)
> >>+{
> >>+	/* Only to be used for undoing previous bpf_prog_add() in some
> >>+	 * error path. We still know that another entity in our call
> >>+	 * path holds a reference to the program, thus atomic_sub() can
> >>+	 * be safely used in such cases!
> >>+	 */
> >>+	WARN_ON(atomic_sub_return(i, &prog->aux->refcnt) == 0);
> >>+}
> >>+EXPORT_SYMBOL_GPL(bpf_prog_sub);
> >
> >the patches look good. I'm only worried about net/net-next merge
> >conflict here. (I would have to deal with it as well).
> >So instead of copying the above helper can we apply net-next's
> >'bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources error path'
> >patch to net without mlx4_xdp_set hunk and then apply
> >the rest of this patch?
> >Even better is to send this patch 2/3 to net-next?
> >yes, it's an issue, but very small one. There is no security
> >concern here, so I would prefer to avoid merge conflict.
> >Did you do a test merge of net/net-next by any chance?
> 
> Yes, I did a test merge and git resolved the above just fine w/o
> any conflicts. I have no strong opinion whether net or net-next.
> If preferred, I can just resend this series in the evening against
> net-next instead, perhaps that's a bit better.

I have slight preference to go via net-next, but since it merges fine,
I don't mind net route too.
