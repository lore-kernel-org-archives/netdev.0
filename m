From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Mon, 7 Jan 2008 19:26:12 -0800 (PST)
Message-ID: <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53736 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753610AbYAHD00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 22:26:26 -0500
In-Reply-To: <4782CF9C.6000508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 7 Jan 2008, Kevin Winchester wrote:

> J. Bruce Fields wrote:
> > 
> > Is there any good basic documentation on this to point people at?
> 
> I would second this question.  I see people "decode" oops on lkml often 
> enough, but I've never been entirely sure how its done.  Is it somewhere 
> in Documentation?

It's actually not necessarily at all that trivial, unless you have a deep 
understanding of the code generated for the architecture in question (and 
even then, some oopses take more time to figure out than others, thanks 
to inlining and tailcalls etc).

If the oops happened with a kernel you generated yourself, it's usually 
rather easy. Especially if you said "y" to the "generate debugging info" 
question at configuration time. Because, in that case, you really just do 
a simple

	gdb vmlinux

and then you can do (for example) something like setting a breakpoint at 
the EIP that was reported for the oops, and it will tell you what line it 
came from.

However, if you don't have the exact binary - which is the common case for 
random oopses reported on lkml - you will generally have to disassemble 
the hex sequence given in the oops (the "Code:" line), and try to match it 
up against the source code to try to figure out what is going on.

Even just the disassembly is not entirely trivial, since the oops will 
give you the eip that it happened at, but you often want to also 
disassemble *backwards* in order to get more of a context (the "Code:" 
line will mark the particular EIP that starts the oopsing instruction by 
enclosing it in <xx>, but with non-constant instruction lengths, you need 
to use a bit of trial-and-error to figure it out.

I usually just compile a small program like

	const char array[]="\xnn\xnn\xnn...";

	int main(int argc, char **argv)
	{
		printf("%p\n", array);
		*(int *)0=0;
	}

and run it under gdb, and then when it gets the SIGSEGV (due to the 
obvious NULL pointer dereference), I can just ask gdb to disassemble 
around the array that contains the code[] stuff. Try a few offsets, to see 
when the disassembly makes sense (and gives the reported EIP as the 
beginning of one of the disassembled instructions).

(You can do it other and smarter ways too, I'm not claiming that's a 
particularly good way to do it, and the old "ksymoops" program used to do 
a pretty good job of this, but I'm used to that particular idiotic way 
myself, since it's how I've basically always done it)

After that, you still need to try to match up the assembly code with the 
source code and figure out what variables the register contents actually 
are all about. You can often try to do a

	make the/affected/file.s

to generate the asm file in your own tree - the register allocation can be 
totally different due to different compilers and different options (and 
things like the fact that maybe the source tree you do this on doesn't 
match the oops report exactly), but it's usually a good starting point to 
compare the disassembly from gdb with the *.s file output from the 
compiler.

Quite often, it's all very obvious (you see some constant or other simple 
pattern). But if you're not used to the assembly format, you'll spend a 
lot of brainpower just trying to figure that part out even for the obvious 
stuff, which is why it's a good thing if you are very comfortable indeed 
with the assembly language of that particular platform.

It's not really all that hard. But the first few times you see those 
oopses, it all looks mostly like just line noise. So it definitely takes 
some practice to do it well.

Anyway, let's take an example, from

	http://lkml.org/lkml/2008/1/1/189

where the most obviously relevant parts are:

	BUG: unable to handle kernel paging request at virtual address 00100100
	EIP:    0060:[<f8819668>] 
	EIP is at evdev_disconnect+0x65/0x9e

	eax: 00000000   ebx: 000ffcf0   ecx: c1926760   edx: 00000033
	esi: f7415600   edi: f741564c   ebp: f7415654   esp: c1967e68
	Call Trace:
		[<c03454b2>] input_unregister_device+0x6f/0xff
		[<c03c6eb6>] klist_release+0x27/0x30
		[<c029178a>] kref_put+0x5f/0x6c
	..
	Code: 5e 4c 81 eb 10 04 00 00 eb 21 8d 83 08 04 00 00 b9 06 00 02 
	      00 ba 1d 00 00 00 e8 6a 93 95 c7 8b 9b 10 04 00 00 81 eb 10 
	      04 00 00 <8b> 83 10 04 00 00 0f 18 00 90 8d 83 10 04 00 00 
	      39 f8 75 cb 8d

so here let's do the above silly C program:

	const char array[]="\x5e\x4c\x81\xeb\x10\x04\x00\x00\xeb\x21..

and running it under gdb gives:

	0x8048500

	Program received signal SIGSEGV, Segmentation fault.
	0x080483f7 in main () at test.c:14
	14              *(int*)0=0;

and now I can just try

	x/20i 0x8048500

and it turns out that already gives a reasonable disassembly. The first 
few instructions are bogus: they're really part of the previous 
instruction, but it looks pretty sane around the actual problem spot, 
which is "array+43" (there are 42 bytes of code before the EIP one, and 20 
bytes after):

	0x8048500 <array>:      pop    %esi
	0x8048501 <array+1>:    dec    %esp
	0x8048502 <array+2>:    sub    $0x410,%ebx
	0x8048508 <array+8>:    jmp    0x804852b <array+43>
	0x804850a <array+10>:   lea    0x408(%ebx),%eax
	0x8048510 <array+16>:   mov    $0x20006,%ecx
	0x8048515 <array+21>:   mov    $0x1d,%edx
	0x804851a <array+26>:   call   0xcf9a1889
	0x804851f <array+31>:   mov    0x410(%ebx),%ebx
	0x8048525 <array+37>:   sub    $0x410,%ebx
	0x804852b <array+43>:   mov    0x410(%ebx),%eax
	0x8048531 <array+49>:   prefetchnta (%eax)
	0x8048534 <array+52>:   nop
	0x8048535 <array+53>:   lea    0x410(%ebx),%eax
	0x804853b <array+59>:   cmp    %edi,%eax
	0x804853d <array+61>:   jne    0x804850a <array+10>
	0x804853f <array+63>:   lea    (%eax),%eax
	.. 

so now we know that the faulting instruction was that

	mov    0x410(%ebx),%eax

and we can also see that this also matches the address that caused the 
oops (ebx=000ffcf0, so 0x410(%ebx) is 00100100, which matches the "unable 
to handle kernel paging request" message).

(Now, people used to kernel oopses will also recognize 00100100 as the 
LIST_POISON1, so this is all about dereferencing the ->next pointer of a 
list entry that has been removed from the list, but that's a whole 
separate level of kernel knowledge).

Anyway, you can now do

	make drivers/input/evdev.s

and see if you can find that kind of code sequence in there. You can use 
the "EIP: evdev_disconnect+0x65/0x9e" thing as a hint: if your compiler 
setup isn't too different, it's likely to be roughly two thirds into that 
evdev_disconnect function (but inlining really can mean that it's 
somewhere else entirely in the source tree!)

The rest left as an exercise for the reader.

		Linus
