From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 net-next 3/4] secure_seq: use SipHash in place of MD5
Date: Sat, 7 Jan 2017 14:09:11 -0800
Message-ID: <20170107220911.GB8327@zzz>
References: <20170107144057.15432-1-Jason@zx2c4.com>
 <20170107144057.15432-4-Jason@zx2c4.com>
 <20170107.163736.2224609477435674963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ak@linux.intel.com,
        David.Laight@aculab.com, tom@herbertland.com,
        hannes@stressinduktion.org, eric.dumazet@gmail.com, luto@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170107.163736.2224609477435674963.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sat, Jan 07, 2017 at 04:37:36PM -0500, David Miller wrote:
> From: "Jason A. Donenfeld" <Jason@zx2c4.com>
> Date: Sat,  7 Jan 2017 15:40:56 +0100
> 
> > This gives a clear speed and security improvement. Siphash is both
> > faster and is more solid crypto than the aging MD5.
[snip]
> 
> This and the next patch are a real shame, performance wise, on cpus
> that have single-instruction SHA1 and MD5 implementations.  Sparc64
> has both, and I believe x86_64 can do SHA1 these days.
> 
> It took so long to get those instructions into real silicon, and then
> have software implemented to make use of them as well.
> 
> Who knows when we'll see SipHash widely deployed in any instruction
> set, if at all, right?  And by that time we'll possibly find out that
> "Oh shit, this SipHash thing has flaws!" and we'll need
> DIPPY_DO_DA_HASH and thus be forced back to a software implementation
> again.
> 
> I understand the reasons why these patches are being proposed, I just
> thought I'd mention the issue of cpus that implement secure hash
> algorithm instructions.

Well, except those instructions aren't actually used in these places.  Although
x86_64 SHA1-NI accelerated SHA-1 is available in the Linux crypto API, it seems
that in kernel code it remains impractical to use these instructions on small
amounts of data because they use XMM registers, which means the overhead of
kernel_fpu_begin()/kernel_fpu_end() must be incurred.  Furthermore,
kernel_fpu_begin() is not allowed in all contexts so there has to be a fallback.

Out of curiosity, is this actually a solvable problem, e.g. by making the code
using the XMM registers responsible for saving and restoring the ones clobbered,
or by optimizing kernel_fpu_begin()/kernel_fpu_end()?  Or does it in fact remain
impractical for such instructions to be used for applications like this one?

Eric
