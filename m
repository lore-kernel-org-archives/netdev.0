From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next] net: squash ->rx_handler and
 ->rx_handler_data into single rcu pointer
Date: Sat, 30 Mar 2013 09:23:08 -0700
Message-ID: <1364660588.5113.110.camel@edumazet-glaptop>
References: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	streeter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1364659034-7049-1-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-03-30 at 16:57 +0100, Jiri Pirko wrote:
> No need to have two pointers in struct netdevice for rx_handler func and
> priv data. Just embed rx_handler structure into driver port_priv and
> have ->func pointer there. This introduces no performance penalty,
> reduces struct netdevice by one pointer and reduces number of needed
> rcu_dereference calls from 2 to 1.
> 

Thats not true.

> Note this also fixes the race bug pointed out by Steven Rostedt and
> fixed by patch "[PATCH] net: add a synchronize_net() in
> netdev_rx_handler_unregister()" by Eric Dumazet. This is based on
> current net-next tree where the patch is not applied yet.
> I can rebase it on whatever tree/state, just say so.
> 
> Smoke tested with all drivers who use rx_handler.
> 
> Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
> ---

I see no value for this patch.

It obfuscates things for no good reason.

Once again rcu_dereference(dev->field) has no cost, its a memory read,
like dev->field.

I fear you don't understand enough RCU to make so invasive changes.

Your patch adds a double dereference on fast path, and its more
expensive than two single deref.

dev->rx_handler actually gets the function pointer, and after your patch
we would have to do dev->rx_handler->func instead, which is bad on many
cpus.

I'll send a patch reordering some fields of net_device, because as time
passed, it seems a lot of junk broke work done in commit
cd13539b8bc9ae884 (net: shrinks struct net_device)

offsetof(struct net_device,dev_addr)=0x258
offsetof(struct net_device,rx_handler)=0x2b8
offsetof(struct net_device,ingress_queue)=0x2c8
offsetof(struct net_device,broadcast)=0x278
