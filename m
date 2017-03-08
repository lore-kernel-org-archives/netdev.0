From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: netlink: GPF in netlink_unicast
Date: Wed, 8 Mar 2017 08:51:02 -0500
Message-ID: <20170308135102.GH10258@madcap2.tricolour.ca>
References: <CACT4Y+bmJpMCcbKZqdp_jvhS=K3O2rBPrPD-b1F_WqRLS9Y=0A@mail.gmail.com>
 <CAM_iQpW90SdHKEpXeQ7u6RFKo5ABXAiKZVzxsZWRbK=Qw86BQQ@mail.gmail.com>
 <20170307040317.GU18258@madcap2.tricolour.ca>
 <CAHC9VhTf5ndE961JMM2fUSUozf+BvF78jE4FFpuwwSn0=rnH7g@mail.gmail.com>
 <20170307155531.GA10258@madcap2.tricolour.ca>
 <CAHC9VhQ2Kp1YQ7eTOjjaX2UsucZEkr+OBNNuEQjzM32Be1nRgg@mail.gmail.com>
 <CAHC9VhSP_Ut08ixbkEiQPN4c3vCahBdVWpsyFZY+PYCPfMuzXw@mail.gmail.com>
 <20170308132544.GG10258@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>, linux-audit@redhat.com,
        David Miller <davem@davemloft.net>,
        Dmitry Vyukov <dvyukov@google.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170308132544.GG10258@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-03-08 08:25, Richard Guy Briggs wrote:
