From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 19:27:50 +0900
Message-ID: <201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
References: <1333448001-2507-1-git-send-email-pablo@netfilter.org>
	<1333448001-2507-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:53326 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab2DCK15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 06:27:57 -0400
In-Reply-To: <1333448001-2507-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pablo@netfilter.org:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> If CONFIG_NF_CONNTRACK_TIMEOUT=n we have following warning :
> 
>   CC [M]  net/netfilter/xt_CT.o
> net/netfilter/xt_CT.c: In function ‘xt_ct_tg_check_v1’:
> net/netfilter/xt_CT.c:284: warning: label ‘err4’ defined but not used
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_CT.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
> index 0c8e438..138b75e 100644
> --- a/net/netfilter/xt_CT.c
> +++ b/net/netfilter/xt_CT.c
> @@ -281,8 +281,10 @@ out:
>  	info->ct = ct;
>  	return 0;
>  
> +#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
>  err4:
>  	rcu_read_unlock();
> +#endif
>  err3:
>  	nf_conntrack_free(ct);
>  err2:
> -- 
> 1.7.2.5

Looking at that function:

216 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
217         if (info->timeout) {
218                 typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
219                 struct ctnl_timeout *timeout;
220                 struct nf_conn_timeout *timeout_ext;
221 
222                 rcu_read_lock();
223                 timeout_find_get =
224                         rcu_dereference(nf_ct_timeout_find_get_hook);
225 
226                 if (timeout_find_get) {
227                         const struct ipt_entry *e = par->entryinfo;
228                         struct nf_conntrack_l4proto *l4proto;
229 
230                         if (e->ip.invflags & IPT_INV_PROTO) {
231                                 ret = -EINVAL;
232                                 pr_info("You cannot use inversion on "
233                                          "L4 protocol\n");
234                                 goto err4;
235                         }
236                         timeout = timeout_find_get(info->timeout);
237                         if (timeout == NULL) {
238                                 ret = -ENOENT;
239                                 pr_info("No such timeout policy \"%s\"\n",
240                                         info->timeout);
241                                 goto err4;
242                         }
243                         if (timeout->l3num != par->family) {
244                                 ret = -EINVAL;
245                                 pr_info("Timeout policy `%s' can only be "
246                                         "used by L3 protocol number %d\n",
247                                         info->timeout, timeout->l3num);
248                                 goto err4;
249                         }
250                         /* Make sure the timeout policy matches any existing
251                          * protocol tracker, otherwise default to generic.
252                          */
253                         l4proto = __nf_ct_l4proto_find(par->family,
254                                                        e->ip.proto);
255                         if (timeout->l4proto->l4proto != l4proto->l4proto) {
256                                 ret = -EINVAL;
257                                 pr_info("Timeout policy `%s' can only be "
258                                         "used by L4 protocol number %d\n",
259                                         info->timeout,
260                                         timeout->l4proto->l4proto);
261                                 goto err4;
262                         }
263                         timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
264                                                             GFP_KERNEL);
                            We are under rcu_read_lock() here.

265                         if (timeout_ext == NULL) {
266                                 ret = -ENOMEM;
267                                 goto err4;
268                         }
269                 } else {
270                         ret = -ENOENT;
271                         pr_info("Timeout policy base is empty\n");
272                         goto err4;
273                 }
274                 rcu_read_unlock();
275         }
276 #endif
