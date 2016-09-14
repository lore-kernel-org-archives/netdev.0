From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v5 0/6] Add eBPF hooks for cgroups
Date: Wed, 14 Sep 2016 08:55:21 -0700
Message-ID: <20160914155519.GA48309@ast-mbp.thefacebook.com>
References: <1473696735-11269-1-git-send-email-daniel@zonque.org>
 <20160913115627.GA4898@salvia>
 <da300784-284c-0d1f-a82e-aa0a0f8ae116@zonque.org>
 <20160913172408.GC6138@salvia>
 <6de6809a-13f5-4000-5639-c760dde30223@zonque.org>
 <57D937B9.2090100@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57D937B9.2090100-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 01:42:49PM +0200, Daniel Borkmann wrote:
> >As I said, I'm open to discussing that. In order to make it work for L3,
> >the LL_OFF issues need to be solved, as Daniel explained. Daniel,
> >Alexei, any idea how much work that would be?
> 
> Not much. You simply need to declare your own struct bpf_verifier_ops
> with a get_func_proto() handler that handles BPF_FUNC_skb_load_bytes,
> and verifier in do_check() loop would need to handle that these ld_abs/
> ld_ind are rejected for BPF_PROG_TYPE_CGROUP_SOCKET.

yep. that part is solvable.
I'm still torn between l2 and l3.
On one side it sux to lose l2 information. yet we don't have a use case
to look into l2 for our container monitoring, so the only thing
lack of l2 will do is confuse byte accounting, since instead of
skb->len, we'd need to do skb->len + ETH_HLEN...
but I guess vlan handling messes it up as well.
On the other side doing it at socket level we can drop these checks:
+       if (!sk || !sk_fullsock(sk))
+               return 0;
+
+       if (sk->sk_family != AF_INET &&
+           sk->sk_family != AF_INET6)
+               return 0;
which will make it even faster when it's on.
So I don't mind either l2 and l3. I guess if l3 approach will prove
to be limiting, we can add l2 later?
