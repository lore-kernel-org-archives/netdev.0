From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP user interface confusions
Date: Wed, 21 Sep 2016 09:18:58 +0200
Message-ID: <20160921091858.4e44f5e5@redhat.com>
References: <20160915201402.15b65136@redhat.com>
	<20160915185835.GA4418@gmail.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Brenden Blanco <bblanco-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160915185835.GA4418-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Sep 2016 11:58:35 -0700
Brenden Blanco <bblanco-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> On Thu, Sep 15, 2016 at 08:14:02PM +0200, Jesper Dangaard Brouer wrote:
> > Hi Brenden,
> > 
> > I don't quite understand the semantics of the XDP userspace interface.
> > 
> > We allow XDP programs to be (unconditionally) exchanged by another
> > program, this avoids taking the link down+up and avoids reallocating
> > RX ring resources (which is great).
> > 
> > We have two XDP samples programs in samples/bpf/ xdp1 and xdp2.  Now I
> > want to first load xdp1 and then to avoid the linkdown I load xdp2,
> > and then afterwards remove/stop program xdp1.
> > 
> > This does NOT work, because (in samples/bpf/xdp1_user.c) when xdp1
> > exits it unconditionally removes the running XDP program (loaded by xdp2)
> > via set_link_xdp_fd(ifindex, -1).  The xdp2 user program is still
> > running, and is unaware of its xdp/bpf program have been unloaded.
> > 
> > I find this userspace interface confusing. What this your intention?
> > Perhaps you can explain what the intended semantics or specification is?  
> 
> In practice, we've used a single agent process to manage bpf programs on
> behalf of the user applications. This agent process uses common linux
> functionalities to add semantics, while not really relying on the bpf
> handles themselves to take care of that. For instance, the process may
> put some lockfiles and what-not in /var/run/$PID, and maybe returns the
> list of running programs through a http: or unix: interface.
> 
> So, from a user<->kernel API, the requirements are minimal...the agent
> process just overwrites the loaded bpf program when the application
> changes, or a new application comes online. There is nobody to 'notify'
> when a handle changes.
> 
> When translating this into the kernel api that you see now, none of this
> exists, because IMHO the kernel api should be unopinionated and generic.
> The result is something that appears very "fire-and-forget", which
> results in something simple yet safe at the same time; the refcounting
> is done transparently by the kernel.
> 
> So, in practice, there is no xdp1 or xdp2, just xdp-agent at different
> points in time. Or, better yet, no agent, just the programs running in
> the kernel, with the handles of the programs residing solely in the
> device, which are perhaps pinned to /sys/fs/bpf for semantic management
> purposes. I didn't feel like it was appropriate to conflate different
> bpf features in the kernel samples, so we don't see (and probably never
> will) a sample which combines these features into a whole. That is best
> left to userspace tools. It so happens that this is one of the projects
> I am currently active on at $DAYJOB, and we fully intend to share the
> details of that when it's in a suitable state.

For the record, I'm not happy with this response.

IHMO the XDP userspace API should have been thought more through. Where
is the specification and documentation for this interface?

There is no official XDP userspace daemon, thus your proposed file-lock
scheme falls apart.  We can easily imagine, several different
open-source projects using XDP, they will not coordinate what /var/run
lock-file to use.  An admin installs several of these to evaluate
them.  Later he gets really confused, because both of them run by
mistake (and it is random who "wins" due to systemd parallel boot).

The programs themselves have no-way to catch this error situation, and
report it.  This is the main mistake of this API approach.  The admin
also have a hard time debugging this, as our query interface is a bool,
so he just see that some XDP program _is_ running.

Sorry, but we have to do better than this.  We have to maintain these
APIs for the next +10 years.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
