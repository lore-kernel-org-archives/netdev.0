From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 20/24] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Thu, 6 Apr 2017 08:29:09 -0400
Message-ID: <20170406122907.GA53880@ast-mbp.thefacebook.com>
References: <149142326734.5101.4596394505987813763.stgit@warthog.procyon.org.uk>
 <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org,
        gnomes@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
        Chun-Yi Lee <jlee@suse.com>,
        linux-security-module@vger.kernel.org, keyrings@vger.kernel.org,
        gregkh@linuxfoundation.org, matthew.garrett@nebula.com
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f194.google.com ([209.85.213.194]:33743 "EHLO
        mail-yb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754077AbdDFM3O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:29:14 -0400
Content-Disposition: inline
In-Reply-To: <149142344547.5101.4518618716303032193.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 09:17:25PM +0100, David Howells wrote:
> From: Chun-Yi Lee <jlee@suse.com>
> 
> There are some bpf functions can be used to read kernel memory:
> bpf_probe_read, bpf_probe_write_user and bpf_trace_printk.  These allow
> private keys in kernel memory (e.g. the hibernation image signing key) to
> be read by an eBPF program.  Prohibit those functions when the kernel is
> locked down.
> 
> Signed-off-by: Chun-Yi Lee <jlee@suse.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: netdev@vger.kernel.org
> ---
> 
>  kernel/trace/bpf_trace.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index cee9802cf3e0..7fde851f207b 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -65,6 +65,11 @@ BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
>  {
>  	int ret;
>  
> +	if (kernel_is_locked_down()) {
> +		memset(dst, 0, size);
> +		return -EPERM;
> +	}

this will obviously break the program. How about disabling loading tracing
programs during the lockdown completely?

Also is there a description of what this lockdown trying to accomplish?
The cover letter is scarce in details.
