From: Ian Campbell <ijc@debian.org>
Subject: Re: [PATCHv2 1/3] xen-netback: return correct ethtool
	stats
Date: Sat, 30 May 2015 11:29:02 +0100
Message-ID: <1432981742.5748.221.camel@debian.org>
References: <1425467688-12846-1-git-send-email-david.vrabel@citrix.com>
	<1425467688-12846-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
	786936@bugs.debian.org, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>, David Miller <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1425467688-12846-2-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Control: fixed -1 4.0-1~exp1

On Wed, 2015-03-04 at 11:14 +0000, David Vrabel wrote:
> Use correct pointer arithmetic to get the pointer to each stat.

I think this incorrect arithmetic was also responsible for the crash
reported in http://bugs.debian.org/786936 which was using the resulting
stray pointer.

I'll add the fix to our kernel but: David (Miller) could we also have it
queued for stable please?

Thanks.

Reasoning:

IP: [<ffffffffa06802a0>] xenvif_get_ethtool_stats+0x50/0x80 [xen_netback]

(gdb) disas xenvif_get_ethtool_stats+0x50
Dump of assembler code for function xenvif_get_ethtool_stats:
   0x0000000000005280 <+0>:	callq  0x5285 <xenvif_get_ethtool_stats+5>
   0x0000000000005285 <+5>:	mov    0x900(%rdi),%r9d
   0x000000000000528c <+12>:	mov    $0x0,%r8
   0x0000000000005293 <+19>:	lea    -0x1(%r9),%r10d
   0x0000000000005297 <+23>:	imul   $0x36258,%r10,%r10
   0x000000000000529e <+30>:	xchg   %ax,%ax
   0x00000000000052a0 <+32>:	test   %r9d,%r9d
   0x00000000000052a3 <+35>:	je     0x52f8 <xenvif_get_ethtool_stats+120>
   0x00000000000052a5 <+37>:	movzwl (%r8),%esi
   0x00000000000052a9 <+41>:	mov    0x8f8(%rdi),%rcx
   0x00000000000052b0 <+48>:	lea    0x0(,%rsi,8),%rax
   0x00000000000052b8 <+56>:	shl    $0x6,%rsi
   0x00000000000052bc <+60>:	sub    %rax,%rsi
   0x00000000000052bf <+63>:	lea    (%rcx,%rsi,1),%rax
   0x00000000000052c3 <+67>:	lea    0x36258(%rcx,%r10,1),%rcx
   0x00000000000052cb <+75>:	add    %rcx,%rsi
   0x00000000000052ce <+78>:	xor    %ecx,%ecx
   0x00000000000052d0 <+80>:	add    0x36220(%rax),%rcx
   0x00000000000052d7 <+87>:	add    $0x36258,%rax
   0x00000000000052dd <+93>:	cmp    %rsi,%rax
   0x00000000000052e0 <+96>:	jne    0x52d0 <xenvif_get_ethtool_stats+80>
   0x00000000000052e2 <+98>:	add    $0x22,%r8
   0x00000000000052e6 <+102>:	mov    %rcx,(%rdx)
   0x00000000000052e9 <+105>:	add    $0x8,%rdx
   0x00000000000052ed <+109>:	cmp    $0x0,%r8
   0x00000000000052f4 <+116>:	jne    0x52a0 <xenvif_get_ethtool_stats+32>
   0x00000000000052f6 <+118>:	repz retq 
   0x00000000000052f8 <+120>:	xor    %ecx,%ecx
   0x00000000000052fa <+122>:	jmp    0x52e2 <xenvif_get_ethtool_stats+98>
End of assembler dump.
(gdb) list *xenvif_get_ethtool_stats+0x50
0x52d0 is in xenvif_get_ethtool_stats (/build/linux-RGM_Ed/linux-3.16.7-ckt9/drivers/net/xen-netback/interface.c:349).

... and in the Debian kernel interface.c:349 is the accum += line from
the patch.

Ian.

> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index f38227a..3aa8648 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -340,12 +340,11 @@ static void xenvif_get_ethtool_stats(struct net_device *dev,
>  	unsigned int num_queues = vif->num_queues;
>  	int i;
>  	unsigned int queue_index;
> -	struct xenvif_stats *vif_stats;
>  
>  	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++) {
>  		unsigned long accum = 0;
>  		for (queue_index = 0; queue_index < num_queues; ++queue_index) {
> -			vif_stats = &vif->queues[queue_index].stats;
> +			void *vif_stats = &vif->queues[queue_index].stats;
>  			accum += *(unsigned long *)(vif_stats + xenvif_stats[i].offset);
>  		}
>  		data[i] = accum;
