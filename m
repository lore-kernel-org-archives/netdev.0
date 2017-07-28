From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 3/3] tap: XDP support
Date: Thu, 27 Jul 2017 20:51:40 -0700
Message-ID: <20170727205140.2b3ca38a@cakuba.netronome.com>
References: <1501147533-12368-1-git-send-email-jasowang@redhat.com>
        <1501147533-12368-4-git-send-email-jasowang@redhat.com>
        <20170727201338.65d56b2a@cakuba.netronome.com>
        <7d1cb7bf-43c1-3993-be00-04e4676dd917@redhat.com>
        <20170728064603-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170728064603-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Jul 2017 06:46:40 +0300, Michael S. Tsirkin wrote:
> On Fri, Jul 28, 2017 at 11:28:54AM +0800, Jason Wang wrote:
> > > > +	old_prog = rtnl_dereference(tun->xdp_prog);
> > > > +	if (old_prog)
> > > > +		bpf_prog_put(old_prog);
> > > > +	rcu_assign_pointer(tun->xdp_prog, prog);  
> > > Is this OK?  Could this lead to the program getting freed and then
> > > datapath accessing a stale pointer?  I mean in the scenario where the
> > > process gets pre-empted between the bpf_prog_put() and
> > > rcu_assign_pointer()?  
> > 
> > Will call bpf_prog_put() after rcu_assign_pointer().  
> 
> I suspect you need to sync RCU or something before that.

I think the bpf_prog_put() will use call_rcu() to do the actual free:

static void __bpf_prog_put(struct bpf_prog *prog, bool do_idr_lock)
{
	if (atomic_dec_and_test(&prog->aux->refcnt)) {
		trace_bpf_prog_put_rcu(prog);
		/* bpf_prog_free_id() must be called first */
		bpf_prog_free_id(prog, do_idr_lock);
		bpf_prog_kallsyms_del(prog);
		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
	}
}

It's just that we are only under the rtnl here, RCU lock is not held, so
grace period may elapse between bpf_prog_put() and rcu_assign_pointer().
