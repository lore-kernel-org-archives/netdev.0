From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] NET: Normalize jiffies reported to userspace, in
 neighbor management code
Date: Mon, 10 Nov 2003 23:02:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110230233.254061da.davem@redhat.com>
References: <20031110.104536.79654717.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031110.104536.79654717.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Nov 2003 10:45:36 -0600 (CST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> more jiffies normalizations reported to userspace, in core/neighbour.c.
 ...
> +extern int proc_dointvec_userhz_jiffies(ctl_table *, int, struct file *,
> +					void __user *, size_t *);

This function is huge and it reuses a lot of existing logic.

Cannot you implement it simply like this:

int proc_dointvec_userhz_jiffies(ctl_table *, int, struct file *,
					void __user *, size_t *)
{
	return do_proc_dointvec(table,write,filp,buffer,lenp,HZ/USER_HZ,OP_SET);
}

Right?

Linus, what we need here is a function that converts to/from
USER_HZ and HZ jiffies for a few sysctl knobs in core/neighbour.c

Yoshfuji copied all of the logic of routines such as do_proc_dointvec()
replacing the "conv" conversion multiplies and divides with calls to
jiffies_to_clock_t() and friends.  While this is the cleanest implementation
it sure wastes a lot of code for such a minor difference in behavior.

Won't my above idea work?

Another idea is to change do_proc_dointvec() to take a conversion function
pointer instead of this "conv" thing.  Maybe even proc_dointvec_minmax()
could be implemented in terms of do_proc_dointvec() with such a scheme.
