From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH v2 net-next] fix unsafe set_memory_rw from softirq
Date: Thu, 03 Oct 2013 16:02:13 -0700
Message-ID: <1380841333.19002.259.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380840466-3822-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Xi Wang <xi.wang@gmail.com>, x86@kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380840466-3822-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-10-03 at 15:47 -0700, Alexei Starovoitov wrote:
> on x86 system with net.core.bpf_jit_enable = 1
> 

> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -644,7 +644,9 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
>  	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
>  
>  	bpf_jit_free(fp);
> +#if !defined(CONFIG_X86_64) /* x86_64 has a deferred free */
>  	kfree(fp);
> +#endif

Sorry this is not very nice.

Make bpf_jit_free(fp) a bool ?  true : caller must free, false : caller
must not free ?

if (bpf_jit_free(fp))
	kfree(fp);

Or move the kfree() in bpf_jit_free()
