From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Sun, 5 Jun 2016 15:53:52 +0300
Message-ID: <42e1cc6f-ad10-33b7-6722-1416e1b92422@cogentembedded.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34086 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbcFEMxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 08:53:54 -0400
Received: by mail-lf0-f50.google.com with SMTP id s186so14643652lfs.1
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 05:53:53 -0700 (PDT)
In-Reply-To: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/4/2016 7:24 PM, Daniel Borkmann wrote:

> Add a possibility where the user can just specify the parent and
> all filters under that parent are then being purged. Currently,
> for example for scripting, one needs to specify pref/prio to have
> a well-defined number for 'tc filter del' command for addressing
> the previously created instance or additionally filter handle in
> case of priorities being the same. Improve usage by allowing the
> option for tc to specify the parent and removing the whole chain
> for that given parent.
>
> Example usage after patch, no tc changes required:
>
>   # tc qdisc replace dev foo clsact
>   # tc filter add dev foo egress bpf da obj ./bpf.o
>   # tc filter add dev foo egress bpf da obj ./bpf.o
>   # tc filter show dev foo egress
>   filter protocol all pref 49151 bpf
>   filter protocol all pref 49151 bpf handle 0x1 bpf.o:[classifier] direct-action
>   filter protocol all pref 49152 bpf
>   filter protocol all pref 49152 bpf handle 0x1 bpf.o:[classifier] direct-action
>   # tc filter del dev foo egress
>   # tc filter show dev foo egress
>   #
>
> Previously, RTM_DELTFILTER requests with invalid prio of 0 were
> rejected, so only netlink requests with RTM_NEWTFILTER and NLM_F_CREATE
> flag were allowed where the kernel would auto-generate a pref/prio.
> We can piggyback on that and use prio of 0 as a wildcard for
> requests of RTM_DELTFILTER.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  net/sched/cls_api.c | 24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index a75864d..caa1dd4 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -156,11 +156,22 @@ replay:
>  	cl = 0;
>
>  	if (prio == 0) {
> -		/* If no priority is given, user wants we allocated it. */
> -		if (n->nlmsg_type != RTM_NEWTFILTER ||
> -		    !(n->nlmsg_flags & NLM_F_CREATE))
> +		switch (n->nlmsg_type) {
> +		case RTM_DELTFILTER:
> +			if (protocol || t->tcm_handle)
> +				return -ENOENT;
> +			break;
> +		case RTM_NEWTFILTER:
> +			/* If no priority is provided by the user,
> +			 * we allocate one.
> +			 */
> +			if (n->nlmsg_flags & NLM_F_CREATE) {
> +				prio = TC_H_MAKE(0x80000000U, 0U);
> +				break;
> +			}

    Need a comment here, something like /* FALL THRU */.

> +		default:
>  			return -ENOENT;
> -		prio = TC_H_MAKE(0x80000000U, 0U);
> +		}
>  	}
>
>  	/* Find head of filter chain. */
[...]

MBR, Sergei
