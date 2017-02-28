From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: don't call strlen() on the user buffer in
 packet_bind_spkt()
Date: Tue, 28 Feb 2017 05:33:09 -0800
Message-ID: <1488288789.9415.249.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170228131759.110380-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170228131759.110380-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-02-28 at 14:17 +0100, Alexander Potapenko wrote:
> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use of
> uninitialized memory in packet_bind_spkt():
> 
> ==================================================================
> BUG: KMSAN: use of unitialized memory
> CPU: 0 PID: 1074 Comm: packet Not tainted 4.8.0-rc6+ #1891
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
> 01/01/2011
>  0000000000000000 ffff88006b6dfc08 ffffffff82559ae8 ffff88006b6dfb48
>  ffffffff818a7c91 ffffffff85b9c870 0000000000000092 ffffffff85b9c550
>  0000000000000000 0000000000000092 00000000ec400911 0000000000000002
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff82559ae8>] dump_stack+0x238/0x290 lib/dump_stack.c:51
>  [<ffffffff818a6626>] kmsan_report+0x276/0x2e0 mm/kmsan/kmsan.c:1003
>  [<ffffffff818a783b>] __msan_warning+0x5b/0xb0
> mm/kmsan/kmsan_instr.c:424
>  [<     inline     >] strlen lib/string.c:484
>  [<ffffffff8259b58d>] strlcpy+0x9d/0x200 lib/string.c:144
>  [<ffffffff84b2eca4>] packet_bind_spkt+0x144/0x230
> net/packet/af_packet.c:3132
>  [<ffffffff84242e4d>] SYSC_bind+0x40d/0x5f0 net/socket.c:1370
>  [<ffffffff84242a22>] SyS_bind+0x82/0xa0 net/socket.c:1356
>  [<ffffffff8515991b>] entry_SYSCALL_64_fastpath+0x13/0x8f
> arch/x86/entry/entry_64.o:?
> chained origin: 00000000eba00911
>  [<ffffffff810bb787>] save_stack_trace+0x27/0x50
> arch/x86/kernel/stacktrace.c:67
>  [<     inline     >] kmsan_save_stack_with_flags mm/kmsan/kmsan.c:322
>  [<     inline     >] kmsan_save_stack mm/kmsan/kmsan.c:334
>  [<ffffffff818a59f8>] kmsan_internal_chain_origin+0x118/0x1e0
> mm/kmsan/kmsan.c:527
>  [<ffffffff818a7773>] __msan_set_alloca_origin4+0xc3/0x130
> mm/kmsan/kmsan_instr.c:380
>  [<ffffffff84242b69>] SYSC_bind+0x129/0x5f0 net/socket.c:1356
>  [<ffffffff84242a22>] SyS_bind+0x82/0xa0 net/socket.c:1356
>  [<ffffffff8515991b>] entry_SYSCALL_64_fastpath+0x13/0x8f
> arch/x86/entry/entry_64.o:?
> origin description: ----address@SYSC_bind (origin=00000000eb400911)
> ==================================================================
> (the line numbers are relative to 4.8-rc6, but the bug persists
> upstream)
> 
> , when I run the following program as root:
> 
> =====================================
>  #include <string.h>
>  #include <sys/socket.h>
>  #include <netpacket/packet.h>
>  #include <net/ethernet.h>
> 
>  int main() {
>    struct sockaddr addr;
>    memset(&addr, 0xff, sizeof(addr));
>    addr.sa_family = AF_PACKET;
>    int fd = socket(PF_PACKET, SOCK_PACKET, htons(ETH_P_ALL));
>    bind(fd, &addr, sizeof(addr));
>    return 0;
>  }
> =====================================
> 
> This happens because addr.sa_data copied from the userspace is not
> zero-terminated, and copying it with strlcpy() in packet_bind_spkt()
> results in calling strlen() on the kernel copy of that non-terminated
> buffer.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  net/packet/af_packet.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 2bd0d1949312..1e7992f3e0a8 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -3111,7 +3111,11 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
>  
>  	if (addr_len != sizeof(struct sockaddr))
>  		return -EINVAL;
> -	strlcpy(name, uaddr->sa_data, sizeof(name));
> +	/* uaddr->sa_data comes from the userspace, it's not guaranteed to be
> +	 * zero-terminated.
> +	 */
> +	name[14] = '\0';
> +	strncpy(name, uaddr->sa_data, sizeof(name));
>  
>  	return packet_do_bind(sk, name, 0, pkt_sk(sk)->num);
>  }

It looks a bug in this implementation of strlcpy() then.

sizeof(name) is 15.

If you use strncpy(X, uaddr->sa_data, 15) , then you might access
uaddr->sa_data[14] and this would still be wrong, since sa_data has 14
bytes only :


struct sockaddr {
  sa_family_t sa_family;
  char        sa_data[14];
};


So I do not believe your patch is right.
