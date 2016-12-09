From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Thu, 8 Dec 2016 22:57:18 -0800
Message-ID: <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-audit@redhat.com, Paul Moore <pmoore@redhat.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209060248.GT22655@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> I also tried to extend Cong Wang's idea to attempt to proactively respond to a
> NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
> stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
> Eliminating the lock since the sock is dead anways eliminates the error.
>
> Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
> get the test case to compile.

It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
are updated as a whole and race between audit_receive_msg() and
NETLINK_URELEASE.


> @@ -1167,10 +1190,14 @@ static void __net_exit audit_net_exit(struct net *net)
>  {
>         struct audit_net *aunet = net_generic(net, audit_net_id);
>         struct sock *sock = aunet->nlsk;
> +
> +       mutex_lock(&audit_cmd_mutex);
>         if (sock == audit_sock) {
>                 audit_pid = 0;
> +               audit_nlk_portid = 0;
>                 audit_sock = NULL;
>         }
> +       mutex_unlock(&audit_cmd_mutex);
>

If you decide to use NETLINK_URELEASE notifier, the above piece is no
longer needed, the net_exit path simply releases a refcnt.
