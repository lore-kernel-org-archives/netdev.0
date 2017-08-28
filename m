From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 2/9] bpf: sockmap, remove STRPARSER map_flags
 and add multi-map support
Date: Mon, 28 Aug 2017 10:31:14 -0700
Message-ID: <20170828173113.ri3llrarcuwjdulx@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141025.14143.23990.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35191 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdH1RbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:31:18 -0400
Received: by mail-pg0-f66.google.com with SMTP id r133so831861pgr.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:31:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141025.14143.23990.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:10:25AM -0700, John Fastabend wrote:
> The addition of map_flags BPF_SOCKMAP_STRPARSER flags was to handle a
> specific use case where we want to have BPF parse program disabled on
> an entry in a sockmap.
> 
> However, Alexei found the API a bit cumbersome and I agreed. Lets
> remove the STRPARSER flag and support the use case by allowing socks
> to be in multiple maps. This allows users to create two maps one with
> programs attached and one without. When socks are added to maps they
> now inherit any programs attached to the map. This is a nice
> generalization and IMO improves the API.
> 
> The API rules are less ambiguous and do not need a flag:
> 
>   - When a sock is added to a sockmap we have two cases,
> 
>      i. The sock map does not have any attached programs so
>         we can add sock to map without inheriting bpf programs.
>         The sock may exist in 0 or more other maps.
> 
>     ii. The sock map has an attached BPF program. To avoid duplicate
>         bpf programs we only add the sock entry if it does not have
>         an existing strparser/verdict attached, returning -EBUSY if
>         a program is already attached. Otherwise attach the program
>         and inherit strparser/verdict programs from the sock map.
> 
> This allows for socks to be in a multiple maps for redirects and
> inherit a BPF program from a single map.
> 
> Also this patch simplifies the logic around BPF_{EXIST|NOEXIST|ANY}
> flags. In the original patch I tried to be extra clever and only
> update map entries when necessary. Now I've decided the complexity
> is not worth it. If users constantly update an entry with the same
> sock for no reason (i.e. update an entry without actually changing
> any parameters on map or sock) we still do an alloc/release. Using
> this and allowing multiple entries of a sock to exist in a map the
> logic becomes much simpler.
> 
> Note: Now that multiple maps are supported the "maps" pointer called
> when a socket is closed becomes a list of maps to remove the sock from.
> To keep the map up to date when a sock is added to the sockmap we must
> add the map/elem in the list. Likewise when it is removed we must
> remove it from the list. This results in searching the per psock list
> on delete operation. On TCP_CLOSE events we walk the list and remove
> the psock from all map/entry locations. I don't see any perf
> implications in this because at most I have a psock in two maps. If
> a psock were to be in many maps its possibly this might be noticeable
> on delete but I can't think of a reason to dup a psock in many maps.
> The sk_callback_lock is used to protect read/writes to the list. This
> was convenient because in all locations we were taking the lock
> anyways just after working on the list. Also the lock is per sock so
> in normal cases we shouldn't see any contention.
> 
> Suggested-by: Alexei Starovoitov <ast@kernel.org>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

nice. I think implementation got cleaner too.
thanks for addresing the comments quickly!
Acked-by: Alexei Starovoitov <ast@kernel.org>

> ---
>  include/uapi/linux/bpf.h |    3 -
>  kernel/bpf/sockmap.c     |  269 ++++++++++++++++++++++++++++------------------
>  2 files changed, 165 insertions(+), 107 deletions(-)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 97227be..08c206a 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -143,9 +143,6 @@ enum bpf_attach_type {
>  
>  #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
>  
> -/* If BPF_SOCKMAP_STRPARSER is used sockmap will use strparser on receive */
> -#define BPF_SOCKMAP_STRPARSER	(1U << 0)
> -

Please update tools/include/uapi/linux/bpf.h as well.
Right now it's kinda messed up and still has:
enum bpf_sockmap_flags {
        BPF_SOCKMAP_UNSPEC,
        BPF_SOCKMAP_STRPARSER,
        __MAX_BPF_SOCKMAP_FLAG
};
that's separate patch of course. Not a blocker for this set.
