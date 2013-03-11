From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-next v2] SUNRPC:
 rpcrdma_register_default_external: Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 19:48:51 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com>
References: <20130310202838.GL31448@fieldses.org>
	 <1363023447-22453-1-git-send-email-tim.gardner@canonical.com>
	 <20130311181450.GC30618@fieldses.org> <513E27C0.8050108@canonical.com>
	 <20130311191545.GA642@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Tom Tucker" <tom-/Yg/VP3ZvrM@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shani Michaeli <shanim-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130311191545.GA642-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Content-Language: en-US
Content-ID: <5883212D2F34174E8925941C629BF1EC-oP88Kt8RkgzdA/Lu/QRl1Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-11 at 15:15 -0400, J. Bruce Fields wrote:
> On Mon, Mar 11, 2013 at 12:51:44PM -0600, Tim Gardner wrote:
> > On 03/11/2013 12:14 PM, J. Bruce Fields wrote:
> > <snip>
> > >>
> > >> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
> > >> and pass this request down through rpcrdma_register_external() and
> > >> rpcrdma_register_default_external(). This is less overhead then using
> > >> kmalloc() and requires no extra error checking as the allocation burden is
> > >> shifted to the transport client.
> > > 
> > > Oh good--so that works, and the req is the right place to put this?  How
> > > are you testing this?
> > > 
> > > (Just want to make it clear: I'm *not* an expert on the rdma code, so my
> > > suggestion to put this in the rpcrdma_req was a suggestion for something
> > > to look into, not a claim that it's correct.)
> > > 
> > 
> > Just compile tested so far. Incidentally, I've been through the call stack:
> > 
> > call_transmit
> >  xprt_transmit
> >   xprt->ops->send_request(task)
> >    xprt_rdma_send_request
> >     rpcrdma_marshal_req
> >      rpcrdma_create_chunks
> >       rpcrdma_register_external
> >        rpcrdma_register_default_external
> > 
> > It appears that the context for kmalloc() should be fine unless there is
> > a spinlock held around call_transmit() (which seems unlikely).
> 
> Right, though I think it shouldn't be GFP_KERNEL--looks like writes
> could wait on it.

Nothing inside the RPC client should be using anything heavier than
GFP_NOWAIT (unless done at setup).

> In any case, the embedding-in-rpcrdma_req solution does look cleaner if
> that's correct (e.g. if we can be sure there won't be two simultaneous
> users of that array).

Putting it in the rpcrdma_req means that you have one copy per transport
slot. Why not rather put it in the rpcrdma_xprt?
AFAICS you only need this array at transmit time for registering memory
for RDMA, at which time the transport XPRT_LOCK guarantees that nobody
else is competing for these resources.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
