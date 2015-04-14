From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 06:19:32 -0700
Message-ID: <1429017572.7346.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jiri Pirko <jpirko@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-04-14 at 14:25 +0200, Denys Vlasenko wrote:
> On x86 allyesconfig build:
> The function compiles to 130 bytes of machine code.
> It has 493 callsites.
> Total reduction of vmlinux size: 27906 bytes.
> 
>    text	     data      bss       dec     hex filename
> 82447071 22255384 20627456 125329911 77861f7 vmlinux4
> 82419165 22255384 20627456 125302005 777f4f5 vmlinux5

This sounds a big hammer to me.

These savings probably comes from the BUG_ON() that could simply be
removed.
The second one for sure has no purpose. First one looks defensive.

For a typical (non allyesconfig) kernel, net_generic() would translate
to :

return net->gen[id - 1]


Tunnels need this in fast path, so I presume we could introduce
net_generic_rcu() to keep this stuff inlined where it matters.

static inline void *net_generic_rcu(const struct net *net, int id)
{
	struct net_generic *ng = rcu_dereference(net->gen);

	return ng->ptr[id - 1];
}
