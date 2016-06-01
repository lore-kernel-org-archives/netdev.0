From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 02/12] net: cls_bpf: add hardware offload
Date: Wed, 1 Jun 2016 10:13:48 -0700
Message-ID: <574F17CC.8020704@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35344 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319AbcFAROF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 13:14:05 -0400
Received: by mail-pf0-f194.google.com with SMTP id f144so4631586pfa.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 10:14:05 -0700 (PDT)
In-Reply-To: <1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 09:50 AM, Jakub Kicinski wrote:
> This patch adds hardware offload capability to cls_bpf classifier,
> similar to what have been done with U32 and flower.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---


Nice!

[...]

> +static void cls_bpf_stop_offload(struct tcf_proto *tp,
> +				 struct cls_bpf_prog *prog)
> +{
> +	struct net_device *dev = tp->q->dev_queue->dev;
> +
> +	if (!prog->offloaded)
> +		return;
> +	if (WARN_ON(!tc_should_offload(dev, 0)))
> +		return;

This warn on is a bit concerning it looks like you can get
a program stuck in hardware but removed from the software
stack. Any idea why this could happen? I think it is better
to solve the root problem or just remove this if its dbg code.

One thought is you need to block disabling the ethtool flag
if the hardware has running ebpf codes. Haven't got to the
driver patches yet though so not sure if you did this or not.
And now that I think about it I better go check the other
drivers.

> +
> +	if (cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)) {
> +		pr_err("Stopping hardware offload failed!\n");
> +		return;
> +	}
> +
> +	prog->offloaded = false;
> +}
> +
>  static int cls_bpf_init(struct tcf_proto *tp)
>  {
>  	struct cls_bpf_head *head;
> @@ -179,6 +246,7 @@ static int cls_bpf_delete(struct tcf_proto *tp, unsigned long arg)
>  {
>  	struct cls_bpf_prog *prog = (struct cls_bpf_prog *) arg;
>  
> +	cls_bpf_stop_offload(tp, prog);
>  	list_del_rcu(&prog->link);
>  	tcf_unbind_filter(tp, &prog->res);
>  	call_rcu(&prog->rcu, __cls_bpf_delete_prog);
> @@ -195,6 +263,7 @@ static bool cls_bpf_destroy(struct tcf_proto *tp, bool force)
>  		return false;
>  
>  	list_for_each_entry_safe(prog, tmp, &head->plist, link) {
> +		cls_bpf_stop_offload(tp, prog);
>  		list_del_rcu(&prog->link);
>  		tcf_unbind_filter(tp, &prog->res);
>  		call_rcu(&prog->rcu, __cls_bpf_delete_prog);
> @@ -415,6 +484,8 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
>  	if (ret < 0)
>  		goto errout;
>  
> +	cls_bpf_offload(tp, prog, oldprog);
> +
>  	if (oldprog) {
>  		list_replace_rcu(&oldprog->link, &prog->link);
>  		tcf_unbind_filter(tp, &oldprog->res);
> 


Otherwise this looks really good.

.John
