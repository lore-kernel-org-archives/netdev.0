From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Thu, 16 Mar 2017 09:58:54 -0700
Message-ID: <1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
	<1489678147-21404-8-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, peterz@infradead.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, jmorris@namei.org,
	linux-kernel@vger.kernel.org,
	Hans Liljestrand <ishkamiel@gmail.com>, kuznet@ms2.inr.ac.ru,
	kaber@trash.net, David Windsor <dwindsor@gmail.com>
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1489678147-21404-8-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 17:28 +0200, Elena Reshetova wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.


...

>  static __always_inline void sock_hold(struct sock *sk)
>  {
> -	atomic_inc(&sk->sk_refcnt);
> +	refcount_inc(&sk->sk_refcnt);
>  }
>  

While I certainly see the value of these refcount_t, we have a very
different behavior on these atomic_inc() which were doing a single
inlined LOCK RMW on x86.

We now call an external function performing a 
atomic_read(), various ops/tests, then atomic_cmpxchg_relaxed(), in a
loop, loosing the nice ability for x86 of preventing live locks.

Looks a lot of bloat, just to be able to chase hypothetical bugs in the
kernel.

I would love to have a way to enable extra debugging when I want a debug
kernel, like LOCKDEP or KASAN.

By adding all this bloat, we assert linux kernel is terminally buggy and
every atomic_inc() we did was suspicious, and need to be always
instrumented/validated.
