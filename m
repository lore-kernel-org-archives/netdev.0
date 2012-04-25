From: Jiang Liu <liuj97@gmail.com>
Subject: Re: [PATCH v1 6/8] dmaengine: enhance network subsystem to support
 DMA device hotplug
Date: Wed, 25 Apr 2012 23:47:19 +0800
Message-ID: <4F981C87.60403@gmail.com>
References: <1335189109-4871-1-git-send-email-jiang.liu@huawei.com> <1335189109-4871-7-git-send-email-jiang.liu@huawei.com> <CABE8wwvi_Yz8AyALr1-uDW9xSgrSqfrYWhB_22NQ2ydTa81+mg@mail.gmail.com> <4F961041.7010106@huawei.com> <CABE8wwvW9MUWaqSUCPMr7_yj7XGtSj+X9VE1-xWrEusZ3TMaqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiang Liu <jiang.liu@huawei.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Keping Chen <chenkeping@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABE8wwvW9MUWaqSUCPMr7_yj7XGtSj+X9VE1-xWrEusZ3TMaqQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,
	Thanks for your great comments about the performance penalty issue. And I'm trying
to refine the implementation to reduce penalty caused by hotplug logic. If the algorithm works
correctly, the optimized hot path code will be:

------------------------------------------------------------------------------
struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
{
        struct dma_chan *chan = this_cpu_read(channel_table[tx_type]->chan);

        this_cpu_inc(dmaengine_chan_ref_count);
        if (static_key_false(&dmaengine_quiesce)) {
                chan = NULL;
        }

        return chan;
}
EXPORT_SYMBOL(dma_find_channel);

struct dma_chan *dma_get_channel(struct dma_chan *chan)
{
        if (static_key_false(&dmaengine_quiesce))
                atomic_inc(&dmaengine_dirty);
        this_cpu_inc(dmaengine_chan_ref_count);

        return chan;
}
EXPORT_SYMBOL(dma_get_channel);

void dma_put_channel(struct dma_chan *chan)
{
        this_cpu_dec(dmaengine_chan_ref_count);
}
EXPORT_SYMBOL(dma_put_channel);
-----------------------------------------------------------------------------

The disassembled code is:
(gdb) disassemble dma_find_channel 
Dump of assembler code for function dma_find_channel:
   0x0000000000000000 <+0>:	push   %rbp
   0x0000000000000001 <+1>:	mov    %rsp,%rbp
   0x0000000000000004 <+4>:	callq  0x9 <dma_find_channel+9>
   0x0000000000000009 <+9>:	mov    %edi,%edi
   0x000000000000000b <+11>:	mov    0x0(,%rdi,8),%rax
   0x0000000000000013 <+19>:	mov    %gs:(%rax),%rax
   0x0000000000000017 <+23>:	incq   %gs:0x0				//overhead: this_cpu_inc(dmaengine_chan_ref_count)
   0x0000000000000020 <+32>:	jmpq   0x25 <dma_find_channel+37>	//overhead: if (static_key_false(&dmaengine_quiesce)), will be replaced as NOP by jump label
   0x0000000000000025 <+37>:	pop    %rbp
   0x0000000000000026 <+38>:	retq   
   0x0000000000000027 <+39>:	nopw   0x0(%rax,%rax,1)
   0x0000000000000030 <+48>:	xor    %eax,%eax
   0x0000000000000032 <+50>:	pop    %rbp
   0x0000000000000033 <+51>:	retq   
End of assembler dump.
(gdb) disassemble dma_put_channel 	// overhead: to decrease channel reference count, 6 instructions
Dump of assembler code for function dma_put_channel:
   0x0000000000000070 <+0>:	push   %rbp
   0x0000000000000071 <+1>:	mov    %rsp,%rbp
   0x0000000000000074 <+4>:	callq  0x79 <dma_put_channel+9>
   0x0000000000000079 <+9>:	decq   %gs:0x0
   0x0000000000000082 <+18>:	pop    %rbp
   0x0000000000000083 <+19>:	retq   
End of assembler dump.
(gdb) disassemble dma_get_channel 
Dump of assembler code for function dma_get_channel:
   0x0000000000000040 <+0>:	push   %rbp
   0x0000000000000041 <+1>:	mov    %rsp,%rbp
   0x0000000000000044 <+4>:	callq  0x49 <dma_get_channel+9>
   0x0000000000000049 <+9>:	mov    %rdi,%rax
   0x000000000000004c <+12>:	jmpq   0x51 <dma_get_channel+17>
   0x0000000000000051 <+17>:	incq   %gs:0x0
   0x000000000000005a <+26>:	pop    %rbp
   0x000000000000005b <+27>:	retq   
   0x000000000000005c <+28>:	nopl   0x0(%rax)
   0x0000000000000060 <+32>:	lock incl 0x0(%rip)        # 0x67 <dma_get_channel+39>
   0x0000000000000067 <+39>:	jmp    0x51 <dma_get_channel+17>
End of assembler dump.

So for a typical dma_find_channel()/dma_put_channel(), the total overhead
is about 10 instructions and two percpu(local) memory updates. And there's
no shared cache pollution any more. Is this acceptable ff the algorithm 
works as expected? I will test the code tomorrow.

For typical systems which don't support DMA device hotplug, the overhead
could be completely removed by condition compilation.

Any comments are welcomed!

Thanks!
--gerry


On 04/24/2012 11:09 AM, Dan Williams wrote:
>>> If you are going to hotplug the entire IOH, then you are probably ok
