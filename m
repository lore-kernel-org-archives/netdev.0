From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 14:10:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB5483@AcuExch.aculab.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
 <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
 <20170320131629.GA26405@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "ishkamiel@gmail.com" <ishkamiel@gmail.com>,
        "dwindsor@gmail.com" <dwindsor@gmail.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320131629.GA26405@gondor.apana.org.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu
> Sent: 20 March 2017 13:16
> On Mon, Mar 20, 2017 at 11:39:37AM +0100, Peter Zijlstra wrote:
> >
> > Can we at least give a benchmark and have someone run numbers? We should
> > be able to quantify these things.
> 
> Do you realise how many times this thing gets hit at 10Gb/s or
> higher? Anyway, since you're proposing this change you should
> demonstrate that it does not cause a performance regression.

What checks does refcnt_t actually do?

An extra decrement is hard to detect since the item gets freed early.
I guess making the main 'allocate/free' code hold (say) 64k references
would give some leeway for extra decrements.

An extra increment will be detected when the count eventually wraps.
Unless the error is in a very common path that won't happen for a long time.

On x86 the cpu flags from the 'lock inc/dec' could be used to reasonably
cheaply detect errors - provided you actually generate a forwards branch.

Otherwise having a common, but not every packet, code path verify that the
reference count is 'sane' would give reasonable coverage.

	David
