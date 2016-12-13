From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Tue, 13 Dec 2016 02:51:17 -0500
Message-ID: <20161213075117.GH22660@madcap2.tricolour.ca>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
 <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca>
 <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca>
 <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
 <CAM_iQpVcHGywXn90EpiSz-LsUDgKVqs-7BY-L7UBCu2VxkC31Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>, linux-audit@redhat.com,
        syzkaller <syzkaller@googlegroups.com>,
        David Miller <davem@davemloft.net>,
        Dmitry Vyukov <dvyukov@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56482 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751041AbcLMHvV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 02:51:21 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpVcHGywXn90EpiSz-LsUDgKVqs-7BY-L7UBCu2VxkC31Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-09 23:40, Cong Wang wrote:
> On Fri, Dec 9, 2016 at 8:13 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > On Fri, Dec 9, 2016 at 3:01 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> >> On 2016-12-08 22:57, Cong Wang wrote:
> >>> On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> >>> > I also tried to extend Cong Wang's idea to attempt to proactively respond to a
> >>> > NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
> >>> > stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
> >>> > Eliminating the lock since the sock is dead anways eliminates the error.
> >>> >
> >>> > Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
> >>> > get the test case to compile.
> >>>
> >>> It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
> >>> are updated as a whole and race between audit_receive_msg() and
> >>> NETLINK_URELEASE.
> >>
> >> This is what I expected and why I originally added the mutex lock in the
> >> callback...  The dumps I got were bare with no wrapper identifying the
> >> process context or specific error, so I'm at a bit of a loss how to
> >> solve this (without thinking more about it) other than instinctively
> >> removing the mutex.
> >
> > Netlink notifier can safely be converted to blocking one, I will send
> > a patch.
> >
> > But I seriously doubt you really need NETLINK_URELEASE here,
> > it adds nothing but overhead, b/c the netlink notifier is called on
> > every netlink socket in the system, but for net exit path, that is
> > relatively a slow path.
> >
> > Also, kauditd_send_skb() needs audit_cmd_mutex too.
> 
> Please let me know what you think about the attached patch?
> 
> Thanks!

> commit a12b43ee814625933ff155c20dc863c59cfcf240
> Author: Cong Wang <xiyou.wangcong@gmail.com>
> Date:   Fri Dec 9 17:56:42 2016 -0800
> 
>     audit: close a race condition on audit_sock
>     
>     Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> diff --git a/kernel/audit.c b/kernel/audit.c
> index f1ca116..ab947d8 100644
> --- a/kernel/audit.c
> +++ b/kernel/audit.c
> @@ -423,6 +423,8 @@ static void kauditd_send_skb(struct sk_buff *skb)
>  				snprintf(s, sizeof(s), "audit_pid=%d reset", audit_pid);
>  				audit_log_lost(s);
>  				audit_pid = 0;
> +				audit_nlk_portid = 0;
> +				sock_put(audit_sock);
>  				audit_sock = NULL;
>  			} else {
>  				pr_warn("re-scheduling(#%d) write to audit_pid=%d\n",
> @@ -899,6 +901,9 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  				audit_log_config_change("audit_pid", new_pid, audit_pid, 1);
>  			audit_pid = new_pid;
>  			audit_nlk_portid = NETLINK_CB(skb).portid;
> +			sock_hold(skb->sk);
> +			if (audit_sock)
> +				sock_put(audit_sock);
>  			audit_sock = skb->sk;
>  		}
>  		if (s.mask & AUDIT_STATUS_RATE_LIMIT) {
> @@ -1167,10 +1172,6 @@ static void __net_exit audit_net_exit(struct net *net)
>  {
>  	struct audit_net *aunet = net_generic(net, audit_net_id);
>  	struct sock *sock = aunet->nlsk;
> -	if (sock == audit_sock) {
> -		audit_pid = 0;
> -		audit_sock = NULL;
> -	}

So how does this not leak memory leaving the sock refcount incremented
by the registered audit daemon when that daemon shuts down normally?


- RGB