> On 2017-03-07 14:23, Paul Moore wrote:
> > On Tue, Mar 7, 2017 at 1:44 PM, Paul Moore <paul@paul-moore.com> wrote:
> > > On Tue, Mar 7, 2017 at 10:55 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > >> On 2017-03-07 09:29, Paul Moore wrote:
> > >>> On Mon, Mar 6, 2017 at 11:03 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > >>> > On 2017-03-06 10:10, Cong Wang wrote:
> > >>> >> On Mon, Mar 6, 2017 at 2:54 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > >>> >> > Hello,
> > >>> >> >
> > >>> >> > I've got the following crash while running syzkaller fuzzer on
> > >>> >> > net-next/8d70eeb84ab277377c017af6a21d0a337025dede:
> > >>> >> >
> > >>> >> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > >>> >> > general protection fault: 0000 [#1] SMP KASAN
> > >>> >> > Dumping ftrace buffer:
> > >>> >> >    (ftrace buffer empty)
> > >>> >> > Modules linked in:
> > >>> >> > CPU: 0 PID: 883 Comm: kauditd Not tainted 4.10.0+ #6
> > >>> >> > Hardware name: Google Google Compute Engine/Google Compute Engine,
> > >>> >> > BIOS Google 01/01/2011
> > >>> >> > task: ffff8801d79f0240 task.stack: ffff8801d7a20000
> > >>> >> > RIP: 0010:sock_sndtimeo include/net/sock.h:2162 [inline]
> > >>> >> > RIP: 0010:netlink_unicast+0xdd/0x730 net/netlink/af_netlink.c:1249
> > >>> >> > RSP: 0018:ffff8801d7a27c38 EFLAGS: 00010206
> > >>> >> > RAX: 0000000000000056 RBX: ffff8801d7a27cd0 RCX: 0000000000000000
> > >>> >> > RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000000002b0
> > >>> >> > RBP: ffff8801d7a27cf8 R08: ffffed00385cf286 R09: ffffed00385cf286
> > >>> >> > R10: 0000000000000006 R11: ffffed00385cf285 R12: 0000000000000000
> > >>> >> > R13: dffffc0000000000 R14: ffff8801c2fc3c80 R15: 00000000014000c0
> > >>> >> > FS:  0000000000000000(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
> > >>> >> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > >>> >> > CR2: 0000000020cfd000 CR3: 00000001c758f000 CR4: 00000000001406f0
> > >>> >> > Call Trace:
> > >>> >> >  kauditd_send_unicast_skb+0x3c/0x70 kernel/audit.c:482
> > >>> >> >  kauditd_thread+0x174/0xb00 kernel/audit.c:599
> > >>> >> >  kthread+0x326/0x3f0 kernel/kthread.c:229
> > >>> >> >  ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
> > >>> >> > Code: 44 89 fe e8 56 15 ff ff 8b 8d 70 ff ff ff 49 89 c6 31 c0 85 c9
> > >>> >> > 75 27 e8 b2 b2 f4 fd 49 8d bc 24 b0 02 00 00 48 89 f8 48 c1 e8 03 <42>
> > >>> >> > 80 3c 28 00 0f 85 37 06 00 00 49 8b 84 24 b0 02 00 00 4c 8d
> > >>> >> > RIP: sock_sndtimeo include/net/sock.h:2162 [inline] RSP: ffff8801d7a27c38
> > >>> >> > RIP: netlink_unicast+0xdd/0x730 net/netlink/af_netlink.c:1249 RSP:
> > >>> >> > ffff8801d7a27c38
> > >>> >> > ---[ end trace ad1bba9d457430b6 ]---
> > >>> >> > Kernel panic - not syncing: Fatal exception
> > >>> >> >
> > >>> >> >
> > >>> >> > This is not reproducible and seems to be caused by an elusive race.
> > >>> >> > However, looking at the code I don't see any proper protection of
> > >>> >> > audit_sock (other than the if (!audit_pid) which is obviously not
> > >>> >> > enough to protect against races).
> > >>> >>
> > >>> >> audit_cmd_mutex is supposed to protect it, I think.
> > >>> >> But kauditd_send_unicast_skb() seems not holding this mutex.
> > >>> >
> > >>> > Hmmmm, I wonder if it makes sense to wrap most of the contents of the
> > >>> > outer while loop in kauditd_thread in the audit_cmd_mutex, or around the
> > >>> > first two innter while loops and the "if (auditd)" condition after the
> > >>> > "quick_loop:" label.  The condition on auditd is supposed to catch that
> > >>> > case.  We don't want it locked while playing with the scheduler at the
> > >>> > bottom of that function.
> > >>>
> > >>> Let me look into this and play around with a few things.  I suspected
> > >>> there might be a problem here, so I've got thoughts on how we might
> > >>> resolve it; I just need to see code them up and see what option sucks
> > >>> the least.
> > >>>
> > >>> FWIW Richard, yes wrapping most of kauditd_thread *should* resolve
> > >>> this but it's pretty heavy handed and not my first choice.
> > >>
> > >> That's why the inner loops made a bit more sense since it wasn't really
> > >> necessary and ran afoul of the scheduler anyways.
> > >
> > > One of my preferred options was to get us away from protecting
> > > everything with the audit_cmd_mutex by creating a new locking approach
> > > for the auditd connection state (using RCU/spinlocks since it rarely
> > > changes in practice) and leaving the audit_cmd_mutex for it's
> > > traditional role.  This should minimize the performance impact of the
> > > lock and clean things up a bit.  I'm also moving all the auditd
> > > connection state into a single struct (instead of several variables
> > > associated only by convention) which moves us oh so slightly closer to
> > > allowing multiple auditd connections (hey, it's something).
> > >
> > > It's taking a bit longer than expected as I'm dealing with a bit of a
> > > head cold (or something) and my mind is far less than 100% at the
> > > moment ...
> > 
> > Ooof.  I just noticed something, and maybe this is the fever talking,
> > but why do we ever NULL out audit_sock and why are we bothering with
> > those holds/puts?  We create the audit netlink socket in
> > audit_net_init() and it should remain valid until we kill it in
> > audit_next_exit(); we sorta cheat on this now because we track the
> > socket both in the per-netns audit_net struct as well as audit_sock,
> > but that doesn't make our audit_sock manipulations right ...
> 
> At the moment, you are right, there is no reason to null audit_sock, and
> not like auditd will appear on a different sock yet.

Ok, I pushed send too fast and didn't think this through enough.
Currently, the audit daemon *could* re-appear on a different socket.
While it is still in the same user and pid namespace, it could be
started from a different network namespace and it will set audit_sock to
the socket from that network namespace.

> The only excuse I can give is that this was anticipating audit daemons
> in more than one user namespace necessarily with their own network
> namespaces.  The AUDIT_GET, AUDIT_LIST_RULES commands are treated
> properly since they use the per-netns audit_net struct and don't use the
> primary queue.  The AUDIT_USER_* messages are converted from their
> originating namespaces ok, but will need to be tracked what network
> namespace they came from for multiple audit daemons in the future.
> 
> > Man I hate this code.  I *really* hate this code.
> > 
> > paul moore
> 
> - RGB
> 
> --
> Richard Guy Briggs <rgb@redhat.com>
> Kernel Security Engineering, Base Operating Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
