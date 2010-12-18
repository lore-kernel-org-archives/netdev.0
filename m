From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH v3] kptr_restrict for hiding kernel pointers
Date: Sat, 18 Dec 2010 16:07:59 -0500
Message-ID: <AANLkTimqpKem=rcfk5gsk0bMdWk45EuEThe0wAYiogxc@mail.gmail.com>
References: <1292692835.10804.67.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, mingo@elte.hu, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292692835.10804.67.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 18, 2010 at 12:20 PM, Dan Rosenberg
<drosenberg@vsecurity.com> wrote:

> @@ -1035,6 +1038,26 @@ char *pointer(const char *fmt, char *buf, char=
 *end, void *ptr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return buf + vsnprintf(buf, end - buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ((struct va_format *)ptr)->fmt,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 *(((struct va_format *)ptr)->va));
> + =A0 =A0 =A0 case 'K':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* %pK cannot be used in IRQ context =
because it tests
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* CAP_SYSLOG.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (in_irq() || in_serving_softirq() ||=
 in_nmi())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(1, "%%pK used=
 in interrupt context.\n");
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!kptr_restrict)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; =A0 =A0 =A0 =A0 =
=A0/* %pK does not obscure pointers */
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((kptr_restrict !=3D 2) && capable(C=
AP_SYSLOG))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; =A0 =A0 =A0 =A0 =
=A0/* privileged apps expose pointers,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0unless kptr_restrict is 2 */

I would suggest has_capability_noaudit() since a failure here is not a
security policy violation it is just a code path choice.

I was confused also by the comment about CAP_SYSLOG and IRQ context.
You can check CAP_SYSLOG in IRQ context, it's just that the result is
not going to have any relation to the work being done.  This function
in general doesn't make sense in that context and I don't think saying
that has anything to do with CAP_SYSLOG makes that clear....  Unless
I'm misunderstanding...
