From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 01/15] bpf: BPF support for socket ops
Date: Mon, 19 Jun 2017 20:44:02 +0200
Message-ID: <59481B72.2050307@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-2-brakmo@fb.com> <5943CA1A.2060006@iogearbox.net> <1274D98B-287D-492C-88CC-A14617EB8AAC@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <Kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54676 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754335AbdFSSoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:44:12 -0400
In-Reply-To: <1274D98B-287D-492C-88CC-A14617EB8AAC@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2017 01:41 AM, Lawrence Brakmo wrote:
> On 6/16/17, 5:07 AM, "Daniel Borkmann" <daniel@iogearbox.net> wrote:
[...]
> I see. You are saying have one struct in common but still keep the two
> PROG_TYPES? That makes sense. Do we really need two different
> is_valid_access functions? Both types should be able to see all
> the fields (otherwise adding new fields becomes messy).

Would probably leave the two is_valid_access() separate initially, and
once people ask for it we could potentially open this up to some of
the other fields that are available at that time.

>      > Currently there are two types of ops. The first type expects the BPF
>      > program to return a value which is then used by the caller (or a
>      > negative value to indicate the operation is not supported). The second
>      > type expects state changes to be done by the BPF program, for example
>      > through a setsockopt BPF helper function, and they ignore the return
>      > value.
[...]
>      > +/* Call BPF_SOCKET_OPS program that returns an int. If the return value
>      > + * is < 0, then the BPF op failed (for example if the loaded BPF
>      > + * program does not support the chosen operation or there is no BPF
>      > + * program loaded).
>      > + */
>      > +#ifdef CONFIG_BPF
>      > +static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
>      > +{
>      > +	struct bpf_socket_ops_kern socket_ops;
>      > +
>      > +	memset(&socket_ops, 0, sizeof(socket_ops));
>      > +	socket_ops.sk = sk;
>      > +	socket_ops.is_req_sock = is_req_sock ? 1 : 0;
>
>      Is is_req_sock actually used here in this patch (apart from setting it)?
>      Not seeing that BPF prog will access it, if it also shouldn't access it,
>      then bool type would be better.
>
> The only reason I used a bit was in case I wanted to add more fields later on.
> Does it make sense or should I just use bool?

Didn't know that, but I think starting out with bool seems a bit
cleaner, if needed we could later still switch to bitfield.

>      > +	socket_ops.op = op;
>      > +
>      > +	return bpf_socket_ops_call(&socket_ops);
>      > +}
[...]
>      > +/* Global BPF program for sockets */
>      > +static struct bpf_prog *bpf_socket_ops_prog;
>      > +static DEFINE_RWLOCK(bpf_socket_ops_lock);
>      > +
>      > +int bpf_socket_ops_set_prog(int fd)
>      > +{
>      > +	int err = 0;
>      > +
>      > +	write_lock(&bpf_socket_ops_lock);
>      > +	if (bpf_socket_ops_prog) {
>      > +		bpf_prog_put(bpf_socket_ops_prog);
>      > +		bpf_socket_ops_prog = NULL;
>      > +	}
>      > +
>      > +	/* fd of zero is used as a signal to remove the current
>      > +	 * bpf_socket_ops_prog.
>      > +	 */
>      > +	if (fd == 0) {
>
>      Can we make the fd related semantics similar to dev_change_xdp_fd()?
>
> Do you mean remove program is fd < 0 instead of == 0?

Yes, that and also the ordering of dropping the ref of the existing
bpf_socket_ops_prog program with setting the new one, so you can
convert bpf_socket_ops_prog to RCU more easily.

>      > +		write_unlock(&bpf_socket_ops_lock);
>      > +		return 1;
>      > +	}
>      > +
>      > +	bpf_socket_ops_prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_OPS);
>      > +	if (IS_ERR(bpf_socket_ops_prog)) {
>      > +		bpf_prog_put(bpf_socket_ops_prog);
>
>      This will crash the kernel, passing err value to bpf_prog_put().
[...]
