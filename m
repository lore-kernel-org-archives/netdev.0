From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC 02/12] bpf: offload: add infrastructure for loading
 programs for a specific netdev
Date: Tue, 31 Oct 2017 22:23:42 -0700
Message-ID: <20171101052340.qjbsurtvzkc3gf6k@ast-mbp>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
 <20171101015217.10666-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net, bblanco@gmail.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:43900 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdKAFXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 01:23:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id a8so1101676pfc.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 22:23:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101015217.10666-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 06:52:07PM -0700, Jakub Kicinski wrote:
> The fact that we don't know which device the program is going
> to be used on is quite limiting in current eBPF infrastructure.
> We have to reverse or limit the changes which kernel makes to
> the loaded bytecode if we want it to be offloaded to a networking
> device.  We also have to invent new APIs for debugging and
> troubleshooting support.
> 
> Make it possible to load programs for a specific netdev.  This
> helps us to bring the debug information closer to the core
> eBPF infrastructure (e.g. we will be able to reuse the verifer
> log in device JIT).  It allows device JITs to perform translation
> on the original bytecode.
> 
> __bpf_prog_get() when called to get a reference for an attachment
> point will now refuse to give it if program has a device assigned.
> Following patches will add a version of that function which passes
> the expected netdev in.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
...
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 0b7b54d898bd..d6775e0da8a5 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -259,6 +259,8 @@ union bpf_attr {
>  		__u32		kern_version;	/* checked when prog_type=kprobe */
>  		__u32		prog_flags;
>  		char		prog_name[BPF_OBJ_NAME_LEN];
> +
> +		__u32		prog_ifindex;	/* ifindex of netdev to prep for */

since it removes second invocation of the verifier from the driver
I'm all for it.
May be call it 'target_ifindex' ?
Since it's more than just program offload. With addition of ifindex
we can make the verifier reject the program at load time if it's using
some map type that is not supported by HW or using BPF_DIV insn that
is not supported and so on. There will be plenty of error cases and
showing them to the users early via verifier log would be
convenient and familiar interface.
At prog load time you can probably reserve hw resources for maps too
and reuse verifier log for it as well if maps don't fit and so on.
Then final attach via netlink will be more like 'commit'.

> +
> +	rtnl_lock();
> +	offload->netdev = __dev_get_by_index(net, attr->prog_ifindex);

netdev grabing and releasing logic looks fine.

> +int bpf_prog_offload_verifier_prep(struct bpf_verifier_env *env)
> +{
> +	struct netdev_bpf data = {};
> +	int err;
> +
> +	data.verifier.prog = env->prog;
> +
> +	rtnl_lock();
> +	err = __bpf_offload_ndo(env->prog, BPF_OFFLOAD_VERIFIER_PREP, &data);
> +	if (err)
> +		goto exit_unlock;
> +
> +	env->dev_ops = data.verifier.ops;
> +
> +	env->prog->aux->offload->dev_state = true;
> +	env->prog->aux->offload->verifier_running = true;
...
> +static void __bpf_prog_offload_destroy(struct bpf_prog *prog)
> +{
> +	struct bpf_dev_offload *offload = prog->aux->offload;
> +	struct netdev_bpf data = {};
> +
> +	data.offload.prog = prog;
> +
> +	if (offload->verifier_running)
> +		wait_event(offload->verifier_done, !offload->verifier_running);
...
> +static int bpf_prog_offload_translate(struct bpf_prog *prog)
> +{
> +	struct bpf_dev_offload *offload = prog->aux->offload;
> +	struct netdev_bpf data = {};
> +	int ret;
> +
> +	data.offload.prog = prog;
> +
> +	offload->verifier_running = false;
> +	wake_up(&offload->verifier_done);

the verifier_running logic I don't quite follow.
Why is it necessary?

> -static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
> +static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *attach_type)
>  {
>  	struct fd f = fdget(ufd);
>  	struct bpf_prog *prog;
> @@ -1062,7 +1065,7 @@ static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
>  	prog = ____bpf_prog_get(f);
>  	if (IS_ERR(prog))
>  		return prog;
> -	if (type && prog->type != *type) {
> +	if (attach_type && (prog->type != *attach_type || prog->aux->offload)) {

that's independent variable rename. why?
