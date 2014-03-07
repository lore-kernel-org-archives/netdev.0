From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Fri, 07 Mar 2014 16:58:06 +0100
Message-ID: <5319EC8E.2010606@redhat.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>	<5318ABC0.4040307@citrix.com>
 <CALnjE+rWc=n_F+1jSLQtPrgKSvvxONEkkYxWEHon2_KVNG9z3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CALnjE+rWc=n_F+1jSLQtPrgKSvvxONEkkYxWEHon2_KVNG9z3Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 03/07/2014 05:46 AM, Pravin Shelar wrote:
> But I found bug in datapath user-space queue code. I am not sure how
> this can work with skb fragments and MMAP-netlink socket.
> Here is what happens, OVS allocates netlink skb and adds fragments to
> skb using skb_zero_copy(), then calls genlmsg_unicast().
> But if netlink sock is mmped then netlink-send queues netlink
> allocated skb->head (linear data of skb) and ignore skb frags.
>
> Currently this is not problem with OVS vswitchd since it does not use
> netlink MMAP sockets. But if vswitchd stats using MMAP-netlink socket,
> it can break it.

The secret is out ;-)

I was very surprised too when I noticed that it worked. It's not just
OVS, it's nfqueue as well. The reason is that an netlink mmaped skb is
setup with a giant tailroom in netlink_ring_setup_skb():

	skb->end	= skb->tail + size;

and skb_zerocopy() will consume whatever tailroom is available first:

	/* dont bother with small payloads */
	if (len <= skb_tailroom(to)) {
		skb_copy_bits(from, 0, skb_put(to, len), len);
		return;
	}

I was planning to fix this while adding GSO support to the upcall as
that is the moment when this bug would really surface.
