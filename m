From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Thu, 7 Jul 2016 21:28:37 -0700
Message-ID: <20160708042835.GA15575@ast-mbp.thefacebook.com>
References: <20160707124245.6d95635a@redhat.com>
	<D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
	<20160708022210.GA12244@ast-mbp.thefacebook.com>
	<577F2689.4010602@gmail.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	"Fastabend, John R" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Ari Saha <as754m-60p5jsuXm+c@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <577F2689.4010602-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

On Thu, Jul 07, 2016 at 09:05:29PM -0700, John Fastabend wrote:
> On 16-07-07 07:22 PM, Alexei Starovoitov wrote:
> > On Thu, Jul 07, 2016 at 03:18:11PM +0000, Fastabend, John R wrote:
> >> Hi Jesper,
> >>
> >> I have done some previous work on proprietary systems where we
> >> used hardware to do the classification/parsing then passed a cookie to the
> >> software which used the cookie to lookup a program to run on the packet.
> >> When your programs are structured as a bunch of parsing followed by some
> >> actions this can provide real performance benefits. Also a lot of
> >> existing hardware supports this today assuming you use headers the
> >> hardware "knows" about. It's a natural model for hardware that uses a
> >> parser followed by tcam/cam/sram/etc lookup tables.
> 
> > looking at bpf programs written in plumgrid, facebook and cisco
> > with full certainty I can assure that parse/action split doesn't exist.
> > Parsing is always interleaved with lookups and actions.
> > cpu spends a tiny fraction of time doing parsing. Lookups are the heaviest.
> 
> What is heavy about a lookup? Is it the key generation? The key
> generation can be provided by the hardware is what I was really alluding
> to. If your data structures are ebpf maps though its probably a hash
> or array table and the benefit of leveraging hardware would likely be
> much better if/when there are software structures for LPM or wildcard
> lookups.

there is only hash map in the sw and the main cost of it was doing jhash
math and occasional miss in hashtable.
'key generation' is only copying bytes, so it mostly free.
Just like parsing which is few branches which tend to be predicted
by cpu quite well.
In case of our L4 loadbalancer we need to do consistent hash which
fixed hw probably won't be able to provide.
Unless hw is programmable :)
In general when we developed and benchmarked the programs,
redesigning the program to remove extra hash lookup gave performance
improvement whereas simplifying parsing logic (like removing vlan
handling or ip option) showed no difference in performance.

> > Trying to split single logical program into parsing/after_parse stages
> > has no pracitcal benefit.
> > 
> >> If the goal is to just separate XDP traffic from non-XDP traffic
> >> you could accomplish this with a combination of SR-IOV/macvlan to separate
> >> the device queues into multiple netdevs and then run XDP on just one of
> >> the netdevs. Then use flow director (ethtool) or 'tc cls_u32/flower' to
> >> steer traffic to the netdev. This is how we support multiple networking
> >> stacks on one device by the way it is called the bifurcated driver. Its
> >> not too far of a stretch to think we could offload some simple XDP
> >> programs to program the splitting of traffic instead of
> >> cls_u32/flower/flow_director and then you would have a stack of XDP
> >> programs. One running in hardware and a set running on the queues in
> >> software.
> > 
> > the above sounds like much better approach then Jesper/mine prog_per_ring stuff.
> > If we can split the nic via sriov and have dedicated netdev via VF just for XDP that's way cleaner approach.
> > I guess we won't need to do xdp_rxqmask after all.
> > 
> 
> Right and this works today so all it would require is adding the XDP
> engine code to the VF drivers. Which should be relatively straight
> forward if you have the PF driver working.

Good point. I think the next step should be to enable xdp in VF drivers
and measure performance.
