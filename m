From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] netns: deinline net_generic()
Date: Tue, 14 Apr 2015 14:36:03 +0200
Message-ID: <20150414123603.GD2022@nanopsycho.lan>
References: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429014311-19868-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Apr 14, 2015 at 02:25:11PM CEST, dvlasenk@redhat.com wrote:
>On x86 allyesconfig build:
>The function compiles to 130 bytes of machine code.
>It has 493 callsites.
>Total reduction of vmlinux size: 27906 bytes.

Hmm. That is not much. How about performance impacts?

>
>   text	     data      bss       dec     hex filename
>82447071 22255384 20627456 125329911 77861f7 vmlinux4
>82419165 22255384 20627456 125302005 777f4f5 vmlinux5
>
>Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>CC: Eric W. Biederman <ebiederm@xmission.com>
>CC: David S. Miller <davem@davemloft.net>
>CC: Jan Engelhardt <jengelh@medozas.de>
>CC: Jiri Pirko <jpirko@redhat.com>
>CC: linux-kernel@vger.kernel.org
>CC: netdev@vger.kernel.org
>---
> include/net/netns/generic.h | 15 +--------------
> net/core/net_namespace.c    | 16 ++++++++++++++++
> 2 files changed, 17 insertions(+), 14 deletions(-)
>
>diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
>index 0931618..61a33bf 100644
>--- a/include/net/netns/generic.h
>+++ b/include/net/netns/generic.h
>@@ -31,18 +31,5 @@ struct net_generic {
> 	void *ptr[0];
> };
> 
>-static inline void *net_generic(const struct net *net, int id)
>-{
>-	struct net_generic *ng;
>-	void *ptr;
>-
>-	rcu_read_lock();
>-	ng = rcu_dereference(net->gen);
>-	BUG_ON(id == 0 || id > ng->len);
>-	ptr = ng->ptr[id - 1];
>-	rcu_read_unlock();
>-
>-	BUG_ON(!ptr);
>-	return ptr;
>-}
>+void *net_generic(const struct net *net, int id);
> #endif
>diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>index cb5290b..66c9ba1 100644
>--- a/net/core/net_namespace.c
>+++ b/net/core/net_namespace.c
>@@ -42,6 +42,22 @@ EXPORT_SYMBOL(init_net);
> 
> static unsigned int max_gen_ptrs = INITIAL_NET_GEN_PTRS;
> 
>+void *net_generic(const struct net *net, int id)
>+{
>+	struct net_generic *ng;
>+	void *ptr;
>+
>+	rcu_read_lock();
>+	ng = rcu_dereference(net->gen);
>+	BUG_ON(id == 0 || id > ng->len);
>+	ptr = ng->ptr[id - 1];
>+	rcu_read_unlock();
>+
>+	BUG_ON(!ptr);
>+	return ptr;
>+}
>+EXPORT_SYMBOL(net_generic);
>+
> static struct net_generic *net_alloc_generic(void)
> {
> 	struct net_generic *ng;
>-- 
>1.8.1.4
>
