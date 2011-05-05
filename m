From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Thu, 5 May 2011 10:11:32 -0400
Message-ID: <201105051011.32845.paul.moore@hp.com>
References: <1304432663-1575-1-git-send-email-sam@synack.fr> <201105031802.34724.paul.moore@hp.com> <201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sam@synack.fr, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 03, 2011 10:28:24 PM Tetsuo Handa wrote:
> Paul Moore wrote:
> > On Tuesday, May 03, 2011 10:24:15 AM Samir Bellabes wrote:
> > > snet needs to reintroduce this hook, as it was designed to be: a hook
> > > for updating security informations on objects.
> > 
> > Looking at this and 5/10 again, it seems that you should be able to do
> > what you need with the sock_graft() hook.  Am I missing something?
> > 
> > My apologies if we've already discussed this approach previously ...
> 
> static void snet_socket_post_accept(struct socket *sock, struct socket
> *newsock) {
> 	static void snet_do_send_event(struct snet_info *info)
> 	{
> 		int snet_nl_send_event(struct snet_info *info)
> 		{
> 			skb_rsp = genlmsg_new(size, GFP_KERNEL);
> 			genlmsg_unicast()
> 		}
> 	}
> }
> 
> First problem with using snet_do_send_event() from security_sock_graft() is
> that we have to use GFP_ATOMIC rather than GFP_KERNEL because we are inside
> write_lock_bh()/write_unlock_bh().

I guess I don't see that as being a blocker ...

> static inline int genlmsg_unicast(struct net *net, struct sk_buff *skb, u32
> pid) {
> 	static inline int nlmsg_unicast(struct sock *sk, struct sk_buff *skb, u32
> pid) {
> 		int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
> 			u32 pid, MSG_DONTWAIT)
> 		{
> 			int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
> 				      long *timeo, struct sock *ssk)
> 			{
> 				if (!*timeo) {
> 					return -EAGAIN;
> 			}
> 		}
> 	}
> }
> 
> Second problem is that genlmsg_unicast() might return -EAGAIN because we
> can't sleep inside write_lock_bh()/write_unlock_bh().

Ah yes, the real problem.  I forgot that snet relied on a user space tool.  I 
tend to agree with others who have suggested this is not the right approach, 
but I understand why you want the post_accept() hook; thanks for reminding me.

--
paul moore
linux @ hp
