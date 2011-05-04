From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Wed, 4 May 2011 11:28:24 +0900
Message-ID: <201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<1304432663-1575-3-git-send-email-sam@synack.fr>
	<201105031802.34724.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: paul.moore@hp.com, sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201105031802.34724.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> On Tuesday, May 03, 2011 10:24:15 AM Samir Bellabes wrote:
> > snet needs to reintroduce this hook, as it was designed to be: a hook for
> > updating security informations on objects.
> 
> Looking at this and 5/10 again, it seems that you should be able to do what 
> you need with the sock_graft() hook.  Am I missing something?
> 
> My apologies if we've already discussed this approach previously ...

static void snet_socket_post_accept(struct socket *sock, struct socket *newsock)
{
	static void snet_do_send_event(struct snet_info *info)
	{
		int snet_nl_send_event(struct snet_info *info)
		{
			skb_rsp = genlmsg_new(size, GFP_KERNEL);
			genlmsg_unicast()
		}
	}
}

First problem with using snet_do_send_event() from security_sock_graft() is
that we have to use GFP_ATOMIC rather than GFP_KERNEL because we are inside
write_lock_bh()/write_unlock_bh().

static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32 pid)
{
	static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32 pid)
	{
		int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
			u32 pid, MSG_DONTWAIT)
		{
			int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
				      long *timeo, struct sock *ssk)
			{
				if (!*timeo) {
					return -EAGAIN;
			}
		}
	}
}

Second problem is that genlmsg_unicast() might return -EAGAIN because we can't
sleep inside write_lock_bh()/write_unlock_bh().

Third problem (though independent with security_sock_graft()) is that
snet_do_send_event() ignores snet_nl_send_event() failure.
