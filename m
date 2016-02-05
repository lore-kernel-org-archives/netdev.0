From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 5 Feb 2016 10:07:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD6FBB@AcuExch.aculab.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
 <20160204093021.GB1553@gmail.com>
 <CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
 <CALx6S37+F9UnyDuOgXHKqhNQvBXoQe8G2GCWPbhZE8QBdmz3vg@mail.gmail.com>
 <20160205080136.GA31671@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	the arch/x86 maintainers <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: 'Ingo Molnar' <mingo@kernel.org>, Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160205080136.GA31671@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar
...
> As Linus noticed, data lookup tables are the intelligent solution: if you manage
> to offload the logic into arithmetics and not affect the control flow then that's
> a big win. The inherent branching will be hidden by executing on massively
> parallel arithmetics units which effectively execute everything fed to them in a
> single cycle.

Not necessarily, in real-life they are likely to be a cache miss.

With the parallel execution units you just need to worry about the
register dependency chains.
In this case the 'adc' have dependencies on both the result register
and the flags register.

The best loop might even be:
10:	adc	%rax,0(%rdi,%rcx)
	lea	%rcx,8(%rcx)
	jcxz	20f
	jmp	10b
20:

You then need to insert just enough copies of the adc so they take as long
as the other instructions.

	David
