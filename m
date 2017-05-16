From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 16 May 2017 10:46:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705160955310.1856@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com> <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com> <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com> <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com> <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg>
 <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com> <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg> <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39458 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750949AbdEPHq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 03:46:57 -0400
In-Reply-To: <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 15 May 2017, Cong Wang wrote:

> On Mon, May 15, 2017 at 1:37 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >         Any user that does not set FIB_LOOKUP_NOREF
> > will need nh_dev refcounts. The assumption is that the
> > NHs are accessed, who knows, may be even after RCU grace
> > period. As result, we can not use dev_put on NETDEV_UNREGISTER.
> > So, we should check if there are users that do not
> > set FIB_LOOKUP_NOREF, at first look, I don't see such ones
> > for IPv4.
> 
> I see, although we do have FIB_LOOKUP_NOREF set all the times,
> there are other places we hold fib_clntref too, for example
> mlxsw_sp_router_fib_event_work(), it actually uses nh_dev too...
> 
> So I am afraid moving dev_put() to fib_release_info() is not a solution
> here. I have to rethink about it.

	At first look, they use fib_info_hold() to get fib_clntref 
reference from places where fib_treeref is not fatally decreased
to 0 but later a work is used which finishes the job. I guess, we
can convert such places to use just a fib_treeref reference.
They can use such new method instead of fib_info_hold:

void fib_treeref_get(struct fib_info *fi)
{
	spin_lock_bh(&fib_info_lock);
	fi->fib_treeref++;
	spin_unlock_bh(&fib_info_lock);
}

They will use fib_release_info() to put the reference. But
on FIB_EVENT_ENTRY_DEL there is a small window where the
scheduled work delays the unlink of fib info from the
hash tables, i.e. there is a risk fib_find_info to reuse
a dead fib info.

	May be we can add a fi->fib_flags & RTNH_F_DEAD
check there but the problem is that it is set also on
NETDEV_DOWN. While attempts to add route to device with
!(dev->flags & IFF_UP) is rejected by fib_check_nh(),
fib_create_info still can create routes when
cfg->fc_scope == RT_SCOPE_HOST. So, RTNH_F_DEAD check
in fib_find_info can avoid the reuse of fib info for
host routes while device is down but not unregistered.
As result, many fib infos can be created instead of one
that is reused. Adding new RTNH_F_* flag to properly handle
this does not look good...

Regards
