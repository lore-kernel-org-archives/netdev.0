From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Sun, 18 Mar 2012 05:52:01 -0700
Message-ID: <1332075121.3722.34.camel@edumazet-laptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
	 <1331704535.2456.37.camel@edumazet-laptop>
	 <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
	 <1331712357.2456.58.camel@edumazet-laptop>
	 <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
	 <1331992184.2466.45.camel@edumazet-laptop>
	 <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
 x86@kernel.org,  arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
 mingo@redhat.com, oleg@redhat.com,  peterz@infradead.org,
 rdunlap@xenotime.net, mcgrathr@chromium.org,  tglx@linutronix.de,
 luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
 djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
 akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
 coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-1143-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

Le dimanche 18 mars 2012 à 19:35 +1100, Indan Zupancic a écrit :

> Yes. The main difference would be that the JIT could always generate imm8
> offsets, saving 4 bytes per long offset while also simplifying the compiler
> code. The %rdi + 127 is 4 bytes, and if the rest become slightly faster
> because they're imm8 then it's worth the extra instruction.
> 

Do you understand you try to save 3 bytes in the function prolog, but
your single EMIT4(0x48, 0x83, 0xc7, 127); /* addq $127,%rdi */
defeats this ?

Ancillary instructions are rarely used, libpcap for example doesnt have
support for them.

> I first thought the +127 could be done in two bytes, but 4 bytes are
> needed, so maybe it's not worth it.
...
> The add 127 would be at the start, the first instruction using it would
> be a couple of instructions later, so I don't think the dependency is a
> problem.
> 
> You're right about skb_copy_bits(), I did a quick search for rdi usage
> but missed it was the first parameter too. It would need one extra
> sub 127 or add -127 in the slow path, after the push. But it's the slow
> path already, one extra instruction won't make much difference.

It will, because new NIC drivers tend to provide skbs with fragments.

Using libpcap filter like "udp[100]" calls the skb_copy_bits() helper in
this case.

There is no difference in instruction timing using offset32 or offset8,
so the code you add will slow the filter anyway.

Please dont obfuscate this code, I'd like to keep it maintainable.
