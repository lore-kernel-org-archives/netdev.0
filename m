From: Michal Hocko <mhocko@kernel.org>
Subject: Re: scheduling while atomic from vmci_transport_recv_stream_cb in
 3.16 kernels
Date: Wed, 13 Sep 2017 17:19:39 +0200
Message-ID: <20170913151939.gf7n6rvvjtz47tz7@dhcp22.suse.cz>
References: <20170912090852.qshtrioffwexkslw@dhcp22.suse.cz>
 <B8A42FAB-9E16-4943-98F3-86FC8F195069@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aditya Sarwade <asarwade@vmware.com>,
        Thomas Hellstrom <thellstrom@vmware.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Masik Petr <Petr.Masik@nudz.cz>,
        Ben Hutchings <ben@decadent.org.uk>,
        Sasha Levin <alexander.levin@verizon.com>,
        Stable tree <stable@vger.kernel.org>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B8A42FAB-9E16-4943-98F3-86FC8F195069@vmware.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 13-09-17 15:07:26, Jorgen S. Hansen wrote:
> 
> > On Sep 12, 2017, at 11:08 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > Hi,
> > we are seeing the following splat with Debian 3.16 stable kernel
> > 
> > BUG: scheduling while atomic: MATLAB/26771/0x00000100
> > Modules linked in: veeamsnap(O) hmac cbc cts nfsv4 dns_resolver rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache sunrpc vmw_vso$
> > CPU: 0 PID: 26771 Comm: MATLAB Tainted: G           O  3.16.0-4-amd64 #1 Debian 3.16.7-ckt20-1+deb8u3
> > Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 09/21/2015
> > ffff88315c1e4c20 ffffffff8150db3f ffff88193f803dc8 ffffffff8150acdf
> > ffffffff815103a2 0000000000012f00 ffff8819423dbfd8 0000000000012f00
> > ffff88315c1e4c20 ffff88193f803dc8 ffff88193f803d50 ffff88193f803dc0
> > Call Trace:
> > <IRQ>  [<ffffffff8150db3f>] ? dump_stack+0x41/0x51
> > [<ffffffff8150acdf>] ? __schedule_bug+0x48/0x55
> > [<ffffffff815103a2>] ? __schedule+0x5d2/0x700
> > [<ffffffff8150f9b9>] ? schedule_timeout+0x229/0x2a0
> > [<ffffffff8109ba70>] ? select_task_rq_fair+0x390/0x700
> > [<ffffffff8109f780>] ? check_preempt_wakeup+0x120/0x1d0
> > [<ffffffff81510eb8>] ? wait_for_completion+0xa8/0x120
> > [<ffffffff81096de0>] ? wake_up_state+0x10/0x10
> > [<ffffffff810c3da0>] ? call_rcu_bh+0x20/0x20
> > [<ffffffff810c180b>] ? wait_rcu_gp+0x4b/0x60
> > [<ffffffff810c17b0>] ? ftrace_raw_output_rcu_utilization+0x40/0x40
> > [<ffffffffa02ca6f5>] ? vmci_event_unsubscribe+0x75/0xb0 [vmw_vmci]
> > [<ffffffffa031f5cd>] ? vmci_transport_destruct+0x1d/0xe0 [vmw_vsock_vmci_transport]
> > [<ffffffffa03167e3>] ? vsock_sk_destruct+0x13/0x60 [vsock]
> > [<ffffffff81409f7a>] ? __sk_free+0x1a/0x130
> > [<ffffffffa0320218>] ? vmci_transport_recv_stream_cb+0x1e8/0x2d0 [vmw_vsock_vmci_transport]
> > [<ffffffffa02c9cba>] ? vmci_datagram_invoke_guest_handler+0xaa/0xd0 [vmw_vmci]
> > [<ffffffffa02cab51>] ? vmci_dispatch_dgs+0xc1/0x200 [vmw_vmci]
> > [<ffffffff8106c294>] ? tasklet_action+0xf4/0x100
> > [<ffffffff8106c681>] ? __do_softirq+0xf1/0x290
> > [<ffffffff8106ca55>] ? irq_exit+0x95/0xa0
> > [<ffffffff81516b22>] ? do_IRQ+0x52/0xe0
> > [<ffffffff8151496d>] ? common_interrupt+0x6d/0x6d
> > 
> > AFAICS this has been fixed by 4ef7ea9195ea ("VSOCK: sock_put wasn't safe
> > to call in interrupt context") but this patch hasn't been backported to
> > stable trees. It applies cleanly on top of 3.16 stable tree but I am not
> > familiar with the code to send the backport to the stable maintainer
> > directly.
> > 
> > Could you double check that the patch below (just a blind cherry-pick)
> > is correct and it doesn't need additional patches on top?
> 
> Hi,
> 
> The patch below has been used to fix the above issue by other distros
> - among them Redhat for the 3.10 kernel, so it should work for 3.16 as
> well.

Thanks for the confirmation. I do not see 4ef7ea9195ea ("VSOCK: sock_put
wasn't safe to call in interrupt context") in 3.10 stable branch
though.

> In addition to the patch above, there are two other patches that
> need to be applied on top for the fix to be correct:
> 
> 8566b86ab9f0f45bc6f7dd422b21de9d0cf5415a "VSOCK: Fix lockdep issue."
> 
> and
> 
> 8ab18d71de8b07d2c4d6f984b718418c09ea45c5 "VSOCK: Detach QP check should filter out non matching QPs."

Good to know. I will send all three patches cherry-picked on top of the
current 3.16 stable branch. Could you have a look please?
-- 
Michal Hocko
SUSE Labs
