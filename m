From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Tue, 18 Oct 2016 17:21:53 -0400
Message-ID: <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------703D9C15C32FF00268C60B07"
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35924 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933394AbcJRVV4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 17:21:56 -0400
Received: by mail-io0-f195.google.com with SMTP id o141so553291ioe.3
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 14:21:55 -0700 (PDT)
In-Reply-To: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------703D9C15C32FF00268C60B07
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 16-10-18 04:18 PM, Daniel Borkmann wrote:
> While trying out [1][2], I noticed that tc monitor doesn't show the
> correct handle on delete:
>
>   $ tc monitor
>   qdisc clsact ffff: dev eno1 parent ffff:fff1
>   filter dev eno1 ingress protocol all pref 49152 bpf handle 0x2a [...]
>   deleted filter dev eno1 ingress protocol all pref 49152 bpf handle 0xf3be0c80
>
> In fact, the shown handle points to a kernel address, in this case
> 0xffff8807f3be0c80, which points to a struct cls_bpf_prog from bpf
> classifier.
>
> The issue is not bpf specific though. tcf_fill_node() sets a fh as
> tcm->tcm_handle, which gets overridden on != RTM_DELTFILTER events
> only. For RTM_DELTFILTER events, we cannot call the classifier's
> dump() handler, since notification is given after delete() handler
> returned with success.
>
> At latest when a classifier's dump() handler is called, tm->tcm_handle
> is filled with an actual handle. They are currently classifier
> internal, meaning a tcf_proto can handle multiple classifiers if
> the implementation supports it, so it needs to be queried from the
> callback.
>
> For RTM_DELTFILTER, the fh value contains the address of the object
> to dump. Commit 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
> added the logic to assign tcm->tcm_handle = fh. tcm_handle is 32bit
> so for 64bit archs, it's stored truncated. Prior to that commit, it
> was set to 0. Reintroduce this, so we at least don't leak the kernel
> address or parts of it to unprivileged user space listeners.
>
> Since user space cannot make any sense out of this 32bit part,
> passing a random number would be just as good. Lets pass 0, since i)
> this allows to add the feature at some point for net-next, and ii)
> this is also consistent with notifications via tfilter_notify_chain()
> when we delete the entire chain.
>
>   [1] http://patchwork.ozlabs.org/patch/682828/
>   [2] http://patchwork.ozlabs.org/patch/682829/
>
> Fixes: 4e54c4816bfe ("[NET]: Add tc extensions infrastructure.")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  ( Commit is in -history tree. Jamal, please take a look if you have
>    a chance, thanks. )
>
>  net/sched/cls_api.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 2ee29a3..e11bdc5 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -400,12 +400,11 @@ static int tcf_fill_node(struct net *net, struct sk_buff *skb,
>  	tcm->tcm__pad2 = 0;
>  	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
>  	tcm->tcm_parent = tp->classid;
> +	tcm->tcm_handle = 0;
>  	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
>  	if (nla_put_string(skb, TCA_KIND, tp->ops->kind))
>  		goto nla_put_failure;
> -	tcm->tcm_handle = fh;
>  	if (RTM_DELTFILTER != event) {
> -		tcm->tcm_handle = 0;
>  		if (tp->ops->dump && tp->ops->dump(net, tp, fh, skb, tcm) < 0)
>  			goto nla_put_failure;
>  	}
>


I was sitting on this patch I was going to send ;->
Does this resolve it?

cheers,
jamal



--------------703D9C15C32FF00268C60B07
Content-Type: text/plain; charset=UTF-8;
 name="patch-u32-handle-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-u32-handle-fix"

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 2ee29a3..2b2a797 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -345,7 +345,8 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 			if (err == 0) {
 				struct tcf_proto *next = rtnl_dereference(tp->next);
 
-				tfilter_notify(net, skb, n, tp, fh,
+				tfilter_notify(net, skb, n, tp,
+					       t->tcm_handle,
 					       RTM_DELTFILTER, false);
 				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);

--------------703D9C15C32FF00268C60B07--
