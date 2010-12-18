From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Fri, 17 Dec 2010 16:53:19 -0800
Message-ID: <20101217165319.98670d66.akpm@linux-foundation.org>
References: <1292025924.2965.20.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, eugeneteo@kernel.org, kees.cook@canonical.com,
	mingo@elte.hu, davem@davemloft.net
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1292025924.2965.20.camel@Dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2010 19:05:24 -0500
Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> +	case 'K':
> +		if (kptr_restrict) {
> +			if (in_irq() || in_serving_softirq() || in_nmi())
> +				WARN(1, "%%pK used in interrupt context.\n");
> +
> +			else if (capable(CAP_SYSLOG))
> +				break;
> +
> +			if (spec.field_width == -1) {
> +				spec.field_width = 2 * sizeof(void *);
> +				spec.flags |= ZEROPAD;
> +			}
> +			return number(buf, end, 0, spec);
> +		}
> +		break;

Also, we should emit the runtime warning even if kptr_restrict is
false.  Otherwise programmers might ship buggy code because they didn't
enable kptr_restrict during testing.

So what I ended up with was

	case 'K':
		/*
		 * %pK cannot be used in IRQ context because it tests
		 * CAP_SYSLOG.
		 */
		if (in_irq() || in_serving_softirq() || in_nmi())
			WARN_ONCE(1, "%%pK used in interrupt context.\n");

		if (!kptr_restrict)
			break;		/* %pK does not obscure pointers */

		if (capable(CAP_SYSLOG))
			break;		/* privileged apps expose pointers */

		if (spec.field_width == -1) {
			spec.field_width = 2 * sizeof(void *);
			spec.flags |= ZEROPAD;
		}
		return number(buf, end, 0, spec);

How does that look?


Also...  permitting root to bypass the %pK obscuring seems pretty lame,
really.  I bet a *lot* of the existing %p sites are already root-only
(eg, driver initialisation).  So much of the value is lost.
