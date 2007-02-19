From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Mon, 19 Feb 2007 15:56:23 -0800
Message-ID: <20070219155623.1d78785a@localhost.localdomain>
References: <20070219231447.GA4400@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bert hubert <bert.hubert@netherlabs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43263 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965564AbXBSX4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 18:56:34 -0500
In-Reply-To: <20070219231447.GA4400@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Feb 2007 00:14:47 +0100
bert hubert <bert.hubert@netherlabs.nl> wrote:

> Hi people,
> 
> I'm trying to save people the cost of buying extra servers by making
> PowerDNS (GPL) ever faster, but I've hit a rather fundamental problem.
> 
> Linux 2.6.20-rc4 appears to take 4 microseconds on my P4 3GHz for a
> non-blocking UDPv4 recvfrom() call, both on loopback and ethernet.
> 
> Linux 2.6.18 on my 64 bit Athlon64 3200+ takes a similar amount of time.
> 
> This seems like rather a lot for a 50 byte datagram, but perhaps I'm
> overestimating your abilities :-)
> 
> The program is unthreaded, and I measure like this:
> 
> #define RDTSC(qp) \
> do { \
>   unsigned long lowPart, highPart;					\
>   __asm__ __volatile__("rdtsc" : "=a" (lowPart), "=d" (highPart)); \
>     qp = (((unsigned long long) highPart) << 32) | lowPart; \
> } while (0)
> 
> ...
> 
> uint64_t tsc1, tsc2;
> RDTSC(tsc1);      
> 
> if((len=recvfrom(fd, data, sizeof(data), 0, (sockaddr *)&fromaddr, &addrlen)) >= 0) { 
>     RDTSC(tsc2);      
>     printf("%f\n", (tsc2-tsc1)/3000.0);  // 3GHz P4
> }
> 
> gdb generates the following dump from the actual program,
> x=_Z20handleNewUDPQuestioniRN5boost3anyE, I see nothing untoward happening
> between the two 'rdtsc' opcodes.
> 
> 0x08091de0 <x+0>:  push   %ebp
> 0x08091de1 <x+1>:  mov    %esp,%ebp
> 0x08091de3 <x+3>:  push   %edi
> 0x08091de4 <x+4>:  push   %esi
> 0x08091de5 <x+5>:  push   %ebx
> 0x08091de6 <x+6>:  sub    $0x78c,%esp
> 0x08091dec <x+12>: mov    %gs:0x14,%eax
> 0x08091df2 <x+18>: mov    %eax,0xffffffe4(%ebp)
> 0x08091df5 <x+21>: xor    %eax,%eax
> 0x08091df7 <x+23>: movw   $0x2,0xffffffac(%ebp)
> 0x08091dfd <x+29>: movl   $0x0,0xffffffb0(%ebp)
> 0x08091e04 <x+36>: movw   $0x0,0xffffffae(%ebp)
> 0x08091e0a <x+42>: movl   $0x1c,0xfffff8f4(%ebp)
> 0x08091e14 <x+52>: rdtsc  
> 0x08091e16 <x+54>: mov    %edx,%ebx
> 0x08091e18 <x+56>: mov    0x8(%ebp),%edx
> 0x08091e1b <x+59>: mov    %eax,%esi
> 0x08091e1d <x+61>: lea    0xfffff8f4(%ebp),%eax
> 0x08091e23 <x+67>: mov    %eax,0x14(%esp)
> 0x08091e27 <x+71>: lea    0xffffffac(%ebp),%ecx
> 0x08091e2a <x+74>: lea    0xfffff950(%ebp),%eax
> 0x08091e30 <x+80>: mov    %ecx,0x10(%esp)
> 0x08091e34 <x+84>: movl   $0x0,0xc(%esp)
> 0x08091e3c <x+92>: movl   $0x5dc,0x8(%esp)
> 0x08091e44 <x+100>:        mov    %eax,0x4(%esp)
> 0x08091e48 <x+104>:        mov    %edx,(%esp)
> 0x08091e4b <x+107>:        call   0x8192110 <recvfrom>
> 0x08091e50 <x+112>:        test   %eax,%eax
> 0x08091e52 <x+114>:        mov    %eax,0xfffff8b0(%ebp)
> 0x08091e58 <x+120>:        js     0x8092168 <x+904>
> 0x08091e5e <x+126>:        mov    %ebx,%eax
> 0x08091e60 <x+128>:        xor    %edx,%edx
> 0x08091e62 <x+130>:        mov    %eax,%edx
> 0x08091e64 <x+132>:        mov    $0x0,%eax
> 0x08091e69 <x+137>:        mov    %esi,%ecx
> 0x08091e6b <x+139>:        mov    %eax,%esi
> 0x08091e6d <x+141>:        or     %ecx,%esi
> 0x08091e6f <x+143>:        mov    %edx,%edi
> 0x08091e71 <x+145>:        rdtsc  
> 0x08091e73 <x+147>:        mov    %eax,0xfffff8a0(%ebp)
> 0x08091e79 <x+153>:        mov    0xfffff8a0(%ebp),%eax
> 0x08091e7f <x+159>:        mov    %edx,%ecx
> 0x08091e81 <x+161>:        xor    %ebx,%ebx
> 0x08091e83 <x+163>:        mov    %ecx,%ebx
> 
> recvfrom itself is a tad worrisome, x=recvfrom. I didn't ask for the
> 'libc_enable_asynccancel' stuff. I'm trying to isolate the actual syscall
> but it is proving hard work for an assemnly newbie like me - socketcall
> doesn't make things easier.
> 
> 0xb7d62410 <x+0>:        cmpl   $0x0,%gs:0xc
> 0xb7d62418 <x+8>:        jne    0xb7d62439 <x+41>
> 0xb7d6241a <x+10>:       mov    %ebx,%edx
> 0xb7d6241c <x+12>:       mov    $0x66,%eax
> 0xb7d62421 <x+17>:       mov    $0xc,%ebx
> 0xb7d62426 <x+22>:       lea    0x4(%esp),%ecx
> 0xb7d6242a <x+26>:       call   *%gs:0x10
> 0xb7d62431 <x+33>:       mov    %edx,%ebx
> 0xb7d62433 <x+35>:       cmp    $0xffffff83,%eax
> 0xb7d62436 <x+38>:       jae    0xb7d62469 <x+89>
> 0xb7d62438 <x+40>:       ret    
> 0xb7d62439 <x+41>:       push   %esi
> 0xb7d6243a <x+42>:       call   0xb7d6ddd0 <__libc_enable_asynccancel>
> 0xb7d6243f <x+47>:       mov    %eax,%esi
> 0xb7d62441 <x+49>:       mov    %ebx,%edx
> 0xb7d62443 <x+51>:       mov    $0x66,%eax
> 0xb7d62448 <x+56>:       mov    $0xc,%ebx
> 0xb7d6244d <x+61>:       lea    0x8(%esp),%ecx
> 0xb7d62451 <x+65>:       call   *%gs:0x10
> 0xb7d62458 <x+72>:       mov    %edx,%ebx
> 0xb7d6245a <x+74>:       xchg   %eax,%esi
> 0xb7d6245b <x+75>:       call   0xb7d6dd90 <__libc_disable_asynccancel>
> 0xb7d62460 <x+80>:       mov    %esi,%eax
> 0xb7d62462 <x+82>:       pop    %esi
> 0xb7d62463 <x+83>:       cmp    $0xffffff83,%eax
> 0xb7d62466 <x+86>:       jae    0xb7d62469 <x+89>
> 0xb7d62468 <x+88>:       ret    
> 0xb7d62469 <x+89>:       call   0xb7d998f8 <__i686.get_pc_thunk.cx>
> 0xb7d6246e <x+94>:       add    $0x61b86,%ecx
> 0xb7d62474 <x+100>:      mov    0xffffff2c(%ecx),%ecx
> 0xb7d6247a <x+106>:      xor    %edx,%edx
> 0xb7d6247c <x+108>:      sub    %eax,%edx
> 0xb7d6247e <x+110>:      mov    %edx,%gs:(%ecx)
> 0xb7d62481 <x+113>:      or     $0xffffffff,%eax
> 0xb7d62484 <x+116>:      jmp    0xb7d62438 <x+40>
> 
> Any clues?
> 

Use oprofile to find the hotspot.
