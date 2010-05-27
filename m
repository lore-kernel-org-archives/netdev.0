From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: boot crash in arp_error_report() (Re: [GIT] Networking)
Date: Thu, 27 May 2010 12:27:56 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005271213091.3689@i5.linux-foundation.org>
References: <20100525.165945.39198480.davem@davemloft.net> <20100527190652.GA20303@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100527190652.GA20303@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 27 May 2010, Ingo Molnar wrote:
> 
> FYI, this boot crash in arp_error_report() started triggering in -tip testing:
> 
> [  113.285384] BUG: unable to handle kernel paging request at 6b6b6b87

That's the POISON_FREE signature, with an offset of 28 (0x1c).

And it looks like the whole function got captured in the Code: sequence. 
It looks like this:

   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	0f 1f 44 00 00       	nopl   0x0(%eax,%eax,1)
   9:	89 d3                	mov    %edx,%ebx
   b:	89 d0                	mov    %edx,%eax
   d:	e8 fa fb ff ff       	call   0xfffffc0c		# skb_dst()
  12:	85 c0                	test   %eax,%eax		# dst
  14:	74 12                	je     0x28
  16:	8b 40 40             	mov    0x40(%eax),%eax		# dst->ops
  19:	85 c0                	test   %eax,%eax
  1b:	74 0b                	je     0x28
  1d:*	8b 50 1c             	mov    0x1c(%eax),%edx     <-- trapping instruction
  20:	85 d2                	test   %edx,%edx
  22:	74 04                	je     0x28
  24:	89 d8                	mov    %ebx,%eax
  26:	ff d2                	call   *%edx			# dst->ops->link_failure()
  28:	89 d8                	mov    %ebx,%eax
  2a:	e8 9b 50 fa ff       	call   0xfffa50ca		# skb_free()
  2f:	5b                   	pop    %ebx
  30:	5d                   	pop    %ebp
  31:	c3                   	ret    

Where most of it is "dst_link_failure()" being inlined (that last "callq" 
is the call to kfree_skb().

Looks like 'dst' points to free'd memory, so when we load a pointer from 
it (the dst->ops) field, we get 0x6b6b6b6b, and then when we try to load
dst->ops->link_failure it oopses.

tl;dr: that

	struct dst_entry *dst = skb_dst(skb);

in dst_link_failure seems to result in a stale skb.

		Linus
