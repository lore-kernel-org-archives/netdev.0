From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix unsafe set_memory_rw from softirq
Date: Wed, 02 Oct 2013 21:53:02 -0700
Message-ID: <1380775982.19002.145.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380772231-3566-1-git-send-email-ast@plumgrid.com>
	 <1380774230.19002.135.camel@edumazet-glaptop.roam.corp.google.com>
	 <CAMEtUux5Fvffdg1G-aAe4XN8hJ3oUZyD2Gs3sqcwDdGf9VQ5fw@mail.gmail.com>
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
	linux-kernel@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUux5Fvffdg1G-aAe4XN8hJ3oUZyD2Gs3sqcwDdGf9VQ5fw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-02 at 21:44 -0700, Alexei Starovoitov wrote:

> I think ifdef config_x86 is a bit ugly inside struct sk_filter, but
> don't mind whichever way.

Its not fair to make sk_filter bigger, because it means that simple (non
JIT) filter might need an extra cache line.

You could presumably use the following layout instead :

struct sk_filter
{
        atomic_t                refcnt;
        struct rcu_head         rcu;
	struct work_struct      work;

        unsigned int            len ____cacheline_aligned;    /* Number of filter blocks */
        unsigned int            (*bpf_func)(const struct sk_buff *skb,
                                            const struct sock_filter *filter);
        struct sock_filter      insns[0];
};
