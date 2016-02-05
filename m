From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 17:39:16 -0800
Message-ID: <CA+55aFw1ofEXQUDrKehv0_sZ2XafFOJd=KwEKqW3jetrXeJu_g@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<20160204093021.GB1553@gmail.com>
	<CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
	<CA+55aFwqq6n9OOTNOXMdWN4kJX9iJoP58fZ4KwTc51enxtkqgg@mail.gmail.com>
	<CA+55aFwGt-ZCna4cEUXP2Qd39etMgJYu6MTyimP38GKV4aK_aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwGt-ZCna4cEUXP2Qd39etMgJYu6MTyimP38GKV4aK_aA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 5:27 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>         sum = csum_partial_lt8(*(unsigned long *)buff, len, sum);
>         return rotate_by8_if_odd(sum, align);

Actually, that last word-sized access to "buff" might be past the end
of the buffer. The code does the right thing if "len" is zero, except
for the possible page fault or address verifier complaint.

So that very last call to "csum_partial_lt8()" either needs to be
conditional (easy enough to add an "if (len)" around that whole
statement) or the thing could be unconditional but the load needs to
use "load_unaligned_zeropad()" so that the exception is harmless.

It's probably immaterial which one you pick. The few possibly useless
ALU operations vs a possible branch misprodict penalty are probably
going to make it a wash. The exception will never happen in practice,
but if DEBUG_PAGEALLOC is enabled, or if something like KASAN is
active, it will complain loudly if it happens to go past the
allocation.

               Linus
