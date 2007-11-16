From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re : Bug in using inet_lookup ()
Date: Fri, 16 Nov 2007 13:08:32 +0300
Message-ID: <20071116100832.GA31765@2ka.mipt.ru>
References: <409407.88982.qm@web26101.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59233 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764110AbXKPKIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 05:08:35 -0500
Content-Disposition: inline
In-Reply-To: <409407.88982.qm@web26101.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 16, 2007 at 09:47:08AM +0000, Nj A (nj_a83@yahoo.fr) wrote:
> Hello,
> > Please show at least one bug trace when inet_lookup(&tcp_hashinfo, 0, 0, 0, 0,
> > 0) fails :)
> Trying this the system hangs :-( (setting panic* doesn't change more).

Your code below can not work - you _never_ call inet_lookup().
In your bug inet_lookup() is called, so this wither code is wrong, or
bug is hand written.

And you use inet_iif() which requires dst entry (routing cache), which
you do not setup either.

You can do following to resolve where problem occurs:
$ gdb vmlix
> p inet_lookup
> l *(returned_above_address + 0x300)

it will show you the line where bug occurs.
You have to compile your kernel with debugging symbols.

To prove that inet_lookup() works correctly patch tcv_v4_rcv() to print
lookup result for static source/destination addresses/ports copied from
you message and zero ifindex (the last field).

I'm pretty sure your code, which was not shown yet, has a bug in the
inet_lookup() calling routing.

> However, using (&tcp_hashinfo, ip_src, p_src, ip_dst, p_dst, 0) gives the following oops:

Wrong, you do _NOT_ use this in your code.

> BUG: unable to handle kernel NULL pointer dereference at virtual address 0000xxxx
> printing eip:
> c02f19e1
> *pde = 00000000
> Oops: 0000 [#1]
> CPU:    0
> EIP:    0060:[<c02f19e1>]    Not tainted VLI
> EFLAGS: 00010282   (2.6.18 #1)
> EIP is at inet_lookup+0x300x500
> eax: 9e3779b9   ebx: 00000004   ecx: 9e377a57   edx: f4046f84
> esi: f46a6010   edi: 00000000   ebp: 0000009e   esp: f4046f38
> ds: 007b   es: 007b   ss: 0068
> Process knl-thread (pid: 3068, ti=f4046000 task=f46f0610 task.ti=f4046000)
> Stack: 22921900 f6953840 f46a6010 f46a6000 f4046f84 00000004 f46a6010 f46a6000
> f6953840 f8d3314a 00000004 b7f3a000 00000404 00000005 00000bfe 00000000
> 00000bfe 00000404 00000000 f4046fa8 f6953840 f4aa7880 f4aa7800 f4046fa8
> Code: 00 00 00 8d bc 27 00 00 00 00 55 89 cd 57 0f b7 c9 56 81 e9 47 86 c8 61 53 83 ec 14 89 54 24 10 8b b8 54 02 00 00 b8 b9 79 37 9e <8b> 5f 10 29 d8 89 da 03 44 24 28 c1 ea 0d 29 c8 29 d9 31 d0 89
> EIP: [<c02f19e1>] inet_lookup +0x300x500 SS:ESP 0068:f4046f38
> 
> > Yes, to show the code you are using.
> Ok so basically I am receiving via Netlink a state telling me the ip_src, psrc, ip_dst, pdst.

> sk =
>      inet_lookup (&tcp_hashinfo, payload->src, payload->p_src, payload->dst, payload->p_dst, inet_iif (s_skb));

WRONG!

You did not setup s_skb->dst, so inet_iif() will fail.
Use 0 there, as you were told already several times.
This will not catch device binding though.

> if (!sk)
>      goto no_tcp_socket;
>  if (sk->sk_state == TCP_TIME_WAIT)
>      goto time_wait_socket;
>  ...
>       bh_lock_sock (sk);
>  pdev:
>       spin_lock (&tmp_lock);
>       new_dev = list_entry (&tmp, struct net_device, todo_list);
>       spin_unlock (&tmp_lock);
>       if (!new_dev)
>             goto err;
>       s_skb->dev = new_dev;
> ...
>  switch (sk->sk_state)
>  {
>   case TCP_SYN_RECV:
>    ..
>   case TCP_LISTEN:
>   ..
>   case TCP_SYN_SENT:
>   ..
>  }
>    bh_unlock_sock (sk);
> ...
> /* send reply via Netlink */

This code _NEVER_ calls inet_lookup(), since the first ckeck for
s_skb->dev will fail and you will select device via your list and then
never return to inet_lookup().

Anyway, until your code is presented fully so that people could show you
exactly wrong line it is pretty impossible to try to convince you that
inet_llokup() does work and you have a bug in setup.

-- 
	Evgeniy Polyakov
