From: Jakub Kicinski via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Fri, 8 Jul 2016 18:51:07 +0100
Message-ID: <20160708185107.10c0dbe4@jkicinski-Precision-T1700>
References: <20160707124245.6d95635a@redhat.com>
	<D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
	<20160708022210.GA12244@ast-mbp.thefacebook.com>
	<20160708144453.345b51e5@jkicinski-Precision-T1700>
	<20160708171943.0e1ce8d7@redhat.com>
	<20160708170751.2eaae790@jkicinski-Precision-T1700>
	<577FD8A5.8020700@gmail.com>
Reply-To: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <577FD8A5.8020700-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Fri, 8 Jul 2016 09:45:25 -0700, John Fastabend wrote:
> The only distinction between VFs and queue groupings on my side is VFs
> provide RSS where as queue groupings have to be selected explicitly.
> In a programmable NIC world the distinction might be lost if a "RSS"
> program can be loaded into the NIC to select queues but for existing
> hardware the distinction is there.

To do BPF RSS we need a way to select the queue which I think is all
Jasper wanted.  So we will have to tackle the queue selection at some
point.  The main obstacle with it for me is to define what queue
selection means when program is not offloaded to HW...  Implementing
queue selection on HW side is trivial.

> If you demux using a eBPF program or via a filter model like
> flow_director or cls_{u32|flower} I think we can support both. And this
> just depends on the programmability of the hardware. Note flow_director
> and cls_{u32|flower} steering to VFs is already in place.

Yes, for steering to VFs we could potentially reuse a lot of existing
infrastructure.

> The question I have is should the "filter" part of the eBPF program
> be a separate program from the XDP program and loaded using specific
> semantics (e.g. "load_hardware_demux" ndo op) at the risk of building
> a ever growing set of "ndo" ops. If you are running multiple XDP
> programs on the same NIC hardware then I think this actually makes
> sense otherwise how would the hardware and even software find the
> "demux" logic. In this model there is a "demux" program that selects
> a queue/VF and a program that runs on the netdev queues.

I don't think we should enforce the separation here.  What we may want
to do before forwarding to the VF can be much more complicated than
pure demux/filtering (simple eg - pop VLAN/tunnel).  VF representative
model works well here as fallback - if program could not be offloaded
it will be run on the host and "trombone" packets via VFR into the VF.

If we have a chain of BPF programs we can order them in increasing
level of complexity/features required and then HW could transparently
offload the first parts - the easier ones - leaving more complex
processing on the host.

This should probably be paired with some sort of "skip-sw" flag to let
user space enforce the HW offload on the fast path part.
