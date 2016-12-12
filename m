From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Mon, 12 Dec 2016 05:02:15 -0500
Message-ID: <20161212100215.GA1305@madcap2.tricolour.ca>
References: <20161129164859.GD26673@madcap2.tricolour.ca>
 <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca>
 <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca>
 <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-12-09 20:13, Cong Wang wrote:
> On Fri, Dec 9, 2016 at 3:01 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > On 2016-12-08 22:57, Cong Wang wrote:
> >> On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> >> > I also tried to extend Cong Wang's idea to attempt to proactively respond to a
> >> > NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
> >> > stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
> >> > Eliminating the lock since the sock is dead anways eliminates the error.
> >> >
> >> > Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
> >> > get the test case to compile.
> >>
> >> It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
> >> are updated as a whole and race between audit_receive_msg() and
> >> NETLINK_URELEASE.
> >
> > This is what I expected and why I originally added the mutex lock in the
> > callback...  The dumps I got were bare with no wrapper identifying the
> > process context or specific error, so I'm at a bit of a loss how to
> > solve this (without thinking more about it) other than instinctively
> > removing the mutex.
> 
> Netlink notifier can safely be converted to blocking one, I will send
> a patch.

I had a quick look at how that might happen.  The netlink notifier chain
is atomic.  Would the registered callback funciton need to spawn a
one-time thread to avoid blocking?

> But I seriously doubt you really need NETLINK_URELEASE here,
> it adds nothing but overhead, b/c the netlink notifier is called on
> every netlink socket in the system, but for net exit path, that is
> relatively a slow path.

I was a bit concerned about its overhead, but was hoping to update
audit_sock more quickly in the case of a sock shutting down for any
reason.

> Also, kauditd_send_skb() needs audit_cmd_mutex too.

Agreed.

> I will send a formal patch.

I had a look at your patch.  It looks attractively simple.  The audit
next tree has patches queued that add an audit_reset function that will
require more work.  I still see some potential gaps.

- If the process messes up (or the sock lookup messes up) it is reset
  in the kauditd thread under the audit_cmd_mutex.

- If the process exits normally or is replaced due to an audit_replace
  error, it is reset from audit_receive_skb under the audit_cmd_mutex.

- If the process dies before the kauditd thread notices, either reap it
  via notifier callback or it needs a check on net exit to reset.  This
  last one appears necessary to decrement the sock refcount so the sock
  can be released in netlink_kernel_release().

If we want to be proactive and use the netlink notifier, we assume the
overhead of adding to the netlink notifier chain and eliminate all the
other reset calls under the kauditd thread.  If we are ok being
reactionary, then we'll at least need the net exit check on audit_sock.

Have I understood this correctly?

I'll follow with a patch based on audit#next

There will be an upstream merge conflict between audit#next and net#next
due to the removal of:
	RCU_INIT_POINTER(aunet->nlsk, NULL);                                                        
	synchronize_net();
from the end of audit_net_exit().  This patch should probably go through
the audit maintainer due to the other anticipated merge conflicts.

> Thanks.

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
