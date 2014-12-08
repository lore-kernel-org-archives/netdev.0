From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 10:07:55 -0800
Message-ID: <CA+55aFz6izpVGxkziynRXg7zbHzteQyPJH1Kg91ZO3fzqn3LaQ@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208164650.GB29028@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 8:46 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> I guess this crash is related to the patchset.

Sounds likely.

> [  102.338270] kernel BUG at /home/kas/git/public/linux-next/arch/x86/mm/physaddr.c:26!

So that's

                VIRTUAL_BUG_ON((x > y) || !phys_addr_valid(x));

and the code disassembles to:

   0: 48 01 f8             add    %rdi,%rax
   3: 48 39 c2             cmp    %rax,%rdx
   6: 72 1b                 jb     0x23
   8: 0f b6 0d 9d 7a ec 00 movzbl 0xec7a9d(%rip),%ecx        # 0xec7aac
   f: 48 89 c2             mov    %rax,%rdx
  12: 48 d3 ea             shr    %cl,%rdx
  15: 48 85 d2             test   %rdx,%rdx
  18: 75 09                 jne    0x23
  1a: 5d                   pop    %rbp
  1b: c3                   retq
  1c: 0f 1f 80 00 00 00 00 nopl   0x0(%rax)
  23:* 0f 0b                 ud2     <-- trapping instruction

with thre relevant registers being

> [  102.340011] RAX: 00004100174b4000 RBX: ffff880049c73b08 RCX: 0000000000000028
> [  102.340011] RDX: 0000000000000041 RSI: ffff88015dc980a8 RDI: ffffc900174b4000

so we've taken the second case (the %rcx value is
"boot_cpu_data.x86_phys_bits", which is that "movzbl", and the %rdx
value is the shifted value of %rax).

So %rax seems to contain 'x' at that point, which means that 'y' should be

   x - (__START_KERNEL_map - PAGE_OFFSET)

which means that the _original_ address should be that plus
__START_KERNEL_map, ie just x + PAGE_OFFSET.

So it smells like the original virtual address was that
ffffc900174b4000 that we still find in %rdi.

Which is in the vmalloc address space. So somebody used a vmalloc'ed
address and tried to convert it to a physical address in order to look
up the page.

Which is not a valid operation, and the BUG_ON() is definitely proper.

Now *why* something tried to do a virt_to_page() on a vmalloc'ed
address, that I leave to others.

                        Linus
