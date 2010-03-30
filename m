From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] x86, fs: add sys_compat_write for net/socket.c
Date: Tue, 30 Mar 2010 20:17:57 +0200
Message-ID: <20100330181757.GB14721@Chamillionaire.breakpoint.cc>
References: <1269971469-1254-1-git-send-email-fw@strlen.de>
 <4BB23B35.7060401@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, linux-fsdevel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, x86@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BB23B35.7060401@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H. Peter Anvin <hpa@zytor.com> wrote:
> > On some configurations, e.g. x86_64 with 32bit userspace, netlink/xfrm
> > misinterprets messages from userspace due to different structure
> > layout (u64 has different alignment requirements on x86 vs. x86_64).

[..]

> > As long as messages are sent via sendmsg(), this could be handled via
> > net/compat.c; it will set the CMSG_MSG_COMPAT flag in struct msghdr
> > for compat tasks, which would allow to the xfrm_user code to detect
> > when messages need compat fixups.
> > 
> > Unfortunately, some programs (e.g. pluto ike daemon), send netlink data
> > to the kernel using write().
> > 
> > Thus, introduce f_ops->compat_aio_write and compat_sys_write to treat
> > writes on sockets specially.
> > 
> > This only wires up compat_sys_write for x86/x86_64 -- at the moment this
> > is only required to parse xfrm netlink messages, which happen to only
> > need special treatment in case of COMPAT_FOR_U64_ALIGNMENT=y.
> > 
> > Setting CMSG_MSG_COMPAT depending on plain is_compat_task() in net/socket.c
> > was not done due to concerns regarding the kernel doing socket
> > writes in response to a user event (which might set MSG_COMPAT erronously).
> > 
> 
> OK... I have to ask the question:
> 
> This only applies if you're using unpacked structures with
> non-naturally-aligned objects in them.  Where to we have those, and can
> we shoot the authors?

Fair enough.
This happens e.g. when trying to add xfrm policies or SAs from 32bit x86
userspace on x86_64 kernels, e.g. commands like "ip xfrm pol add dir in"
fail due to user/kernelspace structure size mismatch.

One structure that has this problem is struct xfrm_userpolicy_info, but
there are more.

Now, I realize that adding a write compat syscall is borderline
insanity, and I am open to suggestions.

In fact, I would even accept a "userspace must use sendmsg() when dealing
with xfrm netlink"; the only problem is that my pending xfrm compat patches
depend on this patch being accepted [ or, rather, they depend
on the MSG_COMPAT flag being set; which is currently only done when userspace
uses sendmsg().

In fact, "ip xfrm .. " even works with the xfrm compat patch set applied
because ip xfrm ... happens to use sendmsg(). But not all userspace apps do this ].

Thanks, Florian
